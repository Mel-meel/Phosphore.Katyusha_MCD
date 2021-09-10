  if {[info exists ::tip::version]} { return }

  namespace eval ::tip \
  {
  # ########################
  # package tip
  # ajoute une bulle d'aide à un widget
  #
  variable version 1.2.2
  #
  # (C) 2007, ulis
  # Licence NOL (No Obligation Licence)
  # ------------------------
  # v 1.1
  #   désactivation d'une bulle avec un texte vide
  #   ajout de paramètres internes
  # v 1.2
  #  utilisation des classes de bindings
  #  (pour ne pas polluer les bindings du widget)
  # ########################

    # export du point d'entrée
    namespace export tip

    # gestion des packages
    package require Tk
    package provide tip $version

    # variable globale
    variable {}
    array set {} \
    {
      -color     gold
      -delay1    500
      -delay2    3500
      -height    20
      -width     60
    }

    # bindings de la classe Tip
    bind Tip <Enter> [list ::tip::enter %W %X %Y]
    bind Tip <Leave> [list ::tip::leave %W]
    bind Tip <Motion> [list ::tip::motion %W %X %Y]

    # procédure pour attacher une bulle à un widget
    proc tip {w text} \
    {
      # accès à la variable globale
      variable {}
      # test du type d'opération
      if {$text ne ""} \
      {
        if {![info exists ($w:hide)]} \
        {# création des bindings de la bulle
          bindtags $w [linsert [bindtags $w] 0 Tip]
          puts "bindtags $w [linsert [bindtags $w] 0 Tip]"
        }
        # initialisation des variables utilisées
        foreach name [array names {} -*] { set ($w:$name) $($name) }
        set ($w:text) $text
        set ($w:after) ""
        set ($w:shown) 0
        set ($w:hide) 0
      } \
      elseif {[info exists ($w:hide)]} \
      {# désactivation des bindings de la bulle
        set ($w:hide) 1
      }
    }

    # action quand on entre dans la surface du widget
    proc enter {w x y} \
    {
      # recherche de la fenêtre à bulle
      set w [::tip::tipped $w]
      if {$w eq ""} { return }
      # accès à la variable globale
      variable {}
      # test si activé
      puts "hide $($w:hide)"
      if {$($w:hide)} { return }
      # nettoyage initial
      leave $w
      # affichage de la bulle
      set ($w:after) [after $($w:-delay1) ::tip::show $w $x $y]
    }

    # action quand on sort de la surface du widget
    proc leave {w} \
    {
      # recherche de la fenêtre à bulle
      set w [tipped $w]
      if {$w eq ""} { return }
      # accès à la variable globale
      variable {}
      # nettoyage des évènements et de la bulle
      catch { after cancel $($w:after) }
      catch { destroy $w.tip }
      set ($w:after) ""
      set ($w:shown) 0
    }

    # action quand on bouge dans la surface du widget
    proc motion {w x y} \
    {
      # recherche de la fenêtre à bulle
      set w [::tip::tipped $w]
      if {$w eq ""} { return }
      # accès à la variable globale
      variable {}
      # affichage de la bulle si pas déjà fait
      if {!$($w:shown)} { ::tip::enter $w $x $y }
    }

    # création de la bulle d'aide
    proc show {w x y} \
    {
      # recherche de la fenêtre à bulle
      set w [tipped $w]
      if {$w eq ""} { return }
      # accès à la variable globale
      variable {}
      # nettoyage initial
      leave $w
      # indicateur d'affichage
      set ($w:shown) 1
      # création de la bulle
      toplevel $w.tip -padx 0 -pady 0
      wm overrideredirect $w.tip 1
      label $w.tip.l -text $($w:text) \
        -bd 1 -relief solid -bg $($w:-color)
      grid $w.tip.l -sticky nsew
      grid rowconfig $w.tip 0 -weight 1
      grid columnconf $w.tip 0 -weight 1
      set ww $($w:-width)
      set hh $($w:-height)
      set ww2 [expr {$ww / 2}]
      wm minsize $w.tip $ww $hh
      wm geometry $w.tip +[incr x -$ww2]+[incr y -$hh]
      # armement de la suppression de la bulle
      set ($w:after) [after $($w:-delay2) ::tip::leave $w]
    }

    # recherche du parent à la bulle
    proc tipped {w} \
    {
      set found 0
      while (1) \
      {
        if {[winfo toplevel $w] eq $w} { break }
        if {[lsearch -exact [bindtags $w] Tip] > -1} \
        {
          set found 1
          break
        }
        set w [winfo parent $w]
      }
      return [expr {$found ? $w : ""}]
    }
  }
  # import du point d'entrée
  namespace import ::tip::tip