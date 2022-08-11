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

source "$rpr/C/MCD/INTERFACE_Objets.tcl"
source "$rpr/C/MCD/Objets.tcl"

source "$rpr/C/INTERFACE_Etiquettes.tcl"
source "$rpr/C/INTERFACE_Tables.tcl"
source "$rpr/C/INTERFACE_Relations.tcl"
source "$rpr/C/INTERFACE_Heritages.tcl"
source "$rpr/C/INTERFACE_Code.tcl"
source "$rpr/C/C.tcl"
source "$rpr/C/SQL_gen.tcl"
source "$rpr/C/XML.tcl"
source "$rpr/C/sauvegarde_charge.tcl"
source "$rpr/C/Configurations.tcl"
source "$rpr/C/verification_mcd.tcl"
source "$rpr/C/Interface.tcl"
source "$rpr/C/SQL.tcl"
source "$rpr/C/Associations.tcl"
source "$rpr/C/Etiquettes.tcl"
source "$rpr/C/Entites.tcl"
source "$rpr/C/Sauvegarde.tcl"
source "$rpr/C/Charge.tcl"
source "$rpr/C/MCD.tcl"
source "$rpr/C/Heritages.tcl"
source "$rpr/C/Attributs.tcl"
source "$rpr/C/Historique.tcl"
source "$rpr/C/SVG.tcl"
source "$rpr/C/Code.tcl"
source "$rpr/C/Code_gen.tcl"
source "$rpr/C/MLD.tcl"

source "$rpr/libs/canvas2svg.tcl"
source "$rpr/libs/arabe.tcl"

#set theme awbreeze
#source "$rpr/Themes/colorutils.tcl"
#source "$rpr/Themes/awthemes.tcl"
#source "$rpr/Themes/$theme.tcl"

# Tk
puts -nonewline "Chargement de Tk"
if {[catch {package require Tk}]} {
    puts " # TK obligatoire pour ce programme!"
    exit
} else {
    puts " # OK!"
}

# FreeWrap ne supporte pas l'importation de packages traditionnel
source "$rpr/packages/tooltip.tcl"
source "$rpr/packages/phgettext/phgettext.tcl"

# Img
#package ifneeded Img 1.4.13 [list load [file join "$rpr/libs/Img1.4.13" pkgIndex.tcl] Img]

#ttk::style theme use breeze
#set tbg [ttk::style lookup TFrame -background]
#lassign [winfo rgb . $tbg] bg_r bg_g bg_b
#. configure -background $tbg

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

Katyusha_MCD_init

set version 0.4.6
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
if {![file exists "$rpr/locale/$CONFIGS(LANG).tcl"]} {
    source "$rpr/locale/fr.tcl"
} else {
    source "$rpr/locale/$CONFIGS(LANG).tcl"
}


#Katyusha_Configurations_packages

puts "v$version"

puts "OK!"

set OS [lindex $tcl_platform(os) 0]
set NOTEBOOK_MCD ".editeurs.notebook_mcd"
set ZONE_MCD ".editeurs.notebook_mcd.mcd"
set ZONE_UML ".editeurs.notebook_uml.uml"


puts "OS : $OS"

after 100

Katyusha_Interface
source "$rpr/C/bind.tcl"

# Si un projet est passé en paramètre, l'ouvrir
if { $::argc > 0 } {
    Katyusha_Charge [lindex $::argv 0]
}
