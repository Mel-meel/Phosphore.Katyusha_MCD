## Créé le 4/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################


##
# Donne simplement le chemin du fichier à charger
##
proc Katyusha_charger {} {
    global rep_mcd
    
    set fichier [tk_getOpenFile -initialdir $rep_mcd]
    if {$fichier != ""} {
        Katyusha_Charge $fichier
    }
}

##
# Récupère les données d'une balise
##
proc Katyusha_Charge_balise {balise ligne} {
    set res [string range $ligne [expr [string first "<$balise>" $ligne] + ([string length $balise] + 2)] [expr [string first "</$balise>" $ligne] - 1]]
    return $res
}

##
# Bloc des couleurs
##
proc Katyusha_Charge_bloc_couleurs {bloc} {
    set couleurs [dict create]
    set lignes [split $bloc "\n"]
    foreach ligne $lignes {
        if {[string first "<" $ligne] >= 0} {
            set debut [string first "<" $ligne]
            set fin [string first ">" $ligne $debut]
            set balise [string range $ligne [expr $debut + 1] [expr $fin - 1]]
            set couleur [Katyusha_Charge_balise $balise $bloc]
            dict set couleurs $balise $couleur
        }
    }
    
    return $couleurs
}

##
# Bloc de coordonnées, commun à tout le monde
##
proc Katyusha_Charge_bloc_coords {bloc} {
    set res [list]
    set coords [Katyusha_Charge_balise "coords" $bloc]
    set x [lindex [split $coords "/"] 0]
    set y [lindex [split $coords "/"] 1]
    set res [list $x $y]
    return $res
}

##
# Balaye et enregistre tous les attributs d'une entitée (table ou relation) dans un dictionnaire
##
proc Katyusha_Charge_attributs_entite {bloc_attributs} {
    set liste_attributs [dict create]
    # Balayage des attributs
    set debut 0
    while {[string first "<attribut " $bloc_attributs $debut] != -1} {
        set dict_attribut [dict create]
        set debut_attribut [string first "<attribut " $bloc_attributs $debut]
        set fin_attribut [string first "</attribut>" $bloc_attributs $debut_attribut]
        set attribut [string range $bloc_attributs [expr $debut_attribut + 10] [expr $fin_attribut - 1]]
        set id_attribut [string range $attribut 3 [expr [string first ">" $attribut] - 1]]
        foreach att [list "nom" "type" "complement_type" "taille" "pk" "auto" "valeur" "null" "description"] {
            if {$att == "auto"} {
                set att2 "auto_increment"
            } else {
                set att2 $att
            }
            dict set dict_attribut $att [Katyusha_Charge_balise $att2 $attribut]
        }
        dict set liste_attributs $id_attribut $dict_attribut
        set fin [expr $fin_attribut + 1]
        set debut $fin
    }
    return $liste_attributs
}

##
# Renvoie la table construite à partir de son code XML
##
proc Katyusha_Charge_table {xml version} {
    global ID
    global MCD
    
    set table [Katyusha_Tables_init_table]
    set id_table [string range $xml [expr [string first "<table " $xml] + 10] [expr [string first ">" $xml] - 1]]
    set id_table [expr $id_table + 0]
    # Ajoute le nom à la table
    set nom_table [Katyusha_Charge_balise "nom" $xml]
    dict set table "nom" $nom_table
    # Récupère les coordonnées de l'affichage graphique de la table
    dict set table "coords" [Katyusha_Charge_bloc_coords $xml]
    # Bloc des attributs
    set bloc_attributs [string range $xml [expr [string first "<attributs>" $xml] + 11] [expr [string first "</attributs>" $xml] - 1]]
    dict set table "attributs" [Katyusha_Charge_attributs_entite $bloc_attributs]
    # Si le bloc couleurs existe
    if {[string first "<couleurs" $xml] >= 0 && [Katyusha_compare_versions $version "0.2.5"] == 1} {
        set bloc_couleurs [string range $xml [expr [string first "<couleurs>" $xml] + 10] [expr [string first "</couleurs>" $xml] - 1]]
        if {[string first "<" $bloc_couleurs] >= 0} {
            dict set table "couleurs" [Katyusha_Charge_bloc_couleurs $bloc_couleurs]
        } else {
            dict set table "couleurs" [dict create "fond_tete" $MCD(couleur_fond_tete_table) "ligne" $MCD(couleur_ligne_table) "fond_corps" $MCD(couleur_fond_corps_table) "texte" $MCD(couleur_texte_table)]
        }
    } else {
        dict set table "couleurs" [dict create "fond_tete" $MCD(couleur_fond_tete_table) "ligne" $MCD(couleur_ligne_table) "fond_corps" $MCD(couleur_fond_corps_table) "texte" $MCD(couleur_texte_table)]
    }
    dict set table "description" [string range $xml [expr [string first "<description>" $xml] + 13] [expr [string first "</description>" $xml] - 1]]
    
    # Met à jour l'ID général
    if {$id_table > $ID} {
        set ID $id_table
    }
    
    return [list $id_table $table]
}

