## Créé le 18/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Interface {} {

global IMG
global CONFIGS
global LOCALE
global MCD
global splash
global fichier_sauvegarde
global canvas_x
global canvas_y
global OS
global ZONE_MCD

# Détruit l'image de splash pour pouvoir afficher le reste
destroy .image
set resolution [Katyusha_Configurations_resolution]
set x [lindex $resolution 0]
set y [lindex $resolution 1]
set geo "$x\x$y"
set xs [expr ($x/2)-($x/2)]
set ys [expr ($y/2)-($y/2)]
# Redimentionne la fenêtre
wm geometry . $geo+$xs+$ys
# On actualise, sinon, rien!
update

# Titre de la fenêtre principale
wm title . "Katyusha MCD"
#wm overrideredirect . 1
wm protocol . WM_DELETE_WINDOW {Katyusha_exit_verif}

wm iconphoto . $IMG(logo)

# Taille des canvas
set canvas_x [expr $x - 250]
set canvas_y [expr $y - 150]

# On récupère la taille de l'écran\
set x [winfo screenwidth .]
set y [winfo screenheight .]
#wm geometry . "$x\x$y+0+0"

menu .mb
menu .mb.katyusha -tearoff 0
menu .mb.fichier -tearoff 0
menu .mb.bdd -tearoff 0
menu .mb.mcd -tearoff 0
menu .mb.uml -tearoff 0
menu .mb.code -tearoff 0
menu .mb.aide -tearoff 0
menu .mb.fichier.recents -tearoff 0
. configure -menu .mb
.mb add cascade -menu .mb.katyusha -label [phgt::mc "Katyusha!"]
.mb add cascade -menu .mb.fichier -label [phgt::mc "Projet"]
.mb add cascade -menu .mb.mcd -label [phgt::mc "Modèle Merise"]
.mb add cascade -menu .mb.uml -label [phgt::mc "Diagramme de classe UML"]
.mb add cascade -menu .mb.bdd -label $LOCALE(menu_bdd)
.mb add cascade -menu .mb.code -label $LOCALE(menu_code)
.mb add cascade -menu .mb.aide -label $LOCALE(menu_aide)

# Menu Katyusha
.mb.katyusha add command -label $LOCALE(menu_katyusha_pref) -command INTERFACE_preferences
#.mb.katyusha add command -label $LOCALE(menu_katyusha_maj) -command INTERFACE_MAJ
.mb.katyusha add command -label $LOCALE(menu_quitter) -command Katyusha_exit_verif

# Menu Fichier
.mb.fichier add command -label $LOCALE(menu_mcd_nouveau) -command Katyusha_MCD_nouveau
.mb.fichier add command -label $LOCALE(menu_sauver_sous) -command Katyusha_sauvegarder_sous
.mb.fichier add command -label $LOCALE(menu_sauver) -command Katyusha_sauvegarder

# Projets récement chargés
.mb.fichier add cascade -menu .mb.fichier.recents -label $LOCALE(menu_recents)
.mb.fichier.recents add command -label $LOCALE(recents_init) -command Katyusha_projets_recents_init
foreach fichier [Katyusha_fichiers_recents] {
    if {[file exists $fichier]} {
        .mb.fichier.recents add command -label $fichier -command "Katyusha_Charge $fichier"
    }
}

.mb.fichier add command -label $LOCALE(menu_charger) -command Katyusha_charger
.mb.fichier add command -label $LOCALE(menu_prefs) -command INTERFACE_config_bdd

# Menu modèle Merise
#.mb.mcd add command -label $LOCALE(menu_mcd_entites) -command INTERFACE_liste_entites
.mb.mcd add command -label $LOCALE(menu_mcd_ajout_table) -command "Katyusha_MCD_INTERFACE_Association_ajout_association 100 100"
#.mb.mcd add command -label $LOCALE(menu_mcd_edit_table) -command INTERFACE_edit_table_liste
#.mb.mcd add command -label $LOCALE(menu_mcd_sup_table) -command INTERFACE_liste_entites
.mb.mcd add command -label $LOCALE(menu_mcd_ajout_relation) -command "Katyusha_MCD_INTERFACE_Entite_ajout_entite 100 100"
#.mb.mcd add command -label $LOCALE(menu_mcd_sup_relation) -command INTERFACE_liste_entitesv
.mb.mcd add command -label $LOCALE(menu_mcd_verifier) -command {
    global LOCALE
    
    set verif [Katyusha_verification_mcd_sql $sgbd]
    set erreurs [lindex $verif 2]
    if {$erreurs == "null"} {
        set erreurs [list $LOCALE(mcd_correcte)]
    }
    INTERFACE_erreurs_MCD $erreurs
}
.mb.mcd add command -label $LOCALE(menu_mcd_exporter_svg) -command INTERFACE_exporter_svg
.mb.mcd add command -label $LOCALE(menu_mcd_imprimer) -command INTERFACE_imprimer

