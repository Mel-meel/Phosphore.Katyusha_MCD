## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_GenerationCode_main {tables relations heritages langage type_langage {sgbd "aucun"}} {
    # Pour reconnaitre les "vraies" tables des fausses
    foreach {k table} $tables {
        dict set table "vraie" 1
        dict set tables $k $table
    }
    # Transforme certaines relations en tables
    set tables [Katyusha_MLD_relations_en_tables $relations $tables $sgbd]
    # Applique les changements dûs aux relations sur les tables
    set tables [Katyusha_MLD_applique_changements_tables $relations $tables $sgbd]
    foreach {k v} $tables {
        puts [dict get $v "nom"]
    }
    set code [Katyusha_GenerationCode_tables $tables $langage $type_langage]
    puts $code
}

##
# Construit le script SQL des tables
##
proc Katyusha_GenerationCode_tables {tables langage type_langage} {
    set code ""
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
            set code [Katyusha_GenerationCode_table [Katyusha_GenerationCode_attributs $nom_table $attributs_table $langage $type_langage] $langage $type_langage]
        }
    }
    return $code
}

proc Katyusha_GenerationCode_attributs {nom_table attributs langage type_langage} {
    set fonctions [Katyusha_Generation_Code_fonctions_$type_langage $nom_table $attributs $langage]
    return $fonctions
}

proc Katyusha_GenerationCode_table {code_attributs langage type_langage} {
    return $code_attributs
}





# Pour le moment, que pour PHP mode procédural
proc Katyusha_Generation_Code_fonctions_procedural {nom_table attributs langage} {
    set fonctions [dict create]
    
    ##
    # Fonction de requête select
    ##
    set code "function BDD_$nom_table\_select(\$connex) \{\n"
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
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare($sql) ;\n    \$req->execute() ;\n    \$c = 0 ;\n    while (\$row = \$req->fetch(PDO::FETCH_ASSOC)) \{\n        \$res\[\$c\] = \$row ;\n        \$c = \$c+1 ;\n    \}\n    \$req->closeCursor() ;\n    return \$res ;\n\}\n\n"
    
    ##
    # Fonction de requête select PK
    ##
    set code "$code\nfunction BDD_$nom_table\_select_PK(\$connex, \$$nom_table) \{\n"
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
            set bind "$bind\n    \$req->bindParam($c, \$$nom_table\[\"$nom_attribut\"\]) ;"
            set c [expr $c + 1]
        }
    }
    # Assemble la requête
    set sql "$sql from $nom_table $where"
    
    set code "$code    \$res = array() ;\n    \$req = \$connex->prepare(\"$sql\") ;    $bind\n    \$req->execute() ;\n    \$res = \$req->fetch(PDO::FETCH_ASSOC) ;\n    \$req->closeCursor() ;\n    return \$res ;\n\n"






    return $code
}


















