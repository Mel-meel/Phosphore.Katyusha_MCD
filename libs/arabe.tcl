#Code written by Rani Fayez Ahmad (Superlinux)
#Website: http://www.superlinux.net

#The following procedure is used to extract all ASCII string parts from the Unicode string. in tk_messageBox after rendering to Arabic they come reversed
#So this fix has been added
# It will give the pairs :  (ASCII string part | ASCII string starting index in the Unicode string) .
proc list_of_all_ascii_parts_a_unicode_string { arabic_string} {

set ascii_parts_list [list]
set length [string length $arabic_string]
    for {set i 0} {$i< $length} {incr i} {
        set start_of_ascii $i
        
        set end_of_ascii  $start_of_ascii 
        while {[string is ascii [
            string range $arabic_string $start_of_ascii $end_of_ascii]] ==  1
            && $i<$length}  {
          
                puts [
                    string range $arabic_string $start_of_ascii $end_of_ascii]
                incr i
                incr end_of_ascii 
        }
        
        incr end_of_ascii -1
        
        set ascii_part [
            string range $arabic_string $start_of_ascii $end_of_ascii]
        
        if {[string trim $ascii_part] ne {}} {
          set ascii_parts_list [
              linsert $ascii_parts_list end [list $ascii_part $start_of_ascii]]
        }
    }
    return $ascii_parts_list
}

#a procedure to make Arabic readable when displayed in a Tk widget.
    
