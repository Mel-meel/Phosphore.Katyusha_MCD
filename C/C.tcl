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

##
# Remet sur off tous les boutons de commande
##
proc Katyusha_boutons_ajout_off {} {
    global ACTION_B1
    global CONFIGS
    global NOTEBOOK_MCD
    global ENV
    
    foreach bouton [list "ajout_table" "ajout_relation" "ajout_etiquette" "ajout_heritage"] {
        $NOTEBOOK_MCD.panel.commandes.$bouton configure -relief raised
    }
    set ACTION_B1 "null"
    set ENV "null"
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
proc Katyusha_grille {canvas {pas 10}} {
    global CONFIGS
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    set dbackground [Katyusha_Configurations_couleurs "-dbackground"]
    
    set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
    set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
    
    # Lignes en X
    set dx 0
    set c 0
    while {$dx < [expr $xbcanvas + 1000]} {
        if {$c == [expr $pas * 10]} {
            set c 0
            set couleur "#A6A6A6"
        } else {
            set c [expr $c + $pas]
            set couleur $lbackground
        }
        set dx [expr $dx + $pas]
        $canvas create line $dx 0 $dx [expr $xbcanvas + 1000] -fill $couleur -tag "grille"
        update
    }
    # Lignes en Y
    set dy 0
    set c 0
    while {$dy < [expr $ybcanvas + 1000]} {
        if {$c == [expr $pas * 10]} {
            set c 0
            set couleur "#A6A6A6"
        } else {
            set c [expr $c + $pas]
            set couleur $dbackground
        }
        set dy [expr $dy + $pas]
        $canvas create line 0 $dy [expr $ybcanvas + 1000] $dy -fill $couleur -tag "grille"
        update
    }
}

##
# Ouvre et lis le contenu d'un fichier
##
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
proc Katyusha_zoom_plus {canvas} {
    global zoom_compteur
    
    set zoom_compteur [expr $zoom_compteur + 1]
    $canvas scale all 0 0 1.1 1.1
}

##
# Zoom_arriere
##
proc Katyusha_zoom_moins {canvas} {
    global zoom_compteur
    
    set zoom_compteur [expr $zoom_compteur - 1]
    $canvas scale all 0 0 0.9 0.9
}

##
# Retour au zoom initial
##
proc Katyusha_zoom_initial {canvas} {
    global zoom_compteur
    set n [expr abs($zoom_compteur)]
    
    if {$n > 0} {
        for {set c 0} {$c < $n} {incr c} {
            if {$zoom_compteur < 0} {
                Katyusha_zoom_plus $canvas
            } else {
                Katyusha_zoom_moins $canvas
            }
        }
    }
}

##
# Retourne la valeur de la dernière clef du dictionnaire passé en paramètre
##
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

##
# Enregistre un texte dans un fichier
##
proc Katyusha_C_fichier_enrigistrer {fichier contenu acces} {
    # Enregistre dans le fichier
    set stream [open $fichier $acces]
    puts $stream $contenu
    close $stream
}
