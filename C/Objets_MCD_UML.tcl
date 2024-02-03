## Créé le 10/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Échange la place de deux attributs
##
proc Katyusha_MCD_Objets_deplacer_attribut {objet id_ancien id_nouveau} {
    set attributs [dict get $objet "attributs"]
    
    # Si l'attribut à déplacer n'est pas en début ou en fin de liste, bah il bouge
    if {[lsearch [dict keys $attributs] $id_ancien] != -1 && [lsearch [dict keys $attributs] $id_nouveau] != -1} {
        set ancien [dict get $attributs $id_ancien]
        set nouveau [dict get $attributs $id_nouveau]
        
        dict set attributs $id_ancien $nouveau
        dict set attributs $id_nouveau $ancien
        
        dict set objet "attributs" $attributs
    }
    
    return $objet
}
