## Créé le 18/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
#
##
proc Katyusha_Configurations_liste_elements_config {} {
    return [list "LANG" "RESOLUTION" "STATS" "NOM_BDD_DEFAUT" "SGBD_DEFAUT" "DROP_DEFAUT" "TAILLE_CANVAS" "REP_PROJETS_DEFAUT" "COULEUR_FOND_RELATION_DEFAUT" "COULEUR_LIENS_RELATION_DEFAUT" "COULEUR_LIGNE_RELATION_DEFAUT" "COULEUR_TEXTE_RELATION_DEFAUT" "COULEUR_FOND_TETE_TABLE_DEFAUT" "COULEUR_FOND_CORPS_TABLE_DEFAUT" "COULEUR_LIGNE_TABLE_DEFAUT" "COULEUR_TEXTE_TABLE_DEFAUT" "COULEUR_FOND_ETIQUETTE_DEFAUT" "COULEUR_LIGNE_ETIQUETTE_DEFAUT" "COULEUR_TEXTE_ETIQUETTE_DEFAUT" "COULEUR_FOND_HERITAGE_DEFAUT" "COULEUR_LIGNE_HERITAGE_DEFAUT" "COULEUR_TEXTE_HERITAGE_DEFAUT" "COULEUR_LIENS_HERITAGE_DEFAUT" "AFFICHAGE_OBJETS"]
}

proc Katyusha_Configurations_couleurs {couleur} {
    global THEME
    return ["ttk\:\:theme\:\:$THEME\:\:color" $couleur]
}

##
# Initialisation des configurations
##
proc Katyusha_Configurations_init {} {
    global rep_configs
    global rpr
    global nom_script
    global rep_mcd
    
    ##
    # Créé les répertoires de configuration s'il n'existent pas
    ##
    if {![file exists "~/.phosphore"]} {
        file mkdir "~/.phosphore"
    }
    if {![file exists $rep_configs]} {
        file mkdir $rep_configs
    }
    # Copie le fichier par défaut si le fichier de configuration n'existe pas
    if {![file exists "$rep_configs/katyusha.conf"]} {
        file copy "$rpr/configs/defaut.conf" "$rep_configs/katyusha.conf"
    }
    if {![file exists "$rep_configs/recents"]} {
        file copy "$rpr/configs/recents" "$rep_configs/recents"
    }
    
    # Répertoire par défaut des projets Katyusha! MCD
    set rep_mcd "~/Documents/Katyusha_projets"
    # Si il n'existe pas, le créer
    if {![file exists $rep_mcd]} {
        file mkdir $rep_mcd
    }
    # Nom par défaut du script SQL généré
    set id_script [llength [glob -nocomplain -dir $rep_mcd "projet*.sql"]]
    set nom_script "projet$id_script.sql"
}

proc Katyusha_Configurations_charge_config {fichier} {
    set configs [dict create]
    # Ouvre le fichier en lecture
    set fp [open $fichier "r"]
    set stream [read $fp]
    close $fp
    # Balyage des lignes
    foreach ligne [split $stream "\n"] {
        set clef [lindex [split $ligne ":"] 0]
        set valeur [lindex [split $ligne ":"] 1]
        dict set configs $clef $valeur
    }
    return $configs
}

