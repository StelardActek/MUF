(
WhoTime.muf v1.7M2A, by Stelard Actek of StelTechCor @ FurryMUCK!
 
Ever wanted to know what the local time was for another player? They don't all
live in the US, you know, and chances are that you'll meet, and grow fond of, a
fair amount of people for whom it is mid-morning, while you say it is evening.
 
That's where this program comes in. Set it up on your muck through the usual
means [@action WhoTime;WT=#0, @link WT=WhoTime.muf], and make sure you $include
lib-dbidle. It uses connection primitives to show someone's idle status.
 
Now just run the help. It'll tell you how to set yourself up as a user, display
info on players in the room with you and elsewhere, and convert any time local
for you into local for another user.
 
If you want to set this up, and you're not a Wizard, you'll need to use '@action
WhoTime;WT=me', and then '@link WT=<dbref>', where <dbref> is whatever the
program's number is.
)
$ifdef __version<Muck2.2fb6.00
   $abort Designed to compile only under Fuzzball 6.00 or greater!
$endif
$ifndef __dversion>=Delphinus1.00
   $echo Compiling in $lib/dbidle, as this is not a Delphinus1.00 MUCK...
   $include #142709 ($lib/dbidle)
   $def dbleastidle db-leastidle
$endif
$version 1.7
$include #85365 ($lib/ansify)
$include $lib/look
$include #99677 ($lib/ansistrings)
$def HEADER "~&170-~&130Name~&170--------------~&130Sex~&170-----~&130Species~&170---------------------~&130Local~&170-~&130Time~&170---------~&130Idle~&170--"
$def FOOTER "~&170--------------------------------------------------------------------------------"
$def ONEDAY 86400     (Number of seconds in a day)
$def MAXABSDIF ONEDAY (Maximum Absolute Difference from system time: Default 1 day)
$def TIMEDAY "~&170%a %H~&110:~&170%M~&110:~&170%S"
$def TIMENUM "~&170%H~&110:~&170%M~&110:~&170%S %j"
lvar arg
 
: you-them ( d -- s )
dup me @ = if
   pop "~&120you"
else
   ansify-name
then "~&170" strcat
;
 
: play-zom-filter ( d -- i )
dup player?
swap "Z" flag? or
;
 
: time-expand ( i -- s )
dup 180 > if
   dup 3600 % 60 / swap 3600 / intostr dup strlen 1 = if "0" swap strcat then
   "~&110:~&170" strcat swap intostr dup strlen 1 = if "0" swap strcat then strcat
   "~&170" swap strcat
else
   pop ""
then
;      
 
: get-species ( d -- s )
dup "species_prop" getpropstr dup not if
   pop "species" getpropstr
else
   getpropstr
then
;
 
: who-data ( d -- )
dup ansify-name over awake? not if
   "[" swap "]" strcat strcat
then 18 ansi_strcut pop 18 ASTRleft " " swap strcat
over "sex" getpropstr dup not if
   pop over "gender" getpropstr
then ansify-gender 8 ansi_strcut pop 8 ASTRleft strcat
over get-species 28 ansi_strcut pop 28 ASTRleft "reset,bold,white" textattr strcat
over "WhoTime/Set?" getpropval if
   over "WhoTime/Offset" getpropval systime + TIMEDAY swap timefmt
else
   ""
then 19 ASTRleft strcat
swap dup awake? if
   dup "Z" flag? if owner then
   dbleastidle dup 0 = not if
      time-expand 6 ASTRleft
   else
      pop "      "
   then
else
   pop "      "
then strcat
ansi-tell
;
 
: who-room ( -- )
HEADER ansi-tell
#-1 'play-zom-filter me @ location .contents-filter array_make
foreach
   swap pop
   who-data
repeat
FOOTER ansi-tell
;
 
: str2time ( s -- i )
systime timesplit pop pop pop pop pop
4 rotate ":" explode
3 = not if
   "~&170>> ~&110Syntax error! Type \"" command @ toupper " #HELP\"." strcat strcat ansi-tell
   "-1" exit
then
atoi dup 0 < if -1 * then 4 rotate - 3600 *
swap atoi 4 rotate - 60 *
rot atoi 4 rotate -
+ +
;
 
: set-offset ( var[arg] -- )
arg @ " " .split swap pop str2time dup string? if exit then
arg @ "+" instr if ONEDAY + then
arg @ "-" instr if ONEDAY - then dup
me @ "WhoTime/Offset" rot setprop
me @ "WhoTime/Set?" 1 setprop
systime + "~&130>> ~&170Local time set to " TIMEDAY rot timefmt strcat ansi-tell
;
 
: time-convert ( var[arg] -- )
var DBfrom
 
arg @ " " .split swap pop " " .split swap
dup 1 strcut swap "!" strcmp not if
   swap pop pmatch me @ swap
else
   pop pmatch me @
then DBfrom !
dup player? if
   dup "WhoTime/Set?" getpropval DBfrom @ "WhoTime/Set?" getpropval and if
      swap str2time dup string? if exit then swap over systime + TIMENUM swap timefmt
      " " .split atoi
 
      3 pick "WhoTime/Offset" getpropval DBfrom @ "WhoTime/Offset" getpropval - 5 rotate +
      systime + TIMENUM swap timefmt " " .split atoi
 
      "~&130>> ~&170At " 5 rotate " for " DBfrom @ you-them ", it will be " strcat strcat strcat strcat rot " on the " strcat strcat rot rot -
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
      then "day for " strcat strcat swap you-them "." strcat strcat ansi-tell
   else
      "~&170>> ~&110Both you and your target must have set your local time." ansi-tell
   then
else
   "~&170>> ~&110Syntax error! Type \"" command @ toupper " #HELP\"." strcat strcat ansi-tell
then
;
 
: correct-offset ( var[arg] -- )
me @ "WhoTime/Set?" getpropval if
   arg @ " " .split swap pop ":" explode
   3 = not if
      "~&170>> ~&110Syntax error! Type \"~&170" command @ toupper " #HELP~&110\"." strcat strcat ansi-tell
      "-1" exit
   then
   atoi 3600 *
   swap atoi 60 *
   rot atoi + +
   me @ "WhoTime/Offset" getpropval swap + dup dup 0 < if -1 * then MAXABSDIF > if
      "~&170>> ~&110Error: You can't be more than a day in difference from the system time!" ansi-tell exit
   then
   dup me @ "WhoTime/Offset" rot setprop
   "~&130>> ~&170Local time corrected to " swap systime + TIMEDAY swap timefmt "." strcat strcat ansi-tell
else
   "~&130>> ~&170You must first #SET your local time, before you can correct it." ansi-tell
then
;
 
: show-help ( -- )
"~&120+----------------------+" ansi-tell
"~&120|   ~&130WhoTime.muf v1.7   ~&120|" ansi-tell
"~&120|   ~&170>-*-<~&110  M2  ~&170>-*-<   ~&120| \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" ansi-tell
"~&120|   ~&130by ~&150Stelard Actek   ~&120|  >~&110Stel~&120Tech~&140Cor~&130, MUFfing on request since ~&1701999~&120<" ansi-tell
"~&120|    ~&130of ~&110Stel~&120Tech~&140Cor    ~&120| /____________________________________________\\" ansi-tell
"~&120+----------------------+                            (...~&170or something~&120...)" ansi-tell
" " .tell
"~&160This is a fairly simple little program I wrote to help me, and others like me," ansi-tell
"~&160meet up with those they have relations with online. Living outside the US, this" ansi-tell
"~&160is fairly difficult, but this program should help considerably." ansi-tell
"~&160All times are in \[[4m~&57024 hour~&R~&160 format." ansi-tell
" " .tell
"~&130WT                            ~&170- ~&160This will list all players in the room, their" ansi-tell
"                                ~&160status (awake, idle, asleep), their sex, their" ansi-tell
"                                ~&160species, and, if they are set up to use this" ansi-tell
"                                ~&160program, their local time." ansi-tell
"~&130WT #SET <[+/-]H:M:S>          ~&170- ~&160Sets the user up to use this program. The time," ansi-tell
"                                ~&160as you can see, is in hours, minutes, seconds" ansi-tell
"                                ~&160format, and can be prefixed with a ~&170+~&160 or a ~&170-~&160 to" ansi-tell
"                                ~&160designate the next or previous day from system" ansi-tell
"                                ~&160time." ansi-tell
"                                ~&160So input here your current time, including" ansi-tell
"                                ~&160seconds, and use ~&170+~&160 or ~&170-~&160 to make it the right" ansi-tell
"                                ~&160day as nessisary." ansi-tell
"~&130WT #CORRECT <H:M:S>           ~&170- ~&160A function to help you correct your time" ansi-tell
"                                ~&160offset, should you go into or out of daylight" ansi-tell
"                                ~&160savings, or should you be pedantic about the" ansi-tell
"                                ~&160accuracy of the seconds. Each value (hours," ansi-tell
"                                ~&160minutes and seconds) will be ~&170ADDED~&160 to your" ansi-tell
"                                ~&160current local time. This means if you want to" ansi-tell
"                                ~&160set the clock forwards an hour and back five" ansi-tell
"                                ~&160seconds, you would enter '~&1701:0:-5~&160'." ansi-tell
"~&130WT #CONVERT <[!]name> <H:M:S> ~&170- ~&160Probably the most important function of this" ansi-tell
"                                ~&160program, it lets you convert any local time to" ansi-tell
"                                ~&160the time of someone else. Name is another" ansi-tell
"                                ~&160player. You do not have to be in the room with" ansi-tell
"                                ~&160them, so you can organise meetings via pages." ansi-tell
"                                ~&160If the optional exclaimation point [~&170!~&160] is given," ansi-tell
"                                ~&160the function works in reverse, converting the" ansi-tell
"                                ~&160time of another player to your local time." ansi-tell
"~&130WT #FAR <name>                ~&170- ~&160Simple enough, this shows the same info as WT," ansi-tell
"                                ~&160but for one individual not in the room with" ansi-tell
"                                ~&160you." ansi-tell
"~&130WT #HELP                      ~&170- ~&160Begins a religious Jihad, with fanatic legions" ansi-tell
"                                ~&160waving the Atreides banner across the galaxy." ansi-tell
" " .tell
"~&170NOTE: ~&160This program does not automatically compensate for daylight savings, or" ansi-tell
"~&160other changes in your local time. If you live in an area where these changes" ansi-tell
"~&160occur, you have to update your offset manually, using ~&170#CORRECT~&160." ansi-tell
;
 
: main ( s -- )
arg !
 
arg @ not if who-room exit then
arg @ "#set" stringpfx 1 = if set-offset exit then
arg @ "#conv" stringpfx 1 = if time-convert exit then
arg @ "#cor" stringpfx 1 = if correct-offset exit then
arg @ "#far" stringpfx 1 = if
   arg @ " " .split swap pop .pmatch dup player? if
      HEADER ansi-tell
      who-data
      FOOTER ansi-tell
   else
      pop "~&170>> ~&110That player was not found!" ansi-tell
   then exit
then
arg @ "#h" stringpfx 1 = if show-help exit then
;
