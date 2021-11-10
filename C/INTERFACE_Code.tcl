## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc INTERFACE_Code_generation_php {} {
    global tables
    global relations
    global heritages
    
    Katyusha_GenerationCode_main $tables $relations $heritages "PHP" "procedural"
}


proc INTERFACE_Code_generation_php_objet {} {

}