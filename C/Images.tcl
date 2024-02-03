## Créé le 22/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Images {} {
    global rpr
    global IMG
    
    set IMG(logo) [image create photo -file "$rpr/images/katyusha_mcd_icone.png"]
    set IMG(icone_preferences_x48) [image create photo -file "$rpr/images/preferences-x48.png"]
    set IMG(logo_x48) [image create photo -file "$rpr/images/logo-x48.png"]
    set IMG(ajouter) [image create photo -file "$rpr/images/ajouter.png"]
    set IMG(supprimer) [image create photo -file "$rpr/images/supprimer.png"]
    set IMG(ajouter_table) [image create photo -file "$rpr/images/ajouter_table.png"]
    set IMG(ajouter_relation) [image create photo -file "$rpr/images/ajouter_relation.png"]
    set IMG(ajouter_heritage) [image create photo -file "$rpr/images/ajouter_heritage.png"]
    set IMG(ajouter_etiquette) [image create photo -file "$rpr/images/ajouter_etiquette.png"]
    set IMG(ajouter_classe) [image create photo -file "$rpr/images/ajouter_classe.png"]
    set IMG(ajouter_interface) [image create photo -file "$rpr/images/ajouter_interface.png"]
    set IMG(splash) [image create photo -file "$rpr/images/splash_1.0.x.png"]
    set IMG(editer) [image create photo -file "$rpr/images/editer-x32.png"]
    set IMG(valider) [image create photo -file "$rpr/images/valider-x32.png"]
    set IMG(retour) [image create photo -file "$rpr/images/retour-x32.png"]
    set IMG(gen_sql) [image create photo -file "$rpr/images/gen_sql-x32.png"]
    set IMG(zoom_plus) [image create photo -file "$rpr/images/zoom-in.png"]
    set IMG(zoom_moins) [image create photo -file "$rpr/images/zoom-out.png"]
    set IMG(zoom_initial) [image create photo -file "$rpr/images/zoom-original.png"]
    set IMG(defaire) [image create photo -file "$rpr/images/defaire_x48.png"]
    set IMG(refaire) [image create photo -file "$rpr/images/refaire_x48.png"]
    set IMG(pk) [image create photo -file "$rpr/images/pk.png"]
    set IMG(GNU) [image create photo -file "$rpr/images/license.png"]
    set IMG(fleche_haut) [image create photo -file "$rpr/images/fleche_haut.png"]
    set IMG(fleche_bas) [image create photo -file "$rpr/images/fleche_bas.png"]
}
