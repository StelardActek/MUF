(
WhoTime.muf v1.3, by Stelard Actek of StelTechCor @ FurryMUCK!
 
Ever wanted to know what the local time was for another player? They don't all
live in the US, you know, and chances are that you'll meet, and grow fond of, a
fair amount of people for whom it is mid-morning, while you say it is evening.
 
That's where this program comes in. Set it up on your muck through the usual
means [@action WhoTime;WT=#0, @link WT=WhoTime.muf], and make sure you give the
program a M3 bit. It uses connection primitives to show someone's idle status.
 
Now just run the help. It'll tell you how to set yourself up as a user, display
info on players in the room with you and elsewhere, and convert any time local
for you into local for another user.
)
$include $lib/look
$include $lib/strings
$def HEADER "-Name--------------Sex-----Species---------------------Local-Time---------Idle--"
$def FOOTER "--------------------------------------------------------------------------------"
$def MAXABSDIF 86400 (Maximum Absolute Difference from system time: Default 1 day)
lvar arg
 
: play-zom-filter ( d -- i )
dup player?
swap "Z" flag? or
;
 
: db2con ( d -- c )
dup player? if
   dup awake? if
      descriptors dup 1 = not if
         begin
            swap pop 1 - dup 1 = not while
         repeat
         pop descrcon
      else
         pop descrcon
      then
   else
      pop 0
   then
else
   pop 0
then
;
 
: time-expand ( c -- s )
dup 180 > if
   dup 3600 % 60 / swap 3600 / intostr dup strlen 1 = if "0" swap strcat then
   ":" strcat swap intostr dup strlen 1 = if "0" swap strcat then strcat
else
   pop ""
then
;      
 
: who-data ( d -- )
dup name over awake? not if
   "[" swap "]" strcat strcat
then 18 STRleft " " swap strcat
over "sex" getpropstr dup not if
   pop over "gender" getpropstr
then 8 STRleft strcat
over "species" getpropstr 28 STRleft strcat
over "WhoTime/Set?" getpropval if
   over "WhoTime/Offset" getpropval systime + "%a %T" swap timefmt
else
   ""
then 19 STRleft strcat
swap dup awake? if
   db2con dup 0 = not if
      conidle time-expand 6 STRleft
   else
      pop "      "
   then
else
   pop "      "
then strcat
.tell
;
 
: who-room ( -- )
HEADER .tell
#-1 'play-zom-filter me @ location .contents-filter pop
begin
   dup #-1 dbcmp not while
   who-data
repeat
FOOTER .tell
;
 
: str2time ( s -- i )
systime timesplit pop pop pop pop pop
4 rotate ":" explode
3 = not if
   ">> Syntax error! Type \"" command @ toupper " #HELP\"." strcat strcat .tell
   "-1" exit
then
atoi dup 0 < if -1 * then 4 rotate - 3600 *
swap atoi 4 rotate - 60 *
rot atoi 4 rotate -
+ +
;
 
: set-offset ( var[arg] -- )
arg @ " " .split swap pop str2time dup string? if exit then
arg @ "+" instr if 86400 + then
arg @ "-" instr if 86400 - then dup
me @ "WhoTime/Offset" rot setprop
me @ "WhoTime/Set?" 1 setprop
systime + ">> Local time set to " "%a %T" rot timefmt strcat .tell
;
 
: time-convert ( var[arg] -- )
arg @ " " .split swap pop " " .split swap .pmatch
dup player? if
   dup "WhoTime/Set?" getpropval me @ "WhoTime/Set?" getpropval and if
      swap str2time dup string? if exit then swap over systime + "%T %j" swap timefmt
      " " .split atoi
      
      3 pick "WhoTime/Offset" getpropval me @ "WhoTime/Offset" getpropval - 5 rotate +
      systime + "%T %j" swap timefmt " " .split atoi
      
      ">> At " 5 rotate " for you, it will be " strcat strcat rot " on the " strcat strcat rot rot -
      dup 1 = over -300 < or if
         pop "previous "
      else
         dup 0 = if
            pop "same "
         else
            dup -1 = over 300 > or if
               pop "following "
            else
               pop "special (please report this error to Stelard) "
            then
         then
      then "day for " strcat strcat swap name "." strcat strcat .tell
   else
      ">> Both you and your target must have set your local time." .tell
   then
else
   ">> Syntax error! Type \"" command @ toupper " #HELP\"." strcat strcat .tell
then
;
 
: correct-offset ( var[arg] -- )
me @ "WhoTime/Set?" getpropval if
   arg @ " " .split swap pop ":" explode
   3 = not if
      ">> Syntax error! Type \"" command @ toupper " #HELP\"." strcat strcat .tell
      "-1" exit
   then
   atoi 3600 *
   swap atoi 60 *
   rot atoi + +
   me @ "WhoTime/Offset" getpropval swap + dup dup 0 < if -1 * then MAXABSDIF > if
      ">> Error: You can't be more than a day in difference from the system time!" .tell exit
   then
   dup me @ "WhoTime/Offset" rot setprop
   ">> Local time corrected to " swap systime + "%a %T" swap timefmt "." strcat strcat .tell
else
   ">> You must first #SET your local time, before you can correct it." .tell
then
;
 
: show-help ( -- )
"+----------------------+" .tell
"|   WhoTime.muf v1.3   |" .tell
"|    [:<-  M3  ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
"|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
"|    of StelTechCor    | /____________________________________________\\" .tell
"+----------------------+                            (...or something...)" .tell
" " .tell
"This is a fairly simple little program I wrote to help me, and others like me," .tell
"meet up with those they have relations with online. Living outside the US, this" .tell
"is fairly difficult, but this program should help considerably." .tell
" " .tell
"WT                            - This will list all players in the room, their" .tell
"                                status (awake, idle, asleep), their sex, their" .tell
"                                species, and, if they are set up to use this" .tell
"                                program, their local time." .tell
"WT #SET <[+/-]HH:MM:SS>       - Sets the user up to use this program. The time," .tell
"                                as you can see, is in hours, minutes, seconds" .tell
"                                format, and can be prefixed with a + or a - to" .tell
"                                designate the next or previous day from system" .tell
"                                time." .tell
"WT #CORRECT <HH:MM:SS>        - A function to help you correct your time" .tell
"                                offset, should you go into or out of daylight" .tell
"                                savings, or should you be pedantic about the" .tell
"                                accuracy of the seconds. Each value (hours," .tell
"                                minutes and seconds) will be ADDED to your" .tell
"                                current local time. This means if you want to" .tell
"                                set the clock forwards an hour and back five" .tell
"                                seconds, you would enter '1:0:-5'." .tell
"WT #CONVERT <name> <HH:MM:SS> - Probably the most important function of this" .tell
"                                program, it lets you convert any local time to" .tell
"                                the time of someone else. Name is another" .tell
"                                player. You do not have to be in the room with" .tell
"                                them, so you can organise meetings via pages." .tell
"WT #FAR <name>                - Simple enough, this shows the same info as WT," .tell
"                                but for one individual not in the room with" .tell
"                                you." .tell
"WT #HELP                      - Begins a religious Jihad, with fanatic legions" .tell
"                                waving the Atreides banner across the galaxy." .tell
" " .tell
"NOTE: This program does not automatically compensate for daylight savings, or" .tell
"other changes in your local time. If you live in an area where these changes" .tell
"occur, you have to update your offset manually, using #CORRECT." .tell
;
 
: main ( s -- )
arg !
 
arg @ not if who-room exit then
arg @ "#set" stringpfx 1 = if set-offset exit then
arg @ "#conv" stringpfx 1 = if time-convert exit then
arg @ "#cor" stringpfx 1 = if correct-offset exit then
arg @ "#far" stringpfx 1 = if
   arg @ " " .split swap pop .pmatch dup player? if
      HEADER .tell
      who-data
      FOOTER .tell
   else
      pop ">> That player was not found!" .tell
   then exit
then
arg @ "#h" stringpfx 1 = if show-help exit then
;
