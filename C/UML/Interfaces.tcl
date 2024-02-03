## Créé le 6/8/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Interfaces_ajout {} {
    Katyusha_UML_Objets_maj_arbre_objets
}

proc Katyusha_UML_Interfaces_creer_affichage_graphique {id interface} {

}

proc Katysha_UML_Interfaces_creer_interface {interface_tmp} {
    # Charge la variable globale contenant toutes les tables
    global interfaces
    global interfaces_graphique
    global ID
    
    # Ajoute la nouvelle classe aux classes existantes
    dict set interfaces $ID $interfaces_tmp
    set graph [Katyusha_UML_Interfaces_creer_affichage_graphique $ID $interfaces_tmp]
    # Ajoute la liste temporaire au dictionnaire graphique des classes
    dict set classes_graphique $ID $graph
    puts [phgt::mc "Ajout de l'interface : [dict get $interface_tmp nom]"]
    
    set ID [expr $ID + 1]
    unset graph
    # Met à jour l'arbre des entités
    Katyusha_UML_Objets_maj_arbre_objets
    
    #Katyusha_Historique_maj
}
