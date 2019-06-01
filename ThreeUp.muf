(ThreeUp.muf -- A card game by Stelard Actek. v1.92
 
ThreeUp.muf - User's Manual
---------------------------
 
Author: Stelard Actek
Author email: stelardactek@bigpond.com
              [Please send comments, constructive criticism and problem reports for this program]
Version: 1.92
Requires: M2SL flags
          .confirm definition
          .split definition
          .tell definition
          lib/reflist
          lib/strings
          Players! ;>
 
Description:
 
ThreeUp is a card game I learnt during my first year at college and is the only game of cards I exhibit any aptitude at and enjoy. This program will basically allow you to set up a virtual deck of cards on a muck and play. It only simulates the actual game. If you want money or items of clothing to change paws depending on the outcome of the game, you'll have to do it yourself. I'm not going to change this, because I only wrote the program because you can't role play a card game.
 
How to install:
1. Make a program called ThreeUp.muf and copy the program code into it.
2. Set the program to M2, S and L.
3. Create an object. Call it 'Deck of cards' or somesuch.
4. Create an action on the object with the name 'tshuffle;tjoin;tend;tstatus;tbegin;tplay;tpick;tpickup;tdraw;tfold;tkick;tsetup;tpub;tpriv;tchat;thelp'
5. Link that action to this program.
6. Play!
 
Good luck, and enjoy!
)
 
$include $lib/reflist
$include $lib/strings
$def Suit1 "Blades"        (Suit names.)
$def Suit2 "Staves"
$def Suit3 "Lovers"
$def Suit4 "Jewels"
$def SuitMatch "[^bslj]"   (Used in smatch routine. Should match all non suit prefixes.)
$def NumSuitLet 1          (X number of prefix letters from suit name to use as reference.)
$def 01Name "Elite"        (Special card names.)
$def 11Name "Apprentice"
$def 12Name "Scholar"
$def 13Name "Master"
$def WildName "Cosmos"
$def DefCards 3            (Number of cards in down, up and in paw. Alter at your own risk.)
lvar MaxUp
lvar MaxDown
lvar MaxPaw
lvar MaxPlayers
lvar arg
lvar deck
lvar tempval
lvar tempstr
lvar obj
 
: notify_game ( s -- )
deck @ "Private?" getpropval if
   deck @ "ingame" REF-first
   begin
      dup #-1 dbcmp not while
      over over swap notify
      deck @ "ingame" rot REF-next
   repeat pop pop
else
   me @ location #-1 rot notify_except
then
;
 
: compiletempstr ( var[tempstr,tempval] i -- var[tempstr] )
tempval @ = tempval @ 1 = not and if
   " and " swap strcat
else
   tempval @ 1 = not if
      ", " swap strcat
   then
then
tempstr @ swap strcat tempstr !
;
 
: int2card ( i -- s )
dup 0 = if
   pop "Nothing"
   exit
then
dup 15 bitand
dup 1 > over 11 < and if
   intostr
else
   dup 1 = if
      pop 01Name
   else
      dup 11 = if
         pop 11Name
      else
         dup 12 = if
            pop 12Name
         else
            dup 13 = if
               pop 13Name
            else
               dup 14 = if
                  pop WildName
               then
            then
         then
      then
   then
then
 
swap -4 bitshift
dup 0 = if
   pop Suit1
else
   dup 1 = if
      pop Suit2
   else
      dup 2 = if
         pop Suit3
      else
         dup 3 = if
            pop Suit4
         then
      then
   then
then
" of " swap strcat strcat
;
 
: random-card ( -- i )
random 14 % 1 +
random 4 % 4 bitshift bitor
;
 
: init-cards ( var[deck] -- )
0 tempval !
me @ "ThreeUp" remove_prop
me @ name " recieves " MaxDown @ intostr " cards down, " MaxUp @ intostr " cards up ("
strcat strcat strcat strcat strcat tempstr !
begin
   random-card
   intostr " " swap " " strcat strcat
   deck @ "cardsdealt" getpropstr over instr 0 = not if
      pop continue
   then
   deck @ "cardsdealt" getpropstr over strcat deck @ "cardsdealt" rot setprop
   me @ "ThreeUp/Down" getpropstr swap strcat me @ "ThreeUp/Down" rot setprop
   tempval @ 1 + tempval !