##
# Retourne un dictionnaire contenant toutes les tables du fichier chargé
##
proc Katyusha_Charge_tables {xml version} {
    set tables [dict create]
    set debut 0
    # Balayage du XML et découpe par blocs d'une table
    while {[string first "<table" $xml $debut] != -1} {
        set debut_bloc_table [string first "<table" $xml $debut]
        set fin_bloc_table [string first "</table>" $xml $debut_bloc_table]
        # Découpe le bloc XML correspondant à une table
        set bloc_table [string range $xml $debut_bloc_table [expr $fin_bloc_table + 8]]
        # Traite le bloc XML de la table
        set table_tmp [Katyusha_Charge_table $bloc_table $version]
        # Ajoute la table traitée aux autres tables
        dict set tables [lindex $table_tmp 0] [lindex $table_tmp 1]
        set debut [expr $fin_bloc_table + 1]
    }
    # Renvoie le dictionnaire contenant touts les tables correctements formatées
    return $tables
}

proc Katyusha_Charge_liens_relation {xml} {
    set liens [dict create]
    set debut 0
    # Balayage du XML et découpe par blocs d'un lien
    while {[string first "<lien " $xml $debut] != -1} {
        set debut_bloc_lien [string first "<lien " $xml $debut]
        set fin_bloc_lien [string first "</lien>" $xml $debut_bloc_lien]
        set bloc_lien [string range $xml $debut_bloc_lien [expr $fin_bloc_lien + 3]]
        set id_lien [string range $bloc_lien [expr [string first "id=" $bloc_lien 0] + 3] [expr [string first ">" $bloc_lien 0] - 1]]
        set table_lien [Katyusha_Charge_balise "table_lien" $bloc_lien]
        set type_lien [Katyusha_Charge_balise "n_lien" $bloc_lien]
        set relatif_lien [Katyusha_Charge_balise "relatif" $bloc_lien]
        dict set liens $id_lien [list $table_lien $type_lien $relatif_lien]
        unset bloc_lien id_lien table_lien type_lien
        set debut $fin_bloc_lien
    }
    return $liens
}

