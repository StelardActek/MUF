(  Lib-Ansify.muf -FUZZBALL6- v1.1
   Set of library routines for easily 'ansifying' programs.
   Written by Stelard Actek, with some parts being based off other libs.
   Comments and Ideas to: stelardactek@bigpond.com
   
   Requires:
      At least Muck2.2fb6.00b4
      .confirm
      .tell
      .yes?
)
(
   ansify-unparseobj [ d -- s ]
      Just like unparseobj, but returns an ANSI coded coloured string.
      Colour code can be changed with the defines below.
   
   ansify-name [ d -- s ]
      As above, but replacing the name prim instead of the unparseobj.
   
   ansify-unparse [ d -- s ]
      Once again, as above, but replacing the .unparse function from lib-look.
      Ie. It checks me @ and returns either name or unparseobj depending on its
      permissions.
 
   ansify-gender [ s -- 's ]
      Most of use to those writing room listings, this function will take a
      gender string [E.g. 'female', 'male', 'herm'] and return it colour coded.
 
   ansify-list-contents [ s d -- ]
      Calls get-contents followed by ansify-long-display to print out all of
      the contents of the given dbref. If there are any contents listed, then
      the string on the stack is printed out, for "Contents:" or the like.
      If the contents list is empty, the string is ignored.
   
   ansify-long-display [ d... i -- ]
      List the dbref stack range given, in the usual format for the server.
      All elements on separate lines, using ansify-unparse.  The bottom
      element is printed first.
   
   ansify-short-list [ d... i -- s ]
      Turns the range of dbrefs on the stack into a properly formatted string,
      with commas and colour codes. 1 element is just returned, 2 elements
      returns '1 and 2', more elements return '1, 2, 3, and 4' or similar. 
      Returns a null string if there are no elements. Again, the bottom element
      is first in the list.
   
   ansify-short-display [ d... i -- ]
      Calls ansify-short-list, then prints out "You see <string>." to the user.
      Prints "You see nothing." if nothing is on the list.
   
   ansify-exitname [ d -- s ]
      Returns a compiled and colour coded string for exit names. If the
      environment prop 'ansify/altexit?' is set to 'yes', then it automatically
      puts the first alternative in brackets.
      Eg.  An exit named 'To the Outside;Out;o;etc.' would become
      'To the Outside [Out]', with, by default, green for the main text, and
      yellow for the text and the parentheses. Handy for exit listers. Will now
      also show exits locked to me @ in a different colour.
   
   ansi-tell [ s -- ]
   ansi-notify [ d s -- ]
   ansi-notify-except [ d d s -- ]
   ansi-notify-exclude [ d dn ... d1 n s -- ]
   ansi-connotify [ i s -- ]
      All of these are included to emulate parsing of the colour codes used by
      lib-ansi-free and, apparently, GlowMUCK. This is so that programs written
      for them can be more easily ported, and to allow those who find it easier
      to work with said codes. The codes follow the form ~&abc, where 'a' is
      the attribute, 'b' is the foreground colour, and 'c' is the background
      colour. See the table below for details:
      
         No.   Attribute:        Colour:
         --    ---------         ------
         0     Reset             Black
         1     Bold              Red
         2     Faint             Green
         3     Italic            Yellow
         4                       Blue
         5     Blink             Magenta
         6     Rapid blink       Cyan
         7     Reverse           White
         8     Concealed
      
      Also supported is the code ~&R, which will is interpreted as the reset
      attribute alone. ~&B [bell] and ~&C [Clear] are filtered out, but not
      supported as yet.
      
      NB: Most clients do not support all of these attributes, and some
          interpret them differently. Case in point, Bold usually signafies
          the use of bright colour as apposed to dim.
   
   ansi-convert [ s -- s ]
      Simply takes a string and converts all of the lib-ansi-free in it
      [mentioned above] to real escape codes. For those who only use them
      occasionally.
   
   libansi-strcut [ s i -- s s ]
   libansi-strip [ s -- s ]
   libansi-strlen [ s -- i ]
      These are just like strcut, strip and strlen, except that they ignore
      both real ANSI escape codes, and lib-ansi-free colour codes.
)
(
@set $lib/ansify=_docs:@list $lib/ansify=1-102
@set $lib/ansify=_defs/ansi-convert:"$lib/ansify" match "ansi-convert" call
@set $lib/ansify=_defs/ansi-notify:"$lib/ansify" match "ansi-notify" call
@set $lib/ansify=_defs/ansi-notify-except:"$lib/ansify" match "ansi-notify-except" call
@set $lib/ansify=_defs/ansi-notify-exclude:"$lib/ansify" match "ansi-notify-exclude" call
@set $lib/ansify=_defs/ansi-notify_except:"$lib/ansify" match "ansi-notify-except" call
@set $lib/ansify=_defs/ansi-notify_exclude:"$lib/ansify" match "ansi-notify-exclude" call
@set $lib/ansify=_defs/ansi-tell:"$lib/ansify" match "ansi-tell" call
@set $lib/ansify=_defs/ansify-exitname:"$lib/ansify" match "ansify-exitname" call
@set $lib/ansify=_defs/ansify-list-contents:"$lib/ansify" match "ansify-list-contents" call
@set $lib/ansify=_defs/ansify-long-display:"$lib/ansify" match "ansify-long-display" call
@set $lib/ansify=_defs/ansify-name:"$lib/ansify" match "ansify-name" call
@set $lib/ansify=_defs/ansify-short-display:"$lib/ansify" match "ansify-short-display" call
@set $lib/ansify=_defs/ansify-short-list:"$lib/ansify" match "ansify-short-list" call
@set $lib/ansify=_defs/ansify-unparse:"$lib/ansify" match "ansify-unparse" call
@set $lib/ansify=_defs/ansify-unparseobj:"$lib/ansify" match "ansify-unparseobj" call
@set $lib/ansify=_defs/ansify-gender:"$lib/ansify" match "ansify-gender" call
@set $lib/ansify=_defs/ansify-sex:"$lib/ansify" match "ansify-gender" call
@set $lib/ansify=_defs/libansi-strcut:"$lib/ansify" match "libansi-strcut" call
@set $lib/ansify=_defs/libansi-strip:"$lib/ansify" match "libansi-strip" call
@set $lib/ansify=_defs/libansi-strlen:"$lib/ansify" match "libansi-strlen" call
)
$ifdef __version<Muck2.2fb6.00 
   $abort Designed to compile on Muck2.2fb6.00 or later!
$endif
$author Stelard Actek of StelTechCor @ FurryMUCK!
$version 1.1
$def BellSeq ""
$def p_on_player "_prefs/ansify/on_player"
$def p_off_player "_prefs/ansify/off_player"
$def p_on_zombie "_prefs/ansify/on_zombie"
$def p_off_zombie "_prefs/ansify/off_zombie"
$def p_vehicle "_prefs/ansify/vehicle"
$def p_room "_prefs/ansify/room"
$def p_thing "_prefs/ansify/thing"
$def p_prog "_prefs/ansify/prog"
$def p_dbref "_prefs/ansify/dbref"
$def p_exitname "_prefs/ansify/exitname"
$def p_exitalt "_prefs/ansify/exitalt"
$def p_lockname "_prefs/ansify/lockname"
$def p_female "_prefs/ansify/female"
$def p_male "_prefs/ansify/male"
$def p_herm "_prefs/ansify/herm"
$define c_on_player me @ p_on_player getpropstr dup not if pop d_on_player then $enddef
$define c_off_player me @ p_off_player getpropstr dup not if pop d_off_player then $enddef
$define c_on_zombie me @ p_on_zombie getpropstr dup not if pop d_on_zombie then $enddef
$define c_off_zombie me @ p_off_zombie getpropstr dup not if pop d_off_zombie then $enddef
$define c_vehicle me @ p_vehicle getpropstr dup not if pop d_vehicle then $enddef
$define c_room me @ p_room getpropstr dup not if pop d_room then $enddef
$define c_thing me @ p_thing getpropstr dup not if pop d_thing then $enddef
$define c_prog me @ p_prog getpropstr dup not if pop d_prog then $enddef
$define c_dbref me @ p_dbref getpropstr dup not if pop d_dbref then $enddef
$define c_exitname me @ p_exitname getpropstr dup not if pop d_exitname then $enddef
$define c_exitalt me @ p_exitalt getpropstr dup not if pop d_exitalt then $enddef
$define c_lockname me @ p_lockname getpropstr dup not if pop d_lockname then $enddef
$define c_female me @ p_female getpropstr dup not if pop d_female then $enddef
$define c_male me @ p_male getpropstr dup not if pop d_male then $enddef
$define c_herm me @ p_herm getpropstr dup not if pop d_herm then $enddef
$def d_on_player "bold,green"    ( Default colour for players that are awake )
$def d_off_player "green"        ( Default colour for players that are asleep )
$def d_on_zombie "bold,red"      ( Default colour for zombies that are awake )
$def d_off_zombie "red"          ( Default colour for zombies that are asleep )
$def d_vehicle "bold,blue"       ( Default colour for vehicles )
$def d_room "bold,cyan"          ( Default colour for rooms )
$def d_thing "bold,magenta"      ( Default colour for miscellaneous things )
$def d_prog "bold,white"         ( Default colour for programs )
$def d_dbref "bold,yellow"       ( Default colour for dbrefs )
$def d_exitname "bold,green"     ( Default colour for exits )
$def d_exitalt "bold,yellow"     ( Default colour for alternative exit names )
$def d_lockname "green"          ( Default colour for locked exits )
$def d_female "uline,bold,magenta"     ( Default colour for 'female' string )
$def d_male "uline,bold,cyan"          ( Default colour for 'male' string )
$def d_herm "uline,bold,yellow"        ( Default colour for 'herm*' string )
 
: fem-str ( s -- b )
{ "female" "vixen" "mare" "girl" }list swap array_matchval array_count
;
 
: guy-str ( s -- b )
{ "male" "guy" "boy" "tod" "stallion" }list swap array_matchval array_count
;
 
: herm-str ( s -- b )
{ "herm" "hermaphrodite" "shem" "shemale" "she-male" "female+" "girl+" }list swap array_matchval array_count
;
 
( ---------------------------------------------------------------------------- )
 
: safeattr ( s1 s2 -- s )
over swap 2 TRY
   textattr
CATCH
   pop
ENDCATCH
dup strlen over ansi_strlen = not if
   swap pop
then "\[[0m" swap strcat
;
 
: colour-code ( d -- s )
dup player? if
   awake? if
      c_on_player
   else
      c_off_player
   then
else
   dup thing? if
      dup "z" flag? if
         owner awake? if
            c_on_zombie
         else
            c_off_zombie
         then
      else
         "v" flag? if
            c_vehicle
         else
            c_thing
         then
      then
   else
      dup room? if
         pop c_room
      else
         dup program? if
            pop c_prog
         else
            dup exit? if
               me @ swap locked? if
                  c_lockname
               else
                  c_exitname
               then
            then
         then
      then
   then
then
;
 
: ansi-convert ( s -- s )
{ swap
"~&" explode_array foreach
   swap 0 = if continue then
   dup 1 ansi_strcut swap "R" stringcmp not if
      "\[[0m" swap strcat swap pop continue
   else
      pop
   then
   dup 1 ansi_strcut swap "B" stringcmp not if
      BellSeq swap strcat swap pop continue
   else
      pop
   then
   dup 1 ansi_strcut swap "C" stringcmp not if
      swap pop continue
   else
      pop
   then
   dup "" " " subst not if pop continue then
   3 ansi_strcut swap
   1 ansi_strcut 1 ansi_strcut 3 reverse
   "\[[%s;3%s;4%sm" fmtstring swap strcat
repeat
}list "" array_join
;
 
: ansify-name ( d -- s )
dup name swap colour-code safeattr
;
 
: ansify-unparseobj ( d -- s )
dup unparseobj swap colour-code safeattr "(#" split "(#" swap strcat c_dbref safeattr strcat
;
 
: ansify-unparse ( d -- s )
me @ "Silent" flag?
if
   ansify-name exit
then
dup me @ swap controls not
if
   dup "Link_OK" flag? not
   if
      dup "Chown_OK" flag? over player? not and not
      if
         dup "Abode" flag? not
         if
            ansify-name exit
         then
      then
   then
then
ansify-unparseobj
;
 
: ansify-gender ( s -- 's )
dup fem-str if
   c_female safeattr
else
   dup guy-str if
      c_male safeattr
   else
      dup herm-str if
         c_herm safeattr
      then
   then
then
;
 
: ansify-long-display ( d... i -- )
begin
   dup
while
   1 - dup 2 + rotate
   dup dbref?
   if
      ansify-unparse
   then
   .tell
repeat
pop
;
 
: ansify-short-list ( d... i -- s )
dup 3 <
if
   1 - dup 2 + rotate ansify-name over
   if
      " " strcat
   then
else
   ""
   begin
      over 1 >
   while
      swap 1 - swap over 3 + rotate ansify-name ", " strcat strcat
   repeat
then
swap
if
   "and " strcat swap ansify-name strcat
then
;
 
: ansify-short-display ( d... i -- )
ansify-short-list dup
if
   "You see " swap strcat "." strcat .tell
else
   "You see nothing." .tell
then
;
 
: ansify-list-contents ( s d -- )
(.get-contents dup)
contents_array array_vals dup
if
   dup 2 + rotate .tell
   ansify-long-display
else
   pop pop
then
;
 
: ansify-exitname ( d -- s )
dup "ansify/altexit?" envpropstr 3 pick owner rot 2 TRY controls CATCH pop 0 ENDCATCH swap .yes? and if
   name ";" split ";" split pop " (%s)" fmtstring c_exitalt safeattr strcat c_exitname safeattr
else
   ansify-name ";" split pop
then
;
 
: ansi? ( d -- b )
"color" flag?
;
 
: ansi-tell ( s -- )
ansi-convert .tell
;
 
: ansi-notify ( d s -- )
ansi-convert notify
;
 
: ansi-notify-except ( d d s -- )
ansi-convert notify_except
;
 
: ansi-notify-exclude ( d dn ... d1 n s -- )
ansi-convert notify_exclude
;
 
: ansi-connotify ( i s -- )
ansi-convert connotify
;
 
: libansi-strip ( s -- s )
{ swap
"~&" explode_array foreach
   swap 0 = if continue then
   dup 1 ansi_strcut swap "R" stringcmp not if
      swap pop continue
   else
      pop
   then
   dup 1 ansi_strcut swap "B" stringcmp not if
      swap pop continue
   else
      pop
   then
   dup 1 ansi_strcut swap "C" stringcmp not if
      swap pop continue
   else
      pop
   then
   dup "" " " subst not if pop continue then
   3 ansi_strcut swap pop
repeat
}list "" array_join
;
 
: libansi-strlen ( s -- i )
libansi-strip ansi_strlen
;
 
lvar numtocut
lvar strcut_s1
lvar strcut_s2
lvar numcutsofar
: libansi-strcut ( s i -- s1 s2 ; like strcut, but ignores ANSI codes. )
numtocut !
dup "~&" instr 0 = if
   numtocut @ \ansi_strcut exit
then
0 numcutsofar !
"" strcut_s1 !
numtocut @ 0 = if "" swap exit then
numtocut @ over "~&" instr > not if numtocut @ \ansi_strcut exit then
strcut_s2 !
begin
strcut_s2 @
dup "~&" instr 0 = if
   dup ansi_strlen numcutsofar @ + numtocut @ > if ( I see enuff slicables! )
     numtocut @ numcutsofar @ - \ansi_strcut swap
     numtocut @ numcutsofar !
     strcut_s1 @ swap strcat strcut_s1 !
     strcut_s2 !
   else
     numtocut @ numcutsofar !
     strcut_s1 @ swap strcat strcut_s1 !
     "" strcut_s2 !
   then
else
dup "~&" instr 1 = if
   dup "~&R" stringpfx over "~&C" stringpfx or if
     3
   else
     5
   then
   \ansi_strcut swap strcut_s1 @ swap strcat strcut_s1 ! strcut_s2 !
else
   dup "~&" instr 1 -
   dup numcutsofar @ + numtocut @ < if ( If I dun see enuff cuttable chars
                                         to satisfy my base desire..mrowr! )
( Top of stack here contains how many cuttable chars I can get. )
     numcutsofar @ over + numcutsofar !
     \ansi_strcut swap strcut_s1 @ swap strcat strcut_s1 ! strcut_s2 !
   else ( Else..if you have a long stretch of cuttable chars.. )
     pop
     numtocut @ numcutsofar @ - \ansi_strcut swap
     numtocut @ numcutsofar !
     strcut_s1 @ swap strcat strcut_s1 !
     strcut_s2 !
   then
then then
strcut_s2 @ not
numcutsofar @ numtocut @ = or until
strcut_s1 @ strcut_s2 @
;
 
: runnable ( s -- )
me @ ansi? not if
   "This program will be useless to you unless you set your COLOR bit, and have" .tell
   "an ANSI colour compatable client. Type '@set me=C', and run this program" .tell
   "again. If you do not see colour, then your client is not compatable, and you" .tell
   "should type '@set me=!C' to return you to normal." .tell
   exit
then
begin
   "~&110Lib~&170-~&120Ansify ~&130Colour ~&140Code ~&150Preference ~&160Editor" ansi-tell
   "~&170----------------------------------------" ansi-tell
   " " .tell
   "~&170Please select an object type to colour code:" ansi-tell
   " " .tell
   "~&170--~&130Key~&170-~&130Option~&170----------------------------------~&130Example~&170---------------------------"
   ansi-tell
   "  ~&1301.  ~&160Players that are awake:                 " "Stelard" c_on_player safeattr strcat ansi-tell
   "  ~&1302.  ~&160Players that are asleep:                " "Snoozy"c_off_player safeattr strcat ansi-tell
   "  ~&1303.  ~&160Puppets/Zombies that are awake:         " "Deric" c_on_zombie safeattr strcat ansi-tell
   "  ~&1304.  ~&160Puppets/Zombies that are asleep:        " "Eva" c_off_zombie safeattr strcat ansi-tell
   "  ~&1305.  ~&160Vehicles:                               " "STFC Freedom" c_vehicle safeattr strcat ansi-tell
   "  ~&1306.  ~&160Room names:                             " "Kitchen" c_room safeattr strcat ansi-tell
   "  ~&1307.  ~&160Things:                                 " "Computer" c_thing safeattr strcat ansi-tell
   "  ~&1308.  ~&160MUF Scripts:                            " "Lib-Ansify" c_prog safeattr strcat ansi-tell
   "  ~&1309.  ~&160Database Refs:                          " "(#126PJB)" c_dbref safeattr strcat ansi-tell
   "  ~&13010. ~&160Exits which you can pass through:       " "North" c_exitname safeattr strcat ansi-tell
   "  ~&13011. ~&160Exits which you can not pass through:   " "South" c_lockname safeattr strcat ansi-tell
   "  ~&13012. ~&160Alternate exits:                        " "To the window " c_exitname safeattr "(North)" c_exitalt
                                                                       safeattr strcat strcat ansi-tell
   " " .tell
   "  ~&13013. ~&160Females:                                " "Vixen" ansify-gender strcat ansi-tell
   "  ~&13014. ~&160Males:                                  " "Stallion" ansify-gender strcat ansi-tell
   "  ~&13015. ~&160Hermaphrodites and Shemales:            " "Herm" ansify-gender strcat ansi-tell
   " " .tell
   "  ~&130Q. ~&160Quit" ansi-tell
   " " .tell
   
   read
   
   dup atoi dup 1 >= over 15 <= and if
      "~&170Please enter a new comma deliminated list of Fuzzball colour commands," ansi-tell
      "~&170a blank space to return to default, or a full stop ('.') to cancel." ansi-tell
      "~&170Here is a list of valid commands:" ansi-tell
      " " .tell
      "~&160  reset    bold   dim       uline    flash   reverse" ansi-tell
      "~&160  black    red    yellow    green    cyan    blue    magenta    white" ansi-tell
      "~&160  bg_black bg_red bg_yellow bg_green bg_cyan bg_blue bg_magenta bg_white" ansi-tell
      " " .tell
      "~&170Note that some of these may be unsupported by your client." ansi-tell
      read
      
      dup "." stringcmp if
         "t" over 2 TRY
            textattr
         CATCH
            swap pop "" swap
         ENDCATCH pop
         swap intostr
         p_herm "15" subst
         p_male "14" subst
         p_female "13" subst
         p_exitalt "12" subst
         p_lockname "11" subst
         p_exitname "10" subst
         p_dbref "9" subst
         p_prog "8" subst
         p_thing "7" subst
         p_room "6" subst
         p_vehicle "5" subst
         p_off_zombie "4" subst
         p_on_zombie "3" subst
         p_off_player "2" subst
         p_on_player "1" subst
         me @ 3 reverse "" " " subst setprop
      else
         pop pop
      then
   then pop
   
   dup 1 strcut pop "Q" stringcmp not if break then
repeat
"~&130>> ~&160Done!" ansi-tell
;
 
PUBLIC ansify-list-contents
PUBLIC ansify-long-display
PUBLIC ansify-name
PUBLIC ansify-short-display
PUBLIC ansify-short-list
PUBLIC ansify-unparse
PUBLIC ansify-unparseobj
PUBLIC ansify-exitname
PUBLIC ansify-gender
PUBLIC ansi-tell
PUBLIC ansi-notify
PUBLIC ansi-notify-except
PUBLIC ansi-notify-exclude
PUBLIC ansi-connotify
PUBLIC ansi-convert
PUBLIC ansi?
PUBLIC libansi-strip
PUBLIC libansi-strlen
PUBLIC libansi-strcut
