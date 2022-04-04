## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################



##
# Détermine si une table est table fille d'un héritage
##
proc Katyusha_MLD_table_fille_ {id_table table} {
    global heritages
    
    set res 0
    foreach {k heritage} $heritages {
        set filles [dict get $heritage "filles"]
        foreach {k fille} $filles {
            if {$fille == $id_table} {
                set res 1
            }
        }
    }
    
    return $res
}

##
# Détermine si une table est table mère d'un héritage
##
proc Katyusha_MLD_table_mere_ {id_table table} {
    global heritages
    
    set res 0
    set id_heritage -1
    foreach {k heritage} $heritages {
        set mere [dict get $heritage "mere"]
        if {$mere == $id_table} {
            set res 1
            set id_heritage $k
        }
    }
    
    return [list $id_heritage $res]
}

##
# Si une nouvelle table doit être créé, récupère les clefs primaires des tables liés pour en faire des colones de la table créée
##
proc Katyusha_MLD_attributs_n_table {liens sgbd} {
    set SQL ""
    set attributs [dict create]
    foreach {k lien} $liens {
        set table_lien [lindex $lien 0]
        set n_lien [lindex $lien 1]
        if {$n_lien == "0.n" || $n_lien == "0.1" || $n_lien == "1.n" || $n_lien == "n.n"} {
            # Liste des clefs primaires de la table
            set liste_pk_table [Katyusha_MLD_pks_table $table_lien $n_lien 1]
            # Balayage des clefs primaires
            foreach {kk attribut} $liste_pk_table {
                dict set attributs [expr [Dict_dernier_id $attributs] + 1] $attribut
            }
        }
    }
    return $attributs
}

##
# Détermine si une nouvelle table doit être créer
#       1 pour une nouvelle table
#       0 sinon
##
proc Katyusha_MLD_liens_n_table {liens} {
    set n_table 1
    
    if {[dict size $liens] == 2} {
        foreach {k lien} $liens {
            set table_lien [lindex $lien 0]
            set n_lien [lindex $lien 1]
            if {$n_table == 1} {
                if {$n_lien == "1.1"} {
                    set n_table 0
                } else {
                }
            }
        }
    }
    
    return $n_table
}

##
# Transforme certaines relations en tables
##
proc Katyusha_MLD_relations_en_tables {relations tables sgbd} {
    foreach {k relation} $relations {
        set liens [dict get $relation "liens"]
        set nom [dict get $relation "nom"]
        set attributs [dict get $relation "attributs"]
        # Nouvelle table?
        set n_table [Katyusha_MLD_liens_n_table $liens]
        
        if {$n_table == 1} {
            # Créé les attributs de la nouvelle table
            dict set table_tmp "nom" $nom
            dict set table_tmp "description" ""
            set attributs_gen [Katyusha_MLD_attributs_n_table $liens $sgbd]
            # Regroupe les attributs de départ et les attributs générés
            set c [expr [lindex [dict keys $attributs_gen] [expr [llength [dict keys $attributs_gen]] - 1]] + 1]
            foreach {k v} $attributs {
                dict set attributs_gen $c $v
                set c [expr $c + 1]
            }
            dict set table_tmp "attributs" $attributs_gen
            dict set table_tmp "vraie" 0
            dict set tables [expr [Katyusha_Tables_dernier_id $tables] + 1] $table_tmp
        }
    }
    return $tables
}

