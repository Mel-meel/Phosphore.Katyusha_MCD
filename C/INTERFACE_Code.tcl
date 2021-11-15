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
            
            Katyusha_GenerationCode_main $tables $relations $heritages "PHP" "procedural" [$f.prefix.e get] $E_fichier_unique
            
            destroy $f
        }
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy ".fen_gen_code_php_procedural"}
        pack $f.commandes.ok $f.commandes.ko -fill x -side left -padx 50
    pack $f.titre $f.prefix $f.nfichiers $f.commandes -fill x
    # Titre le la présente fenêtre
    wm title $f "Générer le code d'accès à la base de données pour PHP procédural"
    # Mise à jour forcée de l'affichage graphique
    update
}


proc INTERFACE_Code_generation_php_objet {} {

}