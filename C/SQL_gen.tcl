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
# Retourne le nombre de clefs primaires d'une table
##
proc Katyusha_GenerationSQL_nombre_pk_table {table} {
    #set 
}

##
# Construit le script SQL d'un attribut
##
proc Katyusha_GenerationSQL_attribut {id attribut sgbd si_pk} {
    set SQL ""
    set nom_attribut [dict get $attribut "nom"]
    set type_attribut [string toupper [dict get $attribut "type"]]
    set ctype_attribut [dict get $attribut "complement_type"]
    set taille_attribut [dict get $attribut "taille"]
    set pk_attribut [dict get $attribut "pk"]
    set null_attribut [dict get $attribut "null"]
    set auto_attribut [dict get $attribut "auto"]
    set valeur_attribut [dict get $attribut "valeur"]
    set signe [dict get $attribut "signe"]
    set unique [dict get $attribut "unique"]
    
    set sql_nom $nom_attribut
    
    # Si l'attribut est en incrémentation automatique, le type est modifié selon le SGBD
    if {$auto_attribut == 1} {
        set sql_auto " [lindex [Katyusha_SQL_auto_increment $sgbd] 0]"
        set null_attribut 0
    } else {
        set sql_auto ""
    }
    
    set sql_type " [string toupper $type_attribut]"
    
    if {$ctype_attribut != ""} {
        set sql_ctype "($ctype_attribut)"
    } else {
        set sql_ctype ""
    }
    set sql_taille [Katyusha_GenerationSQL_sql_taille_attribut $attribut]
    
    # Détermine si un attribut est nul
    if {$valeur_attribut != "null" && $pk_attribut == 0 || $null_attribut == 0 && $pk_attribut == 0} {
        set sql_null " NOT NULL"
    } else {
        set sql_null ""
    }
    
    if {$si_pk == 1 && $pk_attribut == 1} {
        set sql_pk " PRIMARY KEY"
    } else {
        set sql_pk ""
    }
    
    if {$unique == 1} {
        set sql_unique " UNIQUE"
    } else {
        set sql_unique ""
    }
    
    if {$signe == 1} {
        set sql_signe " UNSIGNED"
    } else {
        set sql_signe ""
    }
    
    # Valeur par défaut de l'attribut
    if {$auto_attribut == 0 && $valeur_attribut != "" && $valeur_attribut != "null"} {
        set sql_valeur " DEFAULT [Katyusha_GenerationSQL_format_cotes $valeur_attribut]"
    } else {
        set sql_valeur ""
    }
    set SQL "$sql_nom$sql_type$sql_taille$sql_ctype$sql_null$sql_signe$sql_unique$sql_pk$sql_valeur$sql_auto"
    return $SQL
}

##
# Construit le script SQL des tables
##
proc Katyusha_GenerationSQL_tables_sql {tables sgbd} {
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
            }
        }
        
        foreach {k attribut} $attributs_table {
            if {[dict get $attribut "pk"] == 1} {
                set null_attribut 0
            }
            # Si une seule clefs primaire, on ajoute l'élément à l'attribut
            if {[llength $pks] == 1} {
                set si_pk 1
            } else {
                set si_pk 0
            }
            set attribut_sql "    [Katyusha_GenerationSQL_attribut $k $attribut $sgbd $si_pk]"
            if {$attributs_sql != ""} {
                set attributs_sql "$attributs_sql, \n$attribut_sql"
            } else {
                set attributs_sql "$attributs_sql$attribut_sql"
            }
        }
        # Balayage des clefs primaires de la table si il y en a plus d'une
        if {[llength $pks] > 1} {
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
# Construit le code SQL des clefs étrangères de toute la base
##
proc Katyusha_GenerationSQL_fks_sql {fks sgbd} {
    set SQL ""
    foreach fk $fks {
        set SQL "$SQL[Katyusha_SQL_ajout_fk [dict get $fk table_lien] [dict get $fk table_liee] [dict get $fk nom] [dict get $fk nom_origine] $sgbd]\n"
    }
    return $SQL
}

proc Katyusha_GenerationSQL_mld_vers_sql {mld fks sgbd} {
    set SQL "[Katyusha_GenerationSQL_tables_sql $mld $sgbd]"
    set SQL "$SQL\n\n\n[Katyusha_GenerationSQL_fks_sql $fks $sgbd]"
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
    
    set mld_fks [Katyusha_MLD_mcd_vers_mld $tables $relations $heritages]
    set MLD [lindex $mld_fks 0]
    set FKS [lindex $mld_fks 1]
    set SQL "$SQL\n[Katyusha_GenerationSQL_mld_vers_sql $MLD $FKS $sgbd]"
    
    # Défini le chemin d'enregistrement du fichier SQL
    if {$id_projet == -1} {
        set id_projet [llength [glob -nocomplain -dir $rep_mcd "projet*"]]
    }
    if {$MCD(rep) == $CONFIGS(REP_PROJETS_DEFAUT) || $MCD(rep) == ""} {
        set MCD(rep) [tk_chooseDirectory -initialdir $CONFIGS(REP_PROJETS_DEFAUT)]
    }
    if {$MCD(rep) != ""} {
        set fichier "$MCD(rep)/$MCD(nom)\-$sgbd.sql"
        # Enregistre dans le fichier
        Katyusha_C_fichier_enrigistrer $fichier $SQL "w+"
        
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