##
# Renvoie la relation construite à partir de son code XML
##
proc Katyusha_Charge_relation {xml version} {
    global ID
    global MCD
    
    set relation [Katyusha_Relations_init_relation]
    set id_relation [string range $xml [expr [string first "<relation " $xml] + 13] [expr [string first ">" $xml] - 1]]
    # Ajoute le nom à la relation
    set nom_relation [Katyusha_Charge_balise "nom" $xml]
    dict set relation "nom" $nom_relation
    # Récupère les coordonnées de l'affichage graphique de la relation
    dict set relation "coords" [Katyusha_Charge_bloc_coords $xml]
    # Isole le bloc des liens
    set debut_bloc_lien [string first "<liens>" $xml 0]
    set fin_bloc_lien [string first "</liens>" $xml $debut_bloc_lien]
    set bloc_liens [string range $xml [expr $debut_bloc_lien + 8] [expr $fin_bloc_lien - 2]]
    dict set relation "liens" [Katyusha_Charge_liens_relation $bloc_liens]
    set bloc_attributs [string range $xml [expr [string first "<attributs>" $xml] + 11] [expr [string first "</attributs>" $xml] - 1]]
    dict set relation "attributs" [Katyusha_Charge_attributs_entite $bloc_attributs]
    # Si le bloc couleurs existe
    if {[string first "<couleurs" $xml] >= 0 && [Katyusha_compare_versions $version "0.2.5"] == 1} {
        set bloc_couleurs [string range $xml [expr [string first "<couleurs>" $xml] + 10] [expr [string first "</couleurs>" $xml] - 1]]
        if {[string first "<" $bloc_couleurs] >= 0} {
            dict set relation "couleurs" [Katyusha_Charge_bloc_couleurs $bloc_couleurs]
        } else {
            dict set relation "couleurs" [dict create "fond" $MCD(couleur_fond_relation) "ligne" $MCD(couleur_ligne_relation) "liens" $MCD(couleur_liens_relation) "texte" $MCD(couleur_texte_relation)]
        }
    } else {
        dict set relation "couleurs" [dict create "fond" $MCD(couleur_fond_relation) "ligne" $MCD(couleur_ligne_relation) "liens" $MCD(couleur_liens_relation) "texte" $MCD(couleur_texte_relation)]
    }
    dict set relation "description" [string range $xml [expr [string first "<description>" $xml] + 8] [expr [string first "</description>" $xml] - 1]]
    
    # Met à jour l'ID général
    if {$id_relation > $ID} {
        set ID $id_relation
    }
    
    return [list $id_relation $relation]
}

##
# Retourne un dictionnaire contenant toutes les relations du fichier chargé
##
proc Katyusha_Charge_relations {xml version} {
    set relations [dict create]
    set debut 0
    # Balayage du XML et découpe par blocs d'une relation
    while {[string first "<relation" $xml $debut] != -1} {
        set debut_bloc_relation [string first "<relation" $xml $debut]
        set fin_bloc_relation [string first "</relation>" $xml $debut_bloc_relation]
        # Découpe le bloc XML correspondant à une relation
        set bloc_relation [string range $xml $debut_bloc_relation [expr $fin_bloc_relation + 8]]
        # Traite le bloc XML de la relation
        set relation_tmp [Katyusha_Charge_relation $bloc_relation $version]
        # Ajoute la relation traitée aux autres relations
        dict set relations [lindex $relation_tmp 0] [lindex $relation_tmp 1]
        set debut [expr $fin_bloc_relation + 1]
    }
    # Renvoie le dictionnaire contenant toutes les relations correctements formatées
    return $relations
}

proc Katyusha_Charge_etiquette {xml version} {
    global ID
    global MCD
    
    set etiquette [dict create]
    # ID de l'étiquette
    set id_etiquette [string range $xml [expr [string first "<etiquette " $xml] + 14] [expr [string first ">" $xml] - 1]]
    dict set etiquette "nom" [Katyusha_Charge_balise "nom" $xml]
    dict set etiquette "texte" [Katyusha_Charge_balise "texte" $xml]
    # Si le bloc couleurs existe
    if {[string first "<couleurs" $xml] >= 0} {
        set bloc_couleurs [string range $xml [expr [string first "<couleurs>" $xml] + 10] [expr [string first "</couleurs>" $xml] - 1]]
        if {[string first "<" $bloc_couleurs] >= 0 && [Katyusha_compare_versions $version "0.2.5"] == 1} {
            dict set etiquette "couleurs" [Katyusha_Charge_bloc_couleurs $bloc_couleurs]
        } else {
            dict set etiquette "couleurs" [dict create "fond" $MCD(couleur_fond_etiquette) "ligne" $MCD(couleur_ligne_etiquette) "texte" $MCD(couleur_texte_etiquette)]
        }
    } else {
        dict set etiquette "couleurs" [dict create "fond" $MCD(couleur_fond_etiquette) "ligne" $MCD(couleur_ligne_etiquette) "texte" $MCD(couleur_texte_etiquette)]
    }
    # Récupère les coordonnées de l'affichage graphique de l'étiquette
    dict set etiquette "coords" [Katyusha_Charge_bloc_coords $xml]
    
    # Met à jour l'ID général
    if {$id_etiquette > $ID} {
        set ID $id_etiquette
    }
    
    return [list $id_etiquette $etiquette]
}

