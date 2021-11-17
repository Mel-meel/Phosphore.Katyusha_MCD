## Créé le 10/11/2021 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc INTERFACE_Code_generation_php {} {
    global LOCALE
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
    label $f.titre -text "Code PHP procédural"
    pack $f.titre -pady 10 -padx 50
    frame $f.prefix
        label $f.prefix.l -text "Préfix des fonctions : "
        entry $f.prefix.e
        pack $f.prefix.l $f.prefix.e -fill x -side left
    frame $f.nfichiers
        label $f.nfichiers.l -text "Toutes les fonctions dans un seul fichier : "
        checkbutton $f.nfichiers.c -onvalue 1 -offvalue 0 -variable E_fichier_unique
        pack $f.nfichiers.l $f.nfichiers.c -fill x -side left
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            global tables
            global relations
            global heritages
            global E_fichier_unique
            
            set f ".fen_gen_code_php_procedural"
            
            Katyusha_GenerationCode_main_procedural $tables $relations $heritages "php" "procedural" [$f.prefix.e get] $E_fichier_unique
            
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy ".fen_gen_code_php_procedural"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.prefix $f.nfichiers $f.commandes -fill x
    # Titre le la présente fenêtre
    wm title $f "Générer le code d'accès à la base de données pour PHP procédural"
    # Mise à jour forcée de l'affichage graphique
    update
}


##
# Interface de génération des objets de base de données propre à Doctrine
# !! Expérimental !!
##
proc INTERFACE_Code_generation_php_objet_doctrine {} {
    global LOCALE
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
    label $f.titre -text "Code PHP objet des modèles pour Doctrine"
    pack $f.titre -pady 10 -padx 50
    frame $f.ns
        label $f.ns.l -text "Namespace : "
        entry $f.ns.e
        pack $f.ns.l $f.ns.e -fill x -side left
    frame $f.prefix
        label $f.prefix.l -text "Préfix des classes : "
        entry $f.prefix.e
        pack $f.prefix.l $f.prefix.e -fill x -side left
    frame $f.nfichiers
        label $f.nfichiers.l -text "Toutes les classes dans un seul fichier : "
        checkbutton $f.nfichiers.c -onvalue 1 -offvalue 0 -variable E_fichier_unique
        pack $f.nfichiers.l $f.nfichiers.c -fill x -side left
    label $f.att -text "Attention, la génération de code pour Doctrine est encore expérimentale!" -foreground red
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command {
            global tables
            global relations
            global heritages
            global E_fichier_unique
            
            set f ".fen_gen_code_php_objet_doctrine"
            
            Katyusha_GenerationCode_main_orm $tables $relations $heritages "php" "doctrine" [$f.ns.e get] [$f.prefix.e get] $E_fichier_unique
            
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy ".fen_gen_code_php_objet_doctrine"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -pady 10 -padx 50
    pack $f.ns $f.prefix $f.nfichiers $f.att $f.commandes -fill x
    # Titre le la présente fenêtre
    wm title $f "Générer le code d'accès à la base de données pour l'ORM Doctrine"
    # Mise à jour forcée de l'affichage graphique
    update
}
