#!/usr/bin/tclsh

## Créé le 22/6/2020 ##

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

# Pour les packages embarqués
#lappend auto_path [file join "$rpr/packages"]


source "$rpr/C/fonctions_interface.tcl"
source "$rpr/C/Images.tcl"
source "$rpr/C/Splash.tcl"

source "$rpr/C/MCD/MCD.tcl"
source "$rpr/C/MCD/INTERFACE_Objets.tcl"
source "$rpr/C/MCD/Objets.tcl"
source "$rpr/C/MCD/Heritages.tcl"
source "$rpr/C/MCD/Associations.tcl"
source "$rpr/C/MCD/Etiquettes.tcl"
source "$rpr/C/MCD/Entites.tcl"
source "$rpr/C/MCD/Attributs.tcl"
source "$rpr/C/MCD/Interface_MCD.tcl"
source "$rpr/C/MCD/INTERFACE_Associations.tcl"
source "$rpr/C/MCD/INTERFACE_Etiquettes.tcl"
source "$rpr/C/MCD/INTERFACE_Entites.tcl"
source "$rpr/C/MCD/INTERFACE_Heritages.tcl"


source "$rpr/C/UML/UML.tcl"
source "$rpr/C/UML/Objets.tcl"
source "$rpr/C/UML/Classes.tcl"
source "$rpr/C/UML/Interface_UML.tcl"
source "$rpr/C/UML/Interface_Classes.tcl"
source "$rpr/C/UML/Interface_Objets.tcl"


source "$rpr/C/Interface_Objets_MCD_UML.tcl"
source "$rpr/C/Objets_MCD_UML.tcl"

source "$rpr/C/INTERFACE_Code.tcl"
source "$rpr/C/INTERFACE_Configurations.tcl"
source "$rpr/C/C.tcl"
source "$rpr/C/SQL_gen.tcl"
source "$rpr/C/XML.tcl"
source "$rpr/C/sauvegarde_charge.tcl"
source "$rpr/C/Configurations.tcl"
source "$rpr/C/verification_mcd.tcl"
source "$rpr/C/Interface.tcl"
source "$rpr/C/SQL.tcl"
source "$rpr/C/Sauvegarde.tcl"
source "$rpr/C/Charge.tcl"
source "$rpr/C/Historique.tcl"
source "$rpr/C/SVG.tcl"
source "$rpr/C/Code.tcl"
source "$rpr/C/Modeles/Code_gen.tcl"
source "$rpr/C/MLD.tcl"
source "$rpr/C/Liens.tcl"

source "$rpr/libs/canvas2svg.tcl"
source "$rpr/libs/arabe.tcl"

set THEME katyusha_darkblue

# Tk
puts -nonewline "Chargement de Tk"
if {[catch {package require Tk}]} {
    puts " # TK obligatoire pour ce programme!"
    exit
} else {
    puts " # OK!"
}

source "$rpr/Themes/katyusha/$THEME.tcl"

ttk::style theme use $THEME
set tbg [ttk::style lookup TFrame -background]
lassign [winfo rgb . $tbg] bg_r bg_g bg_b
. configure -background $tbg

# FreeWrap ne supporte pas l'importation de packages traditionnel
source "$rpr/packages/tooltip.tcl"
source "$rpr/packages/phgettext/phgettext.tcl"
source "$rpr/packages/phxml/phxml.tcl"

array set CONFIG {}
array set MCD {}

# Splash
set CONFIGS(RESOLUTION) "auto"
Katyusha_Splash $rpr

puts "Initialisation........"

Katyusha_Images

# Configurations
puts "Chargement des configurations"
set rep_configs "~/.phosphore/katyusha_mcd"
Katyusha_Configurations_init
Katyusha_Configurations_charge $rpr $rep_configs

# Répertoire par défaut des projets Katyusha MCD
set id_projet -1

set ENV "null"

Katyusha_MCD_init
Katyusha_UML_init

set version "1.0.0 alpha 1"
set splash [lindex [list "Катюша!" "Katyusha!" "!کاتیوشا" "कात्युषा" "კატიუშა" "Կատյուշա" "Катюша!"] [expr int((rand() * 7) + 1) - 1]]
set sgbd 0
# Fichier dans lequel toutes les sauvegardes simples se feronts
set fichier_sauvegarde ""
# Action du bouton Gauche de la souris
set ACTION_B1 "null"

set zoom_compteur 0


# Initialisation de la traduction
puts "Chargement de la langue locale"
phgt::src "$rpr/locale" "fr"


# Par défaut, français


#Katyusha_Configurations_packages

puts "v$version"

puts "OK!"

set OS [lindex $tcl_platform(os) 0]
set NOTEBOOK_MCD ".editeurs.notebook_mcd"
set NOTEBOOK_UML ".editeurs.notebook_uml"
set ZONE_MCD ".editeurs.notebook_mcd.mcd"
set ZONE_UML ".editeurs.notebook_uml.uml"


puts "OS : $OS"

after 2000

Katyusha_Interface
source "$rpr/C/MCD/Bind_MCD.tcl"
source "$rpr/C/UML/Bind_UML.tcl"
source "$rpr/C/Commandes.tcl"

# Si un projet est passé en paramètre, l'ouvrir
if { $::argc > 0 } {
    Katyusha_Charge [lindex $::argv 0]
}