##
# Retourne un dictionnaire de toutes les étiquettes
##
proc Katyusha_Charge_etiquettes {xml version} {
    set etiquettes [dict create]
    set debut 0
    # Balayage du XML et découpe par blocs d'une étiquette
    while {[string first "<etiquette" $xml $debut] != -1} {
        set debut_bloc_etiquette [string first "<etiquette" $xml $debut]
        set fin_bloc_etiquette [string first "</etiquette>" $xml $debut_bloc_etiquette]
        # Découpe le bloc XML correspondant à une étiquette
        set bloc_etiquette [string range $xml $debut_bloc_etiquette [expr $fin_bloc_etiquette + 8]]
        # Traite le bloc XML de l'étiquette
        set etiquette_tmp [Katyusha_Charge_etiquette $bloc_etiquette $version]
        # Ajoute l'étiquette traitée aux autres etiquettes
        dict set etiquettes [lindex $etiquette_tmp 0] [lindex $etiquette_tmp 1]
        set debut [expr $fin_bloc_etiquette + 1]
    }
    return $etiquettes
}

proc Katyusha_Charge_heritage {xml version} {
    global ID
    global MCD
    
    set heritage [dict create]
    # ID de l'étiquette
    set id_heritage [string range $xml [expr [string first "<heritage " $xml] + 13] [expr [string first ">" $xml] - 1]]
    dict set heritage "mere" [Katyusha_Charge_balise "table_mere" $xml]
    # Récupère toutes les tables filles
    set filles [dict create]
    set debut 0
    # Charge le bloc XML des tables filles
    set bloc_filles [Katyusha_Charge_bloc_entite $xml "tables_filles"]
    # Balayage des tables filles
    while {[string first "<fille " $bloc_filles $debut] != -1} {
        set debut_fille [string first "<fille " $bloc_filles $debut]
        set fin_fille [string first "</fille>" $bloc_filles $debut]
        # Ligne XML de la fille
        set xml_fille [string range $bloc_filles $debut_fille $fin_fille]
        # ID de la fille
        set id_fille [string range $xml_fille [expr [string first "id" $xml_fille] + 3] [expr [string first ">" $xml_fille] - 1]]
        set fille [string range $xml_fille [expr [string first ">" $xml_fille] + 1] [expr [string length $xml_fille] - 2]]
        # Ajoute au dictionnaire des tables filles
        dict set filles $id_fille $fille
        set debut [expr $fin_fille + 1]
    }
    dict set heritage "filles" $filles
    # Récupère la contrainte de l'héritage
    dict set heritage "contrainte" [Katyusha_Charge_balise "contrainte" $xml]
    # Si le bloc couleurs existe
    if {[string first "<couleurs" $xml] >= 0 && [Katyusha_compare_versions $version "0.2.5"] == 1} {
        set bloc_couleurs [string range $xml [expr [string first "<couleurs>" $xml] + 10] [expr [string first "</couleurs>" $xml] - 1]]
        if {[string first "<" $bloc_couleurs] >= 0} {
            dict set heritage "couleurs" [Katyusha_Charge_bloc_couleurs $bloc_couleurs]
        } else {
            dict set heritage "couleurs" [dict create "fond" $MCD(couleur_fond_heritage) "ligne" $MCD(couleur_ligne_heritage) "liens" $MCD(couleur_liens_heritage) "texte" $MCD(couleur_texte_heritage)]
        }
    } else {
        dict set heritage "couleurs" [dict create "fond" $MCD(couleur_fond_heritage) "ligne" $MCD(couleur_ligne_heritage) "liens" $MCD(couleur_liens_heritage) "texte" $MCD(couleur_texte_heritage)]
    }
    # Récupère les coordonnées de l'affichage graphique de l'étiquette
    dict set heritage "coords" [Katyusha_Charge_bloc_coords $xml]
    
    # Met à jour l'ID général
    if {$id_heritage > $ID} {
        set ID $id_heritage
    }
    
    return [list $id_heritage $heritage]
}

