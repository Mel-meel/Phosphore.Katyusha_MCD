## Créé le 2/3/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

###############################################################################
#                                                                             #
#   Fonctions ne générant pas d'affichage graphique, ou un affichage          #
#   sur le canvas principal                                                   #
#                                                                             #
###############################################################################

proc lremove {liste quoi} {
    return [lsearch -all -inline -not -exact $liste $quoi]
}

proc Katyusha_action_boutons_ajout {entite_select} {
    global ACTION_B1
    
    set entites [list "table" "relation" "etiquette"]
    
    if {$ACTION_B1 == "ajout_$entite_select"} {
        set ACTION_B1 "null"
        .panel.commandes.ajout_$entite_select configure -relief raised
    } else {
        set ACTION_B1 "ajout_$entite_select"
        .panel.commandes.ajout_$entite_select configure -relief sunken
    }
    foreach entite $entites {
        if {$entite != $entite_select} {
            .panel.commandes.ajout_$entite configure -relief raised
        }
    }
}

##
# Remet sur off tous les boutons de commande
##
proc Katyusha_boutons_ajout_off {} {
    global ACTION_B1
    foreach bouton [list "ajout_table" "ajout_relation" "ajout_etiquette" "ajout_heritage"] {
        .panel.commandes.$bouton configure -relief raised
    }
    set ACTION_B1 "null"
}

##
# Renvoie une liste contenant tous les SGBD dont Katyusha (merveilleux programme) peut générer un code SQL
##
proc liste_sgbd {} {
    return [list "mysql" "sqlite3" "postgres" "sqlserver" "oracle"]
}

##
# Renvoie une liste contenant tous les SGBD disponibles selon les modules installés
##
proc liste_sgbd_dispo {} {
    set liste_sgdb {}
    
    # SQLite 3
    if {![catch {package require tdbc::sqlite3}]} {
        lappend liste_sgbd "sqlite3"
    }
    # MySQL
    if {![catch {package require tdbc::mysql}]} {
        lappend liste_sgbd "mysql"
    }
    # Postgre
    if {![catch {package require tdbc::postgre}]} {
        lappend liste_sgbd "postregsql"
    }
    # ODBC
    if {![catch {package require tdbc::odbc}]} {
        lappend liste_sgbd "odbc"
    }
    
    return $liste_sgbd
}

##
# Retourne une liste des tables pour les comboboxs
##
proc liste_tables {} {
    global tables
    # Si il y a au moins deux tables
    #if {[dict size $tables] >= $min} {
        foreach {k v} $tables {
            set nom [dict get $v "nom"]
            lappend liste_tables "$nom"
        }
    #} else {
    #    set liste_tables [list]
    #}
    return $liste_tables
}

##
# Création de la grille du canvas
##
proc Katyusha_grille {} {
    global canvas_x
    global canvas_y
    global CONFIGS

    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    # Lignes en X
    set dx 0
    set c 0
    while {$dx < [expr $xbcanvas + 1000]} {
        if {$c == 100} {
            set c 0
            set couleur "#A6A6A6"
        } else {
            set c [expr $c + 10]
            set couleur "#DDDDDD"
        }
        set dx [expr $dx + 10]
        .mcd.canvas.c create line $dx 0 $dx [expr $xbcanvas + 1000] -fill $couleur -tag "grille"
        update
    }
    # Lignes en Y
    set dy 0
    set c 0
    while {$dy < [expr $ybcanvas + 1000]} {
        if {$c == 100} {
            set c 0
            set couleur "#A6A6A6"
        } else {
            set c [expr $c + 10]
            set couleur "#DDDDDD"
        }
        set dy [expr $dy + 10]
        .mcd.canvas.c create line 0 $dy [expr $ybcanvas + 1000] $dy -fill $couleur -tag "grille"
        update
    }
}

# Ouvre un fichier
proc file_read {fichier acces} {
    if {[file exists $fichier]} {
        set fp [open $fichier $acces]
        set file_data [read $fp]
        close $fp
    } else {
        set file_data "Aucun fichier de ce nom : $fichier"
    }
    return $file_data
}

##
# Controle si une chaine n'est pas une commande SQL et donc interdit
# Retourne 0 si le mot n'est pas interdit
# 1 sinon
##
proc Katyusha_controle_noms_interdits {$chaine} {
    set chaine [string tolower $chaine]
    set res 0
    set noms_interdits [list "create" "database" "table" "vue" "primary" "key" "text" "int" "bigint" "tinyint" "varchar" "char"]
    foreach nom $noms_interdits {
        if {$chaine == $nom} {
            set res 1
        }
    }
    return $res
}

##
# Retourne la liste des projets récements ouverts
##
proc Katyusha_fichiers_recents {} {
    global rep_configs
    
    set fichier "$rep_configs/recents"
    set contenu [file_read $fichier "r"]
    set lignes [lreverse [split $contenu "\n"]]
    
    return $lignes
}

##
# Réinitialise la liste des projets récement ouverts
##
proc Katyusha_projets_recents_init {} {
    global rep_configs
    global rpr
    
    file delete "$rep_configs/recents"
    file copy "$rpr/configs/recents" "$rep_configs/recents"
}

proc hyperlink { name args } {
  if { "Underline-Font" ni [ font names ] } {
    font create Underline-Font {*}[ font actual TkDefaultFont ]
    font configure Underline-Font -underline true -size 12
  }
  if { [ dict exists $args -command ] } {
    set command [ dict get $args -command ]
    dict unset args -command
  }
  label $name {*}$args -foreground blue -font Underline-Font
  if { [ info exists command ] } {
    bind $name <Button-1> $command
  }
  return $name
}

##
# Zoom avant
##
proc Katyusha_zoom_plus {} {
    global zoom_compteur
    
    set zoom_compteur [expr $zoom_compteur + 1]
    .mcd.canvas.c scale all 0 0 1.1 1.1
}

##
# Zoom_arriere
##
proc Katyusha_zoom_moins {} {
    global zoom_compteur
    
    set zoom_compteur [expr $zoom_compteur - 1]
    .mcd.canvas.c scale all 0 0 0.9 0.9
}

##
# Retour au zoom initial
##
proc Katyusha_zoom_initial {} {
    global zoom_compteur
    set n [expr abs($zoom_compteur)]
    
    if {$n > 0} {
        for {set c 0} {$c < $n} {incr c} {
            if {$zoom_compteur < 0} {
                Katyusha_zoom_plus
            } else {
                Katyusha_zoom_moins
            }
        }
    }
}

proc Dict_dernier_id {d} {
    set ids [dict keys $d]
    return [lindex $ids [expr [llength $ids] - 1]]
}

proc Katyusha_compare_versions {v1 v2} {
    set res 0
    set v1 [split $v1 "."]
    set v2 [split $v2 "."]
    if {[lindex $v1 0] > [lindex $v2 0]} {
        set res 1
    } elseif {[lindex $v1 0] == [lindex $v2 0]} {
        if {[lindex $v1 1] > [lindex $v2 1]} {
            set res 1
        } elseif {[lindex $v1 1] == [lindex $v2 1]} {
            if {[lindex $v1 2] > [lindex $v2 2]} {
                set res 1
            }
        }
    }
    return $res
}
