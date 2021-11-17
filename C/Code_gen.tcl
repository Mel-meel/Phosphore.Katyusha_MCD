## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_GenerationCode_main_procedural {tables relations heritages langage type_langage prefix fichier_unique {sgbd "aucun"}} {
    global MCD
    global CONFIGS
    
    # Pour reconnaitre les "vraies" tables des fausses
    foreach {k table} $tables {
        dict set table "vraie" 1
        dict set tables $k $table
    }
    # Transforme certaines relations en tables
    set tables [Katyusha_MLD_relations_en_tables $relations $tables $sgbd]
    # Applique les changements dûs aux relations sur les tables
    set tables [Katyusha_MLD_applique_changements_tables $relations $tables $sgbd]
    set codes [Katyusha_GenerationCode_tables $tables $langage $type_langage $prefix "null" "null"]
    
    
    if {$MCD(rep) == $CONFIGS(REP_PROJETS_DEFAUT) || $MCD(rep) == ""} {
        set MCD(rep) [tk_chooseDirectory -initialdir $CONFIGS(REP_PROJETS_DEFAUT)]
    }
    
    if {$MCD(rep) != ""} {
        file mkdir "$MCD(rep)/$MCD(nom)\_$langage"
        # Si toutes les classes dans un seul fichier
        if {$fichier_unique == 1} {
            # Langage PHP
            if {$langage == "php"} {
                set code "<?php\n"
                foreach {nom code_table} $codes {
                    set code "$code\n$code_table"
                }
                set code "$code\n?>"
                set fichier "$MCD(rep)/$MCD(nom)\_$langage\/Base.php"
            }
            # Enregistre toutes les fonctions dans le fichier
            Katyusha_C_fichier_enrigistrer $fichier $code "w+"
            set message "Fonctions [string toupper $langage] enregistrées dans le fichier : $MCD(rep)/$MCD(nom)\_$langage\/Base.php"
        # Sinon, un fichier par classe
        } else {
            # Langage PHP
            if {$langage == "php"} {
                set code ""
                foreach {nom code_table} $codes {
                    set fichier "$MCD(rep)/$MCD(nom)\_$langage\/$nom.php"
                    set code "<?php\n$code_table\n?>"
                    # Enregistre toutes les fonctions dans le fichier
                    Katyusha_C_fichier_enrigistrer $fichier $code "w+"
                }
            }
            set message "Fichiers [string toupper $langage] enregistrés dans le répertoire : $MCD(rep)/$MCD(nom)\_$langage"
        }
        set res_info [tk_messageBox -icon info -type ok -message $message]
    }
}

##
# Uniquement pour du PHP procédural
##
proc Katyusha_GenerationCode_tables {tables langage type_langage prefix} {
    set code [list]
    # Balayage des tables
    foreach {k table} $tables {
        # On ne génère le script sql de la table que si elle n'est pas table fille d'un héritage
        if {[Katyusha_MLD_table_fille_ $k $table] == 0} {
            set nom_table [dict get $table "nom"]
            puts "Génération du code $langage de la table : $nom_table"
            set attributs_table [dict get $table "attributs"]
            # Si la table en question est table mère d'un héritage, elle aspire les attributs de ses filles
            # Et on lui ajoute un attribut discriminant
            set table_mere [Katyusha_MLD_table_mere_ $k $table]
            if {[lindex $table_mere 1] == 1} {
                set attributs_table [Katyusha_MLD_table_mere_ajout_attributs_filles $attributs_table [lindex $table_mere 0] $nom_table]
            }
            dict set code $nom_table [Katyusha_GenerationCode_table [Katyusha_GenerationCode_attributs $nom_table $attributs_table $langage $type_langage $prefix] $langage $type_langage]
        }
    }
    return $code
}

##
# Génère pour chaque table le code correspondant au langage, au type de langage et à l'ORM choisi
# 11/11/2021 : Pour le moment ne fonctionne que pour PHP procédural avec PDO et pour l'ORM PHP Doctrine
##
proc Katyusha_GenerationCode_tables {tables langage type_langage prefix orm ns} {
    set code [dict create]
    # Balayage des tables
    foreach {k table} $tables {
        # On ne génère le script sql de la table que si elle n'est pas table fille d'un héritage
        if {[Katyusha_MLD_table_fille_ $k $table] == 0} {
            set nom_table [dict get $table "nom"]
            puts "Génération du code $langage de la table : $nom_table"
            set attributs_table [dict get $table "attributs"]
            # Si la table en question est table mère d'un héritage, elle aspire les attributs de ses filles
            # Et on lui ajoute un attribut discriminant
            set table_mere [Katyusha_MLD_table_mere_ $k $table]
            if {[lindex $table_mere 1] == 1} {
                set attributs_table [Katyusha_MLD_table_mere_ajout_attributs_filles $attributs_table [lindex $table_mere 0] $nom_table]
            }
            dict set code $nom_table [Katyusha_GenerationCode_table [Katyusha_GenerationCode_attributs $nom_table $attributs_table $langage $type_langage $prefix $orm $ns] $langage $type_langage]
        }
    }
    return $code
}

