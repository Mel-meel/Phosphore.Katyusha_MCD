#!/usr/bin/tclsh
#
#
#
# 7.11
#   - set menu.relief to solid.

set ap [file normalize [file dirname [info script]]]
if { $ap ni $::auto_path } {
  lappend ::auto_path $ap
}
set ap [file normalize [file join [file dirname [info script]] .. code]]
if { $ap ni $::auto_path } {
  lappend ::auto_path $ap
}
unset ap
package require awthemes

namespace eval ::ttk::theme::awdark {

  proc setBaseColors { } {
    global STYLES
    
    variable colors

    array set colors {
        style.arrow           solid-bg
        style.checkbutton     roundedrect-check
        style.menubutton      solid
        style.radiobutton     circle-circle-hlbg
        style.treeview        solid
        is.dark               true
    }
    set colors(bg.bg) [dict get $STYLES "background"]
    set colors(bg.dbg) [dict get $STYLES "dbackground"]
    set colors(bg.ddbg) [dict get $STYLES "ddbackground"]
    set colors(bg.lbg) [dict get $STYLES "lbackground"]
    set colors(graphics.color) [dict get $STYLES "graphics"]
    set colors(fg.fg) [dict get $STYLES "foreground"]
  }

  proc setDerivedColors { } {
    variable colors

    set colors(arrow.color) $colors(fg.fg)
    set colors(border) #000000
    set colors(border.scale) $colors(bg.dbg)
    set colors(border.tab) $colors(bg.lbg)
    set colors(button) $colors(bg.dbg)
    set colors(button.active) $colors(bg.lbg)
    set colors(button.anchor) {}
    set colors(button.padding) {5 3}
    set colors(entrybg.bg) $colors(bg.dbg)
    set colors(entry.padding) {5 1}
    set colors(menubutton) $colors(bg.lbg)
    set colors(menubutton.background) $colors(bg.bg)
    set colors(menubutton.padding) {5 2}
    set colors(menu.relief) solid
    set colors(menu.background) $colors(bg.bg)
    set colors(notebook.tab.focusthickness) 5
    set colors(scrollbar.color.grip) #000000
    set colors(select.bg) $colors(graphics.color)
    set colors(spinbox.color.bg) $colors(graphics.color)
    set colors(tab.active) $colors(bg.ddbg)
    set colors(tab.disabled) $colors(bg.ddbg)
    set colors(tab.inactive) $colors(bg.ddbg)
    set colors(tab.selected) $colors(bg.ddbg)
    set colors(tab.use.topbar) true
    set colors(trough.color) $colors(bg.dbg)
  }

  proc init { } {
    set theme awdark
    set version 7.12
    ::ttk::awthemes::init $theme
    package provide $theme $version
    package provide ttk::theme::${theme} $version
  }

  init
}