tempval @ MaxDown @ = until
 
0 tempval !
begin
   random-card
   dup intostr " " swap " " strcat strcat
   deck @ "cardsdealt" getpropstr over instr 0 = not if
      pop continue
   then
   deck @ "cardsdealt" getpropstr over strcat deck @ "cardsdealt" rot setprop
   me @ "ThreeUp/Up" getpropstr swap strcat me @ "ThreeUp/Up" rot setprop
   tempval @ 1 + tempval !
   int2card
   MaxUp @ compiletempstr
tempval @ MaxUp @ = until
tempstr @ "), and " MaxPaw @ intostr " cards in paw." strcat strcat strcat "<> " swap strcat notify_game
 
0 tempval !
"<> Cards in paw: " tempstr !
begin
   random-card
   dup intostr " " swap " " strcat strcat
   deck @ "cardsdealt" getpropstr over instr 0 = not if
      pop continue
   then
   deck @ "cardsdealt" getpropstr over strcat deck @ "cardsdealt" rot setprop
   me @ "ThreeUp/Paw" getpropstr swap strcat me @ "ThreeUp/Paw" rot setprop
   tempval @ 1 + tempval !
   int2card
   MaxPaw @ compiletempstr
tempval @ MaxPaw @ = until
tempstr @ .tell
;
 
: next-player ( var[deck] -- d )
deck @ "ingame" me @ REF-next dup #-1 dbcmp if
   deck @ "ingame" REF-first
then
dup deck @ "curplayer" rot setprop
deck @ "drawn" remove_prop
;
 
: end-player ( d -- i )
"ThreeUp" remove_prop 0
;
 
: end-game ( var[deck] -- )
deck @ "dealer" getprop dup not if
   "<> There is no game to end!" .tell
   exit
then
dup location me @ location dbcmp (is dealer in same room as other players?)
over me @ dbcmp not rot awake? and and if
   "<> Only the dealer can end the game!" .tell
   exit
then
"<> " me @ name " gathers up the cards and returns them to the deck." strcat strcat notify_game
deck @ "dealer" remove_prop
deck @ "cardsdealt" remove_prop
deck @ "cardstack" remove_prop
deck @ "curplayer" remove_prop
'end-player deck @ "ingame" REF-filter pop
deck @ "ingame" remove_prop
deck @ "drawn" remove_prop
;
 
: shuffle-cards ( var[deck] -- )
deck @ "dealer" getprop if
   "<> Please end the current game first." .tell
   exit
then
deck @ "ingame" me @ intostr "#" swap strcat setprop
"<> " me @ name " shuffles the ThreeUp deck..." strcat strcat notify_game
deck @ "dealer" me @ setprop
deck @ "cardsdealt" remove_prop
deck @ "cardstack" remove_prop
deck @ "curplayer" remove_prop
'end-player deck @ "ingame" REF-filter pop
deck @ "drawn" remove_prop
init-cards
;
 
: join-game ( var[deck] -- )
deck @ "ingame" getpropstr dup strlen swap "" " " subst strlen - MaxPlayers @ 1 - = if
   "<> This game is full, sorry." .tell
   exit
then
deck @ "cardstack" getpropstr if
   "<> The game has already started. You'll have to wait, sorry." .tell
   exit
then
deck @ "ingame" me @ REF-inlist? if
   "<> You've already joined the game!" .tell
   exit
then
deck @ "dealer" getprop dup dbref? not if
   pop
   "<> No game has been started!" .tell
   exit
then
dup location me @ location dbcmp not if
   pop
   "<> No game has been started here!" .tell
   exit
then
me @ dbcmp if
   "<> You can't join yourself!" .tell
   exit
then
deck @ "ingame" me @ REF-add
"<> " me @ name " joins the game!" strcat strcat notify_game
init-cards
;
 
: status-player ( d -- 0 )
obj !
obj @ name 20 STRleft
obj @ "ThreeUp/Down" getpropstr dup strlen swap "" " " subst strlen - 2 / intostr 5 STRcenter
obj @ "ThreeUp/Up" getpropstr dup strlen swap "" " " subst strlen - 2 / intostr 5 STRcenter
obj @ "ThreeUp/Paw" getpropstr dup strlen swap "" " " subst strlen - 2 / intostr 4 STRcenter
strcat strcat strcat .tell
0
;
 
