( STC-TorD.muf v1.2b, by Stelard Actek of StelTechCor @ FurryMUCK!
 
 What can I say? One day, my second favourite place to hang out on Furry was
 suddenly gone. The Palace of the Dragons' Truth or Dare pools have held a
 special place in my heart for a long time. True, of late, I've not had much
 fun there, due to a worrying streak of unoriginality and limpness among the
 players, but still. A friend told me a coalition of furs had taken it upon
 themselves to create a replacement area. The new command set I found there
 was, just close enough to the old one to be maddening, and missing some
 features. Hence this, my solution, rendered in lovely Multiple User Forth.
 
 Right, that's enough of that. To set the program up, simply create an action.
 Anywhere, on anything. It can be a room or an object, or even yourself, but
 the latter makes no sense unless you want to be the only person to play it.
 Name it 'Q;A;D;AOK;DOK;TIMER;PICK;HISTORY;SPIN;GRAB;RESET;RESTART;STATUS',
 and link it to this program. That's it! This program stores all it's data on
 the action, so porters make sure the program is set HARDUID.
 
 The status of the game is stored on the action, so make sure that if you're
 going to have several rooms setup like this, you have separate action sets
 for each room. Also, for the same reasons, don't split the action up. Make
 it one action, as above.
 
 Last notes:
   This is a BETA release! It is untested, beyond the simple testing one
   does during coding. I take no responsibility et cetera, et cetera, though
   I don't see how it could possibly do any damage.
   If you have a problem, either page mail Stelard @ FurryMUCK! or email
   stelardactek@bigpond.com. Remeber to tell me WHAT you were doing, not
   just the error message!
 
 Uses:
   lib/look
   lib/reflist
   lib/strings
   .confirm
   .popn
   .tell
)
( @list <ref>=1-39 )
lvar arg
$include $lib/look
$include $lib/reflist
$include $lib/strings
$def notify_room me @ location #-1 rot notify_except
$ifndef __version>Muck2.2fb6.00b4
   $def popn .popn
$endif
 
: pzafilter ( d -- b )
dup player? over "Z" flag? or if
   awake?
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
"" "!" subst
"" "?" subst
"" "." subst
"" "," subst
"" ";" subst
"" ":" subst
;
 
: set-target ( d -- )
trigger @ "_CurTarget" rot setprop
;
 
: set-daree ( d -- b )
trigger @ "_DareTargets/" me @ intostr strcat 3 pick setprop
trigger @ "_CurDarees" 3 pick REF-inlist? if
   0 exit
then
trigger @ "_CurDarees" 3 pick REF-add
trigger @ "_CurDares/" rot intostr "/Darer" strcat strcat me @ setprop
1
;
 
: get-targetstr ( -- s )
trigger @ "_CurTarget" getprop dup dbref? if
   name
else
   pop "?"
then
;
 
: get-playerstr ( -- s )
trigger @ "_CurPlayer" getprop dup dbref? if
   name
else
   pop "?"
then
;
 
: parse-pose ( s -- s )
  dup if
    dup strlen 3 > if
      dup strip "'" 1 strncmp not if
        dup 4 strcut pop " " instr not if " " swap strcat then
      then
    then
    ". ,':!?-"
    over strip 1 strcut pop instr not if " " swap strcat then
  then
  me @ name me @ "_prefs/prepose" getpropstr strcat swap strcat
;
 
: ask-question ( s -- )
dup 1 strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " asks, \"" strcat swap "\"" strcat strcat
then
"<> (" me @ name " asks " get-targetstr ") " 6 pick
strcat strcat strcat strcat strcat notify_room
trigger @ "_CurQuestion" rot setprop
;
 
: give-dare ( s -- )
dup 1 strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " dares, \"" strcat swap "\"" strcat strcat
then
trigger @ "_DareTargets/" me @ intostr strcat getprop
"<> (" me @ name " dares " 4 pick dup dbref? if name else pop "?" then ") " 7 pick
strcat strcat strcat strcat strcat notify_room
trigger @ "_CurDares/" rot intostr "/Dare" strcat strcat rot setprop
;
 
( --------------------------------------------------------------------------- )
 
