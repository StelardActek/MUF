( ***** Misc ANSI String routines -- STR *****
  ***** Very quick and dirty hack by Stelard [20/07/02] *****
These routines deal with spaces in strings.
 ASTRblank?   [       str -- bool         ]  true if str null or only spaces
 ASTRsls      [       str -- str'         ]  strip leading spaces
 ASTRsts      [       str -- str'         ]  strip trailing spaces
 ASTRstrip    [       str -- str'         ]  strip lead and trail spaces
 ASTRsms      [       str -- str'         ]  strips out mult. internal spaces
 
These two are routines to split a string on a substring, non-inclusive.
 ASTRsplit    [ str delim -- prestr postr ]  splits str on first delim. nonincl.
 ASTRrsplit   [ str delim -- prestr postr ]  splits str on last delim. nonincl.
 
The following are useful for formatting strings into fields.
 ASTRfillfield [str char width -- padstr  ] return padding string to width chars
 ASTRcenter   [ str width -- str'         ]  center a string in a field.
 ASTRleft     [ str width -- str'         ]  pad string w/ spaces to width chars
 ASTRright    [ str width -- str'         ]  right justify string to width chars
 
The following are case insensitive versions of instr and rinstr:
 Ainstring    [  str str2 -- position     ]  find str2 in str and return pos
 Arinstring   [  str str2 -- position     ]  find last str2 in str & return pos
 
These convert between ascii integers and string character.
 ASTRasc      [      char -- i            ]  convert character to ASCII number
 ASTRchar     [         i -- char         ]  convert number to character
 
This routine is useful for parsing command line input:
 ASTRparse    [      str -- str1 str2 str3]  " #X Y  y = Z"  ->  "X" "Y y" " Z"
)
$include $lib/ansify (#85365 on FM)
 
: split
    swap over over swap
    instr dup not if
        pop swap pop ""
    else
        1 - libansi-strcut rot
        libansi-strlen libansi-strcut
        swap pop
    then
;
 
: rsplit
    swap over over swap
    rinstr dup not if
        pop swap pop ""
    else
        1 - libansi-strcut rot
        libansi-strlen libansi-strcut
        swap pop
    then
;
 
: sms ( str -- str')
    dup "  " instr if
        " " "  " subst 'sms jmp
    then
;
 
: fillfield (str padchar fieldwidth -- padstr)
  rot libansi-strlen - dup 1 < if pop pop "" exit then
  swap over begin swap dup strcat swap 2 / dup not until pop
  swap libansi-strcut pop
;
 
: left (str fieldwidth -- str')
  over " " rot fillfield strcat
;
 
: right (str fieldwidth -- str')
  over " " rot fillfield swap strcat
;
 
: center (str fieldwidth -- str')
  over " " rot fillfield
  dup libansi-strlen 2 / libansi-strcut
  rot swap strcat strcat
;
 
: STRasc ( c -- i )
    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" strcat
    swap
    dup not if
 and exit
    then
    instr dup if
        31 +
    then
;
 
: STRchr ( i -- c )
    dup 31 > over 128 < and if
        " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" strcat
        swap 32 - libansi-strcut swap pop 1 libansi-strcut pop
    else
        pop "."
    then
;
 
: STRparse ( s -- s1 s2 s3 ) (
    Before: " #option  tom dick  harry = message "
    After:  "option" "tom dick harry" " message "
    )
    "=" rsplit swap
    striplead dup "#" 1 strncmp not if
        1 libansi-strcut swap pop
        " " split
    else
        "" swap
    then
    strip sms rot
;
 
public split
public rsplit
public sms
public fillfield
public left
public right
public center
public STRasc
public STRchr
public STRparse