: upcards-player ( d -- 0 )
dup obj !
name "'s upwards facing cards:" strcat .tell
"-1" obj @ "ThreeUp/Up" getpropstr strip "  " explode pop
begin
   atoi dup -1 = not if
      int2card "   " swap strcat tempstr !
   else
      break
   then
   atoi dup -1 = not if
      int2card tempstr @ 30 STRleft swap strcat .tell
   else
      tempstr @ .tell pop break
   then
repeat
" " .tell
0
;
 
: status-game ( var[deck] -- )
"Name                Down  Up  Paw" .tell
'status-player deck @ "ingame" REF-filter pop
" " .tell
arg @ "#full" instring 0 = not if
   'upcards-player deck @ "ingame" REF-filter pop
then
"Your cards in paw:" .tell
"-1" me @ "ThreeUp/Paw" getpropstr strip "  " explode pop
begin
   atoi dup -1 = not if
      int2card "   " swap strcat tempstr !
   else
      break
   then
   atoi dup -1 = not if
      int2card tempstr @ 30 STRleft swap strcat .tell
   else
      tempstr @ .tell pop break
   then
repeat
" " .tell
"Cards left in deck:   "
56 deck @ "cardsdealt" getpropstr dup strlen swap "" " " subst strlen - 2 / - intostr strcat .tell
deck @ "cardstack" getpropstr dup dup if
   "Cards in stack:       "
   swap dup strlen swap "" " " subst strlen - 2 / 1 - intostr strcat .tell
   "Card on top of stack: " swap striptail " " .rsplit swap pop
   atoi int2card strcat .tell
then
deck @ "curplayer" getprop dup dbref? if
   "Current player:       " swap name strcat .tell
then
;
 
: begin-game ( var[deck] -- )
deck @ "dealer" getprop dbref? not if
   "<> Shuffle the deck and wait for players to join first." .tell
   exit
then
deck @ "cardstack" getpropstr if
   "<> The game has already begun!" .tell
   exit
then
me @ deck @ "dealer" getprop dbcmp not if
   "<> Only the dealer can begin the game!" .tell
   exit
then
deck @ "cardstack" " 0 " setprop
begin
   random-card
   dup intostr " " swap " " strcat strcat
   deck @ "cardsdealt" getpropstr over instr 0 = not while pop pop
repeat
dup deck @ "cardstack" getpropstr swap strcat deck @ "cardstack" rot setprop
deck @ "cardsdealt" getpropstr swap strcat deck @ "cardsdealt" rot setprop int2card
"<> " me @ name " flips the top card off the deck, leaving the " strcat strcat swap " laying face up, and the game begins." strcat strcat notify_game
deck @ "curplayer" me @ setprop
;
 
: is-inpaw? ( i -- i )
intostr " " swap " " strcat strcat
me @ "ThreeUp/Paw" getpropstr swap instr 0 = not
;
 
: play-card ( var[deck,arg] -- )
deck @ "cardstack" getpropstr not if
   "<> The game hasn't started yet!" .tell
   exit
then
" places " tempstr !
0 tempval !
me @ deck @ "curplayer" getprop dbcmp not if
   "<> Hey! Wait your turn!" .tell
   exit
then
arg @ not if
   "<> Play which cards?" .tell
   exit
then
arg @ " " .split swap dup number? not if
   dup 01Name swap stringpfx if
      pop 1
   else
      dup 11Name swap stringpfx if
         pop 11
      else
         dup 12Name swap stringpfx if
            pop 12
         else
            dup 13Name swap stringpfx if
               pop 13
            else
               dup WildName swap stringpfx if
                  pop 14
               else
                  "<> I don't recongise that card name. Is it a newly invented one?" .tell
                  exit
               then
            then
         then
      then
   then
else
   atoi
then dup 14 > if
   "<> Now. You're just making things up, arn't you?" .tell
   exit
then dup
deck @ "cardstack" getpropstr striptail " " .rsplit swap pop atoi
15 bitand dup 1 = if
   pop 15
