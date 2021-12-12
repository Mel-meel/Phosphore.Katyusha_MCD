set fichier "Base-mysql.sql"

##
# Nettoie les espaces vides
##
proc Katyusha_RE_nettoyage_espaces_vides {contenu} {
    set contenu [string map {"\t" ""} $contenu]
    set contenu [string map {"\r" ""} $contenu]
    set contenu [string map {"\n" ""} $contenu]
    
    while {[string first "  " $contenu] != -1} {
        set contenu [string map {"  " " "} $contenu]
    }
    
    return $contenu
}

proc Katyusha_RE_isoler_commandes_creation_tables {commandes} {
    set commandes_tables [list]
    
    foreach commande $commandes {
        set debut [string first "CREATE" [string toupper $commande]]
        if {$debut != -1} {
            set suite [string first "TABLE" [string toupper $commande] $debut]
            if {$suite != -1} {
                puts $commande
            }
        }
    }
    return $commandes_tables
}

##
# Supprime les commentaires
##
proc Katyusha_RE_supprimer_commentaires {contenu} {
    
    # Commentaires "/* ... */"
    set debut 0
    while {[string first "/*" $contenu $debut] != -1} {
        set debut_com [string first "/*" $contenu $debut]
        set fin_com [string first "*/" $contenu $debut_com]
        
        set commentaire [string range $contenu $debut_com [expr $fin_com + 1]]
        # Supprime le commentaire trouvé
        set contenu [string map [list $commentaire ""] $contenu]
        
        set debut $fin_com
    }
    
    # Commentaires "-- ..."
    set debut 0
    while {[string first "--" $contenu $debut] != -1} {
        set debut_com [string first "--" $contenu $debut]
        set fin_com [string first "\n" $contenu $debut_com]
        
        set commentaire [string range $contenu $debut_com [expr $fin_com - 1]]
        # Supprime le commentaire trouvé
        set contenu [string map [list $commentaire ""] $contenu]
        
        set debut $fin_com
    }
    
    # Commentaires "# ..."
    set debut 0
    while {[string first "#" $contenu $debut] != -1} {
        set debut_com [string first "#" $contenu $debut]
        set fin_com [string first "\n" $contenu $debut_com]
        
        set commentaire [string range $contenu $debut_com [expr $fin_com - 1]]
        # Supprime le commentaire trouvé
        set contenu [string map [list $commentaire ""] $contenu]
        
        set debut $fin_com
    }
    
    return $contenu
}

##
# Ouvre et lis le contenu d'un fichier
##
proc file_read {fichier acces} {
    if {[file exists $fichier]} {
        set fp [open $fichier $acces]
        set file_data [read $fp]
        close $fp
    } else {
        set file_data "Aucun fichier de ce nom : $fichier"
    }
    return $file_data
}

set contenu [file_read $fichier "r"]


# Supprime les commentaires
set contenu [Katyusha_RE_supprimer_commentaires $contenu]
# Nettoie le fichier
set contenu [Katyusha_RE_nettoyage_espaces_vides $contenu]

# Coupe le contenu en commandes SQL
set commandes [split $contenu ";"]
#puts $commandes

set commandes_tables [Katyusha_RE_isoler_commandes_creation_tables $commandes]
puts $commandes_tables