##
# Retourne un dictionnaire de tous les héritage
##
proc Katyusha_Charge_heritages {xml version} {
    set heritages [dict create]
    set debut 0
    # Balayage du XML et découpe par blocs d'un héritage
    while {[string first "<heritage" $xml $debut] != -1} {
        set debut_bloc_heritage [string first "<heritage" $xml $debut]
        set fin_bloc_heritage [string first "</heritage>" $xml $debut_bloc_heritage]
        # Découpe le bloc XML correspondant à un héritage
        set bloc_heritage [string range $xml $debut_bloc_heritage [expr $fin_bloc_heritage + 8]]
        # Traite le bloc XML de l'héritage
        set heritage_tmp [Katyusha_Charge_heritage $bloc_heritage $version]
        # Ajoute l'héritage traitée aux autres héritages
        dict set heritages [lindex $heritage_tmp 0] [lindex $heritage_tmp 1]
        set debut [expr $fin_bloc_heritage + 1]
    }
    return $heritages
}

##
# Isole le bloc XML d'un type d'entité donnée
##
proc Katyusha_Charge_bloc_entite {xml entite} {
    set bloc ""
    set debut_bloc [string first "<$entite>" $xml]
    set fin_bloc [string first "</$entite>" $xml]
    set bloc [string range $xml [expr $debut_bloc + [string length "<$entite>"]] [expr $fin_bloc - 1]]
    return $bloc
}

##
# Construit le MCD à partir du fichier charger
# TODO : contrôle de la version du logiciel pour vérifier la compatibilité du fichier chargé
##
proc Katyusha_Charge {fichier} {
    global MCD
    global tables
    global relations
    global etiquettes
    global heritages
    global ID
    global fichier_sauvegarde
    global version
    
    # Ouvre le fichier de sauvegarde
    set stream [file_read $fichier "r"]
    # Vérifie l'intégrité du fichier XML
    if {[Katyusha_Charge_XML_verif $stream] == 1} {
        set ok "yes"
    } else {
        set ok [tk_messageBox -message "Le fichier n'est pas correcte.\nLe charger quand même?" -type yesno -icon warning]
    }
    if {$ok == "yes"} {
        # Réinitialise le MCD avant des créer les entités, associations, ...
        Katyusha_MCD_nouveau
        set fichier_sauvegarde $fichier
        set MCD(rep) [file dirname $fichier_sauvegarde]
        .infos.fichier configure -text $fichier_sauvegarde
        # Nettoie le fichier
        set stream [string map [list "\t" ""] $stream]
        # Version de Katyusha! qui à enregistré le fichier
        set version_a [Katyusha_Charge_balise "version" $stream]
        # Découpe le fichier en plusieurs parties :
        #       Entités
        #       Associations
        #       Étiquettes
        #       Héritages
        # Entités
        set bloc_tables [Katyusha_Charge_bloc_entite $stream "tables"]
        set tables [Katyusha_Charge_tables $bloc_tables $version_a]
        # Associations
        set bloc_relations [Katyusha_Charge_bloc_entite $stream "relations"]
        set relations [Katyusha_Charge_relations $bloc_relations $version_a]
        # Étiquettes
        set bloc_etiquettes [Katyusha_Charge_bloc_entite $stream "etiquettes"]
        set etiquettes [Katyusha_Charge_etiquettes $bloc_etiquettes $version_a]
        # Héritages
        set bloc_heritages [Katyusha_Charge_bloc_entite $stream "heritages"]
        set heritages [Katyusha_Charge_heritages $bloc_heritages $version_a]
        # Mise à jour graphique des objets
        maj_tables
        Katyusha_Relations_maj
        Katyusha_Relations_MAJ_lignes_relations
        Katyusha_Etiquettes_maj
        Katyusha_Heritages_maj
        Katyusha_MAJ_SC
        Katyusha_Historique_maj
        set ID [expr $ID + 1]
    }
}

proc Katyusha_Charge_XML_verif {xml} {
    # Vérifie s'il y a du contenu hors balises
    # TODO
    # Si il y a des entités
    if {[string first "<tables>" $xml] != -1 && [string first "</tables>" $xml] != -1} {
        set bloc_tables [Katyusha_Charge_bloc_entite $xml "tables"]
    }
    set ok 1
    return $ok
}
