## Créé le 4/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Attributs_dernier_id {attributs} {
    set id 0
    set ids [dict keys $attributs]
    set id [lindex [expr [llength $ids] - 1]]
    return $id
}
