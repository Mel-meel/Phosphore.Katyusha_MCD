proc Katyusha_SVG_canvas {canvas} {
    global 
    
    set taille [Katyusha_SVG_taille_svg $c]
    set res "<svg xmlns='http://www.w3.org/2000/svg'[att width [lindex $taille 0]][att height [lindex $taille 1]]>\n"



    set res "$res</svg>\n"
}
