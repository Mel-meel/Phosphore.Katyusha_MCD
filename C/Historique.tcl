## Créé le 6/6/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Met à jour le dictionnaire d'historiquepour les actions "défaire" et "refaire"
##
proc Katyusha_Historique_maj {} {
    global tables
    global relations
    global heritages
    global etiquettes
    global id_historique
    global historique_actions
    global tables_graphique
    
    # Historique des action
    set id_historique [expr $id_historique + 1]
    dict set historique_actions $id_historique [list $tables $relations $heritages $etiquettes]
}

proc Katyusha_Historique_defaire {} {
    global tables
    global relations
    global heritages
    global etiquettes
    global id_historique
    global historique_actions
    global tables_graphique
    
    # Historique des action
    if {[expr $id_historique - 1] >= 0} {
        set id_historique [expr $id_historique - 1]
        set tables [lindex [dict get $historique_actions $id_historique] 0]
        set relations [lindex [dict get $historique_actions $id_historique] 1]
        set heritages [lindex [dict get $historique_actions $id_historique] 2]
        set etiquettes [lindex [dict get $historique_actions $id_historique] 3]
        Katyusha_MCD_canvas_effacer
        maj_tables
        Katyusha_Relations_maj
        Katyusha_Heritages_maj
        Katyusha_Etiquettes_maj
    }
}

proc Katyusha_Historique_refaire {} {
    global tables
    global relations
    global heritages
    global etiquettes
    global id_historique
    global historique_actions
    global tables_graphique
    
    # Historique des action
    if {[expr $id_historique + 1] <= [expr [dict size $historique_actions] - 1]} {
        set id_historique [expr $id_historique + 1]
        set tables [lindex [dict get $historique_actions $id_historique] 0]
        set relations [lindex [dict get $historique_actions $id_historique] 1]
        set heritages [lindex [dict get $historique_actions $id_historique] 2]
        set etiquettes [lindex [dict get $historique_actions $id_historique] 3]
        Katyusha_MCD_canvas_effacer
        maj_tables
        Katyusha_Relations_maj
        Katyusha_Heritages_maj
        Katyusha_Etiquettes_maj
    }
}
