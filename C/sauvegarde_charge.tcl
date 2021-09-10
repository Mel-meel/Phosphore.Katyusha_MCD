## Créé le 5/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Vérifie si quelque chose à été modifé avant de quitter
##
proc Katyusha_exit_verif {} {
    # Charge les dictionnaires à comparer
    global tables
    global tables_a
    global relations
    global relations_a
    global fichier_sauvegarde
    ##
    # Au lancement du programme, au chargement et à chaque enregistrement, une copie du dictionnaire des tables est créé
    # Ici, on compare ce nouveau dictionnaire (qui ne se met pas à jour à la création d'une nouvelle table) avec celui
    # se mettant automatiquement à jour à chaque nouvelle action sur une table.
    # Si les deux dictionnaires sont identiques, alors rien n'à été modifié, donc on peut quitter
    # Sinon, on informe que quelque chose à été modifié
    ##
    if {$tables == $tables_a && $relations == $relations_a} {
        puts "Au revoir"
        exit
    } else {
        set reponse [tk_messageBox -message "Quitter sans sauvegarder?" -type yesnocancel]
        puts "Oups.."
        if {$reponse == "yes"} {
            puts "Au revoir"
            exit
        } elseif {$reponse == "no"} {
            Katyusha_sauvegarder
            #puts "Au revoir"
            #exit
        } elseif {$reponse == "cancel"} {
            puts "Finalement, on reste"
        }
    }
}

##
# Enregistre toute une arborescence XML dans des dictionnaires
##
proc Phosphore_XML_var {xml {var ""}} {
    set debut 0
    set res [dict create]
    while {[string first "<" $xml $debut] != -1} {
        # Cherche la balise d'ouverture de l'élément
        set debut [expr [string first "<" $xml $debut] + 1]
        set fin [expr [string first ">" $xml $debut] - 1]
        set balise_o [string range $xml $debut $fin]
        # Détache les attributs du nom
        # Cherche la balise de fermeture de l'élément
        if {[string first " " $balise_o] != -1} {
            set attributs_tmp [split $balise_o " "]
            set balise_o [lindex $attributs_tmp 0]
            foreach el $attributs_tmp {
                if {$el != $balise_o} {
                    lappend attributs $el
                }
            }
            unset $attributs_tmp
        }
        set debut_f [expr [string first "</$balise_o" $xml $debut] + 1]
        set fin_f [expr [string first ">" $xml $debut_f] - 1]
        set balise_f [string range $xml $debut_f $fin_f]
        # Contenu de la balise
        set contenu [string range $xml [expr $fin + 2] [expr $debut_f - 2]]
        # Si le contenu de la balise est du XML, il faut recommencer l'opération
        # avec le contenu, jusqu'à ce que tous les sous-éléments soit enregistrés
        # dans un dictionnaire
        if {[Phosphore_string_XML_ $contenu]} {
            dict set res $balise_o [Phosphore_XML_var $contenu]
        } else {
            dict set res $balise_o $contenu
        }
        set debut $fin_f
    }
    return $res
}

proc Katyusha_MAJ_SC {} {
    global tables
    global tables_a
    global relations
    global relations_a
    global heritages
    global heritages_a
    global etiquettes
    global etiquettes_a
    
    set tables_a $tables
    set relations_a $relations
    set heritages_a $heritages
    set etiquettes_a $etiquettes
}
