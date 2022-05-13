#SingleInstance,force
#NoEnv
#CommentFlag, //

global a := 0

Gui, Add, Button, x157 y76 w160 h70 , TEST
Gui, Show, w479 h226, test
return

GuiClose:
ExitApp

ButtonTEST:
MsgBox % a := random(5,500) // comment that have to be removed
return

/*

large comment
.
.
. AYO
. CAUGHT IN 4k ULTRA HD
.

*/

random(min, max) // another comment
{
random, rand1, % min, % max
return rand1
}
