## Créé le 5/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Retourne le type que supporte le SGBD passé en paramètre pour un auto incrémentation
##
proc Katyusha_SQL_auto_increment_type {sgbd} {
    if {$sgbd == "mysql"} {
        set type "integer"
    } elseif {$sgbd == "sqlite3" || $sgbd == "sqlite"} {
        set type "integer"
    } elseif {$sgbd == "postgres"} {
        set type "serial"
    } elseif {$sgbd == "sqlserver"} {
        set type "integer"
    } elseif {$sgbd == "oracle"} {
        set type "integer"
    } else {
        set type ""
    }
    
    return $type
}

##
# Liste des types standards SQL
##
proc Katyusha_SQL_liste_types {} {
    set types [list "integer" "smallint" "bigint" "bigserial" "double" "float" "real" "numeric" "text" "char" "varchar" "bool" "boolean" "date" "datetime" "time" "year" "timestamp"]
    return $types
}

proc Katyusha_SQL_mots_clefs {} {
    set mots [list "create" "table" "alter" "database" "view" "add" "column" "constraint" "references" "not null" "primary key" "foreign key" "default" "unsigned" "unique"]
    return $mots
}

proc Katyusha_SQL_liste_types_taille {} {
    set types [list "varchar" "char"]
    return $types
}

##
# Créé le code SQL pour une auto incrémentation
##
proc Katyusha_SQL_auto_increment {sgbd} {
    if {$sgbd == "mysql"} {
        set res [list "AUTO_INCREMENT" 0]
    } elseif {$sgbd == "sqlite3" || $sgbd == "sqlite"} {
        set res [list "AUTOINCREMENT" 0]
    } elseif {$sgbd == "sqlserver"} {
        set res [list "IDENTITY\(1,1\)" 0]
    } elseif {$sgbd == "postgres"} {
        set res [list "" 0]
    } elseif {$sgbd == "oracle"} {
        set res [list "GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1)" 0]
    } else {
        set res [list "" 0]
    }
    return $res
}

proc Katyusha_SQL_drop_base {base sgbd} {
    set SQL "DROP DATABASE IF EXISTS $base ;\nCREATE DATABASE $base ;"
    if {$sgbd == "mysql"} {
        set SQL "$SQL\nUSE $base ;"
    } elseif {$sgbd == "sqlserver"} {
        set SQL "$SQL\nUSE $base ;"
    } elseif {$sgbd == "postgresql"} {
        set SQL "$SQL\n\\c $base ;"
    } else {
        set SQL ""
    }
    return $SQL
}

##
# Raccourci les noms des clefs étrangères de façon à ce que ça ne dépasse pas 64 caractère, sinon
# gros bug avec MySQL, semble passer pour les autres SGBD
##
proc Katyusha_SQL_raccourci_limite_64 {nom} {
    set longueur [string length $nom]
    
    if {$longueur > 64} {
        set res "[string range $nom 0 58][expr int([expr rand() * 100000])]"
    } else {
        set res $nom
    }
    
    return $res
}

proc Katyusha_SQL_ajout_fk {table_lien table_lier nom_attribut nom_origine_attribut sgbd} {
    set fk "FK_$table_lier\_$nom_attribut\_$table_lien"
    if {$sgbd == "mysql"} {
        set fk [Katyusha_SQL_raccourci_limite_64 $fk]
    }
    return "ALTER TABLE $table_lien ADD CONSTRAINT $fk FOREIGN KEY \($nom_attribut\) REFERENCES $table_lier\($nom_origine_attribut\) ;\n"
}

proc Katyusha_SQL_ajout_colone {table_lien nom_attribut type_attribut taille_attribut} {
    if {$taille_attribut == "null"} {
        set taille_attribut ""
    } else {
        set taille_attribut "($taille_attribut)"
    }
    set SQL "ALTER TABLE $table_lien ADD COLUMN $nom_attribut [string toupper $type_attribut]$taille_attribut NOT NULL ;\n"
    return $SQL
}

##
# Color les mots clefs SQL dans le text passé en paramètre
##
proc Katyusha_SQL_coloration {texte script} {
    set lignes [split $script "\n"]
    
    set mots [Katyusha_SQL_mots_clefs]
    set types [Katyusha_SQL_liste_types]
    lappend types "serial"
    #lappend types "int"
    
    set COM 0
    
    set c 1
    foreach ligne $lignes {
        # Balayage des types SQL
        foreach type $types {
            set type [string toupper $type]
            set debut 0
            while {[string first $type $ligne $debut] >= 0} {
                $texte tag add rouge $c.[string first $type $ligne] $c.[expr [string first $type $ligne] + [string length $type]]
                set debut [expr [string first $type $ligne] + 1]
            }
        }
        # Balayage des mots clefs du langage SQL, hors types
        foreach mot $mots {
            set mot [string toupper $mot]
            set debut 0
            while {[string first $mot $ligne $debut] >= 0} {
                $texte tag add orange $c.[string first $mot $ligne] $c.[expr [string first $mot $ligne] + [string length $mot]]
                set debut [expr [string first $mot $ligne] + 1]
            }
        }
        # Balayage des types bool
        foreach type [list "true" "false"] {
            set type [string tolower $type]
            set debut 0
            while {[string first $type $ligne $debut] >= 0} {
                $texte tag add rose $c.[string first $type $ligne] $c.[expr [string first $type $ligne] + [string length $type]]
                set debut [expr [string first $type $ligne] + 1]
            }
        }
        # Cherche un commentaire
        if {$COM == 0} {
            set debut_com [string first "/*" $ligne]
        } else {
            set debut_com 0
        }
        set fin_com [expr [string first "*/" $ligne $debut_com] + 2]
        if {$debut_com >= 0} {
            if {$fin_com >= 0} {
                set COM 0
                $texte tag add gris $c.$debut_com $c.$fin_com
            } else {
                set COM 1
                $texte tag add gris $c.$debut_com $c.[string length $ligne]
            }
        } else {
            if {$fin_com >= 0} {
                set COM 0
                $texte tag add gris $c.0 $c.$fin_com
            } else {
                set COM 1
                $texte tag add gris $c.0 $c.[string length $ligne]
            }
        }
        set c [expr $c + 1]
    }
    
    $texte tag configure rouge -foreground #AD3925
    $texte tag configure orange -foreground #FF7000
    $texte tag configure rose -foreground #DE00E3
    $texte tag configure gris -foreground #717171
# -font 9x15bold
}
