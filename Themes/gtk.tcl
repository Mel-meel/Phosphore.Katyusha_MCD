# style/gtk.tcl --
#
#	This file implements package style::gtk
#
# Copyright (c) -- none, but stolen by wiki.tcl.tk/gtklook.tcl (2006)
#

package provide ttk::theme::gtk 0.1

namespace eval ttk {
  namespace eval theme {
    namespace eval gtk {
      variable version 0.1
    }
  }
}

namespace eval ttk::theme::gtk {
    if { [tk windowingsystem] == "x11" } {
	option add *borderWidth 1 widgetDefault
	option add *activeBorderWidth 1 widgetDefault
	option add *selectBorderWidth 1 widgetDefault
	option add *font -adobe-helvetica-medium-r-normal-*-12-*-*-*-*-*-*

	option add *padX 2
	option add *padY 4

	option add *Listbox.background white
	option add *Listbox.selectBorderWidth 0
	option add *Listbox.selectForeground white
	option add *Listbox.selectBackground \#4a6984

	option add *Entry.background white
	option add *Entry.foreground black
	option add *Entry.selectBorderWidth 0
	option add *Entry.selectForeground white
	option add *Entry.selectBackground \#4a6984

	option add *Text.background white
	option add *Text.selectBorderWidth 0
	option add *Text.selectForeground white
	option add *Text.selectBackground \#4a6984

	option add *Menu.activeBackground \#4a6984
	option add *Menu.activeForeground white
	option add *Menu.activeBorderWidth 0
	option add *Menu.highlightThickness 0
	option add *Menu.borderWidth 2

	option add *MenuButton.activeBackground \#4a6984
	option add *MenuButton.activeForeground white
	option add *MenuButton.activeBorderWidth 0
	option add *MenuButton.highlightThickness 0
	option add *MenuButton.borderWidth 0

	option add *highlightThickness 0
	option add *troughColor \#bdb6ad
    }
}
# end of namespace style::gtk

package provide ttk::theme::gtk $::ttk::theme::gtk::version