then >= over 1 = or over 2 = or over 10 = or over 14 = or not if
   "<> The card you play must have equal or greater value to the card on top of the stack, or be a special card." .tell
   exit
then
swap
dup not if
   "<> Okay, you also need to say which suit to play..." .tell
   exit
then
dup SuitMatch smatch if
   "<> There's something in there that's not a suit in this game..." .tell
   exit
then
dup Suit1 NumSuitLet strcut pop instring 0 = not if
   over dup is-inpaw? not if
      "<> You can't play a card not in your paw!" .tell
      exit
   then
   dup intostr " " swap " " strcat strcat
   deck @ "cardstack" getpropstr over strcat deck @ "cardstack" rot setprop
   me @ "ThreeUp/Paw" getpropstr "" rot subst me @ "ThreeUp/Paw" rot setprop
   int2card
   tempval @ 1 + tempval !
   over strlen compiletempstr
then
dup Suit2 NumSuitLet strcut pop instring 0 = not if
   over 16 bitor dup is-inpaw? not if
      "<> You can't play a card not in your paw!" .tell
      exit
   then
   dup intostr " " swap " " strcat strcat
   deck @ "cardstack" getpropstr over strcat deck @ "cardstack" rot setprop
   me @ "ThreeUp/Paw" getpropstr "" rot subst me @ "ThreeUp/Paw" rot setprop
   int2card
   tempval @ 1 + tempval !
   over strlen compiletempstr
then
dup Suit3 NumSuitLet strcut pop instring 0 = not if
   over 32 bitor dup is-inpaw? not if
      "<> You can't play a card not in your paw!" .tell
      exit
   then
   dup intostr " " swap " " strcat strcat
   deck @ "cardstack" getpropstr over strcat deck @ "cardstack" rot setprop
   me @ "ThreeUp/Paw" getpropstr "" rot subst me @ "ThreeUp/Paw" rot setprop
   int2card
   tempval @ 1 + tempval !
   over strlen compiletempstr
then
dup Suit4 NumSuitLet strcut pop instring 0 = not if
   over 48 bitor dup is-inpaw? not if
      "<> You can't play a card not in your paw!" .tell
      exit
   then
   dup intostr " " swap " " strcat strcat
   deck @ "cardstack" getpropstr over strcat deck @ "cardstack" rot setprop
   me @ "ThreeUp/Paw" getpropstr "" rot subst me @ "ThreeUp/Paw" rot setprop
   int2card
   tempval @ 1 + tempval !
   over strlen compiletempstr
then
pop dup 14 = if
   "<> Do you want to burn the stack?" .confirm if
      pop 10
   then
then
deck @ "cardstack" getpropstr dup dup strlen swap "" " " subst strlen - 2 / 4 >= if
   strip "  " .rsplit atoi 15 bitand
   swap "  " .rsplit atoi 15 bitand
   swap "  " .rsplit atoi 15 bitand
   swap "  " .rsplit atoi 15 bitand
   swap pop
   dup tempval !
   = swap tempval @ = rot tempval @ = and and if
      pop 10
   then
else
   pop
then
10 = if
   deck @ "cardstack" " 0 " setprop
   me @ name tempstr @ " on top of the stack, which promptly bursts into flames!"
   strcat strcat "<> " swap strcat
   notify_game
else
   next-player
   me @ dup name tempstr @ " on top of the stack, completing %p turn. %S passes the turn to "
   strcat strcat pronoun_sub "<> " swap strcat swap name strcat "." strcat
   notify_game
then
me @ "ThreeUp/Paw" getpropstr dup strlen swap "" " " subst strlen - 2 / MaxPaw @ <
deck @ "cardsdealt" getpropstr dup strlen swap "" " " subst strlen - 2 / 56 < and if
   "<> Cards drawn: " tempstr !
   0 tempval !
   begin
      random-card
      dup intostr " " swap " " strcat strcat
      deck @ "cardsdealt" getpropstr over instr 0 = not if
         pop continue
      then
      deck @ "cardsdealt" getpropstr over strcat deck @ "cardsdealt" rot setprop
      me @ "ThreeUp/Paw" getpropstr swap strcat me @ "ThreeUp/Paw" rot setprop
      tempval @ 1 + tempval !
      int2card
      MaxPaw @ compiletempstr
   me @ "ThreeUp/Paw" getpropstr dup strlen swap "" " " subst strlen - 2 / MaxPaw @ >=
   deck @ "cardsdealt" getpropstr dup strlen swap "" " " subst strlen - 2 / 56 >= or until
   me @ dup name " draws " tempval @ dup 1 = if
      intostr " card from the deck and adds it to %p paw..." strcat
   else
      intostr " cards from the deck and adds them to %p paw..." strcat
   then
   strcat strcat pronoun_sub "<> " swap strcat notify_game
   tempstr @ .tell
