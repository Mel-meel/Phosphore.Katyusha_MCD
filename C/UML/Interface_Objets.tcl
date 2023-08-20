## Créé le 9/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_UML_Interface_Objets_ajout_attribut {objet} {

}
proc Katyusha_UML_Interface_Objets_suppression_attribut {objet} {

}
proc Katyusha_UML_Interface_Objets_ajout_methode {objet} {

}
proc Katyusha_UML_Interface_Objets_suppression_methode {objet} {

}
proc Katyusha_UML_Interface_Objets_deplacer_attribut {f type_objet id_ancien id_nouveau} {
    global classe_tmp
    
    if {$type_objet == "classe"} {
        set classe_tmp [Katyusha_MCD_Objets_deplacer_attribut $classe_tmp $id_ancien $id_nouveau]
        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f $classe_tmp $type_objet
    }
}



##
# Fenêtre d'ajout d'une méthodes à un objet du diagramme UML
# Si l'ID d'un attribut est passé en paramètre, il s'agira alors de l'éditer
##
proc Katyusha_UML_Interface_Objets_ajout_methode {objet {id "null"}} {
    global classe_tmp
    global interface_tmp
    global STYLES
    global IMG
    global E_parametres_methode
    global E_nom_methode
    global E_type_methode
    global E_description_methode
    global E_acces_methode
    
    set f ".fen_ajout_methode"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    # Si l'id de la méthode est en édition
    #if {$id != "null"} {
        if {$objet == "classe"} {
            set methodes [dict get $classe_tmp "methodes"]
        } elseif {$objet == "interface"} {
            set methodes [dict get $interface_tmp "methodes"]
        }
    #}
    

    
    # Valeurs par défaut de l'attribut
    if {$id == "null"} {
        set E_parametres_methode ""
        set E_type_methode ""
        set E_acces_methode "private"
        set E_description_methode ""
        set E_nom_methode "Methode_[expr [dict size $methodes]]"
    } else {
        # Charge les données de l'attribut en édition
        set methode [dict get $methodes $id]
        set E_parametres_methode [dict get $methode "parametres"]
        set E_type_methode [dict get $methode "type"]
        set E_acces_methode [dict get $methode "access"]
        set E_description_attribut ""
        set E_nom_methode [dict get $methode "nom"]
    }
    
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de titre
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Propriétés de la méthode"]
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    
    # Propriétés de la méthode
    ttk::frame $f.prop
        # Nom de la méthode
        ttk::frame $f.prop.nom
            ttk::label $f.prop.nom.l -text [phgt::mc "Nom de la méthode : "] -width 40 -anchor w
            ttk::entry $f.prop.nom.e -textvariable E_nom_methode
            pack $f.prop.nom.l $f.prop.nom.e -side left -fill x
        
        # Type de la méthode
        ttk::frame $f.prop.type
            ttk::label $f.prop.type.l -text [phgt::mc "Type de la méthode : "] -width 40 -anchor w
            ttk::combobox $f.prop.type.cb -values [Katyusha_SQL_liste_types]
            pack $f.prop.type.l $f.prop.type.cb -side left -fill x
            if {$id != "null"} {
                $f.prop.type.cb set $E_type_methode
            }
        
        # Accès de la méthode
        ttk::frame $f.prop.access
            ttk::label $f.prop.access.l -text [phgt::mc "Accès de la méthode : "] -width 40 -anchor w
            ttk::combobox $f.prop.access.cb -values [list "private" "public" "protected"]
            pack $f.prop.access.l $f.prop.access.cb -side left -fill x
            $f.prop.access.cb set $E_acces_methode
        
        pack $f.prop.nom $f.prop.type $f.prop.access -fill x
        
    pack $f.prop -fill x -padx 20
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command "Katyusha_UML_Interface_Objets_ommande_ajout_methode $objet $id"
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Ajouter un attribut"]
    
    # Couleur de fond de la fenêtre
    $f configure -background [dict get $STYLES "lbackground"]
    
    update
}

proc Katyusha_UML_Interface_Objets_ommande_ajout_methode {objet {id "null"}} {
    global E_parametres_methode
    global E_nom_methode
    global E_type_methode
    global E_description_methode
    global E_acces_methode
    
    set f ".fen_ajout_methode"
    
    if {$objet == "classe"} {
        #set ok [Katyusha_UML_Objets_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut]
        set ok 1
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_UML_Classes_ajout_methode [$f.prop.nom.e get] $E_parametres_methode [$f.prop.type.cb get] $E_acces_methode $E_description_methode
            } else {
                #Katyusha_UML_Classes_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            }
            destroy $f
        }
    }
}
