## Créé le 5/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


proc Katyusha_GenerationSQL_format_cotes {valeur} {
    if {[string is entier $valeur] == 0 && [string is boolean $valeur] == 0 && [string is double $valeur] == 0 && [string is integer $valeur] == 0} {
        set res "'$valeur'"
    } else {
        set res $valeur
    }
    return $res
}

proc Katyusha_GenerationSQL_sql_taille_attribut {attribut} {
    set type_attribut [string tolower [dict get $attribut "type"]]
    set taille_attribut [dict get $attribut "taille"]
    set sql ""
    if {$type_attribut == "char" || $type_attribut == "varchar"} {
        if {$taille_attribut == 0} {
            set sql "(255)"
        } else {
            set sql "($taille_attribut)"
        }
    }
    return $sql
}

##
# Construit le script SQL d'un attribut
##
proc Katyusha_GenerationSQL_attribut {id attribut sgbd} {
    set SQL ""
    set nom_attribut [dict get $attribut "nom"]
    set type_attribut [string toupper [dict get $attribut "type"]]
    set ctype_attribut [dict get $attribut "complement_type"]
    set taille_attribut [dict get $attribut "taille"]
    set pk_attribut [dict get $attribut "pk"]
    set null_attribut [dict get $attribut "null"]
    set auto_attribut [dict get $attribut "auto"]
    set valeur_attribut [dict get $attribut "valeur"]
    
    set sql_nom $nom_attribut
    
    # Si l'attribut est en incrémentation automatique, le type est modifié selon le SGBD
    if {$auto_attribut == 1} {
        set type_attribut [Katyusha_SQL_auto_increment_type $sgbd]
    }
    set sql_type " [string toupper $type_attribut]"
    
    if {$auto_attribut == 1} {
        set sql_type "$sql_type [lindex [Katyusha_SQL_auto_increment $sgbd] 0]"
        set null_attribut 0
    }
    
    if {$ctype_attribut != ""} {
        set sql_ctype "($ctype_attribut)"
    } else {
        set sql_ctype ""
    }
    set sql_taille [Katyusha_GenerationSQL_sql_taille_attribut $attribut]
    
    # Détermine si un attribut est nul
    if {$valeur_attribut != "null" || $pk_attribut == 1 || $null_attribut == 0} {
        set sql_null " NOT NULL"
    } else {
        set sql_null ""
    }
    
    # Valeur par défaut de l'attribut
    if {$auto_attribut == 0 && $valeur_attribut != "" && $valeur_attribut != "null"} {
        set sql_valeur " DEFAULT [Katyusha_GenerationSQL_format_cotes $valeur_attribut]"
    } else {
        set sql_valeur ""
    }
    set SQL "$sql_nom$sql_type$sql_taille$sql_ctype$sql_null$sql_valeur"
    return $SQL
}

