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
# Retourne le code XML des configurations de la base sauvegardée
##
proc Katyusha_Sauvegarde_base {} {
    global MCD
    
    set xml "<base>\n\t<nom>$MCD(nom)</nom>\n\t<sgbd>$MCD(sgbd)</sgbd>\n\t<rep>$MCD(rep)</rep>\n\t<drop>$MCD(drop)</drop>\n</base>\n"
    return $xml
}

##
# 
##
proc Katyusha_Sauvegarde_table {id table} {
    global tables_graphique
    global ZONE_MCD
    
    set nom_table [dict get $table nom]
    set xml "\t<table id=$id>\n\t\t<nom>$nom_table</nom>\n\t\t<attributs>\n"
    set attributs [dict get $table attributs]
    # Balayage des attributs de la table
    set id_attribut 0
    foreach {k kb} $attributs {
        set id_attribut [expr $id_attribut + 1]
        set nom_attribut [dict get $kb nom]
        set xml "$xml\t\t\t<attribut id=$id_attribut>\n\t\t\t\t<nom>$nom_attribut</nom>\n"
        set type [dict get $kb type]
        set xml "$xml\t\t\t\t<type>$type</type>\n"
        set complement_type [dict get $kb complement_type]
        set xml "$xml\t\t\t\t<complement_type>$complement_type</complement_type>\n"
        set pk [dict get $kb pk]
        set xml "$xml\t\t\t\t<pk>$pk</pk>\n"
        set taille [dict get $kb taille]
        set xml "$xml\t\t\t\t<taille>$taille</taille>\n"
        set auto [dict get $kb auto]
        set xml "$xml\t\t\t\t<auto_increment>$auto</auto_increment>\n"
        set valeur [dict get $kb valeur]
        set xml "$xml\t\t\t\t<valeur>$valeur</valeur>\n"
        set null [dict get $kb null]
        set xml "$xml\t\t\t\t<null>$null</null>\n"
        set description [dict get $kb description]
        set xml "$xml\t\t\t\t<description>$description</description>\n"
        set xml "$xml\t\t\t</attribut>\n"
    }
    set xml "$xml\t\t</attributs>\n"
    # Couleurs de la table
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $table "couleurs"] {
        set xml "$xml\t\t\t<$k>$v</$k>\n"
    }
    set xml "$xml\t\t</couleurs>\n"
    # Coordonnées de la table graphique
    set id_graphique [lindex [dict get $tables_graphique $id] 0]
    set coords [$ZONE_MCD.canvas.c coords $id_graphique]
    set x [expr [lindex $coords 0] + (([lindex $coords 2] - [lindex $coords 0]) / 2)]
    set y [expr ([lindex $coords 1] + (([lindex $coords 3] - [lindex $coords 1]) / 2)) - 20]
    #set coords [dict get $table coords]
    #set x [lindex $coords 0]
    #set y [lindex $coords 1]
    # Description de la table
    set description [dict get $table description]
    set xml "$xml\t\t<description>$description</description>\n"
    set xml "$xml\t<coords>$x/$y</coords>\n\t</table>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des tables
##
proc Katyusha_Sauvegarde_tables {tables} {
    set xml "<tables>\n"
    # Balayage des tables
    foreach {ka table} $tables {
        set xml "$xml[Katyusha_Sauvegarde_table $ka $table]"
    }
    set xml "$xml</tables>\n"
    return $xml
}

