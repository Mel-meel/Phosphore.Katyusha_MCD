## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Code_attribut_orm {attribut langage orm} {
    set code ""
    
    set nom [dict get $attribut "nom"]
    set type [dict get $attribut "type"]
    set taille [dict get $attribut "taille"]
    set pk [dict get $attribut "pk"]
    set valeur [dict get $attribut "valeur"]
    set null [dict get $attribut "null"]
    
    ##
    # ORM PHP Doctrine
    ##
    if {$langage == "php" && $orm == "doctrine"} {
        puts $attribut
    }
}
