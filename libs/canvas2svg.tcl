

proc Katyusha_SVG_taille_svg {canvas} {
    dict set tailles tables [$canvas bbox "table"]
    dict set tailles relation [$canvas bbox "relation"]
    dict set tailles heritage [$canvas bbox "heritage"]
    dict set tailles etiquettes [$canvas bbox "etiquette"]
    
    set taille [list 0 0]
    
    foreach {k v} $tailles {
        if {$v != ""} {
        if {[lindex $v 2] > [lindex $taille 0]} {
            set taille [list [lindex $v 2] [lindex $taille 1]]
        }
        if {[lindex $v 3] > [lindex $taille 1]} {
            set taille [list [lindex $taille 0] [lindex $v 3]]
        }
        }
    }
    return $taille
}

# http://thecoccinella.org

proc canvas2svg {c} {
    set taille [Katyusha_SVG_taille_svg $c]
    set res "<svg xmlns='http://www.w3.org/2000/svg'[att width [lindex $taille 0]][att height [lindex $taille 1]]>\n"
    # Adjustment when scroll region is shifted
    lassign [concat [$c cget -scrollregion] 0 0 0 0] x0 y0 x1 y1
    set dx [expr {-$x0}]
    set dy [expr {-$y0}]

    foreach item [$c find all] {
        set tags [$c gettags $item]
        if {[lindex $tags 0] != "grille"} {
        set type [$c type $item]
        set atts ""
        #foreach {x0 y0 x1 y1} \
        #    [string map {".0 " " "} "[$c coords $item] "] break
        lassign [$c coords $item] x0 y0 x1 y1
        catch {set fill [rgb2xcolor [$c itemcget $item -fill]]}
        catch {set stroke [rgb2xcolor [$c itemcget $item -outline]]}
        catch {set width [expr round([$c itemcget $item -width])]}
        set pts {}
        foreach {x y} [$c coords $item] {
           lappend pts [list [expr {round($x) + $dx}] [expr {round($y) + $dy}]]
        }
        switch -- $type {
            line {
                set type "polyline"
                append atts [att points [join $pts ", "]]
                append atts [att stroke $fill #000000]
                append atts [att stroke-width $width 1]
            }
            oval {
                set type "ellipse"
                append atts [att cx [expr {($x0+$x1)/2}]]
                append atts [att cy [expr {($y0+$y1)/2}]]
                append atts [att rx [expr {($x1-$x0)/2}]]
                append atts [att ry [expr {($y1-$y0)/2}]]
                append atts [att fill $fill #000000][att stroke $stroke none]
                append atts [att stroke-width $width 1]
            }
            polygon {
                append atts [att points [join $pts ", "]]
                append atts [att fill $fill #000000][att stroke $stroke none]
                append atts [att stroke-width $width 1]
            }
            rectangle {
                set type "rect"
                append atts [att x $x0][att y $y0]
                append atts [att width  [expr {$x1-$x0}]]
                append atts [att height [expr {$y1-$y0}]]
                append atts [att fill $fill #000000][att stroke $stroke none]
                append atts [att stroke-width $width 1]
            }
        }
        append res "  <$type$atts"
        append res " />\n"
        
        }
    }

    foreach item [$c find all] {
        set tags [$c gettags $item]
        if {[lindex $tags 0] != "grille"} {
        set type [$c type $item]
        set atts ""
        #foreach {x0 y0 x1 y1} \
        #    [string map {".0 " " "} "[$c coords $item] "] break
        lassign [$c coords $item] x0 y0 x1 y1
        catch {
            if {$type == "text"} {
                set fill "black"
            } else {
                set fill [rgb2xcolor [$c itemcget $item -fill]]
            }
        }
        catch {set stroke [rgb2xcolor [$c itemcget $item -outline]]}
        catch {set width [expr round([$c itemcget $item -width])]}
        set pts {}
        foreach {x y} [$c coords $item] {
           lappend pts [list [expr {round($x) + $dx}] [expr {round($y) + $dy}]]
        }
        switch -- $type {
            
            text {
                append atts [att x [expr $x1 - $x0]][att y [expr $y0]][att "font-size" 16][att fill $fill #000000]
                set text [$c itemcget $item -text]
            }
        }
        append res "  <$type$atts"
        if {$type=="text"} {
            set texte [split $text "\n"]
            set hauteur [llength $texte]
            set text ""
            set y [expr $y0 - (($hauteur / 2) * 16) + ((($hauteur / 2) * 17) * 0.1)]
            foreach ligne $texte {
                set text "$text<tspan x=\"$x0\" y=\"$y\">$ligne</tspan>\n"
                set y [expr $y + 16]
            }
            append res ">$text</$type>\n"
        } else {
            append res " />\n"
        }
        }
    }
    append res "</svg>"
    return $res
}
proc att {name value {default -}} {
    if {$value != $default} {return " $name=\"$value\""}
}
proc rgb2xcolor rgb {
    if {$rgb == ""} {return none}
    foreach {r g b} [winfo rgb . $rgb] break
    format #%02x%02x%02x [expr {$r/256}] [expr {$g/256}] [expr {$b/256}]
}