proc Katyusha_Sauvegarde_relation {id relation} {
    global relations_graphique
    global ZONE_MCD
    
    set nom_relation [dict get $relation nom]
    set xml "\t<relation id=$id>\n\t\t<nom>$nom_relation</nom>\n\t\t<attributs>\n"
    set attributs [dict get $relation attributs]
    # Balayage des attributs de la relation
    set id_attribut 0
    foreach {k kb} $attributs {
        set id_attribut [expr $id_attribut + 1]
        set nom_attribut [dict get $kb nom]
        set xml "$xml\t\t\t<attribut id=$id_attribut>\n\t\t\t\t<nom>$nom_attribut</nom>\n"
        set type [dict get $kb type]
        set xml "$xml\t\t\t\t<type>$type</type>\n"
        set complement_type [dict get $kb complement_type]
        set xml "$xml\t\t\t\t<complement_type>$complement_type</complement_type>\n"
        set pk [dict get $kb pk]
        set xml "$xml\t\t\t\t<pk>$pk</pk>\n"
        set taille [dict get $kb taille]
        set xml "$xml\t\t\t\t<taille>$pk</taille>\n"
        set auto [dict get $kb auto]
        set xml "$xml\t\t\t\t<auto_increment>$auto</auto_increment>\n"
        set valeur [dict get $kb valeur]
        set xml "$xml\t\t\t\t<valeur>$valeur</valeur>\n"
        set null [dict get $kb null]
        set xml "$xml\t\t\t\t<null>$null</null>\n"
        set description [dict get $kb description]
        set xml "$xml\t\t\t\t<description>$description</description>\n"
        set xml "$xml\t\t\t</attribut>\n"
    }
    set xml "$xml\t\t</attributs>\n\t\t<liens>\n"
    set liens [dict get $relation liens]
    # Balyage des liens
    foreach {k lien} $liens {
        set table_lien [lindex $lien 0]
        set n_lien [lindex $lien 1]
        set relatif [lindex $lien 2]
        set xml "$xml\t\t\t<lien id=$k>\n"
        set xml "$xml\t\t\t\t<table_lien>$table_lien</table_lien>\n\t\t\t\t<n_lien>$n_lien</n_lien>\n\t\t\t\t<relatif>$relatif</relatif>\n"
        set xml "$xml\t\t\t</lien>\n"
    }
    # Couleurs de la relation
    set xml "$xml\t\t<couleurs>\n"
    foreach {k v} [dict get $relation "couleurs"] {
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
    set xml "$xml\t\t</liens>\n\t<coords>$x/$y</coords>\n\t</relation>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des étiquettes
##
proc Katyusha_Sauvegarde_relations {relations} {
    set xml "<relations>\n"
    # Balayage des relations
    foreach {ka relation} $relations {
        set xml "$xml[Katyusha_Sauvegarde_relation $ka $relation]"
    }
    set xml "$xml</relations>\n"
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
    set xml "$xml\t\t<coords>$x/$y</coords>\n\t</etiquette>\n"
    return $xml
}

##
# Retourne le code XML de l'ensemble des relations
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
    
    set xml "\t<heritage id=$id>\n"
    # Sauvegarde des tables concernées par l'héritage
    set table_mere [dict get $heritage "mere"]
    set xml "$xml\t\t<table_mere>$table_mere</table_mere>\n\t\t<tables_filles>\n"
    set filles [dict get $heritage "filles"]
    foreach {k fille} $filles {
        set xml "$xml\t\t\t<fille id=$k>$fille</fille>\n"
    }
    set xml "$xml\t\t</tables_filles>\n"
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
    set xml "$xml\t\t<coords>$x/$y</coords>\n\t</heritage>\n"
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
# Enregistre toutes les données dans un fichier au format XML
##
proc Katyusha_Sauvegarde {} {
    global MCD
    global LOCALE
    global tables
    global relations
    global heritages
    global etiquettes
    global fichier_sauvegarde
    global version
    global rep_configs
    
    set xml ""
    # En tête XML
    set xml "$xml<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<katyusha>\n\t<version>$version</version>\n</katyusha>\n"
    # Enregistrement des configurations de la base
    set xml "$xml[Katyusha_Sauvegarde_base]"
    # Enregistrement des tables
    set xml "$xml[Katyusha_Sauvegarde_tables $tables]"
    # Enregistrement des relations
    set xml "$xml[Katyusha_Sauvegarde_relations $relations]"
    # Enregistrement des etiquettes
    set xml "$xml[Katyusha_Sauvegarde_etiquettes $etiquettes]"
    # Enregistrement des héritages
    set xml "$xml[Katyusha_Sauvegarde_heritages $heritages]"
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
    
    puts "$LOCALE(mcd_sauv_sous)$fichier_sauvegarde"
    # Met à jour les dictionnaires de sauvegarde
    Katyusha_MAJ_SC
}