##
# Construit le script SQL des tables
##
proc Katyusha_tables_sql {tables sgbd} {
    set SQL ""
    # Balayage des tables
    foreach {k table} $tables {
        # On ne génère le script sql de la table que si elle n'est pas table fille d'un héritage
        if {[Katyusha_MLD_table_fille_ $k $table] == 0} {
        set nom_table [dict get $table "nom"]
        puts "Génération de la table : $nom_table"
        set attributs_table [dict get $table "attributs"]
        # Si la table en question est table mère d'un héritage, elle aspire les attributs de ses filles
        # Et on lui ajoute un attribut discriminant
        set table_mere [Katyusha_MLD_table_mere_ $k $table]
        if {[lindex $table_mere 1] == 1} {
            set attributs_table [Katyusha_MLD_table_mere_ajout_attributs_filles $attributs_table [lindex $table_mere 0] $nom_table]
        }
        # Si pas de description, ""
        if {[dict exists $table "description"]} {
            set description_table [dict get $table "description"]
        } else {
            set description_table ""
        }
        set attributs_sql ""
        set pks_sql ""
        set pks [list]
        # Balayage des attributs de la table
        foreach {k attribut} $attributs_table {
            if {[dict get $attribut "pk"] == 1} {
                lappend pks [dict get $attribut "nom"]
                set null_attribut 0
            }
            set attribut_sql "    [Katyusha_GenerationSQL_attribut $k $attribut $sgbd]"
            if {$attributs_sql != ""} {
                set attributs_sql "$attributs_sql, \n$attribut_sql"
            } else {
                set attributs_sql "$attributs_sql$attribut_sql"
            }
        }
        # Balayage des clefs primaires de la table
        foreach pk $pks {
            if {$pks_sql == ""} {
                set pks_sql ", \n    PRIMARY KEY($pk"
            } else {
                set pks_sql "$pks_sql, $pk"
            }
        }
        if {$pks_sql != ""} {
            set pks_sql "$pks_sql)"
        }
        # Construit le script de la table
        if {$description_table != "" && $description_table != "\n"} {
            set description_table "\n/*\nTODO\n*/\n"
        }
        set table "/* Table : $nom_table */\n$description_table\nCREATE TABLE $nom_table (\n$attributs_sql$pks_sql\n) ;\n\n\n"
        # Ajoute le script de la table au script général
        set SQL "$SQL$table"
        }
    }
    return $SQL
}

##
# Renvoie une liste contenant la ou les clefs primaire(s) d'une table selon son nom
##
proc Katyusha_pk_table {nom_table sgbd {pk_relatif 0}} {
    global tables
    
    set attributs [list]
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
                # Supprime les incrémentations automatiques
                dict set attribut "auto" 0
                dict set attribut "valeur" ""
                if {[string first $nom_table $nom_attribut] == -1} {
                    dict set attribut "nom" "$nom_attribut\_$nom_table"
                }
                dict set attribut "pk" $pk_relatif
                if {$pk_attribut == 1} {
                    dict set attributs [expr [Katyusha_Tables_dernier_id $tables] + 1] $attribut
                }
            }
        }
    }
    return $attributs
}

##
# Ajoute un drop et create au script SQL
##
proc Katyusha_GenerationSQL_base {sgbd} {
    global CONFIGS
    global MCD
    
    set SQL ""
    
    # Si drop
    if {$MCD(drop) == 1} {
        set SQL "$SQL[Katyusha_SQL_drop_base $MCD(nom) $sgbd]\n\n\n"
    }
    
    return $SQL
}

##
# Créé le code SQL des clefs étrangères à ajouter
##
proc Katyusha_GenerationSQL_FK {tables relations sgbd} {
    set SQL ""
    foreach {k relation} $relations {
        set nom_relation [dict get $relation "nom"]
        # Récupère et analyse les liens de la relation
        set liens [dict get $relation "liens"]
        set n_table [Katyusha_MLD_liens_n_table $liens]
        
        # Si une nouvelle table doit être créée
        if {$n_table == 1} {
            foreach {k lien} $liens {
                set table_lien [lindex $lien 0]
                set n_lien [lindex $lien 1]
                set pk_table_lien [Katyusha_pk_table $table_lien $sgbd 1]
                foreach {k pk} $pk_table_lien {
                    set nom_pk [dict get $pk "nom"]
                    set nom_origine_pk [dict get $pk "nom_origine"]
                    set SQL "$SQL[Katyusha_SQL_ajout_fk $nom_relation $table_lien $nom_pk $nom_origine_pk $sgbd]"
                }
            }
        } else {
            set liens [dict get $relation "liens"]
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
            set pk_table_liee [Katyusha_pk_table $table_liee $sgbd]
            foreach {k pk} $pk_table_liee {
                set nom_pk [dict get $pk "nom"]
                set nom_origine_pk [dict get $pk "nom_origine"]
                set type_pk [dict get $pk "type"]
                if {[lsearch [Katyusha_SQL_liste_types_taille] [string tolower $type_pk]] != -1} {
                    set taille_pk [dict get $pk "taille"]
                } else {
                    set taille_pk "null"
                }
                set SQL "$SQL[Katyusha_SQL_ajout_fk $table_lien $table_liee $nom_pk $nom_origine_pk $sgbd]"
            }
        }
    }
    return $SQL
}

