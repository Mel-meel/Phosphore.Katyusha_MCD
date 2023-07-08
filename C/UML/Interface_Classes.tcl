## Créé le 8/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Si aucune table n'est spécifiée en argument, il s'agira d'un ajout de table.
# Si une table est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc Katyusha_UML_Interface_Classes_ajout_classe {x y {id "null"}} {
    global STYLES
    global coords
    global IMG
    global classes
    global classe_tmp
    global id_attribut_graphique
    global E_nom_classe
    
    
    set f ".fen_ajout_classe"
    
    # Initialise la table temporaire
    if {$id == "null"} {
        # Transfert des coordonnées
        set coords [list $x $y]
        set classe_tmp [Katyusha_UML_Classes_init_classe]
        dict set classe_tmp "coords" $coords
        set E_nom_classe [phgt::mc "Classe_%s" [list [expr [dict size $classes] + 1]]]
    } else {
        set classe [dict get $classes $id]
        set classe_tmp $classe
        set E_nom_classe [dict get $classe "nom"]
    }
    dict set classe_tmp "id" $id
    set id_attribut_graphique 0
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de choix du nom de la table
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Nom de la classe : "]
        ttk::entry $f.nom.e -textvariable E_nom_classe
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
    
    ##
    # Attributs de la classe
    ##
    ttk::frame $f.attributs
        # Commandes des attributs
        ttk::frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_MCD_INTERFACE_Objets_ajout_attribut "table"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Objets_suppression_attribut "table"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -width 1200 -height 400 -background [dict get $STYLES "lbackground"] -highlightbackground [dict get $STYLES "graphics"]
        ttk::frame $f.attributs.c.f
            # Liste des attributs
            ttk::frame $f.attributs.c.f.liste
                ttk::label $f.attributs.c.f.titre -text [phgt::mc "Liste des attributs de la classe"]
                pack $f.attributs.c.f.titre -fill x
                ttk::frame $f.attributs.c.f.tete
                    ttk::label $f.attributs.c.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.type -text [phgt::mc "Type"] -width 15 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.accces -text [phgt::mc "Accès"] -width 10 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.taille -text [phgt::mc "Taille"] -width 10 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.valeur -text [phgt::mc "Valeur\npar défaut"] -width 20 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.id -text [phgt::mc "Identifiant?"] -width 15 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.m -text "" -width 6 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.d -text "" -width 6 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.attributs.c.f.tete.e -text "" -width 5 -background [dict get $STYLES "background"] -relief solid
                    
                    pack $f.attributs.c.f.tete.nom $f.attributs.c.f.tete.type $f.attributs.c.f.tete.accces $f.attributs.c.f.tete.taille $f.attributs.c.f.tete.valeur $f.attributs.c.f.tete.id $f.attributs.c.f.tete.m $f.attributs.c.f.tete.d $f.attributs.c.f.tete.e -fill both -expand 1 -side left
                pack $f.attributs.c.f.tete -fill both
                ttk::frame $f.attributs.c.f.corps
                
                pack $f.attributs.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'entité est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.attributs.c.f.corps $table "entite"
                    }
            pack $f.attributs.c.f.liste -side left -fill x
        pack $f.attributs.c -side left -expand 1 -fill both
        $f.attributs.c create window 0 0 -anchor nw -window $f.attributs.c.f
        ttk::scrollbar $f.attributs.yscroll -command "$f.attributs.c yview"
        pack $f.attributs.yscroll -side right -fill y
        $f.attributs.c configure -scrollregion "0 0 1000 10000"
    pack $f.attributs -fill x -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.attributs.c configure -yscrollcommand "$f.attributs.yscroll set"
    
    ###
    # Méthodes de la classe
    ##
    ttk::frame $f.methodes
        # Commandes des attributs
        ttk::frame $f.methodes.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.methodes.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_MCD_INTERFACE_Objets_ajout_attribut "table"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.methodes.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_MCD_INTERFACE_Objets_suppression_attribut "table"}
            pack $f.methodes.commandes.ajout $f.methodes.commandes.supp -padx 10
        pack $f.methodes.commandes -side left -fill x
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.methodes.c -width 1200 -height 400 -background [dict get $STYLES "lbackground"] -highlightbackground [dict get $STYLES "graphics"]
        ttk::frame $f.methodes.c.f
            # Liste des attributs
            ttk::frame $f.methodes.c.f.liste
                ttk::label $f.methodes.c.f.titre -text [phgt::mc "Liste des Méthodes de la classe"]
                pack $f.methodes.c.f.titre -fill x
                ttk::frame $f.methodes.c.f.tete
                    ttk::label $f.methodes.c.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.type -text [phgt::mc "Type"] -width 15 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.accces -text [phgt::mc "Accès"] -width 10 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.taille -text [phgt::mc "Taille"] -width 10 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.valeur -text [phgt::mc "Valeur\npar défaut"] -width 20 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.id -text [phgt::mc "Identifiant?"] -width 15 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.m -text "" -width 6 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.d -text "" -width 6 -background [dict get $STYLES "background"] -relief solid
                    ttk::label $f.methodes.c.f.tete.e -text "" -width 5 -background [dict get $STYLES "background"] -relief solid
                    
                    pack $f.methodes.c.f.tete.nom $f.methodes.c.f.tete.type $f.methodes.c.f.tete.accces $f.methodes.c.f.tete.taille $f.methodes.c.f.tete.valeur $f.methodes.c.f.tete.id $f.methodes.c.f.tete.m $f.methodes.c.f.tete.d $f.methodes.c.f.tete.e -fill both -expand 1 -side left
                pack $f.methodes.c.f.tete -fill both
                ttk::frame $f.methodes.c.f.corps
                
                pack $f.methodes.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'entité est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.methodes.c.f.corps $table "entite"
                    }
            pack $f.methodes.c.f.liste -side left -fill x
        pack $f.methodes.c -side left -expand 1 -fill both
        $f.methodes.c create window 0 0 -anchor nw -window $f.methodes.c.f
        ttk::scrollbar $f.methodes.yscroll -command "$f.attributs.c yview"
        pack $f.methodes.yscroll -side right -fill y
        $f.methodes.c configure -scrollregion "0 0 1000 10000"
    pack $f.methodes -fill x -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.methodes.c configure -yscrollcommand "$f.attributs.yscroll set"
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command Katyusha_MCD_INTERFACE_Entites_COMMANDE_ajout_table
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {
            if {[winfo exists .fen_ajout_attribut]} {
                destroy .fen_ajout_attribut
            }
            destroy .fen_ajout_classe
        }
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f [phgt::mc "Ajouter une classe"]
    } else {
        wm title $f [phgt::mc "Éditer la classe %s" [list $E_nom_table]]
    }
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    # Mise à jour forcée de l'affichage graphique
    update
}
