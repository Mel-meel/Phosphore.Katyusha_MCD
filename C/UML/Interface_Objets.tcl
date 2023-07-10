## Créé le 9/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Interface_Objets_ajout_attribut {objet} {

}
proc Katyusha_UML_Interface_Objets_suppression_attribut {objet} {

}
proc Katyusha_UML_Interface_Objets_ajout_methode {objet} {

}
proc Katyusha_UML_Interface_Objets_suppression_methode {objet} {

}
proc Katyusha_UML_Interface_Objets_deplacer_attribut {f type_objet id_ancien id_nouveau} {
    global classe_tmp
    
    if {$type_objet == "classe"} {
        set classe_tmp [Katyusha_MCD_Objets_deplacer_attribut $classe_tmp $id_ancien $id_nouveau]
        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f $classe_tmp $type_objet
    }
}
