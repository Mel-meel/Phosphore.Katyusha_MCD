## Créé le 23/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Initialise le nouveau MCD
##
proc Katyusha_MCD_init {} {
    global tables
    global ID
    global historique_actions
    global id_historique
    global tables_graphique
    global relations
    global relations_graphique
    global heritages
    global heritages_graphique
    global etiquettes
    global etiquettes_graphique
    global lignes_graphique
    global textes_cardinalites
    global procedures
    global coords
    global table_tmp
    global relation_tmp
    global heritage_tmp
    global etiquette_tmp
    global tables_a
    global relations_a
    global heritages_a
    global etiquettes_a
    global E_defaut_valeur
    global MCD
    global CONFIGS
    global fichier_sauvegarde
    
    # Dictionnaire contenant toutes les tables et leurs informations, sauf graphiques
    set tables [dict create]
    set ID 0
    # Dictionnaire contenant toutes les informations relatives à l'affichage graphique des tables
    set tables_graphique [dict create]
    # Dictionnaire contenant toutes les relations entre les tables et leurs informations, sauf graphiques
    set relations [dict create]
    # Dictionnaire contenant toutes les informations relatives à l'affichage graphique des relations
    set relations_graphique [dict create]
    # Dictionnaire contenant tous les héritages entre les tables et leurs informations, sauf graphiques
    set heritages [dict create]
    # Dictionnaire contenant toutes les informations relatives à l'affichage graphique des héritages
    set heritages_graphique [dict create]
    # Dictionnaire contenant tous les étiquettes entre les tables et leurs informations, sauf graphiques
    set etiquettes [dict create]
    # Dictionnaire contenant toutes les informations relatives à l'affichage graphique des étiquette
    set etiquettes_graphique [dict create]
    # Historique des action
    set id_historique 0
    dict set historique_actions $id_historique [list $tables $relations $heritages $etiquettes]
    
    set lignes_graphique [dict create]
    set textes_cardinalites [dict create]
    # Dictionnaire contenant toutes les procédures de la base
    set procedures [dict create]
    # Coordonnées temporaires
    set coords [list]
    # Table temporaire
    set table_tmp [dict create]
    # Relation temporaire
    set relation_tmp [dict create]
    # Héritage temporaire
    set heritage_tmp [dict create]
    # Étiquette temporaire
    set etiquette_tmp [dict create]
    
    # Dictionnaires de sauvegarde
    set tables_a $tables
    set relations_a $relations
    set heritages_a $heritages
    set etiquettes_a $etiquettes
    
    set E_defaut_valeur "null"

    set MCD(rep) $CONFIGS(REP_PROJETS_DEFAUT)
    set fichier_sauvegarde ""
}

proc Katyusha_MCD_nouveau {} {
    Katyusha_MCD_canvas_effacer
    Katyusha_MCD_init
    maj_arbre_entites
}

proc Katyusha_MCD_canvas_effacer {} {
    .mcd.canvas.c delete "table"
    .mcd.canvas.c delete "relation"
    .mcd.canvas.c delete "ligne"
    .mcd.canvas.c delete "etiquette"
    .mcd.canvas.c delete "heritage"
    .mcd.canvas.c delete "ligne_heritage"
    .mcd.canvas.c delete "texte_cardinalite"
}