: prog-Q ( -- )
arg @ not if
   trigger @ "_CurQuestion" getpropstr dup not if
      pop "<> " get-playerstr " hasn't asked a question yet." strcat strcat .tell
   else
      "<> (" get-playerstr " asked " get-targetstr ") " 6 rotate
      strcat strcat strcat strcat strcat .tell
   then
   exit
then
trigger @ "_CurPlayer" getprop dup dbref? if
   me @ dbcmp not if
      "<> You can't ask a question until it is your turn!" .tell
      exit
   then
else
   pop "<> You need to restart the game. Type RESTART." .tell
   exit
then
arg @ "=" instr if
   arg @ "=" .split swap match dup pzanfilter if   ( A player=question situation )
      set-target
      ask-question
   else
      pop
      "<> You can't ask someone who isn't here, is asleep, or doesn't exist." .tell
   then
else
   arg @ " " instr if                              ( More than one word parameter )
      trigger @ "_CurTarget" getprop dbref? not if
         arg @ " " explode
         1 - swap char-strip match dup pzanfilter if                    (First word?)
            set-target
         else
            pop 1 - dup 2 + rotate char-strip match dup pzanfilter if   (Last word?)
               set-target
            else
               pop begin                                                (Other words?)
                  dup 0 = not while
                  1 - swap char-strip match dup pzanfilter if
                     set-target
                  else
                     pop
                  then
               repeat
            then
         then
      then
      arg @ ask-question
   else
      arg @ match dup pzanfilter if                ( The one word is a player name )
         "<> " me @ name " directs the question to " 4 pick name "." strcat strcat strcat strcat notify_room
         set-target
      else
         arg @ ask-question
      then
   then
then
;
 
: prog-OK ( s -- )
"A" stringcmp not if
   "<> (" me @ name " accepts " get-targetstr "'s answer) " strcat strcat strcat strcat
   arg @ dup if
      dup 1 strcut swap ":" strcmp not if
         swap pop parse-pose
      else
         pop me @ name " says, \"" strcat swap "\"" strcat strcat
      then strcat
   else
      pop
   then notify_room
   trigger @ "_CurTarget" getprop dup trigger @ "_CurPlayer" rot setprop
   trigger @ "_CurTarget" remove_prop
   trigger @ "_CurQuestion" remove_prop
   trigger @ "_CurAnswer" remove_prop
   trigger @ "_QCount" getpropval 1 + dup trigger @ "_QCount" rot setprop
   trigger @ "_LastQ/" 4 rotate intostr strcat rot setprop
else
   arg @ not if
      "<> Declare who's dare complete? You must specify the daree." .tell
      exit
   then
   arg @ match dup pzanfilter not if
      "<> You can't end the dare of someone who isn't here, is asleep, or doesn't exist." .tell
      exit
   then
   trigger @ "_CurDarees" 3 pick REF-inlist? not if
      "<> That person doesn't have a dare to clear." .tell
      exit
   then
   trigger @ "_CurDares/" 3 pick intostr strcat remove_prop
   trigger @ "_CurDarees" 3 pick REF-delete
   "<> " me @ name " declares " 4 rotate name "'s dare complete." strcat strcat strcat strcat notify_room
then
;
 
: prog-A ( -- )
arg @ not if
   trigger @ "_CurAnswer" getpropstr dup not if
      pop "<> " get-targetstr " hasn't answered yet." strcat strcat .tell
   else
      "<> (" get-targetstr " answered " get-playerstr ") " 6 rotate
      strcat strcat strcat strcat strcat .tell
   then
   exit
then
trigger @ "_CurTarget" getprop dup dbref? if
   me @ dbcmp not if
      "<> You can't answer a question you weren't asked!" .tell
      exit
   then
else
   pop
then
arg @ dup 1 strcut swap ":" strcmp not if
   swap pop parse-pose
else
   pop me @ name " answers, \"" strcat swap "\"" strcat strcat
then
"<> (" me @ name " answers " trigger @ "_CurPlayer" getprop name ") " 6 pick
strcat strcat strcat strcat strcat notify_room
trigger @ "_CurAnswer" rot setprop
;
 