# Menu diagramme de classe UML
#.mb.uml add command -label [phgt::mc "Modèle Merise"] -command INTERFACE_liste_entites
.mb.uml add command -label [phgt::mc "En travaux, arrivera en version 0.5.x"]

# Menu base de donnée
#.mb.bdd add command -label $LOCALE(menu_config_bdd) -command INTERFACE_config_bdd
#.mb.bdd add command -label $LOCALE(menu_connex_bdd) -command INTERFACE_connexion_bdd
.mb.bdd add command -label $LOCALE(menu_gen_sql) -command INTERFACE_generation_sql
#.mb.bdd add command -label $LOCALE(menu_gen_mcd) -command INTERFACE_generation_mcd

# Menu code
.mb.code add command -label $LOCALE(menu_code_generer_php_fonctions) -command INTERFACE_Code_generation_php
.mb.code add command -label $LOCALE(menu_code_generer_php_doctrine) -command INTERFACE_Code_generation_php_objet_doctrine

# Menu Aide
.mb.aide add command -label $LOCALE(menu_aide_a_propos) -command INTERFACE_apropos
.mb.aide add command -label $LOCALE(menu_aide_license) -command INTERFACE_license

##
# Le 4/5/2022 : Ajout d'un widget ttk::notebook qui contiendra deux élément :
# Le premier avec l'interface de modélisation MCD
# Le deuxième avec l'interface de modélisation UML en course de développement
##
ttk::notebook .editeurs
.editeurs add [Katyusha_Interface_editeur_MCD ".editeurs" $canvas_x $canvas_y] -text [phgt::mc "Modèle Merise"]
.editeurs add [Katyusha_Interface_editeur_UML ".editeurs" $canvas_x $canvas_y] -text [phgt::mc "Diagramme de classe UML"]
pack .editeurs -fill both -expand 1
    frame .infos
        frame .infos.s
            if {$OS == "Windows" || $OS == "Win"} {
                button .infos.s.splash -text $LOCALE(attention_os) -foreground red -activeforeground red -command INTERFACE_mise_en_garde
            } else {
                label .infos.s.splash -text $splash
            }
            label .infos.s.position_curseur -text ""
            pack .infos.s.position_curseur -padx 1 -side right
            pack .infos.s.splash -padx 1 -side right
        pack .infos.s -fill x
        label .infos.fichier -text $fichier_sauvegarde
        pack .infos.fichier -fill x
    pack .infos

Katyusha_grille $ZONE_MCD.canvas.c
#maj_arbre_entites

}


proc Katyusha_Interface_editeur_UML {parent canvas_x canvas_y} {
    global LOCALE
    global IMG
    global CONFIGS
    global ZONE_MCD
    global OS
    
    set f [ttk::frame $parent.notebook_uml]
    
    frame $f.notebook_uml_panel
        label $f.notebook_uml_panel.tmp -text [phgt::mc "En travaux, arrivera en version majeure 1.x"]
        pack $f.notebook_uml_panel.tmp
    pack $f.notebook_uml_panel
    
    return $f
}


