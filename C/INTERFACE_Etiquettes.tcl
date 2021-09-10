## Créé le 5/9/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Si aucune etiquette n'est spécifiée en argument, il s'agira d'un ajout de etiquette.
# Si une etiquette est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc INTERFACE_Etiquettes_ajout {x y {id "null"}} {
    global IMG
    global LOCALE
    global etiquettes
    global etiquette_tmp
    global E_nom_etiquette
    puts $id
    set f ".fen_ajout_etiquette"
    
    # S'il s'agit de l'adition d'une étiquette existante
    if {$id != "null"} {
        set etiquette [dict get $etiquettes $id]
    }
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Nom de l'étiquette
    if {$id == "null"} {
        set E_nom_etiquette "Etiquette_[expr [dict size $etiquettes] + 1]"
        dict set etiquette_tmp "coords" [list $x $y]
    } else {
        set E_nom_etiquette [dict get $etiquette "nom"]
        set etiquette_tmp $etiquette
    }
    dict set etiquette_tmp "id" $id

    # Frame de choix du nom de la table
    frame $f.nom
        label $f.nom.l -text $LOCALE(nom_etiquette)
        entry $f.nom.e -textvariable E_nom_etiquette
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    # Texte de l'étiquette
    frame $f.texte
        label $f.texte.l -text $LOCALE(texte_etiquette)
        text $f.texte.t
        pack $f.texte.l $f.texte.t
    pack $f.texte -pady 10 -padx 50
    
    # Texte de l'étiquette déjà existante
    if {$id != "null"} {
        $f.texte.t insert end [dict get $etiquette "texte"]
    }

    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command INTERFACE_COMMANDE_Etiquettes_ajout
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x

    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f $LOCALE(ajouter_une_etiquette)
    } else {
        wm title $f "$LOCALE(editer_l_etiquette)[dict get $etiquette nom]"
    }
    
    # Mise à jour forcée de l'affichage graphique
    update
}

proc INTERFACE_COMMANDE_Etiquettes_ajout {} {
    global etiquette_tmp
    global etiquettes
    global E_nom_etiquette
    global MCD
    
    set id [dict get $etiquette_tmp "id"]
    #dict unset etiquette_tmp "id"
    puts $id
    
    set f ".fen_ajout_etiquette"
    
    dict set etiquette_tmp "nom" $E_nom_etiquette
    dict set etiquette_tmp "texte" [$f.texte.t get 1.0 end]
    dict set etiquette_tmp "couleurs" [dict create "fond" $MCD(couleur_fond_etiquette) "ligne" $MCD(couleur_ligne_etiquette) "texte" $MCD(couleur_texte_etiquette)]
    if {$id == "null"} {
        Katyusha_Etiquettes_ajout_etiquette $etiquette_tmp
    } else {
        dict set etiquettes $id $etiquette_tmp
    }
    unset E_nom_etiquette
    destroy $f
}