: prog-D ( -- )
arg @ "=" instr if
   arg @ "=" .split swap match dup pzanfilter if   ( A player=dare situation )
      set-daree not if
         "<> That person already has a dare to do." .tell
         exit
      then
      give-dare
   else
      pop
      "<> You can't dare someone who isn't here, or doesn't exist." .tell
   then
else
   arg @ " " instr if                              ( More than one word parameter )
      trigger @ "_DareTargets/" me @ intostr strcat getprop dbref? not if
         arg @ " " explode
         1 - swap char-strip match dup pzanfilter if                    (First word?)
            set-daree not if
               "<> That person already has a dare to do." .tell
               exit
            then
         else
            pop 1 - dup 2 + rotate char-strip match dup pzanfilter if   (Last word?)
               set-daree not if
                  "<> That person already has a dare to do." .tell
                  exit
               then
            else
               pop begin                                                (Other words?)
                  dup 0 = not while
                  1 - swap char-strip match dup pzanfilter if
                     set-daree not if
                        "<> That person already has a dare to do." .tell
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
      arg @ match dup pzanfilter if                ( The one word is a player name )
         dup set-daree not if
            "<> That person already has a dare to do." .tell
            exit
         then
         "<> " me @ name " directs the dare to " 4 rotate name "." strcat strcat strcat strcat notify_room
      else
         arg @ give-dare
      then
   then
then
;
 
: prog-time ( -- )
arg @ "=" .split swap atoi swap
"<> " me @ name " sets a timer with the message: \"" 4 pick "\" for " 7 pick intostr " minutes."
strcat strcat strcat strcat strcat strcat notify_room
swap 60 * background sleep
"<> A timer set by " me @ name " goes off with the message: \"" 4 rotate "\""
strcat strcat strcat strcat trigger @ location #-1 rot notify_except
;
 
: prog-pick ( -- )
trigger @ "_CurPlayer" getprop dup dbref? if
   me @ dbcmp not if
      "<> You can't pick a victim until it is your turn!" .tell
      exit
   then
else
   pop "<> You need to restart the game. Type RESTART." .tell
   exit
then
'pzanfilter me @ location .contents-filter dup 0 = if
   "<> There's no one else here..." .tell
   exit
else
   random over % 2 + pick
then
"<> " me @ name "'s eyes scan around the room, eventually settling on " 4 pick name "!"
strcat strcat strcat strcat notify_room
set-target
popn
;
 
: prog-hist ( -- )
"<> History" .tell
"-Player--------------Last-turn--------------------------------------------------" .tell
'pzafilter me @ location .contents-filter
begin
   dup 0 = not while
   1 - swap dup name 20 STRleft " " swap strcat
   trigger @ "_LastQ/" 4 rotate intostr strcat getpropval dup 0 = if
      pop "  -- NONE --"
   else
      trigger @ "_QCount" getpropval swap - dup 1 = if
         intostr " question ago"
      else
         intostr " questions ago"
      then strcat
   then strcat .tell
repeat
"--------------------------------------------------------------------------------" .tell
;
 
: prog-spin ( -- )
'pzanfilter me @ location .contents-filter dup 0 = if me @ else random over %  2 + pick then
"<> " me @ name " spins the spinner, and it stops pointing at " 4 rotate name "!"
strcat strcat strcat strcat notify_room
popn
;
 
: prog-grab ( -- )
"<> " me @ name " grabs the Q!" strcat strcat notify_room
trigger @ "_CurPlayer" me @ setprop
trigger @ "_CurTarget" remove_prop
trigger @ "_CurQuestion" remove_prop
trigger @ "_CurAnswer" remove_prop
;
 
: prog-reset ( s -- )
"ET" instring if
   "Are you sure you want to reset the game? (y/n)" .confirm not if exit then
   "<> " me @ name " resets the game! Kerr-CHUNK!!" strcat strcat notify_room
   trigger @ "_CurTarget" remove_prop
   trigger @ "_CurQuestion" remove_prop
   trigger @ "_CurAnswer" remove_prop
   trigger @ "_QCount" remove_prop
   trigger @ "_LastQ" remove_prop
   trigger @ "_DareTargets" remove_prop
