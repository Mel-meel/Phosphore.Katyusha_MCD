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
menu .mb.aide -tearoff 0
menu .mb.fichier.recents -tearoff 0
. configure -menu .mb
.mb add cascade -menu .mb.katyusha -label $LOCALE(menu_katyusha)
.mb add cascade -menu .mb.fichier -label $LOCALE(menu_fichier)
.mb add cascade -menu .mb.mcd -label $LOCALE(menu_mcd)
.mb add cascade -menu .mb.bdd -label $LOCALE(menu_bdd)
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

# Menu MCD
.mb.mcd add command -label $LOCALE(menu_mcd_entites) -command INTERFACE_liste_entites
.mb.mcd add command -label $LOCALE(menu_mcd_ajout_table) -command "INTERFACE_ajout_table 100 100"
#.mb.mcd add command -label $LOCALE(menu_mcd_edit_table) -command INTERFACE_edit_table_liste
#.mb.mcd add command -label $LOCALE(menu_mcd_sup_table) -command INTERFACE_liste_entites
.mb.mcd add command -label $LOCALE(menu_mcd_ajout_relation) -command "INTERFACE_ajout_relation 100 100"
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

# Menu base de donnée
#.mb.bdd add command -label $LOCALE(menu_config_bdd) -command INTERFACE_config_bdd
#.mb.bdd add command -label $LOCALE(menu_connex_bdd) -command INTERFACE_connexion_bdd
.mb.bdd add command -label $LOCALE(menu_gen_sql) -command INTERFACE_generation_sql
#.mb.bdd add command -label $LOCALE(menu_gen_mcd) -command INTERFACE_generation_mcd

# Menu Aide
.mb.aide add command -label $LOCALE(menu_aide_a_propos) -command INTERFACE_apropos
.mb.aide add command -label $LOCALE(menu_aide_license) -command INTERFACE_license

frame .panel
frame .panel.commandes
    # Bouton on/off d'ajout de table
    button .panel.commandes.ajout_table -text $LOCALE(ajouter_table) -image $IMG(ajouter_table) -command {Katyusha_action_boutons_ajout "table"}
    # Bouton on/off d'ajout d'une relation
    button .panel.commandes.ajout_relation -text $LOCALE(ajouter_relation) -image $IMG(ajouter_relation) -command {Katyusha_action_boutons_ajout "relation"}
    # Bouton on/off d'ajout d'un héritage
    button .panel.commandes.ajout_heritage -text $LOCALE(ajouter_heritage) -image $IMG(ajouter_heritage) -command {Katyusha_action_boutons_ajout "heritage"}
    # Bouton on/off d'ajout d'une étiquette
    button .panel.commandes.ajout_etiquette -text $LOCALE(ajouter_etiquette) -image $IMG(ajouter_etiquette) -command {Katyusha_action_boutons_ajout "etiquette"}
    pack .panel.commandes.ajout_table .panel.commandes.ajout_relation .panel.commandes.ajout_etiquette .panel.commandes.ajout_heritage -side left
pack .panel.commandes
    #button .panel.ajout_procedure -text $LOCALE(ajouter_procedure) -command INTERFACE_ajout_procedure
    #pack .panel.ajout_procedure -fill x
    label .panel.entites -text $LOCALE(entites_de_la_base) -justify left
    pack .panel.entites -fill x
    # Arbre des entités du MCD
    frame .panel.arbre
        canvas .panel.arbre.c -height [expr $canvas_y - 30] -width 250 -yscrollcommand {.panel.arbre.vs set} -scrollregion "0 0 250 4000" -background #F5F5F5
        scrollbar .panel.arbre.vs -command {.panel.arbre.c yview}
        pack .panel.arbre.c .panel.arbre.vs -side left -fill both
    pack .panel.arbre
