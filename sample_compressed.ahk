#SingleInstance,force
#NoEnv
global a:=0
Gui,Add,Button,x157 y76 w160 h70,TEST
Gui,Show,w479 h226,test
return
GuiClose:
ExitApp
ButtonTEST:
MsgBox % a:=random(5,500)
return
random(min,max)
{
random,rand1,% min,% max
return rand1
}