else
   "Are you sure you want to restart the game? (y/n)" .confirm not if exit then
   "<> " me @ name " restarts the game!" strcat strcat notify_room
   'pzafilter me @ location .contents-filter random over % 2 + pick
   "<> The question zooms around the room, eventually settling on " over name "!" strcat strcat notify_room
   trigger @ "_CurPlayer" rot setprop
   trigger @ "_CurTarget" remove_prop
   trigger @ "_CurQuestion" remove_prop
   trigger @ "_CurAnswer" remove_prop
   trigger @ "_CurDarees" remove_prop
   trigger @ "_CurDares" remove_prop
   trigger @ "_DareTargets" remove_prop
   popn
then
;
 
: prog-stat ( -- )
"Game status" .tell
"-----------" .tell
" " .tell
"" arg ! prog-Q
" " .tell
trigger @ "_CurDarees" getpropstr if
   "Dares:" .tell
   trigger @ "_CurDarees" REF-allrefs
   begin
      dup 0 = not while
      1 - swap
      "<> (" "_CurDares/" 3 pick intostr "/Darer" strcat strcat dup trigger @ swap getprop name
      " to " 5 rotate name ") " trigger @ 6 rotate dup strlen 1 - strcut pop getpropstr
      strcat strcat strcat strcat strcat .tell
   repeat
   " " .tell
then
;
 
( --------------------------------------------------------------------------- )
 
: show-help ( -- )
arg @ dup strlen 1 - strcut swap pop atoi
dup 1 <= if
   "+----------------------+" .tell
   "|  STC-TorD.muf v1.2b  |" .tell
   "|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
   "|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
   "|    of StelTechCor    | /____________________________________________\\" .tell
   "+----------------------+                            (...or something...)" .tell
   " " .tell
   "How to play Truth or Dare:" .tell
   " " .tell
   "The aim of Truth or Dare is to embarrass those around you without getting" .tell
   "embarrassed yourself. This is done through the artful use of questions or by" .tell
   "the application of humiliating dares." .tell
   " " .tell
   "If the game room is empty, you'll have to RESET and RESTART the game first, the" .tell
   "latter of which will select a player to go first for you. If the room is not" .tell
   "empty, just sit down and wait for your turn." .tell
   " " .tell
   "Once it's your turn, you may use the Q command to ask a question of one of the" .tell
   "other players. You should use PICK to select a target, or check the HISTORY and" .tell
   "manually select someone who's not been asked yet or recently." .tell
   " " .tell
   "They should answer using the A command. If the answer fits your question, use" .tell
   "AOK to acknowledge their answer, and it will be their turn to ask someone. If" .tell
   "they answer with a request for a dare, use the D command to give them one, and" .tell
   "then use AOK, so that the game may continue whilst they perform your dare." .tell
   " " .tell
   "That's it! There are other commands that you may find useful, so read the rest" .tell
   "of the documentation too. (Q #HELP2)" .tell
then
 
dup 2 = if
   "+----------------------+" .tell
   "|  STC-TorD.muf v1.2b  |" .tell
   "|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
   "|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
   "|    of StelTechCor    | /____________________________________________\\" .tell
   "+----------------------+                            (...or something...)" .tell
   " " .tell
   "Since the disappearance of the Palace of the Dragons, and the establishment" .tell
   "of Genetically Altered Perceptions, I've missed the Truth or Dare of old, and" .tell
   "the muck commands that went with it. This is my attempt at emulating said" .tell
   "commands, with only my memories and no knowledge of the old source code." .tell
   "Apparently the old system was programmed using MPI, where as here I'm using" .tell
   "Multiple User Forth, since I find it easier to comprehend." .tell
   " " .tell
   "Q                         Ah, now if this isn't the most important command," .tell
   "Q <player>              - I don't know what is. Q allows you to do multiple" .tell
   "Q [<player>=]<question>   things. On it's own, Q will display the last" .tell
   "                          question to be asked, who asked it and of whom." .tell
   "                          It can also be given a question, or a player to ask" .tell
   "                          that question of. So you can select a victim with Q," .tell
   "                          then ask the question, do it the other way around," .tell
   "                          or do both at once with by putting them together with" .tell
   "                          an equals sign. Note also that Q is smart enough to" .tell
   "                          pick names out of questions, hence, if you where to" .tell
   "                          ask such a mundane question as:" .tell
   "                              \"What's the colour of my eyes, Ques?\"" .tell
   "                          and there is a player called Ques in the room, then" .tell
   "                          you don't have to specify the player name. You can" .tell
   "                          only ask a question if you have 'the Q'. < ^.^ >" .tell
   "A [<answer>]            - Type this to properly respond to a question you have" .tell
   "                          been asked. Or, type A on it's own to find what the" .tell
   "                          last answer was." .tell
   " " .tell
   "More information on page two (Q #HELP3)." .tell