then
me @ "ThreeUp/Paw" getpropstr not if
   me @ "ThreeUp/Up" getpropstr dup if
      me @ "ThreeUp/Paw" rot setprop
      me @ "ThreeUp/Up" remove_prop
      "<> " me @ dup name " has finished the cards in %p paw! %S picks up %p upwards facing cards."
      strcat pronoun_sub strcat notify_game
      exit
   then
   me @ "ThreeUp/Down" getpropstr dup if
      me @ "ThreeUp/Paw" rot setprop
      me @ "ThreeUp/Down" remove_prop
      "<> " me @ dup name " has finished the cards in %p paw! %S picks up %p downwards facing cards."
      strcat pronoun_sub strcat notify_game
      exit
   then
   "<> " me @ dup name " has finished all %p cards!"
   strcat pronoun_sub strcat notify_game
   me @ end-player
   deck @ "ingame" me @ REF-delete
   deck @ "ingame" " " instr 0 = if
      end-game
   then
then
;
 
: pickup-cards ( var[deck] -- )
deck @ "cardstack" getpropstr not if
   "<> The game hasn't started yet!" .tell
   exit
then
me @ deck @ "curplayer" getprop dbcmp not if
   "<> Hey! Wait your turn!" .tell
   exit
then
deck @ "cardstack" getpropstr
me @ "ThreeUp/Paw" getpropstr strcat "" " 0 " subst me @ "ThreeUp/Paw" rot setprop
deck @ "cardstack" " 0 " setprop
next-player
"<> " me @ name " sighs and picks up the card stack, then passes the turn to "
strcat strcat swap name strcat notify_game
;
 
: draw-card ( var[deck] -- )
deck @ "cardstack" getpropstr not if
   "<> The game hasn't started yet!" .tell
   exit
then
me @ deck @ "curplayer" getprop dbcmp not if
   "<> Hey! Wait your turn!" .tell
   exit
then
deck @ "drawn" getpropval dup MaxPaw @ = if
   "<> You've already drawn your " MaxPaw @ intostr " cards for this turn!" strcat strcat .tell
   pop exit
then
1 + deck @ "drawn" rot setprop
deck @ "cardsdealt" getpropstr dup strlen swap "" " " subst strlen - 2 / 56 = if
   "<> The deck is empty, so you can't draw a card!" .tell
   exit
then
begin
   random-card
   dup intostr " " swap " " strcat strcat
deck @ "cardsdealt" getpropstr over instr 0 = until
deck @ "cardsdealt" getpropstr over strcat deck @ "cardsdealt" rot setprop
me @ "ThreeUp/Paw" getpropstr swap strcat me @ "ThreeUp/Paw" rot setprop
"<> " me @ dup name " draws a card from the deck and adds it to %p paw..." strcat pronoun_sub strcat
notify_game
int2card "<> You got the " swap strcat "." strcat .tell
;
 
: fold-out ( var[deck] -- )
me @ deck @ "dealer" getprop dbcmp if
   "<> You can't fold! You're the dealer!" .tell
   exit
then
deck @ "cardstack" getpropstr not if
   "<> You're folding from a game you're not part of?" .tell
   exit
then
me @ end-player
deck @ "ingame" me @ REF-delete
"<> " me @ dup name " folds. %S gathers up %p cards into a miniature deck and places them with the burnt deck." strcat pronoun_sub strcat notify_game
;
 
: kick-player ( var[deck] -- )
deck @ "cardstack" getpropstr not if
   "<> The game hasn't started yet!" .tell
   exit
then
me @ deck @ "dealer" getprop dbcmp not if
   "<> Only the dealer can kick players from the game!" .tell
   exit