proc Katyusha_Configurations_charge {rep_main rep_configs} {
    global CONFIGS
    global MCD
    # Charge les configurations du fichier local et du fichier pa défaut
    set conf_loc [Katyusha_Configurations_charge_config "$rep_configs/katyusha.conf"]
    set conf_defaut [Katyusha_Configurations_charge_config "$rep_main/configs/defaut.conf"]
    # Compare et prends les élément de configuration par défaut si ils n'existent pas en local
    foreach {k v} $conf_defaut {
		if {[dict exists $conf_loc $k] != 1} {
			dict set conf_loc $k $v
		}
	}
	
	foreach {k v} $conf_loc {
		set CONFIGS($k) $v
	}
	
    set MCD(nom) $CONFIGS(NOM_BDD_DEFAUT)
    set MCD(sgbd) $CONFIGS(SGBD_DEFAUT)
    set MCD(drop) $CONFIGS(DROP_DEFAUT)
    set MCD(rep) $CONFIGS(REP_PROJETS_DEFAUT)
    # Couleurs
    set MCD(couleur_fond_relation) $CONFIGS(COULEUR_FOND_RELATION_DEFAUT)
    set MCD(couleur_liens_relation) $CONFIGS(COULEUR_LIENS_RELATION_DEFAUT)
    set MCD(couleur_ligne_relation) $CONFIGS(COULEUR_LIGNE_RELATION_DEFAUT)
    set MCD(couleur_texte_relation) $CONFIGS(COULEUR_TEXTE_RELATION_DEFAUT)
    set MCD(couleur_fond_tete_table) $CONFIGS(COULEUR_FOND_TETE_TABLE_DEFAUT)
    set MCD(couleur_fond_corps_table) $CONFIGS(COULEUR_FOND_CORPS_TABLE_DEFAUT)
    set MCD(couleur_ligne_table) $CONFIGS(COULEUR_LIGNE_TABLE_DEFAUT)
    set MCD(couleur_texte_table) $CONFIGS(COULEUR_TEXTE_TABLE_DEFAUT)
    set MCD(couleur_fond_etiquette) $CONFIGS(COULEUR_FOND_ETIQUETTE_DEFAUT)
    set MCD(couleur_texte_etiquette) $CONFIGS(COULEUR_TEXTE_ETIQUETTE_DEFAUT)
    set MCD(couleur_ligne_etiquette) $CONFIGS(COULEUR_LIGNE_ETIQUETTE_DEFAUT)
    set MCD(couleur_fond_heritage) $CONFIGS(COULEUR_FOND_HERITAGE_DEFAUT)
    set MCD(couleur_texte_heritage) $CONFIGS(COULEUR_TEXTE_HERITAGE_DEFAUT)
    set MCD(couleur_ligne_heritage) $CONFIGS(COULEUR_LIGNE_HERITAGE_DEFAUT)
    set MCD(couleur_liens_heritage) $CONFIGS(COULEUR_LIENS_HERITAGE_DEFAUT)
    set CONFIGS(AFFICHAGE_OBJETS) [split $CONFIGS(AFFICHAGE_OBJETS) " "]
    
    Katyusha_Configurations_sauve $CONFIGS(LANG)
}

proc Katyusha_Configurations_packages {} {
    set noms [dict create "TDBC" "tdbc"]
    foreach {k v} $noms {
        Katyusha_Configurations_package $k $v
    }
}

proc Katyusha_Configurations_package {nom nom_tcl} {
    puts -nonewline "..............$nom"
    if {[catch {package require $nom_tcl}]} {
        puts " # KO"
    } else {
        puts " # OK!"
    }
}

proc Katyusha_Configurations_resolution {} {
    global CONFIGS
    
    # Si la résolution est en mode automatique
    if {$CONFIGS(RESOLUTION) == "auto"} {
        # On récupère la taille de l'écran
        set x [winfo screenwidth .]
        set y [winfo screenheight .]
        set y [expr $y - 80]
    } else {
        set x [lindex [split $CONFIGS(RESOLUTION) "x"] 0]
        set y [lindex [split $CONFIGS(RESOLUTION) "x"] 1]
    }
    return [list $x $y]
}

##
# Retourne une liste des langues disponibles
##
proc Katyusha_Configurations_liste_langues {} {
    global rpr
    
    #set liste_langues [list]
    #set langues [glob -nocomplain -dir "$rpr/locale" "*.tcl"]
    #foreach langue $langues {
    #    set nom_fichier [lindex [split $langue "/"] 2]
    #    set code_langue [lindex [split $nom_fichier "."] 0]
    #    set fp [open $langue "r"]
    #    set contenu_fichier [read $fp]
    #    close $fp
    #    set premiere_ligne [lindex [split $contenu_fichier "\n"] 0]
    #    set nom_langue [lindex [split $premiere_ligne " "] 1]
    #    lappend liste_langues "$code_langue - $nom_langue"
    #}
    set liste_langues [list "fr - Français" "de - Deutsch" "en - English"]
    return $liste_langues
}