##
# 
##
proc Katyusha_MLD_applique_changements_tables {relations tables {sgbd "aucun"}} {
    foreach {k relation} $relations {
        set liens [dict get $relation "liens"]
        set nom [dict get $relation "nom"]
        set attributs [dict get $relation "attributs"]
        # Nouvelle table?
        set n_table [Katyusha_MLD_liens_n_table $liens]
        
        if {$n_table == 0} {
            set lien1 [dict get $liens 0]
            set lien2 [dict get $liens 1]
            if {[Katyusha_MLD_liens_egaux $liens] == 1} {
                set table_lien [lindex $lien1 0]
                set table_liee [lindex $lien2 0]
            } else {
                set type_lien1 [lindex $lien1 1]
                if {$type_lien1 == "1.1"} {
                    set table_lien [lindex $lien1 0]
                    set table_liee [lindex $lien2 0]
                } else {
                    set table_lien [lindex $lien2 0]
                    set table_liee [lindex $lien1 0]
                }
            }
            set id_table_liee [Katyusha_Tables_ID_table $table_liee]
            set id_table_lien [Katyusha_Tables_ID_table $table_lien]
            
            set pk_table_liee [Katyusha_MLD_pks_table $table_liee [lindex $lien2 1] [lindex $lien2 2]]
            set c [expr [lindex [dict keys $attributs] [expr [llength [dict keys $attributs]] - 1]] + 1]
            foreach {k v} $pk_table_liee {
                dict set attributs $c $v
                set c [expr $c + 1]
            }
            
            set table_lien [dict get $tables $id_table_lien]
            set attributs_table_lien [dict get $table_lien "attributs"]
            set c [expr [lindex [dict keys $attributs_table_lien] [expr [llength [dict keys $attributs_table_lien]] - 1]] + 1]
            foreach {k v} $attributs {
                dict set attributs_table_lien $c $v
                set c [expr $c + 1]
            }
            dict set table_lien "attributs" $attributs_table_lien
            dict set tables $id_table_lien $table_lien
        }
    }
    return $tables
}

##
#
##
proc Katyusha_MLD_table_mere_ajout_attributs_filles {attributs id_heritage nom_table_mere} {
    global heritages
    global tables
    
    set heritage [dict get $heritages $id_heritage]
    set filles [dict get $heritage "filles"]
    set id_attribut [expr [Katyusha_Attributs_dernier_id $attributs] + 1]
    # Balayage des tables filles
    foreach {k id_fille} $filles {
        set fille [dict get $tables $id_fille]
        set attributs_fille [dict get $fille "attributs"]
        foreach {kk attribut} $attributs_fille {
            set id_attribut [expr $id_attribut + 1]
            dict set attributs $id_attribut [dict create "nom" [dict get $attribut "nom"] "type" [dict get $attribut "type"] "complement_type" [dict get $attribut "complement_type"] "taille" 0 "pk" 0 "null" 1 "auto" 0 "valeur" "null"]

        }
    }
    # Ajout de l'attribut discriminant
    set id_attribut [expr $id_attribut + 1]
    dict set attributs $id_attribut [dict create "nom" "type_$nom_table_mere" "type" "varchar" "complement_type" "" "taille" 0 "pk" 0 "null" 0 "auto" 0 "valeur" $nom_table_mere]

    return $attributs
}

proc Katyusha_MLD_liens_egaux {liens} {
    set res 0
    set lien1 "null"
    
    foreach {k lien} $liens {
        set lien2 [lindex $lien 1]
        if {$lien1 == $lien2} {
            set res 1
        } else {
            set res 0
        }
        set lien1 $lien2
    }
    
    return $res
}

##
#
##
proc Katyusha_MLD_pks_table {nom_table cardinalite est_pk} {
    global tables
    
    set attributs [dict create]
    foreach {k table} $tables {
        set nom_table_liste [dict get $table "nom"]
        # Si le nom correspond
        if {$nom_table_liste == $nom_table} {
            set attributs_table [dict get $table "attributs"]
            # Balayage des attributs à la recherche des clefs primaires
            foreach {k attribut} $attributs_table {
                set pk_attribut [dict get $attribut "pk"]
                # Ajoute le nom de la table (s'il n'est pas déjà inclu) pour une meilleure lisibilité
                # et éviter les doublons
                # Par example :
                #       table.id devient table.id_table
                set nom_attribut [dict get $attribut "nom"]
                dict set attribut "nom_origine" $nom_attribut
                dict set attribut "table_origine" $nom_table
                # Supprime les incrémentations automatiques
                dict set attribut "auto" 0
                dict set attribut "valeur" ""
                dict set attribut "card" $cardinalite
                if {[string first $nom_table $nom_attribut] == -1} {
                    dict set attribut "nom" "$nom_attribut\_$nom_table"
                }
                dict set attribut "pk" $est_pk
                if {$pk_attribut == 1} {
                    dict set attributs [expr [Katyusha_Tables_dernier_id $attributs] + 1] $attribut
                }
            }
        }
    }
    return $attributs
}