then
arg @ not if
   "<> Kick who out of the game?" .tell
   exit
then
arg @ match dup player? not if
   "<> Kick who out of the game?" .tell
   exit
then
dup obj !
"Are you sure you want to kick " swap name " out of the game?" strcat strcat .confirm not if
   "<> Kick aborted." .tell
   exit
then
obj @ end-player
deck @ "ingame" obj @ REF-delete
"<> " me @ name " kicks " obj @ name " out of the game!" strcat strcat strcat strcat
notify_game
;
 
: setup-values ( var[deck,arg] -- )
deck @ "cardsdealt" getpropstr if
   "<> Please end the current game first." .tell
   exit
then
arg @ "#p" instring 0 = not if
   arg @ " " .split swap pop atoi
   56 swap / 3 / dup 1 < if
      "You can't have that many players, sorry." .tell exit
   then
   intostr dup dup
   deck @ "Custom/Down" rot setprop
   deck @ "Custom/Up" rot setprop
   deck @ "Custom/Paw" rot setprop
   "<> Custom values set." .tell exit
then
arg @ "#c" instring 0 = not if
   deck @ "Custom" remove_prop
   "<> Default values restored." .tell
else
   arg @ " " explode 3 = if
      dup atoi 3 pick atoi 5 pick atoi + + 56 <= if
         deck @ "Custom/Down" rot setprop
         deck @ "Custom/Up" rot setprop
         deck @ "Custom/Paw" rot setprop
         "<> Custom values set." .tell
      then
   else
      "Syntax:" .tell
      "   " command @ toupper " <CardsDown> <CardsUp> <CardsInPaw>" strcat strcat .tell
   then
then
;
 
: private-game
deck @ "dealer" getprop dup dbref? if
   me @ dbcmp me @ deck @ owner dbcmp or
else
   pop me @ deck @ owner dbcmp
then
not if
   "<> You must be the dealer or deck ownder to set game private/public." .tell exit
then
dup deck @ "Private?" rot setprop if
   "<> Game set private." .tell
   "<> " me @ name " sets the game private." strcat strcat notify_game
else
   "<> Game set public." .tell
   "<> " me @ name " sets the game public." strcat strcat notify_game
then
;
 
: game-chat ( var[arg,deck] -- )
arg @ "" stringcmp 0 = if
   "<> Syntax: " command @ toupper " <message>" strcat strcat .tell
   exit
then
deck @ "Private?" getpropval not if
   "<> The game's not set private! Talk normally!" .tell
   exit
then
me @ name " game-whispers, \"" arg @ "\"" strcat strcat strcat notify_game
;
 
: main-help
arg @ "aim" instring 0 = not if
   "Aim of the game" .tell
   "---------------" .tell
   " " .tell
   "When the game begins, each player will be dealt a three sets of cards. Some facing down, some facing up, and some in 'paw' (hand). As you might guess, only the player knows what they have in paw, everyone knows what everyone else has facing up, and noone knows what anyone has facing down." .tell
   "The aim of the game is very, very simple. Get rid of all your cards, first." .tell
   " " .tell
   exit
then
 
arg @ "turn" instring 0 = not if
   "Using your turn" .tell
   "---------------" .tell
   " " .tell
   "When the game begins, a card will be drawn from the top of the deck and placed down, facing upwards. Everyone sees this card, and it forms what is called the 'stack'." .tell
   "To play a card, you must either have a card of equal or greater value to the card at the top of the stack, or a special card (see Special Cards). If you have more than one card of the same value, you can play them all at once." .tell
   "After you have played your card(s), provided you did not 'burn' the stack (see Burning the Stack), you will pass the turn to the next player." .tell
   "Play all your cards in paw, and you'll pick up your upwards facing cards, finish them, and you'll pick up your downwards facing cards. Finish all of them, and you've won!" .tell
   " " .tell
   "Note: If there are cards left in the deck, and you have less cards in paw than you where initially dealt, you will pickup cards until you have enough in your paw again." .tell
   " " .tell
   exit
then
 