then
 
dup 3 = if
   "+----------------------+" .tell
   "|  STC-TorD.muf v1.2b  |" .tell
   "|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
   "|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
   "|    of StelTechCor    | /____________________________________________\\" .tell
   "+----------------------+                            (...or something...)" .tell
   " " .tell
   "D                       - Dares are the main reason we play, aren't they? So" .tell
   "                          this command is one you'll love to use. It functions" .tell
   "                          almost exactly like Q, even down to the point of" .tell
   "                          picking the target out of a sentence. However, the" .tell
   "                          main difference is that you can dare someone to do" .tell
   "                          something at any time, although convention dictates" .tell
   "                          you should only give a dare when asked for one. There" .tell
   "                          can be multiple dares running at any one time, but" .tell
   "                          you can only give dares to furs who don't already" .tell
   "                          have one." .tell
   "AOK [<message>]         - Accepts the answer given by whoever has been" .tell
   "                          questioned. Anyone can accept an answer, though it" .tell
   "                          should really only be done by the questioner." .tell
   "                          This has been left open, for situations where the" .tell
   "                          original questioner has idled or disconnected." .tell
   "                          You can supply an optional message, which will be" .tell
   "                          said, unless prefixed with a colon (':'), which will" .tell
   "                          cause the message to be posed." .tell
   "DOK <player>            - Fries somefur's brain! Don't type this! < ^.^ >" .tell
   "                          Seriously, in case you can't guess, this is the" .tell
   "                          command for accepting dares. Since there can be more" .tell
   "                          than one dare running at a time, you must specify a" .tell
   "                          fur to release from their agony. Once again, anyone" .tell
   "                          can accept a dare." .tell
   "TIMER <minutes>=<msg>   - Sets a timer, with a message, to go off in the" .tell
   "                          future. The message appears exactly once, after the" .tell
   "                          specified number of minutes have elapsed." .tell
   " " .tell
   "More information on page three (Q #HELP4)." .tell
then
 
dup 4 = if
   "+----------------------+" .tell
   "|  STC-TorD.muf v1.2b  |" .tell
   "|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
   "|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
   "|    of StelTechCor    | /____________________________________________\\" .tell
   "+----------------------+                            (...or something...)" .tell
   " " .tell
   "PICK                    - Randomly selects someone to ask a question of from" .tell
   "                          the room, and sets them up for a question. This" .tell
   "                          means that after running this command, you only have" .tell
   "                          to type Q <question>, rather than designating a" .tell
   "                          target first. Please note that PICK makes no" .tell
   "                          distinction between the fur who you got the Q off of," .tell
   "                          and that poor little kitty that's been sitting in the" .tell
   "                          corner waiting for a go for the last 30 consecutive" .tell
   "                          questions." .tell
   "HISTORY                 - Lists the names of all in the room, and how long it's" .tell
   "                          been, in questions answered, since they last had a" .tell
   "                          chance to ask a question." .tell
   "SPIN                    - Picks a fur at random, but does nothing. Handy for" .tell
   "                          those 'do this to someone' dares." .tell
   "GRAB                    - Grab the Q. Simple as that. Has a 99.999% chance of" .tell
   "                          seriously miffing others if used without due cause." .tell
   "RESET                   - Clears the history list and the last questions and" .tell
   "                          answers. Can be used at any time by anyone." .tell
   "RESTART                 - Clears the dares, questions and answers, and picks" .tell
   "                          a new fur to ask a question, but leaves the history" .tell
   "                          list alone. As above for running." .tell
   "STATUS                  - Shows the last question, who asked it and of whom," .tell
   "                          and any dares currently running." .tell
   "<ANYCOMMAND> #QUICK     - Quick listing of commands and uses." .tell
   "<ANYCOMMAND> #HELP      - Unleashes the Shadow. That BAAAD thing. Run and hide." .tell
   " " .tell
   "Contact information on page four (Q #HELP5)." .tell
