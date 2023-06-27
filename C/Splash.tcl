## Créé le 22/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

proc Katyusha_Splash {rpr} {
    global IMG
    # Titre de la fenêtre principale
    wm title . "Katyusha MCD - Chargement..."
    
    set resolution [Katyusha_Configurations_resolution]
    set x [lindex $resolution 0]
    set y [lindex $resolution 1]
    
    # Récupération des images du splash
    image create photo splash -file "$rpr/images/splash_1.0.x.png"

    # Variables de placement du splash
    set width_t 850
    set height_t 500
    set xs [expr ($x/2)-($width_t/2)]
    set ys [expr ($y/2)-($height_t/2)]

    # Variable de choix du splash
    set splash [expr int(rand()*5)]

    # Dimension de la fenêtre
    label .image -image splash
    pack .image

    set geo "800x500"
    wm geometry . $geo+$xs+$ys
    #wm overrideredirect . 1
    # On actualise, sinon, rien!
    update
}
