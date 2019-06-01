( STC-TorD.muf -FUZZBALL- v1.9F, by Stelard Actek of StelTechCor @ FurryMUCK!
 
 What can I say? One day, my second favourite place to hang out on Furry was
 suddenly gone. The Palace of the Dragons' Truth or Dare pools have held a
 special place in my heart for a long time. True, of late, I've not had much
 fun there, due to a worrying streak of unoriginality and limpness among the
 players, but still. A friend told me a coalition of furs had taken it upon
 themselves to create a replacement area. The new command set I found there
 was just close enough to the old one to be maddening, and missing some
 features. Hence this, my solution, rendered in lovely Multiple User Forth.
 
 Right, that's enough of that. To set the program up, simply create an action.
 Anywhere, on anything. It can be a room or an object, or even yourself, but
 the latter makes no sense unless you want to be the only person to play it.
 Name your action [wait for it... *^.^*]
 'Q;A;D;AOK;DOK;TIMER;PICK;HISTORY;SPIN;GRAB;RESET;RESTART;STATUS;ISWEEP;BOOT',
 and link it to this program.
 
 Now, that used to be it, but since the code enabling the two newest commands
 -- ISWEEP and BOOT -- rely on the players and their homes being set JUMP_OK,
 some steps need to be taken to ensure that all people in the playing area can
 be idle swept and booted from the game if nessisary. To this end, you will
 have to lock your newly created action and the entrace to the Truth or Dare
 room [if you have one, that is] with a program which tests the JUMP_OK flag on
 players and their homes. On FurryMUCK, Sweepable?.muf should be listed under
 the PROGRAMS command.
 
 Also, if you don't like the reminder delay being set to 5 minutes, set the
 _RemindDelay property on your question to a STRING VALUE of the number of
 minutes you want between game reminders. Decimals and values below 1 are not
 acceptable.
 
 That's it! This program stores all it's data on the action, so porters make
 sure the program is set HARDUID.
 
 The status of the game is stored on the action, so make sure that if you're
 going to have several rooms setup like this, you have separate action sets
 for each room. Also, for the same reasons, don't split the action up. Make
 it one action, as above.
 
 Last notes:
   This is a final release. As far as I know, there are no bugs left. Though,
   as they say, a program without bugs is one that hasn't crashed in a while.
   If you have a problem, either page mail Stelard @ FurryMUCK! or email
   stelardactek@bigpond.com. Remeber to tell me WHAT you were doing, not
   just the error message!
 
 Uses:
   lib/ansify
   lib/dbidle
   lib/look
   .confirm
   .tell
)
( @set <ref>=_docs:@list <ref>=1-54 )
lvar arg
lvar start-remind
$include ($lib/ansify)    #85365 (on FM)
$include ($lib/dbidle)    #142709 (on FM)
$include $lib/look
$ifdef __version<Muck2.2fb6.00
   $abort Designed to compile only under Fuzzball 6.00b4 or greater!
$endif
$version             1.9
$def TD_Version      "1.9F"
$def TD_PLastVer     "STC-TorD"
 
$def TD_Def_Remind_Delay   5     (Default number of minutes to wait before)
                                 (reminding the player with the question.)
$def TD_Def_Idle           5     (Default number of minutes a player may be)
                                 (idle before they can be idle swept.)
 
$def TD_STATE_P            8
$def TD_STATE_Q            16
$def TD_STATE_A            32
$def TD_STATE_AOK          64
 
$def TD_PPlayer      "_CurPlayer"
$def TD_PTarget      "_CurTarget"
$def TD_PQuestion    "_CurQuestion"
$def TD_PAnswer      "_CurAnswer"
$def TD_PDarees      "_CurDarees"
$def TD_PDares       "_CurDares"
$def TD_PQCount      "_QCount"
$def TD_PLastQ       "_LastQ"
$def TD_PLastPlayer  "_LastPlayer"
$def TD_PDareTargets "_DareTargets"
$def TD_PRemindDelay "_RemindDelay"
$def TD_PRemindOn?   "_Reminders?"
$def TD_PVoteRemindY "_Reminders?/Yes"
$def TD_PVoteRemindN "_Reminders?/No"
 
$def TD_DDares       "_CurDares/"
$def TD_DLastQ       "_LastQ/"
$def TD_DDareTargets "_DareTargets/"
$def TD_DBootVotes   "_BootVotes/"
 
: safematch ( s -- d )
dup not if pop #-1 else match then
;
 
: yes? ( s -- b )
dup "y" instring
swap "on" instring
or
;
 
: btos ( b -- s )
if "~&170ON" else "~&170OFF" then
;
 
: first_room ( d -- d )
begin
   dup room? not while
   location
repeat
;
 
: notify_room ( s -- )
trigger @ first_room #-1 rot ansi-notify-except
;
 
: pzafilter ( d -- b )
dup ok? if
   dup player? over "Z" flag? or if
      awake?
   else
      pop 0
   then
else
   pop 0
then
;
 
: pzanfilter ( d -- b )
dup ok? if
   dup player? over "Z" flag? or if
      dup me @ dbcmp not if
         awake?
      else
         pop 0
      then
   else
      pop 0
   then
else
   pop 0
then
;
 
: char-strip ( s -- s )
" " "!" subst
" " "?" subst
" " "." subst
" " "," subst
" " ";" subst
" " ":" subst
" " "  " subst
;
 
: set-target ( d -- )
trigger @ TD_PTarget rot setprop
;
 
: set-daree ( d -- b )
trigger @ TD_PDarees 3 pick reflist_find if
   0 exit