then
  
dup 5 = if
   "+----------------------+" .tell
   "|  STC-TorD.muf v1.2b  |" .tell
   "|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
   "|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
   "|    of StelTechCor    | /____________________________________________\\" .tell
   "+----------------------+                            (...or something...)" .tell
   " " .tell
   "      Questions? Problems? Suggestions? Ideas?" .tell
   " " .tell
   "      If so, contact your nearest StelTechCor office by mailing Stelard on" .tell
   "      FurryMUCK, or by emailing stelardactek@bigpond.com." .tell
   " " .tell
   "      For error reports, please tell what error you got, where you where, what" .tell
   "      you typed to get the error, the date and approximate time. It would also" .tell
   "      help to tell who owns the place you where, and how to get there." .tell
   " " .tell
   "      Thank you for your time." .tell
   "                             _____  _________   _____" .tell
   "                            / ___/ /___  ___/  / ___/" .tell
   "                           / /__      / /     / /" .tell
   "                          /__  /     / /     / /" .tell
   "                         ___/ /     / /     / /___" .tell
   "                        /____/ tel /_/ ech /_____/ or" .tell
then
 
dup 5 > if
   "No such help page." .tell
then
 
" " .tell
;
 
( --------------------------------------------------------------------------- )
 
: show-quick ( -- )
"+----------------------+" .tell
"|  STC-TorD.muf v1.2b  |" .tell
"|    [:<- BETA ->:]    | \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/" .tell
"|   by Stelard Actek   |  >StelTechCor, MUFfing on request since 1999<" .tell
"|    of StelTechCor    | /____________________________________________\\" .tell
"+----------------------+                            (...or something...)" .tell
" " .tell
"Quick help:" .tell
" " .tell
"      Q <player>/[<player>=]<question>" .tell
"            Asks a player a question." .tell
"      A <answer>" .tell
"            Answers a question" .tell
"      D <player>/[<player>=]<question>" .tell
"            Gives a player a dare." .tell
"      AOK [<message>]" .tell
"            Declares an answer acceptable and passes the question on." .tell
"      DOK <player>" .tell
"            Declares a dare complete." .tell
"      TIMER <minutes>=<message>" .tell
"            Sets a timer with a message." .tell
"      PICK" .tell
"            Selects a player at random and directs the question to them." .tell
"      HISTORY" .tell
"            Shows who's had a go most recently." .tell
"      SPIN" .tell
"            Selects a player at random, and does nothing." .tell
"      GRAB" .tell
"            Makes it your turn to ask a question. Use sparingly." .tell
"      RESET" .tell
"            Clears the history list, dares, questions and answers." .tell
"      RESTART" .tell
"            Clears the dares, questions and answers, and picks a new player" .tell
"            to ask a question." .tell
"      STATUS" .tell
"            Shows the current game status." .tell
" " .tell
"How to play on page one of the help (Q #HELP)" .tell
;
 
( --------------------------------------------------------------------------- )
 
: main
arg !
 
arg @ 2 strcut pop "#H" stringcmp not if show-help exit then
arg @ 2 strcut pop "#Q" stringcmp not if show-quick exit then
command @ "Q" stringcmp not if prog-Q exit then
command @ 1 strcut "OK" stringcmp not if prog-OK exit else pop then
command @ "A" stringcmp not if prog-A exit then
command @ "D" stringcmp not if prog-D exit then
command @ "TIME" instring if prog-time exit then
command @ "PICK" instring if prog-pick exit then
command @ "HIST" instring if prog-hist exit then
command @ "SPIN" instring if prog-spin exit then
command @ "GRAB" instring if prog-grab exit then
command @ 3 strcut swap "RES" stringcmp not if prog-reset exit else pop then
command @ "STAT" instring if prog-stat exit then
;
