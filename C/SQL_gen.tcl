## Créé le 5/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
#
##
proc Katyush_MLD_pks_table {nom_table {pk_relatif 0}} {
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

proc Katyusha_MLD_table_aspire_attributs_table_liee {lien1 lien2 tables} {
    set id_table [Katyusha_Tables_ID_table [lindex $lien1 0]]
    set table [dict get $tables $id_table]
    set attributs [dict get $table "attributs"]
    set pks [Katyush_MLD_pks_table [lindex $lien2 0] [lindex $lien2 2]]
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
                set pks [Katyush_MLD_pks_table [lindex $lien 0] [lindex $lien 2]]
                # Ajoute les clefs primaires aux attributs
                foreach {kkk pk} $pks {
                    dict set attributs [expr [Dict_dernier_id $attributs] + 1] $pk
                    # Ajoute les clefs primaires des tables liées à la liste des clefs étrangères
                    set fk [dict create "table_lien" [lindex $lien 0] "table_liee" $nom "nom" [dict get $pk "nom"] "nom_origine" [dict get $pk "nom_origine"]]
                    lappend fks $fk
                }
            }
            dict set table_tmp "attributs" $attributs
            dict set tables [expr [Dict_dernier_id $tables] + 1] $table_tmp
        # Si pas de nouvelle table
        } else {
            set lien1 [dict get $liens 0]
            set lien2 [dict get $liens 1]
            #set lien1 [lindex $table1 1]
            #set lien2 [lindex $table2 1]
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
puts $fks
    return [list $tables $fks]
}

proc Katyusha_GenerationSQL_tables {tables relations heritages sgbd} {
    # Pour reconnaitre les "vraies" tables des fausses
    foreach {k table} $tables {
        dict set table "vraie" 1
        dict set tables $k $table
    }
    # Transforme certaines relations en tables
    set tables [Katyusha_MLD_relations_en_tables $relations $tables]
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
    
    #set sql_base [Katyusha_GenerationSQL_base $sgbd]
    #set SQL "$SQL$sql_base"
    
    set MLD [Katyusha_MLD_mcd_vers_mld $tables $relations $heritages]
    set SQL "$SQL$MLD"
    
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