then
trigger @ TD_DDareTargets me @ intostr strcat 3 pick setprop
trigger @ TD_PDarees 3 pick reflist_add
trigger @ TD_DDares rot intostr "/Darer" strcat strcat me @ setprop
1
;
 
: get-targetstr ( -- s )
trigger @ TD_PTarget getprop dup dbref? if
   name
else
   pop "?"
then
;
 
: get-playerstr ( -- s )
trigger @ TD_PPlayer getprop dup dbref? if
   name
else
   pop "?"
then
;
 
: game-state ( -- i )
trigger @ TD_PTarget getprop dbref? not if
   TD_STATE_P
else
   trigger @ TD_PQuestion getpropstr not if
      TD_STATE_Q
   else
      trigger @ TD_PAnswer getpropstr not if
         TD_STATE_A
      else
         TD_STATE_AOK
      then
   then
then
;
 
lvar RemindDelay
: remind-loop ( -- )
trigger @ TD_PRemindOn? getpropval not if exit then
 
game-state
me @ location
trigger @ TD_PPlayer getprop
trigger @ TD_PRemindDelay getpropstr atoi dup 1 < if pop TD_Def_Remind_Delay then 60 * RemindDelay !
background
begin
   RemindDelay @ sleep
   
   dup pzafilter                             (player still awake, still player or zombie)
   over trigger @ TD_PPlayer getprop = and   (still player's turn)
   me @ location 4 pick = and                (i'm still in the t|d area)
   game-state dup 6 pick = rot and           (game is still in the same state. i.e. no questions asked/answered)
   'pzanfilter me @ location .contents-filter array_make array_count 0 > and  (i'm not the only one here)
   trigger @ TD_PRemindOn? getpropval and                                     (reminders are still on)
   while
   
   dup TD_STATE_P = if
      "~&150<> " get-playerstr " needs to pick a questionee." strcat strcat notify_room pop
   else
      dup TD_STATE_Q = if
         "~&150<> " get-playerstr " needs to ask a question." strcat strcat notify_room pop
      else
         TD_STATE_A = if
            "~&150<> " get-targetstr " needs to answer the question." strcat strcat notify_room
         else
            "~&150<> " get-playerstr " hasn't accepted " get-targetstr "'s answer." strcat strcat strcat strcat notify_room
         then
      then
   then
repeat
;
 
: parse-pose ( s -- s )
  dup if
    dup ansi_strlen 3 > if
      dup strip "'" 1 strncmp not if
        dup 4 ansi_strcut pop " " instr not if " " swap strcat then
      then
    then
    ". ,':!?-"
    over strip 1 ansi_strcut pop instr not if " " swap strcat then
  then
  me @ name me @ "_prefs/prepose" getpropstr strcat swap strcat
;
 
: ask-question ( s -- )
dup 1 ansi_strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " asks, \"~&170" strcat swap "~&160\"" strcat strcat
then
"~&150<> (" me @ name " asks " get-targetstr ") ~&160" 6 pick
strcat strcat strcat strcat strcat notify_room
trigger @ TD_PQuestion rot setprop
;
 
: give-dare ( s -- )
dup 1 ansi_strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " dares, \"~&170" strcat swap "~&160\"" strcat strcat
then
trigger @ TD_DDareTargets me @ intostr strcat getprop
"~&150<> (" me @ name " dares " 4 pick dup dbref? if name else pop "?" then ") ~&160" 7 pick
strcat strcat strcat strcat strcat notify_room
trigger @ TD_DDares rot intostr "/Dare" strcat strcat rot setprop
;
 
( --------------------------------------------------------------------------- )
 
: prog-Q ( -- )
0 start-remind !
arg @ not if
   trigger @ TD_PQuestion getpropstr dup not if
      pop "~&150<> " get-playerstr " hasn't asked a question yet." strcat strcat ansi-tell
   else
      "~&150<> (" get-playerstr " asked " get-targetstr ") ~&160" 6 rotate
      strcat strcat strcat strcat strcat ansi-tell
   then
   exit
then
trigger @ TD_PPlayer getprop dup dbref? if
   me @ dbcmp not if
      "~&150<> You can't ask a question until it is your turn!" ansi-tell
      exit
   then
else
   pop "~&150<> You need to restart the game. Type ~&170RESTART~&150." ansi-tell
   exit
then
arg @ "=" instr if
   arg @ "=" split swap dup not if
      "~&150<> You need to specify a player to question before that = sign." ansi-tell
      exit
   then
   safematch dup pzanfilter if   ( A player=question situation )
      game-state TD_STATE_Q <= if start-remind ++ then
      set-target
      ask-question
   else
      pop
      "~&150<> You can't ask someone who isn't here, is asleep, or doesn't exist." ansi-tell
   then
else
   arg @ " " instr if                              ( More than one word parameter )
      trigger @ TD_PTarget getprop dbref? not if
         arg @ char-strip " " explode
         1 - swap safematch dup pzanfilter if                    (First word?)
            set-target
         else
            pop 1 - dup 2 + rotate safematch dup pzanfilter if   (Last word?)
               set-target
            else
               pop begin                                                (Other words?)
                  dup 0 = not while
                  1 - swap safematch dup pzanfilter if
                     set-target
                  else
                     pop
                  then
               repeat
            then
         then
      then
      game-state TD_STATE_Q <= if start-remind ++ then
      arg @ ask-question
   else
      arg @ safematch dup pzanfilter if                ( The one word is a player name )
         "~&150<> " me @ name " directs the question to " 4 pick name "." strcat strcat strcat strcat notify_room
         game-state TD_STATE_P <= if start-remind ++ then
         set-target
      else                                         ( The one word is a question )
         game-state TD_STATE_Q <= if start-remind ++ then
         arg @ ask-question
      then
   then
then
start-remind @ if remind-loop then
;
 
: prog-OK ( s -- )
"A" stringcmp not if
   "~&150<> (" me @ name " accepts " get-targetstr "'s answer) ~&160" strcat strcat strcat strcat
   arg @ dup if
      dup 1 ansi_strcut swap ":" strcmp not if
         swap pop parse-pose
      else
         pop me @ name " says, \"~&170" strcat swap "~&160\"" strcat strcat
      then strcat
   else
      pop
   then notify_room
   game-state
   trigger @ TD_PTarget getprop dup trigger @ TD_PPlayer rot setprop
   trigger @ TD_PTarget remove_prop
   trigger @ TD_PQuestion remove_prop
   trigger @ TD_PAnswer remove_prop
   trigger @ TD_PQCount getpropval 1 + dup trigger @ TD_PQCount rot setprop
   trigger @ TD_DLastQ 4 rotate intostr strcat rot setprop
   trigger @ TD_PLastPlayer me @ setprop
   TD_STATE_AOK = if remind-loop then
else
   arg @ not if
      "~&150<> Declare who's dare complete? You must specify the daree." ansi-tell
      exit
   then
   arg @ safematch dup pzanfilter not if
      "~&150<> You can't end the dare of someone who isn't here, is asleep, or doesn't exist." ansi-tell
      exit
   then
   trigger @ TD_PDarees 3 pick reflist_find not if
      "~&150<> That person doesn't have a dare to clear." ansi-tell
      exit
   then
   trigger @ TD_DDares 3 pick intostr strcat remove_prop
   trigger @ TD_PDarees 3 pick reflist_del
   "~&150<> " me @ name " declares " 4 rotate name "'s dare complete." strcat strcat strcat strcat notify_room
then
;
 
: prog-A ( -- )
arg @ not if
   trigger @ TD_PAnswer getpropstr dup not if
      pop "~&150<> " get-targetstr " hasn't answered yet." strcat strcat ansi-tell
   else
      "~&150<> (" get-targetstr " answered " get-playerstr ") ~&160" 6 rotate
      strcat strcat strcat strcat strcat ansi-tell
   then
   exit
then
trigger @ TD_PTarget getprop dup dbref? if
   me @ dbcmp not if
      "~&150<> You can't answer a question you weren't asked!" ansi-tell
      exit
   then
else
   pop
then
arg @ dup 1 ansi_strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " answers, \"~&170" strcat swap "~&160\"" strcat strcat
then
"~&150<> (" me @ name " answers " trigger @ TD_PPlayer getprop name ") ~&160" 6 pick
strcat strcat strcat strcat strcat notify_room
game-state swap
trigger @ TD_PAnswer rot setprop
TD_STATE_A <= if remind-loop then
;
 
: prog-D ( -- )
arg @ not if
   "~&110Invalid syntax! Type '~&170Q #HELP3~&110'." ansi-tell
   exit
then
arg @ "=" instr if
   arg @ "=" split swap dup not if
      "~&150<> You need to specify a player to dare before that = sign." ansi-tell
      exit
   then
   safematch dup pzanfilter if   ( A player=dare situation )
      set-daree not if
         "~&150<> That person already has a dare to do." ansi-tell
         exit
      then
      give-dare
   else
      pop
      "~&150<> You can't dare someone who isn't here, or doesn't exist." ansi-tell
   then
else
   arg @ " " instr if                              ( More than one word parameter )
      trigger @ TD_DDareTargets me @ intostr strcat getprop dbref? not if
         arg @ char-strip " " explode
         1 - swap safematch dup pzanfilter if                    (First word?)
            set-daree not if
               "~&150<> That person already has a dare to do." ansi-tell
               exit
            then
         else
            pop 1 - dup 2 + rotate safematch dup pzanfilter if   (Last word?)
               set-daree not if
                  "~&150<> That person already has a dare to do." ansi-tell
                  exit
               then
            else
               pop begin                                                (Other words?)
                  dup 0 = not while
                  1 - swap safematch dup pzanfilter if
                     set-daree not if
                        "~&150<> That person already has a dare to do." ansi-tell
                        exit
                     then
                  else
                     pop
                  then
               repeat
            then
         then
      then
      arg @ give-dare
   else
      arg @ safematch dup pzanfilter if                ( The one word is a player name )
         dup set-daree not if
            "~&150<> That person already has a dare to do." ansi-tell
            exit
         then
         "~&150<> " me @ name " directs the dare to " 4 rotate name "." strcat strcat strcat strcat notify_room
      else
         arg @ give-dare
      then
   then
then
;
 
: prog-time ( -- )
arg @ "=" split swap atoi swap
"~&150<> " me @ name " sets a timer with the message: \"~&170" 4 pick "~&150\" for ~&170" 7 pick intostr "~&150 minutes."
strcat strcat strcat strcat strcat strcat notify_room
swap 60 * background sleep
"~&150<> A timer set by " me @ name " goes off with the message: \"~&170" 4 rotate "~&150\""
strcat strcat strcat strcat trigger @ location #-1 rot ansi-notify-except
;
 
: prog-pick ( -- )
trigger @ TD_PPlayer getprop dup dbref? if
   me @ dbcmp not if
      "~&150<> You can't pick a victim until it is your turn!" ansi-tell
      exit
   then
else
   pop "~&150<> You need to restart the game. Type ~&170RESTART~&150." ansi-tell
   exit
then
'pzanfilter me @ location .contents-filter array_make dup array_count dup 0 = if
   "~&150<> There's no one else here..." ansi-tell pop
   exit
else
   over { trigger @ TD_PLastPlayer getprop dup dbref? not if pop #-1 then }list swap array_diff dup array_count dup 0 = if
      pop pop
   then
   random swap % array_getitem
then
"~&150<> " me @ name "'s eyes scan around the room, eventually settling on " 4 pick name "!"
strcat strcat strcat strcat notify_room
game-state swap
set-target
TD_STATE_P <= if remind-loop then
;
 
: prog-hist ( -- )
"~&150<> History" ansi-tell
"~&170-~&130Player~&170--------------~&130Last~&170-~&130turn~&170--------------------------------------------------"
ansi-tell
'pzafilter me @ location .contents-filter
begin
   dup 0 = not while
   1 - swap dup ansify-name dup ansi_strlen "                    " swap strcut swap pop strcat " " swap strcat
   trigger @ TD_DLastQ 4 rotate intostr strcat getpropval dup 0 = if
      pop "  -- NONE --"
   else
      trigger @ TD_PQCount getpropval swap - dup 1 = if
         intostr " question ago"
      else
         intostr " questions ago"
      then strcat
   then "bold,cyan" textattr strcat .tell
repeat
"~&170--------------------------------------------------------------------------------" ansi-tell
;
 
: prog-spin ( -- )
'pzanfilter me @ location .contents-filter array_make dup array_count dup 0 = if
   pop pop me @
else
   random swap % array_getitem
then
"~&150<> " me @ name " spins the spinner, and it stops pointing at " 4 rotate name "!"
strcat strcat strcat strcat notify_room
;
 
: prog-grab ( -- )
"~&150<> " me @ name " ~&170grabs~&150 the Q!" strcat strcat notify_room
trigger @ TD_PPlayer getprop
trigger @ TD_PPlayer me @ setprop
trigger @ TD_PTarget remove_prop
trigger @ TD_PQuestion remove_prop
trigger @ TD_PAnswer remove_prop
me @ = not if remind-loop then
;
 
: prog-reset ( s -- )
"ET" instring if
   "Are you sure you want to reset the game? (y/n)" "bold,red" textattr .confirm not if exit then
   "~&150<> " me @ name " resets the game! Kerr-CHUNK!! (~&170History reset~&150)" strcat strcat notify_room
   trigger @ TD_PQCount remove_prop
   trigger @ TD_PLastQ remove_prop
   trigger @ TD_PLastPlayer remove_prop
else
   0 start-remind !
   "Are you sure you want to restart the game? (y/n)" "bold,red" textattr .confirm not if exit then
   "~&150<> " me @ name " restarts the game!" strcat strcat notify_room
   'pzafilter me @ location .contents-filter dup 0 = if me @ else random over % 2 + pick then
   "~&150<> The question zooms around the room, eventually settling on " over name "!" strcat strcat notify_room
   trigger @ TD_PPlayer getprop dup dbref? if
      dup pzafilter swap location me @ location = and not if
         start-remind ++
      then
   else
      pop start-remind ++
   then
   trigger @ TD_PPlayer rot setprop
   trigger @ TD_PTarget remove_prop
   trigger @ TD_PQuestion remove_prop
   trigger @ TD_PAnswer remove_prop
   trigger @ TD_PDarees remove_prop
   trigger @ TD_PDares remove_prop
   trigger @ TD_PDareTargets remove_prop
   popn
   start-remind @ if remind-loop then
then
;
 
: prog-stat ( -- )
"<> Game status" "bold,magenta" textattr .tell
"--------------" "bold,white" textattr .tell
" " .tell
"~&150Reminders are: " trigger @ TD_PRemindOn? getpropval btos strcat ansi-tell 
" " .tell
"Question:" "bold,yellow" textattr .tell
"" arg ! prog-Q
" " .tell
trigger @ TD_PDarees getpropstr if
   "Dares:" "bold,yellow" textattr .tell
   trigger @ TD_PDarees array_get_reflist
   foreach
      swap pop
      "~&150<> (" TD_DDares 3 pick intostr "/Darer" strcat strcat dup trigger @ swap getprop name
            " to " 5 rotate name ") ~&160" trigger @ 6 rotate dup ansi_strlen 1 - ansi_strcut pop getpropstr
      strcat strcat strcat strcat strcat ansi-tell
   repeat
   " " .tell
then
;
 
: prog-isweep ( -- )
arg @ not if
   "<> Idle sweep who?" "bold,magenta" textattr .tell
   exit
then
arg @ safematch dup pzanfilter not if
   "<> You can only idle sweep a player or a zombie that is here, awake and not you." "bold,magenta" textattr .tell
   exit
then
dup dup "z" flag? if
   owner
then
db-leastidle TD_Def_Idle 60 * < if
   "<> That person is not yet idle enough to idle swept." "bold,magenta" textattr .tell
   exit
then
dup dup getlink 2 try
   moveto
catch
   pop
   "<> Unfortunatly, due to limitations imposed by the programmer's M# Level," "bold,magenta" textattr .tell
   "<> this player could not be swept home, as either they or their home is not" "bold,magenta" textattr .tell
   "<> set JUMP_OK. Sorry for the inconvenience." "bold,magenta" textattr .tell
   exit
endcatch
"~&150<> " swap dup ansify-name "~&150, ~&170" strcat swap db-mostidle 60 / intostr
"~&150 minutes idle, is idle swept home." strcat strcat strcat notify_room
;
 
: prog-boot ( -- )
arg @ not if
   "<> Boot who from the game?" "bold,magenta" textattr .tell
   exit
then
arg @ safematch dup pzanfilter not if
   "<> You can only boot a player or a zombie that is here, awake and not you." "bold,magenta" textattr .tell
   exit
then
dup "J" flag? over getlink "J" flag? and not if
   "<> Unfortunatly, due to limitations imposed by the programmer's M# Level," "bold,magenta" textattr .tell
   "<> this player could not be swept home, as either they or their home is not" "bold,magenta" textattr .tell
   "<> set JUMP_OK. Sorry for the inconvenience." "bold,magenta" textattr .tell
   exit
then
"~&150<> You vote to boot " over ansify-name "~&150 from the game." strcat strcat ansi-tell
TD_DBootVotes over intostr strcat dup trigger @ swap
over over getpropstr not if
   "~&150<> The first vote has gone up to boot " 5 pick ansify-name "~&150 from the game." strcat strcat notify_room
   "~&150<> Type ~&170\"BOOT " 5 pick ansify-name "~&170\"~&150 if you agree." strcat strcat notify_room
then
me @ reflist_add
'pzafilter me @ location .contents-filter array_make
over trigger @ swap array_get_reflist over
array_intersect trigger @ 4 pick 3 pick array_put_reflist
array_count swap array_count 0.75 * 0 round over <= if
   trigger @ rot remove_prop
   swap dup dup getlink moveto
   ansify-name "~&150<> %s~&150, at ~&170%i~&150 votes, is booted from the game." fmtstring notify_room
then
;
 
( --------------------------------------------------------------------------- )
 
: vote-remind ( var[arg] -- )
arg @ " " split swap pop dup yes? not and not
trigger @ TD_PRemindOn? getpropval over = if
   "~&150<> Reminders are already " swap btos "~&150." strcat strcat ansi-tell
   exit
then
"~&150<> You vote to turn reminders " over btos "~&150." strcat strcat ansi-tell
dup if TD_PVoteRemindY else TD_PVoteRemindN then trigger @ swap over over getpropstr not if
   "~&150<> The first vote has gone up to turn reminders " 4 pick btos "~&150." strcat strcat notify_room
   "~&150<> Type ~&170\"Q #REMIND " 4 pick if "YES" else "NO" then "\"~&150 if you agree." strcat strcat notify_room
then
over over me @ reflist_add
'pzafilter me @ location .contents-filter array_make
3 pick 3 pick array_get_reflist over array_intersect 4 rotate 4 rotate 3 pick array_put_reflist
array_count swap array_count 0.75 * 0 round over <= if
   trigger @ TD_PRemindOn? 4 pick setprop
   trigger @ TD_PVoteRemindY remove_prop
   trigger @ TD_PVoteRemindN remove_prop
   swap btos swap "~&150<> At %i votes, reminders are turned %s~&150." fmtstring notify_room
then
;
 
( --------------------------------------------------------------------------- )
 
: help-header ( -- )
"~&120+----------------------+" ansi-tell
"~&120|  ~&130STC-TorD.muf v1.9F  ~&120|" ansi-tell
"~&120|   ~&170>-*-< ~&110M2HL ~&170>-*-<   ~&120| \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" ansi-tell
"~&120|   ~&130by ~&150Stelard Actek   ~&120|  >~&110Stel~&120Tech~&140Cor~&130, MUFfing on request since ~&1701999~&120<" ansi-tell
"~&120|    ~&130of ~&110Stel~&120Tech~&140Cor    ~&120| /____________________________________________\\" ansi-tell
"~&120+----------------------+                            (...~&170or something~&120...)" ansi-tell
" " .tell
;
 
: show-help ( -- )
arg @ dup ansi_strlen 1 - ansi_strcut swap pop atoi
dup 7 > if
   "No such help page." .tell
   exit
then
 
help-header
dup 1 <= if
   "~&160How to play Truth or Dare:" ansi-tell
   " " .tell
   "~&160The aim of Truth or Dare is to embarrass those around you without getting" ansi-tell
   "~&160embarrassed yourself. This is done through the artful use of questions or by" ansi-tell
   "~&160the application of humiliating dares." ansi-tell
   " " .tell
   "~&160If the game room is empty, you'll have to RESET and RESTART the game first, the" ansi-tell
   "~&160latter of which will select a player to go first for you. If the room is not" ansi-tell
   "~&160empty, just sit down and wait for your turn." ansi-tell
   " " .tell
   "~&160Once it's your turn, you may use the Q command to ask a question of one of the" ansi-tell
   "~&160other players. You should use PICK to select a target, or check the HISTORY and" ansi-tell
   "~&160manually select someone who's not been asked yet or recently." ansi-tell
   " " .tell
   "~&160They should answer using the A command. If the answer fits your question, use" ansi-tell
   "~&160AOK to acknowledge their answer, and it will be their turn to ask someone. If" ansi-tell
   "~&160they answer with a request for a dare, use the D command to give them one, and" ansi-tell
   "~&160then use AOK, so that the game may continue whilst they perform your dare." ansi-tell
   " " .tell
   "~&160That's it! There are other commands that you may find useful, so read the rest" ansi-tell
   "~&160of the documentation too. (~&170Q #HELP2~&160)" ansi-tell
   "~&160Alternatively, view the quick listing of available commands. (~&170Q #QUICK~&160)" ansi-tell
then
 
dup 2 = if
   "~&160Since the disappearance of the Palace of the Dragons, and the establishment" ansi-tell
   "~&160of Genetically Altered Perceptions, I've missed the Truth or Dare of old, and" ansi-tell
   "~&160the muck commands that went with it. This is my attempt at emulating said" ansi-tell
   "~&160commands, with only my memories and no knowledge of the old source code." ansi-tell
   "~&160Apparently the old system was programmed using MPI, where as here I'm using" ansi-tell
   "~&160Multiple User Forth, since I find it easier to comprehend." ansi-tell
   " " .tell
   "~&130Q                         ~&160Ah, now if this isn't the most important command," ansi-tell
   "~&130Q <player>              ~&170- ~&160I don't know what is. Q allows you to do multiple" ansi-tell
   "~&130Q [<player>=]<question>   ~&160things. On it's own, Q will display the last" ansi-tell
   "                          ~&160question to be asked, who asked it and of whom." ansi-tell
   "                          ~&160It can also be given a question, or a player to ask" ansi-tell
   "                          ~&160that question of. So you can select a victim with Q," ansi-tell
   "                          ~&160then ask the question, do it the other way around," ansi-tell
   "                          ~&160or do both at once with by putting them together with" ansi-tell
   "                          ~&160an equals sign. Note also that Q is smart enough to" ansi-tell
   "                          ~&160pick names out of questions, hence, if you where to" ansi-tell
   "                          ~&160ask such a mundane question as:" ansi-tell
   "                          ~&160    \"What's the colour of my eyes, Ques?\"" ansi-tell
   "                          ~&160and there is a player called Ques in the room, then" ansi-tell
   "                          ~&160you don't have to specify the player name. You can" ansi-tell
   "                          ~&160only ask a question if you have 'the Q'. < ^.^ >" ansi-tell
   "~&130A [<answer>]            ~&170- ~&160Type this to properly respond to a question you have" ansi-tell
   "                          ~&160been asked. Or, type A on it's own to find what the" ansi-tell
   "                          ~&160last answer was." ansi-tell
   " " .tell
   "~&160More information on page three (~&170Q #HELP3~&160)." ansi-tell
then
 
dup 3 = if
   "~&130D <player>              ~&170- ~&160Dares are the main reason we play, aren't they? So" ansi-tell
   "~&130  [<player>=]<dare>       ~&160this command is one you'll love to use. It functions" ansi-tell
   "                          ~&160almost exactly like Q, even down to the point of" ansi-tell
   "                          ~&160picking the target out of a sentence. However, the" ansi-tell
   "                          ~&160main difference is that you can dare someone to do" ansi-tell
   "                          ~&160something at any time, although convention dictates" ansi-tell
   "                          ~&160you should only give a dare when asked for one. There" ansi-tell
   "                          ~&160can be multiple dares running at any one time, but" ansi-tell
   "                          ~&160you can only give dares to furs who don't already" ansi-tell
   "                          ~&160have one." ansi-tell
   "~&130AOK [<message>]         ~&170- ~&160Accepts the answer given by whoever has been" ansi-tell
   "                          ~&160questioned. Anyone can accept an answer, though it" ansi-tell
   "                          ~&160should really only be done by the questioner." ansi-tell
   "                          ~&160This has been left open, for situations where the" ansi-tell
   "                          ~&160original questioner has idled or disconnected." ansi-tell
   "                          ~&160You can supply an optional message, which will be" ansi-tell
   "                          ~&160said, unless prefixed with a colon (':'), which will" ansi-tell
   "                          ~&160cause the message to be posed." ansi-tell
   "~&130DOK <player>            ~&170- ~&160Fries somefur's brain! Don't type this! < ^.^ >" ansi-tell
   "                          ~&160Seriously, in case you can't guess, this is the" ansi-tell
   "                          ~&160command for accepting dares. Since there can be more" ansi-tell
   "                          ~&160than one dare running at a time, you must specify a" ansi-tell
   "                          ~&160fur to release from their agony. Once again, anyone" ansi-tell
   "                          ~&160can accept a dare." ansi-tell
   "~&130TIMER <minutes>=<msg>   ~&170- ~&160Sets a timer, with a message, to go off in the" ansi-tell
   "                          ~&160future. The message appears exactly once, after the" ansi-tell
   "                          ~&160specified number of minutes have elapsed." ansi-tell
   " " .tell
   "~&160More information on page four (~&170Q #HELP4~&160)." ansi-tell
then
 
dup 4 = if
   "~&130PICK                    ~&170- ~&160Randomly selects someone to ask a question of from" ansi-tell
   "                          ~&160the room, and sets them up for a question. This" ansi-tell
   "                          ~&160means that after running this command, you only have" ansi-tell
   "                          ~&160to type Q <question>, rather than designating a" ansi-tell
   "                          ~&160target first. Please note that PICK makes no" ansi-tell
   "                          ~&160distinction between the fur who you got the Q off of," ansi-tell
   "                          ~&160and that poor little kitty that's been sitting in the" ansi-tell
   "                          ~&160corner waiting for a go for the last 30 consecutive" ansi-tell
   "                          ~&160questions." ansi-tell
   "~&130HISTORY                 ~&170- ~&160Lists the names of all in the room, and how long it's" ansi-tell
   "                          ~&160been, in questions answered, since they last had a" ansi-tell
   "                          ~&160chance to ask a question." ansi-tell
   "~&130SPIN                    ~&170- ~&160Picks a fur at random, but does nothing. Handy for" ansi-tell
   "                          ~&160those 'do this to someone' dares." ansi-tell
   "~&130GRAB                    ~&170- ~&160Grab the Q. Simple as that. Has a 99.999% chance of" ansi-tell
   "                          ~&160seriously miffing others if used without due cause." ansi-tell
   "~&130RESET                   ~&170- ~&160Clears the history list and the last questions and" ansi-tell
   "                          ~&160answers. Can be used at any time by anyone." ansi-tell
   "~&130RESTART                 ~&170- ~&160Clears the dares, questions and answers, and picks" ansi-tell
   "                          ~&160a new fur to ask a question, but leaves the history" ansi-tell
   "                          ~&160list alone. As above for running." ansi-tell
   "~&130STATUS                  ~&170- ~&160Shows the last question, who asked it and of whom," ansi-tell
   "                          ~&160and any dares currently running." ansi-tell
   " " .tell
   "~&160More information on page five (~&170Q #HELP5~&160)." ansi-tell
then
 
dup 5 = if
   "~&130ISWEEP <player>         ~&170- ~&160For those who don't know, there exists on most MUCKs" ansi-tell
   "                          ~&160a 'sweep' command, that basically gets rid of players" ansi-tell
   "                          ~&160who have fallen asleep away from home. Since most" ansi-tell
   "                          ~&160areas set up for Truth or Dare will have a limit on" ansi-tell
   "                          ~&160the number of players allowed in that room, this" ansi-tell
   "                          ~&160command will kick the designated player out and send" ansi-tell
   "                          ~&160them home, if they are idle enough." ansi-tell
   "~&130BOOT <player>           ~&170- ~&160An unfortunately necessary command, this will put up" ansi-tell
   "                          ~&160an anonymous vote to boot the designated player from" ansi-tell
   "                          ~&160the game. 75% of the players in the room need to" ansi-tell
   "                          ~&160agree. Please only use on rude and unruly players." ansi-tell
   "~&130<ANYCOMMAND> #REMIND ?? ~&170- ~&160This turns the controversial reminder code on or off," ansi-tell
   "                          ~&160depending on what you replaces ?? with. ~&170#REMIND YES" ansi-tell
   "                          ~&160or ~&170#REMIND ON~&160 will turn it on, anything else will" ansi-tell
   "                          ~&160turn it off. Like ~&130BOOT~&160, you need a 75% consensus to" ansi-tell
   "                          ~&160change this setting." ansi-tell
   "~&130<ANYCOMMAND> #QUICK     ~&170- ~&160Quick listing of commands and uses." ansi-tell
   "~&130<ANYCOMMAND> #HELP      ~&170- ~&160Unleashes the Shadow. That BAAAD thing. Run and hide." ansi-tell
   " " .tell
   "~&160Version history on page six (~&170Q #HELP6~&160)." ansi-tell
   "~&160Contact information on page seven (~&170Q #HELP7~&160)." ansi-tell
then
 
dup 6 = if
   "~&130v1.0  ~&170- ~&110* ~&160Original release." ansi-tell
   "        ~&110* ~&160Had all the basics, including Q, A, AOK, D, DOK, SPIN, PICK, HISTORY," ansi-tell
   "          ~&160GRAB, RESTART and RESET. Help wasn't too helpful." ansi-tell
   " " .tell
   "~&130v1.1  ~&170- ~&110* ~&160Some small changes and bug fixes. I forget." ansi-tell
   " " .tell
   "~&130v1.2b ~&170- ~&110* ~&160Added a rather dodgey timer." ansi-tell
   "        ~&110* ~&160Added a quick command listing." ansi-tell
   "        ~&110* ~&160Added helpful help." ansi-tell
   "        ~&110* ~&160Added the STATUS command." ansi-tell
   "        ~&110* ~&160Fixed some small bugs." ansi-tell
   " " .tell
   "~&130v1.3b ~&170- ~&110* ~&160Moved to FuzzBall 6! This version and all following it will only run" ansi-tell
   "          ~&160on FuzzBall 6 or higher." ansi-tell
   "        ~&110* ~&160Changed the timer somewhat. Still didn't like it." ansi-tell
   "        ~&110* ~&160Used the new FuzzBall 6 primitives to tidy up the code somewhat." ansi-tell
   "        ~&110* ~&160Added colour." ansi-tell
   " " .tell
   "~&130v1.4b ~&170- ~&110* ~&160Decided the colour scheme looked stupid, and changed it." ansi-tell
   "        ~&110* ~&160Fixed some small bugs." ansi-tell
   " " .tell
   "~&130v1.5F ~&170- ~&110* ~&160Added the infamous Reminder Code!" ansi-tell
   "        ~&110* ~&160Added rudimentary BOOT and ISWEEP functions." ansi-tell
   "        ~&110* ~&160Decided I wouldn't be able to improve the game anymore until I got an" ansi-tell
   "          ~&170M3 bit ~&160(*snort*!), and declared Final Release." ansi-tell
   " " .tell
   "~&130v1.6F ~&170- ~&110* ~&160Got my furry rear kicked. Fixed the Reminder Code so it wouldn't" ansi-tell
   "          ~&160follow people out of the game. Oopsie." ansi-tell
   " " .tell
   "~&130v1.7F ~&170- ~&110* ~&160Fixed a timing issue with the Reminder Code, and made it" ansi-tell
   "          ~&160differentiate between players who have the Q and have done nothing," ansi-tell
   "          ~&160and players who have chosen a questionee, but not asked a question" ansi-tell
   "          ~&160yet." ansi-tell
   "        ~&110* ~&160Added this version history." ansi-tell
   " " .tell
   "~&130v1.8F ~&170- ~&110* ~&160Added the ability to toggle off the Reminder Code, since some people" ansi-tell
   "          ~&160seemed inordinately annoyed with it, whilst others seemed to like it." ansi-tell
   "        ~&110* ~&160Vowed to never declare Final Release ever again." ansi-tell
   " " .tell
   "~&130v1.9F ~&170- ~&110* ~&160Fixed a minor bug concerning name matching." ansi-tell
   " " .tell
   "~&160Contact information on page seven (~&170Q #HELP7~&160)." ansi-tell
then
 
dup 7 = if
   "      ~&160Questions? Problems? Suggestions? Ideas?" ansi-tell
   " " .tell
   "      ~&160If so, contact your nearest StelTechCor office by mailing Stelard on" ansi-tell
   "      ~&160FurryMUCK, or by emailing stelardactek@bigpond.com." ansi-tell
   " " .tell
   "      ~&160For error reports, please tell what error you got, where you where, what" ansi-tell
   "      ~&160you typed to get the error, the date and approximate time. It would also" ansi-tell
   "      ~&160help to tell who owns the place you where, and how to get there." ansi-tell
   " " .tell
   "      ~&160Thank you for your time." ansi-tell
   "                             ~&110_____  ~&120_________   ~&140_____" ansi-tell
   "                            ~&110/ ___/ ~&120/___  ___/  ~&140/ ___/" ansi-tell
   "                           ~&110/ /__      ~&120/ /     ~&140/ /" ansi-tell
   "                          ~&110/__  /     ~&120/ /     ~&140/ /" ansi-tell
   "                         ~&110___/ /     ~&120/ /     ~&140/ /___" ansi-tell
   "                        ~&110/____/ tel ~&120/_/ ech ~&140/_____/ or" ansi-tell
then
 
" " .tell
;
 
( --------------------------------------------------------------------------- )
 
: show-quick ( -- )
help-header
"~&130Quick help:" ansi-tell
" " .tell
"      ~&130Q [<player>]|[<player>=]<question>" ansi-tell
"            ~&160Asks a player a question." ansi-tell
"      ~&130A [<answer>]" ansi-tell
"            ~&160Answers a question" ansi-tell
"      ~&130D [<player>]|[<player>=]<question>" ansi-tell
"            ~&160Gives a player a dare." ansi-tell
"      ~&130AOK [<message>]" ansi-tell
"            ~&160Declares an answer acceptable and passes the question on." ansi-tell
"      ~&130DOK <player>" ansi-tell
"            ~&160Declares a dare complete." ansi-tell
"      ~&130TIMER <minutes>=<message>" ansi-tell
"            ~&160Sets a timer with a message." ansi-tell
"      ~&130PICK" ansi-tell
"            ~&160Selects a player at random and directs the question to them." ansi-tell
"      ~&130HISTORY" ansi-tell
"            ~&160Shows who's had a go most recently." ansi-tell
"      ~&130SPIN" ansi-tell
"            ~&160Selects a player at random, and does nothing." ansi-tell
"      ~&130GRAB" ansi-tell
"            ~&160Makes it your turn to ask a question. Use sparingly." ansi-tell
"      ~&130RESET" ansi-tell
"            ~&160Clears the history list, dares, questions and answers." ansi-tell
"      ~&130RESTART" ansi-tell
"            ~&160Clears the dares, questions and answers, and picks a new player" ansi-tell
"            ~&160to ask a question." ansi-tell
"      ~&130STATUS" ansi-tell
"            ~&160Shows the current game status." ansi-tell
"      ~&130ISWEEP <player>" ansi-tell
"            ~&160Sweeps an idle player." ansi-tell
"      ~&130BOOT <player>" ansi-tell
"            ~&160Holds a vote to boot a player from the game." ansi-tell
" " .tell
"~&160How to play on page one of the help (~&170Q #HELP~&160)" ansi-tell
;
 
( --------------------------------------------------------------------------- )
 
: main
strip arg !
 
me @ TD_PLastVer getpropstr dup if
   TD_Version stringcmp dup 0 < if "newer" else "older" then swap if
      "~&160This is a ~&170%s~&160 version of ~&130STC~&170-~&130TorD.muf~&160 than you have used before." fmtstring ansi-tell
      "~&160For a list of changes, please look at help page six (~&170Q #HELP6~&160)." ansi-tell
      "~&160This message will not appear again for this version." ansi-tell
      me @ TD_PLastVer TD_Version setprop
      exit
   then
else
   pop me @ TD_PLastVer TD_Version setprop
then
 
arg @ 2 ansi_strcut pop "#H" stringcmp not if show-help exit then
arg @ 2 ansi_strcut pop "#Q" stringcmp not if show-quick exit then
arg @ 2 ansi_strcut pop "#R" stringcmp not if vote-remind exit then
command @ "Q" stringcmp not if prog-Q exit then
command @ 1 ansi_strcut "OK" stringcmp not if prog-OK exit else pop then
command @ "A" stringcmp not if prog-A exit then
command @ "D" stringcmp not if prog-D exit then
command @ "TIME" instring if prog-time exit then
command @ "PICK" instring if prog-pick exit then
command @ "HIST" instring if prog-hist exit then
command @ "SPIN" instring if prog-spin exit then
command @ "GRAB" instring if prog-grab exit then
command @ 3 ansi_strcut swap "RES" stringcmp not if prog-reset exit else pop then
command @ "STAT" instring if prog-stat exit then
command @ "ISWEEP" instring if prog-isweep exit then
command @ "BOOT" instring if prog-boot exit then
;
