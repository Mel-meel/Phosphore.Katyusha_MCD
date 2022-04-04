## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Code_table_orm {nom_table code_attributs langage orm} {
    set code ""
    
    ##
    # ORM PHP Doctrine
    ##
    if {$langage == "php" && $orm == "doctrine"} {
        set code "\nclass $nom_table \{\n$code_attributs\n\}\n"
    }
}

proc Katyusha_Code_attribut_orm {attribut langage orm} {
puts $attribut
    set code ""
    
    set nom [dict get $attribut "nom"]
    set type [dict get $attribut "type"]
    set taille [dict get $attribut "taille"]
    if {$taille == 0} {
        set taille 255
    }
    set pk [dict get $attribut "pk"]
    set auto [dict get $attribut "auto"]
    set valeur [dict get $attribut "valeur"]
    set null [dict get $attribut "null"]
    
    ##
    # ORM PHP Doctrine
    ##
    if {$langage == "php" && $orm == "doctrine"} {
        set code "    /**"
        if {$pk == 1} {
            set code "$code\n     * @ORM\\Id\(\)"
        }
        if {$auto == 1} {
            set code "$code\n     * @ORM\\GeneratedValue\(strategy=\"AUTO\"\)"
            set type "integer"
        }
        if {$type == "varchar" || $type == "char" || $type == "text"} {
            set type "string"
            set ctype ", length=$taille"
        } else {
            set ctype ""
        }
        set code "$code\n     * @ORM\\Column\(type=\"$type\"$ctype\)"
        
        # En cas de clef étrangère
        if {[lsearch [dict keys $attribut] "card"] != -1} {
            puts [dict get $attribut "card"]
        }
        set code "$code\n     */"
        set code "$code\n    private \$$nom ;\n"
    }
    return $code
}