arg @ "special" instring 0 = not if
   "Special Cards" .tell
   "-------------" .tell
   " " .tell
   "The following cards are special:" .tell
   " " .tell
   "      Elites        - The equivelant of aces in normal decks, they are the" .tell
   "                      highest card in the deck." .tell
   "      Duces (Two's) - Can be played regardless of the value of the card on top" .tell
   "                      of the stack." .tell
   "      Burns (Ten's) - The same as Duces, except these can burn the stack." .tell
   "                      (see Burning the Stack)" .tell
   "      Cosmos'       - The same as Elites, but the can also burn the stack if" .tell
   "                      you wish." .tell
   " " .tell
   exit
then
 
arg @ "burn" instring 0 = not if
   "Burning the Stack" .tell
   "-----------------" .tell
   " " .tell
   "To 'burn' the stack is to take all the cards in the stack out of play for the remainder of the game. This can be done in three ways." .tell
   " " .tell
   "      1. Using Burns:" .tell
   "            Placing a ten of any suit atop the stack will cause it and the" .tell
   "            the stack to be 'burnt' and removed from play." .tell
   "      2. Using Cosmos:" .tell
   "            Placing a Cosmos of any suit atop the stack will offer you the" .tell
   "            choice of burning the stack or leaving the Cosmos atop the stack." .tell
   "      3. The Four-of-a-kind exception:" .tell
   "            If all cards of the same value gather at the top of the stack, it" .tell
   "         will spontaniously combust." .tell
   " " .tell
   exit
then
 
arg @ "comm" instring 0 = not if
   "Game Commands" .tell
   "-------------" .tell
   " " .tell
   "The commands may vary depending on your setup. If these commands don't work, look around the area you are playing in, as the owner /should/ have put up a notice of the fact." .tell
   " " .tell
   "Further help can be brought up on each command:" .tell
   " " .tell
   "      TSHUFFLE     TJOIN        TBEGIN       TSTATUS      TPLAY        TPICKUP" .tell
   "      TDRAW        TFOLD        TKICK        TEND         TSETUP       TPUB" .tell
   "      TPRIV        TCHAT        THELP" .tell
   " " .tell
   exit
then
 
arg @ "shuf" instring 0 = not if
   "TSHUFFLE" .tell
   "--------" .tell
   " " .tell
   "This command is used to initialise the game, and announce that one is starting. Should be run by one player, once." .tell
   " " .tell
   exit
then
 
arg @ "join" instring 0 = not if
   "TJOIN" .tell
   "-----" .tell
   " " .tell
   "Type this to join a game." .tell
   " " .tell
   exit
then
 
arg @ "begin" instring 0 = not if
   "TBEGIN" .tell
   "------" .tell
   " " .tell
   "Used by the 'dealer' (the one who typed SHUFFLE) to begin the game when everyone has joined." .tell
   " " .tell
   exit
then
 
arg @ "stat" instring 0 = not if
   "TSTATUS" .tell
   "-------" .tell
   " " .tell
   "Shows various information about the game (Your cards, number of cards in stack and deck etc)." .tell
   "STATUS #FULL will tell you what cards you and your opponents have facing upwards." .tell
   " " .tell
   exit
then
 
arg @ "play" instring 0 = not if
   "TPLAY" .tell
   "-----" .tell
   " " .tell
   "Used to play one or more cards. The syntax is 'PLAY <card value> <card suit(s)>'." .tell
   "For example:" .tell
   " " .tell
   "'TPLAY 4 BLJ'      Play 4 of Blade, 4 of Lovers and 4 of Jewels." .tell
   " " .tell
   "'TPLAY 10 S'       Play 10 of Staves." .tell
   " " .tell
   "'TPLAY E J'" .tell
   "      or          Play Elite of Jewels." .tell
   "'TPLAY ELITE J'" .tell
   " " .tell
   exit
then
 
arg @ "pick" instring 0 = not if
   "TPICK/PICKUP" .tell
   "------------" .tell
   " " .tell
   "Picks up the stack and adds it to your paw, passing the turn to the next player. Use only if you can't play a card." .tell
   " " .tell
   exit
then
 
arg @ "draw" instring 0 = not if
   "TDRAW" .tell
   "-----" .tell
   " " .tell
   "Used to draw one card from the deck and add it to your paw. You can draw as many cards from the deck as the minimum number of cards in paw, per turn." .tell
   " " .tell
   exit
then
 