proc Katyusha_MLD_table_aspire_attributs_table_liee {lien1 lien2 tables} {
    set id_table [Katyusha_Tables_ID_table [lindex $lien1 0]]
    set table [dict get $tables $id_table]
    set attributs [dict get $table "attributs"]
    set pks [Katyusha_MLD_pks_table [lindex $lien2 0] [lindex $lien2 1] [lindex $lien1 2]]
        foreach {kk pk} $pks {
            dict set attributs [expr [Dict_dernier_id $attributs] + 1] $pk
            # Ajoute les clefs primaires des tables liées à la liste des clefs étrangères
            set fk [dict create "table_lien" [lindex $lien1 0] "table_liee" [lindex $lien2 0] "nom" [dict get $pk "nom"] "nom_origine" [dict get $pk "nom_origine"]]
            lappend fks $fk
        }
    dict set table "attributs" $attributs
    return [list $table $fks]
}

##
# Transforme le MCD en MLD
# Doit pouvoir gérer les héritages en cascade, les héritages multiples
# Renvoie une liste, le premier élément est un dictionnaire contenant toutes les tables du MLD
# le deuxième est un dictionnaire avec toutes les informations pour construire les clefs étrangères
##
proc Katyusha_MLD_mcd_vers_mld {tables relations heritages} {
    set fks [list]
    # Transforme certaines relations en table
    foreach {k relation} $relations {
        set liens [dict get $relation "liens"]
        set nom [dict get $relation "nom"]
        set attributs [dict get $relation "attributs"]
        # Contrôle si une nouvelles table doit être créer
        set n_table [Katyusha_MLD_liens_n_table $liens]
        # Si nouvelle table
        if {$n_table == 1} {
            # Récupère le nom, les attributs
            set table_tmp [dict create]
            dict set table_tmp "nom" $nom
            # Récupère les clefs primaires des tables liées pour en faire des clefs étrangères
            foreach {kk lien} $liens {
                set pks [Katyusha_MLD_pks_table [lindex $lien 0] [lindex $lien 1] 1]
                # Ajoute les clefs primaires aux attributs
                foreach {kkk pk} $pks {
                    dict set attributs [expr [Dict_dernier_id $attributs] + 1] $pk
                    # Ajoute les clefs primaires des tables liées à la liste des clefs étrangères
                    set fk [dict create "pk" 1 "table_lien" $nom "table_liee" [lindex $lien 0] "nom" [dict get $pk "nom"] "nom_origine" [dict get $pk "nom_origine"]]
                    lappend fks $fk
                }
            }
            dict set table_tmp "attributs" $attributs
            dict set tables [expr [Dict_dernier_id $tables] + 1] $table_tmp
        # Si pas de nouvelle table, forcément un des deux seuls liens est 1.1
        } else {
            set lien1 [dict get $liens 0]
            set lien2 [dict get $liens 1]
            if {[lindex $lien1 1] == "1.1"} {
                set id_table [Katyusha_Tables_ID_table [lindex $lien1 0]]
                set table_fks [Katyusha_MLD_table_aspire_attributs_table_liee $lien1 $lien2 $tables]
                set table [lindex $table_fks 0]
                set fks [concat $fks [lindex $table_fks 1]]
                dict set tables $id_table $table
            } elseif {[lindex $lien2 1] == "1.1"} {
                set id_table [Katyusha_Tables_ID_table [lindex $lien2 0]]
                set table_fks [Katyusha_MLD_table_aspire_attributs_table_liee $lien2 $lien1 $tables]
                set table [lindex $table_fks 0]
                set fks [concat $fks [lindex $table_fks 1]]
                dict set tables $id_table $table
            }
        }
    }
    return [list $tables $fks]
}