proc Katyusha_Interface_editeur_MCD {parent canvas_x canvas_y} {
    global LOCALE
    global IMG
    global CONFIGS
    global ZONE_MCD
    global OS
    global splash
    
    set f [ttk::frame $parent.notebook_mcd]
    
    frame $parent.notebook_mcd.panel
        frame $parent.notebook_mcd.panel.commandes
            # Bouton on/off d'ajout d'une entité
            button $parent.notebook_mcd.panel.commandes.ajout_table -text $LOCALE(ajouter_table) -image $IMG(ajouter_table) -command {Katyusha_action_boutons_ajout "table"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_table $LOCALE(ajouter_table)
            # Bouton on/off d'ajout d'une association
            button $parent.notebook_mcd.panel.commandes.ajout_relation -text $LOCALE(ajouter_relation) -image $IMG(ajouter_relation) -command {Katyusha_action_boutons_ajout "relation"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_relation $LOCALE(ajouter_relation)
            # Bouton on/off d'ajout d'un héritage
            button $parent.notebook_mcd.panel.commandes.ajout_heritage -text $LOCALE(ajouter_heritage) -image $IMG(ajouter_heritage) -command {Katyusha_action_boutons_ajout "heritage"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_heritage $LOCALE(ajouter_heritage)
            # Bouton on/off d'ajout d'une étiquette
            button $parent.notebook_mcd.panel.commandes.ajout_etiquette -text $LOCALE(ajouter_etiquette) -image $IMG(ajouter_etiquette) -command {Katyusha_action_boutons_ajout "etiquette"}
            tooltip::tooltip $parent.notebook_mcd.panel.commandes.ajout_etiquette $LOCALE(ajouter_etiquette)
            pack $parent.notebook_mcd.panel.commandes.ajout_table $parent.notebook_mcd.panel.commandes.ajout_relation $parent.notebook_mcd.panel.commandes.ajout_etiquette $parent.notebook_mcd.panel.commandes.ajout_heritage -side left
        pack $parent.notebook_mcd.panel.commandes
        label $parent.notebook_mcd.panel.entites -text $LOCALE(entites_de_la_base) -justify left
        pack $parent.notebook_mcd.panel.entites -fill x
        # Arbre des objets du MCD
        frame $parent.notebook_mcd.panel.arbre
            canvas $parent.notebook_mcd.panel.arbre.c -height [expr $canvas_y - 30] -width 250 -yscrollcommand "$parent.notebook_mcd.panel.arbre.vs set" -scrollregion "0 0 250 4000" -background #F5F5F5
            scrollbar $parent.notebook_mcd.panel.arbre.vs -command "$parent.notebook_mcd.panel.arbre.c yview"
            pack $parent.notebook_mcd.panel.arbre.c $parent.notebook_mcd.panel.arbre.vs -side left -fill both
        pack $parent.notebook_mcd.panel.arbre
    pack $parent.notebook_mcd.panel -side left
    frame $parent.notebook_mcd.mcd
        # Infos de la base de données
        frame $parent.notebook_mcd.mcd.infos_bdd
            button $parent.notebook_mcd.mcd.infos_bdd.zoom_plus -text "+" -image $IMG(zoom_plus) -command "Katyusha_zoom_plus $ZONE_MCD.canvas.c"
            button $parent.notebook_mcd.mcd.infos_bdd.zoom_moins -text "-" -image $IMG(zoom_moins) -command "Katyusha_zoom_moins $ZONE_MCD.canvas.c"
            button $parent.notebook_mcd.mcd.infos_bdd.zoom_initial -text "1:1" -image $IMG(zoom_initial) -command "Katyusha_zoom_initial $ZONE_MCD.canvas.c"
            button $parent.notebook_mcd.mcd.infos_bdd.defaire -text "défaire" -image $IMG(defaire) -command Katyusha_Historique_defaire
            button $parent.notebook_mcd.mcd.infos_bdd.refaire -text "refaire" -image $IMG(refaire) -command Katyusha_Historique_refaire
            pack $parent.notebook_mcd.mcd.infos_bdd.zoom_plus $parent.notebook_mcd.mcd.infos_bdd.zoom_moins $parent.notebook_mcd.mcd.infos_bdd.zoom_initial $parent.notebook_mcd.mcd.infos_bdd.defaire $parent.notebook_mcd.mcd.infos_bdd.refaire -side left
        pack $parent.notebook_mcd.mcd.infos_bdd -fill x
        # Canvas principal
        frame $parent.notebook_mcd.mcd.canvas
            # C'est pas parfait, mais ça marche
            # À revoir completement
            scrollbar $parent.notebook_mcd.mcd.canvas.vs -command "$parent.notebook_mcd.mcd.canvas.c yview"
            set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
            set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
            canvas $parent.notebook_mcd.mcd.canvas.c -background white -height [expr $canvas_y] -width [expr $canvas_x - 50] -xscrollcommand "$parent.notebook_mcd.mcd.hs set" -yscrollcommand "$parent.notebook_mcd.mcd.canvas.vs set" -scrollregion "0 0 $xbcanvas $ybcanvas"
            pack $parent.notebook_mcd.mcd.canvas.c -side left -fill both -expand 1
            pack $parent.notebook_mcd.mcd.canvas.vs -side left -fill y
            #.mcd.canvas.c configure -scrollregion [.mcd.canvas.c bbox all]
        pack $parent.notebook_mcd.mcd.canvas -fill x
            scrollbar $parent.notebook_mcd.mcd.hs -orient horiz -command "$parent.notebook_mcd.mcd.canvas.c xview"
            pack $parent.notebook_mcd.mcd.hs -side top -fill x
    pack $parent.notebook_mcd.mcd -side left
    
    return $f
}