proc Katyusha_GenerationSQL_heritages {tables heritages sgbd} {
    foreach {k table} $tables {
        # On ne génère le script sql de la table que si elle n'est pas table fille d'un héritage
        if {[Katyusha_MLD_table_fille_ $k $table] == 0} {
            set nom_table [dict get $table "nom"]
            puts "Génération de la table : $nom_table"
            set attributs_table [dict get $table "attributs"]
            # Si la table en question est table mère d'un héritage, elle aspire les attributs de ses filles
            # Et on lui ajoute un attribut discriminant
            set table_mere [Katyusha_MLD_table_mere_ $k $table]
            if {[lindex $table_mere 1] == 1} {
                set attributs_table [Katyusha_GenerationSQL_table_mere_ajout_attributs_filles $attributs_table [lindex $table_mere 0] $nom_table]
            }
        }
    }
}

proc Katyusha_GenerationSQL_tables {tables relations heritages sgbd} {
    # Pour reconnaitre les "vraies" tables des fausses
    foreach {k table} $tables {
        dict set table "vraie" 1
        dict set tables $k $table
    }
    # Transforme certaines relations en tables
    set tables [Katyusha_MLD_relations_en_tables $relations $tables $sgbd]
    # Applique les changements dûs aux relations sur les tables
    set tables [Katyusha_MLD_applique_changements_tables $relations $tables $sgbd]
    set SQL "[Katyusha_tables_sql $tables $sgbd]\n[Katyusha_GenerationSQL_FK $tables $relations $sgbd]"
    
    return $SQL
}

##
# Génère le script SQL du MCD
##
proc Katyusha_generation_sql {sgbd} {
    global tables
    global relations
    global heritages
    global id_projet
    global rep_mcd
    global version
    global fk
    global MCD
    global CONFIGS
    
    puts "Génération du script SQL pour $sgbd"
    
    set SQL "/* Script généré automatiquement par Katyusha MCD v$version pour $sgbd */\n\n"
    
    set sql_base [Katyusha_GenerationSQL_base $sgbd]
    set SQL "$SQL$sql_base"
    
    set sql_tables [Katyusha_GenerationSQL_tables $tables $relations $heritages $sgbd]
    set SQL "$SQL$sql_tables"
    
    # Défini le chemin d'enregistrement du fichier SQL
    if {$id_projet == -1} {
        set id_projet [llength [glob -nocomplain -dir $rep_mcd "projet*"]]
    }
    if {$MCD(rep) == $CONFIGS(REP_PROJETS_DEFAUT) || $MCD(rep) == ""} {
        set MCD(rep) [tk_chooseDirectory]
    }
    if {$MCD(rep) != ""} {
        set fichier "$MCD(rep)/$MCD(nom)\-$sgbd.sql"
        # Enregistre dans le fichier
        set stream [open $fichier "w+"]
        puts $stream $SQL
        close $stream
        
        puts "Script SQL généré avec succès : $fichier"
    } else {
        set fichier ""
    }
    return [list $SQL $fichier]
}

##
# Vérifie le MCD avant génération du script SQL
##
proc Katyusha_verification_mcd_sql {sgbd} {
    set verif [Katyusha_verification_mcd]
    set res_sql [list 0 0]
    if {[lindex $verif 0] == 0} {
        # Informe qu'il y a un problème
        set errs [lindex $verif 1]
        set res_info [tk_messageBox -icon warning -type ok -message "Il y a une erreur dans le MCD qui empêche la génération du script SQL pour $sgbd"]
    } else {
        set errs "null"
        set res_sql [Katyusha_generation_sql $sgbd]
    }
    return [list [lindex $res_sql 0] [lindex $res_sql 1] $errs]
}