##
# Retourne le nom de la langue selon son code
##
proc Katyusha_Configurations_langue_code {code} {
    global rpr
    
    if {[file exists "$rpr/locale/$code.po"]} {
        set langue "$rpr/locale/$code.po"
    } else {
        set langue "$rpr/locale/fr.po"
    }
    set fp [open $langue "r"]
    set contenu_fichier [read $fp]
    close $fp
    set premiere_ligne [lindex [split $contenu_fichier "\n"] 0]
    set nom_langue [lindex [split $premiere_ligne " "] 1]
    return $nom_langue
}

##
# Enregistre les nouveaux paramètres de la base de données, ils doivent avoir été contrôlés avant
##
proc Katyusha_Configurations_MCD {nom liste_sgbd drop_base} {
    global MCD
    global fichier_sauvegarde
    
    # Nom
    if {$nom != $MCD(nom) && $nom != ""} {
        set MCD(nom) $nom
    }
    # Liste des SGBD
    if {[lindex $liste_sgbd 0] != ""} {
        set MCD(sgbd) $liste_sgbd
    }
    # Drop?
    if {$drop_base != $MCD(drop) && $drop_base != ""} {
        set MCD(drop) $drop_base
    }
    if {![file exists "$MCD(rep)/$MCD(nom)"]} {
        set fichier_sauvegarde "$MCD(rep)/$MCD(nom).mcd"
        Katyusha_sauvegarder
    } else {
        set c 1
        while {![file exists "$MCD(rep)/$MCD(nom)$c"]} {
            set fichier_sauvegarde "$MCD(rep)/$MCD(nom).mcd"
            Katyusha_sauvegarder
            set c [expr $c + 1]
        }
    }
}

##
# Enregistre les préférences de Katyusha MCD
##
proc Katyusha_Configurations_sauve {langue {maj_canvas 0}} {
    global CONFIGS
    global rep_configs
    global E_conf_att_nom
    global E_conf_att_type
    global E_conf_att_null
    global E_conf_att_defaut
    global E_conf_att_taille
    
    set CONFIGS(LANG) [lindex [split $langue " - "] 0]
    set conf ""
    
    foreach element [Katyusha_Configurations_liste_elements_config] {
        set conf "$conf$element:$CONFIGS($element)\n"
    }
	

	
    set tmp ""
    foreach el $CONFIGS(AFFICHAGE_OBJETS) {
        if {$tmp == ""} {
            set tmp "AFFICHAGE_OBJETS:$el"
        } else {
            set tmp "$tmp\ $el"
        }
    }
	
    set conf "LANG:$CONFIGS(LANG)\nRESOLUTION:$CONFIGS(RESOLUTION)\nSTATS:$CONFIGS(STATS)\nNOM_BDD_DEFAUT:$CONFIGS(NOM_BDD_DEFAUT)\nSGBD_DEFAUT:$CONFIGS(SGBD_DEFAUT)\nDROP_DEFAUT:$CONFIGS(DROP_DEFAUT)\nTAILLE_CANVAS:$CONFIGS(TAILLE_CANVAS)\n$tmp"
    
    # Ouvre le fichier en écriture
    set fp [open "$rep_configs/katyusha.conf" "w+"]
    set stream [read $fp]
    puts $fp $conf
    close $fp
    
    if {$maj_canvas == 1} {
        # Met à jour le canvas
        Katyusha_MCD_canvas_effacer
        # Mise à jour graphique des entités
        maj_tables
        Katyusha_Relations_maj
        Katyusha_Relations_MAJ_lignes_relations
        Katyusha_Etiquettes_maj
        Katyusha_Heritages_maj
        Katyusha_MAJ_SC
        Katyusha_Historique_maj
    }
}