proc Katyusha_GenerationCode_attributs {nom_table attributs langage type_langage prefix orm ns} {
    
    set fonctions [Katyusha_GenerationCode_$type_langage $nom_table $attributs $langage $prefix]
    return $fonctions
}

proc Katyusha_GenerationCode_table {code_attributs langage type_langage} {
    return $code_attributs
}

# Pour le moment, que pour PHP mode procédural
proc Katyusha_GenerationCode_procedural {nom_table attributs langage prefix} {
    set fonctions [dict create]
    
    ##
    # Fonction de requête select
    ##
    set code "function $prefix$nom_table\_select(\$connex) \{\n"
    set sql ""
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        if {$sql == ""} {
            set sql "select $nom_attribut"
        } else {
            set sql "$sql, $nom_attribut"
        }
    }
    set sql "$sql from $nom_table"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;\n    \$req->execute() ;\n    \$c = 0 ;\n    while (\$row = \$req->fetch(PDO::FETCH_ASSOC)) \{\n        \$res\[\$c\] = \$row ;\n        \$c = \$c+1 ;\n    \}\n    \$req->closeCursor() ;\n    return \$res ;\n\}\n\n"
    
    
    ##
    # Fonction de requête select PK
    ##
    set code "$code\nfunction $prefix$nom_table\_select_PK(\$connex, \$$nom_table) \{\n"
    set sql ""
    set where ""
    set bind ""
    set c 1
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        if {$sql == ""} {
            set sql "select $nom_attribut"
        } else {
            set sql "$sql, $nom_attribut"
        }
        # Construit la clause where
        if {[dict get $attribut "pk"] == 1} {
            if {$bind == ""} {
                set where "where $nom_attribut = ?"
            } else {
                set where "$where and $nom_attribut = ?"
            }
            set bind "$bind    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;\n"
            set c [expr $c + 1]
        }
    }
    # Assemble la requête
    set sql "$sql from $nom_table $where"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;\n$bind    \$req->execute() ;\n    \$res = \$req->fetch(PDO::FETCH_ASSOC) ;\n    \$req->closeCursor() ;\n    return \$res ;\n\}\n\n"
    
    
    ##
    # Fonction d'insertion des données
    ##
    set code "$code\nfunction $prefix$nom_table\_insert(\$connex, \$$nom_table) \{\n"
    set sql ""
    set sql_var ""
    set bind ""
    set c 1
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        if {$sql == ""} {
            set sql "$nom_attribut"
            set sql_var "?"
        } else {
            set sql "$sql, $nom_attribut"
            set sql_var "$sql_var, ?"
        }
        set bind "$bind    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;\n"
        set c [expr $c + 1]
    }
    set sql "insert into $nom_table ($sql) values ($sql_var)"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;\n$bind    \$req->execute() ;\n    \$req->closeCursor() ;\n\}\n\n"
    
    
    ##
    # Fonction de requête update PK
    ##
    set code "$code\nfunction $prefix$nom_table\_update_PK(\$connex, \$$nom_table) \{\n"
    set sql ""
    set where ""
    set bind ""
    set bbind ""
    set c 1
    set cc 1
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        if {[dict get $attribut "pk"] == 0} {
            if {$bind == ""} {
                set sql "set $nom_attribut = ?"
            } else {
                set sql "$sql, set $nom_attribut = ?"
            }
            set bind "$bind    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;\n"
            set c [expr $c + 1]
        }
    }
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        if {[dict get $attribut "pk"] == 1} {
            if {$bbind == ""} {
                set where "$nom_attribut = ?"
            } else {
                set where "$where and $nom_attribut = ?"
            }
            set bbind "$bbind    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;\n"
            set c [expr $c + 1]
        }
    }
    # Assemble la requête
    set sql "update $nom_table $sql where $where"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;\n$bind$bbind    \$req->execute() ;\n    \$res = \$req->fetch(PDO::FETCH_ASSOC) ;\n    \$req->closeCursor() ;\n    return \$res ;\n\}\n\n"
    
    
    ##
    # Fonction de requête delete PK
    ##
    set code "$code\nfunction $prefix$nom_table\_delete_PK(\$connex, \$$nom_table) \{\n"
    set sql ""
    set where ""
    set bind ""
    set c 1
    foreach {k attribut} $attributs {
        set nom_attribut [dict get $attribut "nom"]
        # Construit la clause where
        if {[dict get $attribut "pk"] == 1} {
            if {$bind == ""} {
                set where "where $nom_attribut = ?"
            } else {
                set where "$where and $nom_attribut = ?"
            }
            set bind "$bind    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;\n"
            set c [expr $c + 1]
        }
    }
    # Assemble la requête
    set sql "delete from $nom_table $where"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;\n$bind    \$req->execute() ;\n    \$res = \$req->fetch(PDO::FETCH_ASSOC) ;\n    \$req->closeCursor() ;\n    return \$res ;\n\}"
    
    
    return $code
}