arg @ "fold" instring 0 = not if
   "TFOLD" .tell
   "-----" .tell
   " " .tell
   "You'll quit the game. You cards are placed to one side and not used for the rest of the game." .tell
   " " .tell
   exit
then
 
arg @ "kick" instring 0 = not if
   "TKICK" .tell
   "-----" .tell
   " " .tell
   "Used by the dealer to kick an roudy or sleeping player from the game. Essentially forces them to fold." .tell
   "Syntax: 'TKICK <name>'" .tell
   " " .tell
   exit
then
 
arg @ "end" instring 0 = not if
   "TEND" .tell
   "----" .tell
   " " .tell
   "Used by the dealer to end the game." .tell
   "If the dealer is asleep or not present, then anyone may end the game." .tell
   " " .tell
   exit
then
 
arg @ "setup" instring 0 = not if
   "TSETUP" .tell
   "------" .tell
   " " .tell
   "Customises the number of cards to be dealt. Must be used before starting a game." .tell
   " " .tell
   "'TSETUP X Y Z'     Will set X for cards down, Y for cards up, and Z for cards in paw." .tell
   "'TSETUP #P X'      Will set cards up for X number of players." .tell
   "'TSETUP #C'        Will reset defaults (generally 3 up, 3 down, 3 in paw)." .tell
   " " .tell
   exit
then
 
arg @ "pub" instring 0 = not if
   "TPUB" .tell
   "----" .tell
   " " .tell
   "Sets the game public. All in the room will hear game messages." .tell
   " " .tell
   exit
then
 
arg @ "priv" instring 0 = not if
   "TPRIV" .tell
   "-----" .tell
   " " .tell
   "Sets the game private. Only players will hear game messages." .tell
   " " .tell
   exit
then
 
arg @ "chat" instring 0 = not if
   "TCHAT" .tell
   "-----" .tell
   " " .tell
   "Sends a message all players in a private game." .tell
   "Thanks to Artimus for the suggestion!" .tell
   " " .tell
   exit
then
 
arg @ "help" instring 0 = not if
   "THELP" .tell
   "-----" .tell
   " " .tell
   "This help system, dummy! ;)" .tell
   " " .tell
   exit
then
 
"ThreeUp.muf v1.92 (by Stelard Actek) Help" .tell
"-----------------------------------------" .tell
" " .tell
"Syntax: 'THELP <topic>'" .tell
" " .tell
"Available topics:" .tell
" " .tell
"      AIM         - Aim of the game" .tell
"      TURN        - Using your turn" .tell
"      SPECIAL     - Special Cards" .tell
"      BURNING     - Burning the Stack" .tell
"      COMMANDS    - Game Commands" .tell
" " .tell
;
 
: main ( s -- )
arg !
trig location deck !
 
deck @ "Custom/Up" getpropstr dup if
   atoi MaxUp !
else
   pop DefCards MaxUp !
then
deck @ "Custom/Down" getpropstr dup if
   atoi MaxDown !
else
   pop DefCards MaxDown !
then
deck @ "Custom/Paw" getpropstr dup if
   atoi MaxPaw !
else
   pop DefCards MaxPaw !
then
MaxUp @ MaxDown @ MaxPaw @ + + dup 56 > if
   "Setup error!" .tell
   "Reseting to defaults!" .tell
   deck @ "Custom" remove_prop exit
then
56 swap / MaxPlayers !
 
command @ "setup" instring 0 = not if setup-values exit then
command @ "shuf" instring 0 = not if shuffle-cards exit then
command @ "join" instring 0 = not if join-game exit then
command @ "end" instring 0 = not if end-game exit then
command @ "stat" instring 0 = not if status-game exit then
command @ "begin" instring 0 = not if begin-game exit then
command @ "play" instring 0 = not if play-card exit then
command @ "pick" instring 0 = not if pickup-cards exit then
command @ "draw" instring 0 = not if draw-card exit then
command @ "fold" instring 0 = not if fold-out exit then
command @ "kick" instring 0 = not if kick-player exit then
command @ "priv" instring 0 = not if 1 private-game exit then
command @ "pub" instring 0 = not if 0 private-game exit then
command @ "chat" instring 0 = not if game-chat exit then
command @ "help" instring 0 = not if main-help exit then
;