pack .panel -side left
frame .mcd
    # Infos de la base de données
    frame .mcd.infos_bdd
        label .mcd.infos_bdd.nom_bdd -text "Nom de la base de données : $MCD(nom)"
        label .mcd.infos_bdd.sgbd -text "SGBD cible : $MCD(sgbd)"
        # Bouton d'édition
        button .mcd.infos_bdd.edit -text $LOCALE(editer) -image $IMG(editer) -compound right -command INTERFACE_config_bdd
        # Bouton de génération du script SQL pour le SGBD par défaut
        button .mcd.infos_bdd.gen -text $MCD(sgbd) -image $IMG(gen_sql) -compound right -command {
            global MCD
            if {[Katyusha_verification_mcd] == 1} {
                set res_info [tk_messageBox -icon warning -type ok -message "Il y a une erreur dans le MCD qui empêche la génération du script SQL pour $MCD(sgbd)"]
            } else {
                set SQL [Katyusha_generation_sql $MCD(sgbd)]
                INTERFACE_script_SQL [lindex $SQL 0] [lindex $SQL 1]
            }
        }
        #pack .mcd.infos_bdd.gen .mcd.infos_bdd.edit -fill x -side right
        #pack .mcd.infos_bdd.nom_bdd .mcd.infos_bdd.sgbd -fill x -side left -padx 50
        button .mcd.infos_bdd.zoom_plus -text "+" -image $IMG(zoom_plus) -command Katyusha_zoom_plus
        button .mcd.infos_bdd.zoom_moins -text "-" -image $IMG(zoom_moins) -command Katyusha_zoom_moins
        button .mcd.infos_bdd.zoom_initial -text "1:1" -image $IMG(zoom_initial) -command Katyusha_zoom_initial
        button .mcd.infos_bdd.defaire -text "défaire" -image $IMG(defaire) -command Katyusha_Historique_defaire
        button .mcd.infos_bdd.refaire -text "refaire" -image $IMG(refaire) -command Katyusha_Historique_refaire
        pack .mcd.infos_bdd.zoom_plus .mcd.infos_bdd.zoom_moins .mcd.infos_bdd.zoom_initial .mcd.infos_bdd.defaire .mcd.infos_bdd.refaire -side left
        ##
        # Enregistrement du canvas en svg, pas encore au point, prévu pour version 0.3.x
        ##
        #button .mcd.infos_bdd.imp -text "dsfc" -command {
        #    global MCD
        #    #.mcd.canvas.c postscript -file "$MCD(rep)/test.png"
        #    #set png [image create photo -format window -data .mcd.canvas.c]
        #    set stream [open "$MCD(rep)/test.svg" w+]
        #    puts $stream [canvas2svg .mcd.canvas.c]
        #    close $stream
        #}
        #pack .mcd.infos_bdd.imp -side right
    pack .mcd.infos_bdd -fill x
    # Canvas principal
    frame .mcd.canvas
        # C'est pas parfait, mais ça marche
        # À revoir completement
        scrollbar .mcd.canvas.vs -command {.mcd.canvas.c yview}
        set xbcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 0]
        set ybcanvas [lindex [split $CONFIGS(TAILLE_CANVAS) "x"] 1]
        canvas .mcd.canvas.c -background white -height [expr $canvas_y] -width [expr $canvas_x - 50] -xscrollcommand {.mcd.hs set} -yscrollcommand {.mcd.canvas.vs set} -scrollregion "0 0 $xbcanvas $ybcanvas"
        pack .mcd.canvas.c -side left -expand 1
        pack .mcd.canvas.vs -side left -fill y
        #.mcd.canvas.c configure -scrollregion [.mcd.canvas.c bbox all]
    pack .mcd.canvas -fill x
        scrollbar .mcd.hs -orient horiz -command {.mcd.canvas.c xview}
        pack .mcd.hs -side top -fill x
    # Position X / Y dur curseur et splash
    frame .mcd.infos
        frame .mcd.infos.s
            if {$OS == "Windows" || $OS == "Win"} {
                button .mcd.infos.s.splash -text $LOCALE(attention_os) -foreground red -activeforeground red -command INTERFACE_mise_en_garde
            } else {
                label .mcd.infos.s.splash -text $splash
            }
            label .mcd.infos.s.position_curseur -text ""
            pack .mcd.infos.s.position_curseur -padx 1 -side right
            pack .mcd.infos.s.splash -padx 1 -side right
        pack .mcd.infos.s -fill x
        label .mcd.infos.fichier -text $fichier_sauvegarde
        pack .mcd.infos.fichier -fill x
    pack .mcd.infos
pack .mcd -side left

Katyusha_grille
maj_arbre_entites

}