proc render_arabic args {
    set  arabic_string [lindex $args 0]
    set  is_messageBox [lindex $args 1]

    #The given of the problem is an Arabic sentence
    
    #Break the sentence into words
    set  words [split [string trim $arabic_string]]
    
    #Display the sentence the way TCL receives it
    #The problem is:
    #Tcl receives the Arabic letters: (i) in the reverse order (ii)
    #disconnected.  We want to re-render the Arabic to be displayed correctly
    #tk_messageBox -message $words
    
    #$count is the word index in the arabic sentence   
    set count 0
    
    #the following is just an example of how to get an arabic character index
    #number in the unicode character charts
    #set z {} ; foreach el [split ل {}] {puts [scan $el %c]}
     
    #foreach word in the arabic sentence 
    foreach word $words {
        if {[string is ascii $word]} {
            incr count
            continue
        } 
         
        #else {
        #    set splits [split $word "!@#$%^&*()_+-=~`123456790/\\"]
        #    if {[llength $splits] > 1} {
        #        set split_counter 0
        #        foreach splitting $splits {
        #            set splitting [render_arabic $splitting]
        #            lset splits $split_counter $splitting
        #            incr split_counter
        #        }
        #        set word [join splits]
        #        incr count
        #        continue
        #    }
        #}
         
        #1-get the  substring in the word without the last letter
        #we will deal with the connection of the last letter later
        set original_word $word
        set sub_word [string range $word 0 end-1]
        
        #All the letters from baa2 to yaa2 when they are NOT the last letter;
        #TCL initially has and reads them in their isolated form as in ل م س;
        #they must be converted into their initial form e.g ل م س
        #so replace and convert every occurrence of each of such letters

        #Also other Arabic-like characters like Urdu, Persian, Kurdish... etc, 
        #You may add them similarly over here
        
        set sub_word [ string map {\u0628 \ufe91} $sub_word] ;#ba2
        set sub_word [ string map {\u062A \ufe97} $sub_word] ;#Ta2
        set sub_word [ string map {\u062B \ufe9b} $sub_word] ;#thaa2
        set sub_word [ string map {\u062C \ufe9f} $sub_word] ;#Jeem
        set sub_word [ string map {\u062d \ufea3} $sub_word] ;#7aa2
        set sub_word [ string map {\u062e \ufeA7} $sub_word] ;#5aa2
        set sub_word [ string map {\u0633 \ufeb3} $sub_word] ;#seen
        set sub_word [ string map {\u0634 \ufeb7} $sub_word] ;#sheen
        set sub_word [ string map {\u0635 \ufebb} $sub_word] ;#SSaad
        set sub_word [ string map {\u0636 \ufebf} $sub_word] ;#DDhahd
        set sub_word [ string map {\u0637 \ufec3} $sub_word] ;#TTaa2
        set sub_word [ string map {\u0638 \ufec7} $sub_word] ;#tthaa2 Zah
        set sub_word [ string map {\u0639 \ufeCb} $sub_word] ;#3eyn
        set sub_word [ string map {\u063A \ufeCF} $sub_word] ;#ghyn
        set sub_word [ string map {\u0641 \ufeD3} $sub_word] ;#faa2
        set sub_word [ string map {\u0642 \ufeD7} $sub_word] ;#quaaf
        set sub_word [ string map {\u0643 \ufeDb} $sub_word] ;#kaaf
        set sub_word [ string map {\u0644 \ufedf} $sub_word] ;#lam
        set sub_word [ string map {\u0645 \ufee3} $sub_word] ;#meem
        set sub_word [ string map {\u0646 \ufee7} $sub_word] ;#noon
        set sub_word [ string map {\u0647 \ufeeb} $sub_word] ;#haa2
        set sub_word [ string map {\u064A \ufef3} $sub_word] ;#yaa2
        set sub_word [ string map {\u0626 \ufe8b} $sub_word] ;#hamza 3ala nabera (initial form of yaa2)
        
        #now replace the whole part of the word that excludes the last letter
        #with the conversion done above
        
        set word [string replace $word 0 end-1 $sub_word]
        
        #The following list of characters are the characters initial form
        #mentioned above + the tatweel chacracter
        set initials [list \u0640 \ufe90 \ufe97 \ufe9b \ufe9f \ufea3 \ufeA7 \
            \ufb3 \ufeb7 \ufebb \ufebf \ufec3 \ufec7 \ufeCb \ufeCF \ufeD3 \
            \ufeD7 \ufeDb \ufedf \ufee3 \ufee7 \ufeeb \ufef3]
        
     
        #find the character before the last.
        
        set before_last_char [string index $word end-1]
        
        #for debugging purposes just print the character before the last.
        ## puts $before_last_char
        
        #and try to see if  the character before the last is a word in the list
        #$initials defined in the previous line.
        #and if its true, then convert the last character to it's final linked
        #form
        #this way they will be joined
        if {[lsearch -ascii -inline $initials $before_last_char]
            eq $before_last_char} {
            
            #now get also last chacracter
            set last_character [string index $word end]
            
            #print it for debugging purposes
            ##puts $last_character
            
            #just to make sure that we we are matching correctly print the unicode
            #index number of the character
            ##puts [scan $last_character %c]
            if {[string is ascii $last_character]} {
                set before_last_char [render_arabic $before_last_char]
            }
            
            #\u0627 {
            #    #aleph
            #    set word [ string replace $word end end \ufe8e ]
            #}
            #now convert the last character into its final linked form
            switch -- $last_character {
                \u0628 {
                    #baa2
                    set word [string replace $word end end \ufe90]
                }
                \u0629 {
                    #taa2 marbootta
                    set word [string replace $word end end \ufe94]
                }
                \u062A {
                    #ta2 maftoo7a
                    set word [string replace $word end end \ufe96]
                }
                \u062B {
                    #thaa2
                    set word [string replace $word end end \ufe9A]
                }
                \u062c {
                    #jeem
                    set word [string replace $word end end \ufe9e]
                    puts $word
                }
                \u062d {
                    #7aa2
                    set word [string replace $word end end \ufeA2]
                }

                \u062e {
                    #5aa2
                    set word [string replace $word end end \ufea6]
                }

                \u062f {
                    #dal
                    set word [string replace $word end end \ufeaa]
                }

                \u0630 {
                    #tthal
                    set word [string replace $word end end \ufeac]
                }
                \u0631 {
                    #raa2
                    set word [string replace $word end end \ufeae]
                }
                \u0632 {
                    #zyn
                    set word [string replace $word end end \ufeaf]
                }

                \u0633 {
                    #seen
                    set word [string replace $word end end \ufeb2]
                }
                \u0634 {
                    #sheen
                    set word [string replace $word end end \ufeb6]
                }
                \u0635 {
                    #ssaad
                    set word [string replace $word end end \ufeba]
                }
                \u0636 {
                    #ddaad
                    set word [string replace $word end end \ufebe]
                }
                \u0637 {
                    #ttaa2
                    set word [string replace $word end end \ufec2]
                }
                \u0638 {
                    #tthaa2
                    set word [string replace $word end end \ufec8]
                }
                \u0639 {
                    #3ayn
                    set word [string replace $word end end \ufeca]
                }
                \u063a {
                    #ghyn
                    set word [string replace $word end end \ufece]
                }
                \u0641 {
                    #faa2
                    set word [string replace $word end end \ufed2]
                }
                \u0642 {
                    #quaaf
                    set word [string replace $word end end \ufed6]
                }
                \u0643 {
                    #kaaf
                    set word [string replace $word end end \ufeda]
                }
                  \u0644 {
                    #laam
                    set word [ string replace $word end end \ufede ]
                }
                \u0645 {
                    #meem
                    set word [string replace $word end end \ufee2]
                }
                \u0646 {
                    #noon
                    set word [string replace $word end end \ufee6]
                }
                \u0647 {
                    #haa2
                    set word [string replace $word end end \ufeea]
                }
                \u0648 {
                    #waaw
                    set word [string replace $word end end \ufeee]
                }
                \u0624 {
                    #waaw with hamza above
                    set word [ string replace $word end end \ufe86]
                }
                \u0649 {
                    #alef maqsura
                    set word [string replace $word end end \ufef0]
                }
                \u064a {
                    #yaa2
                    set word [string replace $word end end \ufef1]
                }
                default {
                    #default is nothing to do
                }
            }
     
        }
        # end of if the character before the last is a member of the list
        # $initials
         
        #now reverse every occurrence of the word for correct displaying on the
        #screen

        set arabic_string [
            regsub -all "\\m$original_word\\M" $arabic_string $word]

        #add and replace the corrected/conversion-of word with malformed one. in
        #the arabic sentence
        #the whole words in the sentence yet are still in the reverse order
        #lset words $count $word
        
        #move to the  next word
        incr count
    }
    
    #The following 2 line is left for you to see the final result. just remove
    #the comment sign (#)
    #tk_messageBox -message $words
    #puts "before return: $arabic_string \n is_messageBox=$is_messageBox"
    
    #reverse the whole string
    set arabic_string [string reverse $arabic_string]
     
    #If you see that the ASCII string parts of the whole Arabic/Unicode are
    #reversed, then add another one and only one additional parameter to the
    #Arabic/Unicode string and set it only to
    #"1" (the number ONE).

    if { $is_messageBox ==1 } {
    foreach part [list_of_all_ascii_parts_a_unicode_string $arabic_string] {
        set part_string [string reverse [ lindex $part 0 ]]
        set start_of_ascii [ lindex $part 1 ]
        set length_part_string [string length $part_string]
        
        set arabic_string [string replace $arabic_string $start_of_ascii [expr $start_of_ascii + $length_part_string -1] $part_string]
      
    }
  }
  return $arabic_string 
}
