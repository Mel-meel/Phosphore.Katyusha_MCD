## Créé le 4/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Donne le chemin du fichier à sauvegarder
##
proc Katyusha_sauvegarder {} {
    global fichier_sauvegarde
    if {$fichier_sauvegarde == ""} {
        Katyusha_sauvegarder_sous
    }
    if {$fichier_sauvegarde != ""} {
        Katyusha_Sauvegarde
    }
}

proc Katyusha_sauvegarder_sous {} {
    global fichier_sauvegarde
    global rep_mcd
    
    set fichier [tk_getSaveFile -initialdir $rep_mcd]
    if {$fichier != ""} {
        # Vérifie l'extension du fichier
        set ext [string range $fichier [expr [string length $fichier] - 4] [expr [string length $fichier] - 1]]
        if {$ext != ".mcd"} {
            set fichier_sauvegarde "$fichier.mcd"
        } else {
            set fichier_sauvegarde $fichier
        }
        .infos.fichier configure -text $fichier_sauvegarde
        if {$fichier_sauvegarde != ""} {
            Katyusha_Sauvegarde
        }
    }
}

##
# Code XML d'une seule entité
##
proc Katyusha_Sauvegarde_entite {id entite} {
    global tables_graphique
    global ZONE_MCD
    
    set nom_entite [dict get $entite "nom"]
    set xml "\t<entite id=\"$id\">\n\t\t<nom>$nom_entite</nom>\n\t\t<attributs>\n"
    set attributs [dict get $entite "attributs"]
    # Balayage des attributs de la table
    foreach {k attribut} $attributs {
        set xml "$xml\t\t\t<attribut id=\"$k\">\n"
        foreach {kk valeur} $attribut {
            set xml "$xml\t\t\t\t<$kk>$valeur</$kk>"
        }
        set xml "$xml\t\t\t</attribut>\n"
    }
    set xml "$xml\t\t</attributs>\n"
    # Couleurs de la table
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $entite "couleurs"] {
        set xml "$xml\t\t\t<$k>$v</$k>\n"
    }
    set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de l'entite graphique
    set id_graphique [lindex [dict get $tables_graphique $id] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
    #set coords [dict get $table coords]
    #set x [lindex $coords 0]
    #set y [lindex $coords 1]
    # Description de la table
    set description [dict get $entite description]
    set xml "$xml\t\t<description>$description</description>\n"
    set xml "$xml\t\t<coords>\n\t\t<x>$x</x>\n\t\t<y>$y</y>\n\t\t</coords>\n\t</entite>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des entites
##
proc Katyusha_Sauvegarde_entites {entites} {
    set xml "<entites>\n"
    # Balayage des entites
    foreach {ka entite} $entites {
        set xml "$xml[Katyusha_Sauvegarde_entite $ka $entite]"
    }
    set xml "$xml</entites>\n"
    return $xml
}

proc Katyusha_Sauvegarde_association {id association} {
    global relations_graphique
    global ZONE_MCD
    
    set nom_association [dict get $association "nom"]
    set xml "\t<association id=$id>\n\t\t<nom>$nom_association</nom>\n\t\t<attributs>\n"
    set attributs [dict get $association "attributs"]
    # Balayage des attributs de l'association
    foreach {k attribut} $attributs {
        set xml "$xml\t\t\t<attribut id=\"$k\">\n"
        foreach {kk valeur} $attribut {
            set xml "$xml\t\t\t\t<$kk>$valeur</$kk>"
        }
        set xml "$xml\t\t\t</attribut>\n"
    }
    set xml "$xml\t\t</attributs>\n\t\t<liens>\n"
    set liens [dict get $association "liens"]
    # Balyage des liens
    foreach {k lien} $liens {
        set entite_lien [lindex $lien 0]
        set n_lien [lindex $lien 1]
        set relatif [lindex $lien 2]
        set xml "$xml\t\t\t<lien id=$k>\n"
        set xml "$xml\t\t\t\t<entite_lien>$entite_lien</entite_lien>\n\t\t\t\t<n_lien>$n_lien</n_lien>\n\t\t\t\t<relatif>$relatif</relatif>\n"
        set xml "$xml\t\t\t</lien>\n"
    }
    # Couleurs de la relation
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $association "couleurs"] {
        set xml "$xml\t\t\t<$k>$v</$k>\n"
    }
    set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de la relation graphique
    set id_graphique [lindex [dict get $relations_graphique $id] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 15]
    #set coords [dict get $relation coords]
    #set x [lindex $coords 0]
    #set y [lindex $coords 1]
    set xml "$xml\t\t</liens>\n\t<coords>\n\t\t<x>$x</x>\n\t\t<y>$y</y>\n\t\t</coords>\n\t</association>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des associations
##
proc Katyusha_Sauvegarde_associations {associations} {
    set xml "<associations>\n"
    # Balayage des relations
    foreach {ka association} $associations {
        set xml "$xml[Katyusha_Sauvegarde_association $ka $association]"
    }
    set xml "$xml</associations>\n"
    return $xml
}

proc Katyusha_Sauvegarde_etiquette {id etiquette} {
    set nom_etiquette [dict get $etiquette nom]
    set xml "\t<etiquette id=$id>\n\t\t<nom>$nom_etiquette</nom>\n"
    # Texte de l'étiquette
    set texte [dict get $etiquette "texte"]
    set xml "$xml\t\t<texte>$texte</texte>\n"
    # Couleurs de l'étiquette
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $etiquette "couleurs"] {
        set xml "$xml\t\t\t<$k>$v</$k>\n"
    }
    set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de l'étiquette graphique
    set coords [dict get $etiquette coords]
    set x [lindex $coords 0]
    set y [lindex $coords 1]
    set xml "$xml\t\t<coords>\n\t\t<x>$x</x>\n\t\t<y>$y</y>\n\t\t</coords>\n\t</etiquette>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des étiquettes
##
proc Katyusha_Sauvegarde_etiquettes {etiquettes} {
    set xml "<etiquettes>\n"
    # Balayage des etiquettes
    foreach {ka etiquette} $etiquettes {
        set xml "$xml[Katyusha_Sauvegarde_etiquette $ka $etiquette]"
    }
    set xml "$xml</etiquettes>\n"
    return $xml
}

##
#
##
proc Katyusha_Sauvegarde_heritage {id heritage} {
    global heritages_graphique
    global ZONE_MCD
    
    set xml "\t<heritage id=\"$id\">\n"
    # Sauvegarde des tables concernées par l'héritage
    set entite_mere [dict get $heritage "mere"]
    set xml "$xml\t\t<entite_mere>$entite_mere</entite_mere>\n\t\t<entites_filles>\n"
    set filles [dict get $heritage "filles"]
    foreach {k fille} $filles {
        set xml "$xml\t\t\t<fille id=\"$k\">$fille</fille>\n"
    }
    set xml "$xml\t\t</entites_filles>\n"
    # Contrainte de l'héritage
    set xml "$xml\t\t<contrainte>[dict get $heritage contrainte]</contrainte>\n"
    # Couleurs de l'héritage
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $heritage "couleurs"] {
        set xml "$xml\t\t\t<$k>$v</$k>\n"
    }
    set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de l'héritage graphique
    set id_graphique [lindex [dict get $heritages_graphique $id] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set x [lindex $coords 4]
    set y [expr [lindex $coords 5] + 45]
    set xml "$xml\t\t<coords>\n\t\t<x>$x</x>\n\t\t<y>$y</y>\n\t\t</coords>\n\t</heritage>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des héritages
##
proc Katyusha_Sauvegarde_heritages {heritages} {
    set xml "<heritages>\n"
    # Balayage des héritages
    foreach {k heritage} $heritages {
        set xml "$xml[Katyusha_Sauvegarde_heritage $k $heritage]"
    }
    set xml "$xml</heritages>\n"
    return $xml
}

##
# Code XML pour une seule classe
##
proc Katyusha_Sauvegarde_classe {id classe} {
    global classes_graphique
    global ZONE_UML
    
    set nom_classe [dict get $classe "nom"]
    set xml "\t<classe id=\"$id\">\n\t\t<nom>$nom_classe</nom>\n\t\t<attributs>\n"
    set attributs [dict get $classe "attributs"]
    # Balayage des attributs de la classe
    foreach {k attribut} $attributs {
        set xml "$xml\t\t\t<attribut id=\"$k\">\n"
        foreach {kk valeur} $attribut {
            set xml "$xml\t\t\t\t<$kk>$valeur</$kk>"
        }
        set xml "$xml\t\t\t</attribut>\n"
    }
    set xml "$xml\t\t</attributs>\n\t\t<methodes>\n"
    # Balayage des méthodes de la classe
    foreach {k methode} $attributs {
        set xml "$xml\t\t\t<methode id=\"$k\">\n"
        foreach {kk valeur} $methode {
            set xml "$xml\t\t\t\t<$kk>$valeur</$kk>"
        }
        set xml "$xml\t\t\t</methode>\n"
    }
    set xml "$xml\t\t</methodes>\n"
    # Couleurs de la classe
    #set xml "$xml\t\t<couleurs>\n"
    #foreach {k v} [dict get $classe "couleurs"] {
    #    set xml "$xml\t\t\t<$k>$v</$k>\n"
    #}
    #set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de la classe graphique
    set id_graphique [lindex [dict get $classes_graphique $id] 0]
    set coords [$ZONE_UML.modelisation.c coords $id_graphique]
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
    # Description de la table
    set description [dict get $classe description]
    set xml "$xml\t\t<description>$description</description>\n"
    set xml "$xml\t<coords>\n\t\t<x>$x</x>\n\t\t<y>$y</y>\n\t\t</coords>\n\t</classe>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des classes
##
proc Katyusha_Sauvegarde_classes {classes} {
    set xml "<classes>\n"
    # Balayage des tables
    foreach {ka classe} $classes {
        set xml "$xml[Katyusha_Sauvegarde_classe $ka $classe]"
    }
    set xml "$xml</classes>\n"
    return $xml
}

##
# Enregistre toutes les données dans un fichier au format XML
##
proc Katyusha_Sauvegarde {} {
    global MCD
    global tables
    global relations
    global heritages
    global etiquettes
    global classes
    global interfaces
    global fichier_sauvegarde
    global version
    global rep_configs
    
    set xml ""
    # En tête XML
    set xml "$xml<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<katyusha>\n\t<version>$version</version>\n</katyusha>\n"
    
    ##
    # Partie Merise
    ##
    set xml "$xml\n<diagramme_merise>\n"
    
    # Enregistrement des entités
    set xml "$xml[Katyusha_Sauvegarde_entites $tables]"
    # Enregistrement des associations
    set xml "$xml[Katyusha_Sauvegarde_associations $relations]"
    # Enregistrement des etiquettes
    set xml "$xml[Katyusha_Sauvegarde_etiquettes $etiquettes]"
    # Enregistrement des héritages
    set xml "$xml[Katyusha_Sauvegarde_heritages $heritages]"
    
    set xml "$xml\n</diagramme_merise>"
    
    ##
    # Partie UML
    ##
    set xml "$xml\n<digramme_classes>\n"
    
    # Enregistrement des classes
    set xml "$xml[Katyusha_Sauvegarde_classes $classes]"
    
    set xml "$xml\n</digramme_classes>"
    
    # Enregistre dans le fichier
    set stream [open $fichier_sauvegarde "w+"]
    set MCD(rep) [file dirname $fichier_sauvegarde]
    puts $stream $xml
    close $stream
    
    # Enregistre le chemin du fichier dans le fichier de configuration des projets récents
    set contenu $fichier_sauvegarde
    foreach fichier [Katyusha_fichiers_recents] {
        if {$fichier == $fichier_sauvegarde} {
            set contenu ""
        }
    }
    set stream [open "$rep_configs/recents" "a+"]
    puts $stream $contenu
    close $stream
    
    puts "$fichier_sauvegarde"
    # Met à jour les dictionnaires de sauvegarde
    Katyusha_MAJ_SC
}