###############################################################
#                   Code pour les ORM                         #
###############################################################

proc Katyusha_GenerationCode_main_orm {tables relations heritages langage orm ns prefix fichier_unique {sgbd "aucun"}} {
    global MCD
    global CONFIGS
    
    # Transforme certaines relations en tables
    set tables [Katyusha_MLD_relations_en_tables $relations $tables $sgbd]
    # Applique les changements dûs aux relations sur les tables
    set tables [Katyusha_MLD_applique_changements_tables $relations $tables $sgbd]
    set codes [Katyusha_GenerationCode_tables_orm $tables $langage $orm $ns $prefix]
    
    if {$MCD(rep) == $CONFIGS(REP_PROJETS_DEFAUT) || $MCD(rep) == ""} {
        set MCD(rep) [tk_chooseDirectory -initialdir $CONFIGS(REP_PROJETS_DEFAUT)]
    }
    
    if {$MCD(rep) != ""} {
        file mkdir "$MCD(rep)/$MCD(nom)\_$langage\_$orm"
        # Si toutes les classes dans un seul fichier
        if {$fichier_unique == 1} {
            # Langage PHP
            if {$langage == "php"} {
                set code "<?php\n// src/Base.php\nuse Doctrine\\ORM\\Mapping as ORM ;\n"
                foreach {nom code_classe} $codes {
                    set code "$code\n$code_classe"
                }
                set code "$code\n?>"
                set fichier "$MCD(rep)/$MCD(nom)\_$langage\_$orm/Base.php"
            }
            # Enregistre toutes les classes dans le fichier
            Katyusha_C_fichier_enrigistrer $fichier $code "w+"
            set message "Classes [string toupper $langage] enregistrées dans le fichier : $MCD(rep)/$MCD(nom)\_$langage\_$orm/Base.php"
        # Sinon, un fichier par classe
        } else {
            # Langage PHP
            if {$langage == "php"} {
                set code ""
                foreach {nom code_classe} $codes {
                    set fichier "$MCD(rep)/$MCD(nom)\_$langage\_$orm/$nom.php"
                    set code "<?php\n// src/$nom.php\nuse Doctrine\\ORM\\Mapping as ORM ;\n$code_classe\n?>"
                    # Enregistre toutes les classes dans le fichier
                    Katyusha_C_fichier_enrigistrer $fichier $code "w+"
                }
            }
            set message "Classes [string toupper $langage] enregistrées dans le répertoire : $MCD(rep)/$MCD(nom)\_$langage\_$orm"
        }
        set res_info [tk_messageBox -icon info -type ok -message $message]
    }
}

proc Katyusha_GenerationCode_table_orm {table langage orm ns prefix} {
    set code ""
    
    set nom_table [dict get $table "nom"]
    set attributs [dict get $table "attributs"]
    
    foreach {k attribut} $attributs {
        set code "$code\n[Katyusha_Code_attribut_orm $attribut $langage $orm]"
    }
    set code [Katyusha_Code_table_orm $nom_table $code $langage $orm]
    return $code
}

proc Katyusha_GenerationCode_tables_orm {tables langage orm ns prefix} {
    set codes [dict create]
    # Balayage des tables
    foreach {k table} $tables {
        # On ne génère le script sql de la table que si elle n'est pas table fille d'un héritage
        if {[Katyusha_MLD_table_fille_ $k $table] == 0} {
            set nom_table [dict get $table "nom"]
            puts "Génération du code $langage de la table : $nom_table"
            set attributs_table [dict get $table "attributs"]
            # Si la table en question est table mère d'un héritage, elle aspire les attributs de ses filles
            # Et on lui ajoute un attribut discriminant
            set table_mere [Katyusha_MLD_table_mere_ $k $table]
            if {[lindex $table_mere 1] == 1} {
                set attributs_table [Katyusha_MLD_table_mere_ajout_attributs_filles $attributs_table [lindex $table_mere 0] $nom_table]
            }
            dict set codes $nom_table [Katyusha_GenerationCode_table_orm $table $langage $orm $ns $prefix]
        }
    }
    return $codes
}


##
# Génère pour une table le code correspondant à l'ORM choisi
# 11/11/2021 : Pour le moment, uniquement pour l'ORM PHP Doctrine
##
proc Katyusha_GenerationCode_orm {nom_table attributs langage prefix} {

}
