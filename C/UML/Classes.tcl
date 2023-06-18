## Créé le 4/3/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Classes_ajout {} {

}

proc Katyusha_UML_Classes_maj_depuis_mld {mld} {
    global classes
}

proc Katyusha_UML_Classes_creer affichage graphique {} {

}

##
# Créé une classes depuis le MCD
##
proc Katyusha_UML_Classes_creer_classe_depuis_entite {id entite} {
    global tables
    global classes
    global ENV
    global ID_UML
    
    puts "Création de la classe UML pour la table $id"
    puts $entite
    puts "ID de la classe : $ID_UML"
    
    set classe [Katyusha_UML_Classes_init_classe]
    
    dict set classe "nom" [dict get $entite "nom"]
    dict set classe "attributs" [dict get $entite "attributs"]
    dict set classe "coords" [dict get $entite "coords"]
    
    puts $classe
}

##
# Initialise une classe
##
proc Katyusha_UML_Classes_init_classe {} {
    global UML
    
    set classe [dict create]
    dict set classe "attributs" [dict create]
    dict set classe "methodes" [dict create]
    #dict set classe "couleurs" [dict create "fond_tete" $UML(couleur_fond_tete_table) "ligne" $UML(couleur_ligne_table) "fond_corps" $UML(couleur_fond_corps_table) "texte" $UML(couleur_texte_table)]
    
    return $classe
}
