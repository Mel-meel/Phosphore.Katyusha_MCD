#!/usr/bin/env tclsh



          ###           ###
       #########     #########
     ############# #############
    #############################
    #############################
    #############################
     ###########################
      #########################         ########    ########    ########    ##    ##    ########
       #######################          #      #    #           #      #    # #  # #    #      #
        #####################           #      #    ########    ########    #  ##  #    ########
          #################             #      #           #    #      #    #      #    #      #
            #############               ########    ########    #      #    #      #    #      #
              #########
                #####
                  #



########################################################################################################

## Créé le 4/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

# Répertoire racine du script
set rpr [file dirname [info script]]
# Répertoire racine de l'exécutable
#set rpr [file dirname [file normalize [info nameofexecutable]]]

# Tk
puts -nonewline "Chargement de Tk"
if {[catch {package require Tk}]} {
    puts " # TK obligatoire pour ce programme!"
    exit
} else {
    puts " # OK!"
}

##
# Splash screen
##

# Titre de la fenêtre principale
wm title . "Katyusha MCD - Chargement..."

# On récupère la taille de l'écran
set x [winfo screenwidth .]
set y [winfo screenheight .]

# Récupération des images du splash
image create photo splash -file "$rpr/images/splash.png"

# Variables de placement du splash
set width_t 600
set height_t 400
set xs [expr ($x/2)-($width_t/2)]
set ys [expr ($y/2)-($height_t/2)]

# Variable de choix du splash
set splash [expr int(rand()*5)]

# Dimension de la fenêtre
label .image -image splash
pack .image

set geo "600x400"
wm geometry . $geo+$xs+$ys
#wm overrideredirect . 1
# On actualise, sinon, rien!
update

source "$rpr/fonctions_interface.tcl"
source "$rpr/C/INTERFACE_entites.tcl"
source "$rpr/C.tcl"
source "$rpr/C/SQL_gen.tcl"
source "$rpr/C/XML.tcl"
source "$rpr/C/sauvegarde_charge.tcl"
source "$rpr/C/entites.tcl"
source "$rpr/C/configurations.tcl"
source "$rpr/C/verification_mcd.tcl"

###############################################################################
#                                                                             #
#                        Initialisation du programme                          #
#                                                                             #
###############################################################################

puts "Initialisation........"

##
# Charge les configurations
##
set rep_configs "~/.phosphore/katyusha_mcd"

##
# Créé les répertoires de configuration s'il n'existent pas
##
if {![file exists "~/.phosphore"]} {
    file mkdir "~/.phosphore"
}
if {![file exists $rep_configs]} {
    file mkdir $rep_configs
}

array set CONFIG {}
Katyusha_charge_configs $rpr $rep_configs

# Dictionnaire contenant toutes les tables et leurs informations, sauf graphiques
set tables [dict create]
set ID 0
# Dictionnaire contenant toutes les informations relatives à l'affichage graphique des tables
set tables_graphique [dict create]
# Dictionnaire contenant toutes les relations entre les tables et leurs informations, sauf graphiques
set relations [dict create]
# Dictionnaire contenant toutes les informations relatives à l'affichage graphique des relations
set relations_graphique [dict create]
# Dictionnaire contenant tous les héritages entre les tables et leurs informations, sauf graphiques
set heritages [dict create]
# Dictionnaire contenant toutes les informations relatives à l'affichage graphique des héritages
set heritages_graphique [dict create]
# Dictionnaire contenant toutes les procédures de la base
set procedures [dict create]
# Coordonnées temporaires
set coords [list]
# Table temporaire
set table_tmp [dict create]
# Relation temporaire
set relation_tmp [dict create]
# Héritage temporaire
set heritage_tmp [dict create]
set tables_a $tables
set relations_a $relations
set heritages_a $heritages
set version 0.0.3
set splash [lindex [list "Катюша!" "Katyusha!" "کاتیوشا" "Катюша!"] [expr int((rand() * 4) + 1) - 1]]
set sgbd 0
# Fichier dans lequel toutes les sauvegardes simples se feronts
set fichier_sauvegarde ""
# Action du bouton Gauche de la souris
set ACTION_B1 "null"
set langue "fr"

# Répertoire par défaut des projets Katyusha MCD
set rep_mcd "~/Katyusha_projects"
# Si il n'existe pas, le créer
if {![file exists $rep_mcd]} {
    file mkdir $rep_mcd
}

# Nom par défaut du script SQL généré
set id_script [llength [glob -nocomplain -dir $rep_mcd "project*.sql"]]
set nom_script "project$id_script.sql"

# Initialisation de la traduction
puts -nonewline "Chargement de la langue locale"
source "$rpr/locale/$langue.tcl"
puts $LOCALE(chargement_locale_ok)

# Charge les modules nécessaires
puts $LOCALE(chargement_modules)
# TDCB
puts -nonewline "Chargement de TDBC"
if {[catch {package require tdbc}]} {
    puts " # Sans TDBC aucune connexion possibles aux SGBD"
} else {
    puts $LOCALE(chargement_module_tdbc_ok)
    set sgbd 1
}
# MySQL
puts -nonewline "..............MySQL"
if {[catch {package require tdbc::mysql}]} {
    puts " # KO"
} else {
    puts " # OK!"
    set sgbd 1
}
# SQLite 3
puts -nonewline "..............SQLite 3"
if {[catch {package require tdbc::sqlite3}]} {
    puts " # KO"
} else {
    puts " # OK!"
    set sgbd 1
}
# Postgre
puts -nonewline "..............Postgre"
if {[catch {package require tdbc::postgre}]} {
    puts " # KO"
} else {
    puts " # OK!"
    set sgbd 1
}
# ODBC
puts -nonewline "..............ODCB"
if {[catch {package require tdbc::odbc}]} {
    puts " # KO"
} else {
    puts " # OK!"
    set sgbd 1
}
package ifneeded tip 1.2 [list source [file join "$rpr/packages" tip.tcl]]

# Charge les images
source "$rpr/images/images.tcl"

puts "v$version"

puts "OK!"

after 1000
puts "\n__Bienvenue dans Katyusha MCD__\n"
# Détruit l'image de splash pour pouvoir afficher le reste
destroy .image
# Si la résolution est en mode automatique
if {$CONFIGS(RESOLUTION) == "auto"} {
    set y [expr $y - 80]
    set ft "x$y"
    set geo "$x$ft"
} else {
    set geo $CONFIGS(RESOLUTION)
    set x [lindex [split $CONFIGS(RESOLUTION) "x"] 0]
    set y [lindex [split $CONFIGS(RESOLUTION) "x"] 1]
}
set xs [expr ($x/2)-($x/2)]
set ys [expr ($y/2)-($y/2)]
# Redimentionne la fenêtre
wm geometry . $geo+$xs+$ys
# On actualise, sinon, rien!
update
# Charge l'interface graphique
source "$rpr/interface.tcl"
source "$rpr/C/bind.tcl"
