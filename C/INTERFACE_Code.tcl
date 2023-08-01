## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc INTERFACE_Code_generation_php {} {
    global version
    global IMG
    global E_fichier_unique
    
    set E_fichier_unique 0
    
    set f ".fen_gen_code_php_procedural"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    ttk::label $f.titre -text [phgt::mc "Générer du code PHP procédural"]
    pack $f.titre -pady 10 -padx 50
    ttk::frame $f.prefix
        ttk::label $f.prefix.l -text [phgt::mc "Préfix des fonctions"]
        ttk::entry $f.prefix.e
        pack $f.prefix.l $f.prefix.e -fill x -side left
    ttk::frame $f.nfichiers
        ttk::label $f.nfichiers.l -text [phgt::mc "Tout générer dans un seul fichier"]
        ttk::checkbutton $f.nfichiers.c -onvalue 1 -offvalue 0 -variable E_fichier_unique
        pack $f.nfichiers.l $f.nfichiers.c -fill x -side left
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
            global tables
            global relations
            global heritages
            global E_fichier_unique
            
            set f ".fen_gen_code_php_procedural"
            
            Katyusha_GenerationCode_main_procedural $tables $relations $heritages "php" "procedural" [$f.prefix.e get] $E_fichier_unique
            
            destroy $f
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy ".fen_gen_code_php_procedural"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.prefix $f.nfichiers $f.commandes -fill x
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Générer du code PHP procédural"]
    # Mise à jour forcée de l'affichage graphique
    update
}


##
# Interface de génération des objets de base de données propre à Doctrine
# !! Expérimental !!
##
proc INTERFACE_Code_generation_php_objet_doctrine {} {
    global version
    global IMG
    global E_fichier_unique
    
    set E_fichier_unique 0
    
    set f ".fen_gen_code_php_objet_doctrine"
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    ttk::label $f.titre -text [phgt::mc "Récents"]
    pack $f.titre -pady 10 -padx 50
    ttk::frame $f.ns
        ttk::label $f.ns.l -text [phgt::mc "Namespace : "]
        ttk::entry $f.ns.e
        pack $f.ns.l $f.ns.e -fill x -side left
    ttk::frame $f.prefix
        ttk::label $f.prefix.l -text [phgt::mc "préfix : "]
        ttk::entry $f.prefix.e
        pack $f.prefix.l $f.prefix.e -fill x -side left
    ttk::label $f.att -text [phgt::mc "Attention, la génération de code pour l'ORM Doctrine est expérimentale"] -foreground red
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command {
            global tables
            global relations
            global heritages
            global E_fichier_unique
            
            set f ".fen_gen_code_php_objet_doctrine"
            
            Katyusha_GenerationCode_main_orm $tables $relations $heritages "php" "doctrine" [$f.ns.e get] [$f.prefix.e get] $E_fichier_unique
            
            destroy $f
        }
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy ".fen_gen_code_php_objet_doctrine"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.ns $f.prefix $f.att $f.commandes -fill x
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Générer du code PHP objet"]
    # Mise à jour forcée de l'affichage graphique
    update
}
