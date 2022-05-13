#SingleInstance, Force
#Persistent
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
SetWorkingDir % A_ScriptDir
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

GLOBAL VER := "beta_1.1"
GLOBAL DISCORD := "lexx#0457"

GLOBAL InputFile
GLOBAL OutputPath
GLOBAL DroppedFileStatus
GLOBAL EnableInput
GLOBAL EnableOutput

GLOBAL _EMPTY := ""
GLOBAL _LINEINDEX
GLOBAL _COMMENTFLAG := ";"
GLOBAL _COMMENTFLAG_LENGTH := 1
GLOBAL _LARGECOMMENT
GLOBAL _NEWLINE := "`n"
GLOBAL _SPL_ENDLINE

Gui, Font, S10 CDefault Bold, Segoe UI
Gui, Add, Edit, x140 y39 w360 h30 +Center vInputEdit readonly, (Drag & Drop or Select File)
Gui, Add, Edit, x140 y74 w360 h30 +Center vOutputEdit gOutputPath, (Output Path)

Gui, Add, Button, x502 y38 w33 h32 gSelectFile vSelectButton, ...

Gui, Add, Text, x175 y9 w290 h20 +Center vTexxt, Select File
Gui, Add, Button, x270 y114 w100 h30 gCompress vCompressButton disabled, Compress

Gui, Add, Button, x526 y119 w100 h25 gInfo, Info

Gui, Show, w644 h160, AHK Compressor
Gui, +resize
return

GuiClose:
GuiEscape:
ExitApp

GuiSize:
guicontrol,move,InputEdit, % "x" (A_GuiWidth/2)-180 " y" (A_GuiHeight/2)-36
guicontrol,move,OutputEdit, % "x" (A_GuiWidth/2)-180 " y" (A_GuiHeight/2)-2
guicontrol,move,texxt, % "x" (A_GuiWidth/2)-145 " y" (A_GuiHeight/2)-64
guicontrol,move,Button1, % "x" (A_GuiWidth/2)+185 " y" (A_GuiHeight/2)-38
guicontrol,move,Button2, % "x" (A_GuiWidth/2)-50 " y" (A_GuiHeight/2)+38
guicontrol,move,Button3, % "x" A_GuiWidth-108 " y" A_GuiHeight-32
return

Info:

MsgBox,64,Info!,% A_TAB "            AHK Compressor by Lexx`n`nAHK Compressor has been written in couple days, so huge AHK's probably won't be compressed perfectly`n`nAny questions?`n_Discord_: " DISCORD "`n_Version_: " VER
return

GuiDropFiles:
DroppedFileStatus := 1
goto, MainCheck
return

SelectFile:
guicontrolget, InputEdit
guicontrolget, OutputEdit
FileSelectFile, SelectedFile, 3, % A_Desktop , Select AHK, AHK File (*.ahk)

MainCheck:
InputFile := ""
EnableInput := 0
if DroppedFileStatus
{
	guicontrol, disable, CompressButton
	SelectedFile := A_GuiEvent
	if ((StrSplit(SelectedFile, "`n").MaxIndex()) > 1)
	{
		MsgBox, 4112, Error!, You cannot drop more than 1 file at one time!
		return
	}
}

DroppedFileStatus := 0

; checking whether file didnt select
if (SelectedFile == "")
	return

; Spliting File
SplitPath, SelectedFile, FileNameExt, FileDir, FileExt, FileName, FileDrive

; checking extension
; I could do InStr(FileExt, "ahk") and this would check every upper/lower character, but if extention is ahk2 an example it would work too, so i did that shit
if (FileExt != "ahk" || FileExt != "AHK" || FileExt != "Ahk" || FileExt != "AHk" || FileExt != "AhK" || FileExt != "ahK" || FileExt != "aHK" || FileExt != "aHk")
{
	guicontrol, disable, CompressButton
	MsgBox, 4117, Error!, Unavailable file extension!
	IfMsgBox, Cancel
		return
	else
		goto, SelectFile
}

; checking raw file total lines
Loop, Read, % SelectedFile
	RawFileLines := A_Index

; checking whether file even has any code
If (RawFileLines == 0 || RawFileLines == "")
{
MsgBox, 16, Error!, File is empty!
return
}

; Proceeding
InputFile := SelectedFile
GuiControl,,InputEdit,% InputFile
EnableInput := 1
if (EnableInput && EnableOutput)
	guicontrol, enable, CompressButton
else
	guicontrol, disable, CompressButton

guicontrolget, OutputEdit
OutputPath := FileDir
guicontrol,,OutputEdit, % OutputPath
goto, OutputPath
return

OutputPath:
guicontrolget, OutputEdit
EnableOutput := 0

if (SplitPath(OutputEdit, 3) == "")
	IfExist, % OutputEdit
		EnableOutput := 1

if (EnableInput && EnableOutput)
	guicontrol, enable, CompressButton
else
	guicontrol, disable, CompressButton

OutputPath := OutputEdit
return



Compress:
Gui, Submit, NoHide
GLOBAL LargeComment
IfNotExist, % InputFile
{
	MsgBox,4112,Error!, The following file doesn't exists!
	return
}

IfNotExist, % OutputPath
{
	MsgBox,4112,Error!, The following path doesn't exists!
	return
}

OutputPath := RTRIM(OutputPath, "\")

; main loop
mainloop:
IfExist, % OutputPath "\" FileName "_compressed.ahk"
	MsgBox, 52, Warning!, Compressed file is already exists in the current directory. If you continue, the previous file will be removed and replaced, continue?
IfMsgBox, No
	return
else IfMsgBox, Yes
	FileDelete, % OutputPath "\" FileName "_compressed.ahk"

if (RawFileLines > 2000)
	MsgBox, 52, Warning!, Your file is long so some strings might get incorrectly compressed. Continue? (compressor beta_1.1)
IfMsgBox, No
	return	

Loop, Read, % InputFile
{ ; MAIN LOOP
	
	_LINEINDEX := A_Index
	ENDLINE := A_LoopReadLine
	
	; determines useless spaces
	ENDLINE := RTRIM(LTRIM(RTRim(LTRim(ENDLINE, A_SPACE), A_SPACE), A_TAB), A_TAB)
	
	; checking whether the line is a "large comment"
	if InStr(ENDLINE, "/*")
	{
		_LARGECOMMENT := true
		continue
	}
	else if InStr(ENDLINE, "*/")
	{
		_LARGECOMMENT := false
		continue
	}
	
	if (_LARGECOMMENT == true)
		continue
	
	; proceeding comments
	if InStr(ENDLINE, _COMMENTFLAG)
	{
		TempVar := ENDLINE
		_SPL_ENDLINE := StrSplit(ENDLINE, _COMMENTFLAG)
		ENDLINE := LTRIM(_SPL_ENDLINE[_SPL_ENDLINE.MaxIndex()-(_SPL_ENDLINE.MaxIndex()-1)], A_Space)
		
		; checking whether a string is a link, which cause a trouble because of containing "https://" || some people use #commentflag //, because it comfortable
		if InStr(ENDLINE, "http")
		{
			if (SubStr(ENDLINE, StrLen(RTRIM(LTRIM(ENDLINE, A_SPACE), A_SPACE)), 1) == "`:")
				ENDLINE := TempVar
		}
		else InStr(ENDLINE, ")") ||  InStr(ENDLINE, "(") ; checking if its a function
		{
			if (SubStr(ENDLINE, StrLen(ENDLINE), 1)) == "`(" || (SubStr(ENDLINE, StrLen(ENDLINE), 1) == "`)")
				ENDLINE := TempVar
		}
	}
	
		; deleting other comments type
	if InStr(ENDLINE, "#CommentFlag")
	{
		_COMMENTFLAG := StrReplace(StrReplace(StrReplace(ENDLINE, A_SPACE), "#CommentFlag"), ",")
		_COMMENTFLAG_LENGTH := StrLen(_COMMENTFLAG)
		CONTINUE ; REMOVE THIS "CONTINUE" IF YOU WANT TO KEEP #COMMENTFLAG COMMAND IN THE COMPRESSED FILE
	}
	
	; LITE compressing operators || part 1
	
	; THIS IS EXTREMELY BUGGY, ABSOLUTELY NOT RECOMMENDED TO USE, BUT YOU CAN TRY 
	
	/* 
	if InStr(ENDLINE, "if")
	{
		if InStr(ENDLINE, "and")
			ENDLINE := StrReplace(ENDLINE, "and", "&&")
	}
	else InStr(ENDLINE, "if")
	{
		if InStr(ENDLINE, "or")
			ENDLINE := StrReplace(ENDLINE, "or", "||")
	}
	*/
	
	if InStr(ENDLINE, " == ")
		ENDLINE := StrReplace(ENDLINE, " == ", "=")
	else if InStr(ENDLINE, "== ")
		ENDLINE := StrReplace(ENDLINE, "== ", "=")
	else if InStr(ENDLINE, " ==")
		ENDLINE := StrReplace(ENDLINE, " ==", "=")
	
	if InStr(ENDLINE, " = ")
		ENDLINE := StrReplace(ENDLINE, " = ", "=")
	else if InStr(ENDLINE, "= ")
		ENDLINE := StrReplace(ENDLINE, "= ", "=")
	else if InStr(ENDLINE, " =")
		ENDLINE := StrReplace(ENDLINE, " =", "=")
	
	if InStr(ENDLINE, " := ")
		ENDLINE := StrReplace(ENDLINE, " := ", ":=")
	else if InStr(ENDLINE, ":= ")
		ENDLINE := StrReplace(ENDLINE, ":= ", ":=")
	else if InStr(ENDLINE, " :=")
		ENDLINE := StrReplace(ENDLINE, " :=", ":=")
	
	if InStr(ENDLINE, " .= ")
		ENDLINE := StrReplace(ENDLINE, " .= ", ".=")
	else if InStr(ENDLINE, ".= ")
		ENDLINE := StrReplace(ENDLINE, ".= ", ".=")
	else if InStr(ENDLINE, " .=")
		ENDLINE := StrReplace(ENDLINE, " .=", ".=")
	
	; part 2 ===========================
	if InStr(ENDLINE, " += ")
		ENDLINE := StrReplace(ENDLINE, " += ", "+=")
	else if InStr(ENDLINE, "+= ")
		ENDLINE := StrReplace(ENDLINE, "+= ", "+=")
	else if InStr(ENDLINE, " +=")
		ENDLINE := StrReplace(ENDLINE, " +=", "+=")
	
	if InStr(ENDLINE, " -= ")
		ENDLINE := StrReplace(ENDLINE, " -= ", "-=")
	else if InStr(ENDLINE, "-= ")
		ENDLINE := StrReplace(ENDLINE, "-= ", "-=")
	else if InStr(ENDLINE, " -=")
		ENDLINE := StrReplace(ENDLINE, " -=", "-=")
	
	if InStr(ENDLINE, " /= ")
		ENDLINE := StrReplace(ENDLINE, " /= ", "/=")
	else if InStr(ENDLINE, "/= ")
		ENDLINE := StrReplace(ENDLINE, "/= ", "/=")
	else if InStr(ENDLINE, " /=")
		ENDLINE := StrReplace(ENDLINE, " /=", "/=")
	
	if InStr(ENDLINE, " *= ")
		ENDLINE := StrReplace(ENDLINE, " *= ", "*=")
	else if InStr(ENDLINE, "*= ")
		ENDLINE := StrReplace(ENDLINE, "*= ", "*=")
	else if InStr(ENDLINE, " *=")
		ENDLINE := StrReplace(ENDLINE, " *=", "*=")
	
	if InStr(ENDLINE, " && ")
		ENDLINE := StrReplace(ENDLINE, " && ", "&&")
	else if InStr(ENDLINE, "&& ")
		ENDLINE := StrReplace(ENDLINE, "&& ", "&&")
	else if InStr(ENDLINE, " &&")
		ENDLINE := StrReplace(ENDLINE, " &&", "&&")
	
	if InStr(ENDLINE, " || ")
		ENDLINE := StrReplace(ENDLINE, " || ", "||")
	else if InStr(ENDLINE, "|| ")
		ENDLINE := StrReplace(ENDLINE, "|| ", "||")
	else if InStr(ENDLINE, " ||")
		ENDLINE := StrReplace(ENDLINE, " ||", "||")
	
	; part 3 ===========================
	if InStr(ENDLINE, " //= ")
		ENDLINE := StrReplace(ENDLINE, " //= ", "//=")
	else if InStr(ENDLINE, "//= ")
		ENDLINE := StrReplace(ENDLINE, "//= ", "//=")
	else if InStr(ENDLINE, " //=")
		ENDLINE := StrReplace(ENDLINE, " //=", "//=")
	
	if InStr(ENDLINE, " |= ")
		ENDLINE := StrReplace(ENDLINE, " |= ", "|=")
	else if InStr(ENDLINE, "|= ")
		ENDLINE := StrReplace(ENDLINE, "|= ", "|=")
	else if InStr(ENDLINE, " |=")
		ENDLINE := StrReplace(ENDLINE, " |=", "|=")
	
	if InStr(ENDLINE, " ^= ")
		ENDLINE := StrReplace(ENDLINE, " ^= ", "^=")
	else if InStr(ENDLINE, "^= ")
		ENDLINE := StrReplace(ENDLINE, "^= ", "^=")
	else if InStr(ENDLINE, " ^=")
		ENDLINE := StrReplace(ENDLINE, " ^=", "^=")
	
	if InStr(ENDLINE, " &= ")
		ENDLINE := StrReplace(ENDLINE, " &= ", "&=")
	else if InStr(ENDLINE, "&= ")
		ENDLINE := StrReplace(ENDLINE, "&= ", "&=")
	else if InStr(ENDLINE, " &=")
		ENDLINE := StrReplace(ENDLINE, " &=", "&=")
	
	if InStr(ENDLINE, " ~= ")
		ENDLINE := StrReplace(ENDLINE, " ~= ", "~=")
	else if InStr(ENDLINE, "~= ")
		ENDLINE := StrReplace(ENDLINE, "~= ", "~=")
	else if InStr(ENDLINE, " ~=")
		ENDLINE := StrReplace(ENDLINE, " ~=", "~=")
	
	; part 4 ===========================
	if InStr(ENDLINE, " <= ")
		ENDLINE := StrReplace(ENDLINE, " <= ", "<=")
	else if InStr(ENDLINE, "<= ")
		ENDLINE := StrReplace(ENDLINE, "<= ", "<=")
	else if InStr(ENDLINE, " <=")
		ENDLINE := StrReplace(ENDLINE, " <=", "<=")
	
	if InStr(ENDLINE, " >= ")
		ENDLINE := StrReplace(ENDLINE, " >= ", ">=")
	else if InStr(ENDLINE, ">= ")
		ENDLINE := StrReplace(ENDLINE, ">= ", ">=")
	else if InStr(ENDLINE, " >=")
		ENDLINE := StrReplace(ENDLINE, " >=", ">=")
	
	if InStr(ENDLINE, " <<= ")
		ENDLINE := StrReplace(ENDLINE, " <<= ", "<<=")
	else if InStr(ENDLINE, "<<= ")
		ENDLINE := StrReplace(ENDLINE, "<<= ", "<<=")
	else if InStr(ENDLINE, " <<=")
		ENDLINE := StrReplace(ENDLINE, " <<=", "<<=")
	
	if InStr(ENDLINE, " >>= ")
		ENDLINE := StrReplace(ENDLINE, " >>= ", ">>=")
	else if InStr(ENDLINE, ">>= ")
		ENDLINE := StrReplace(ENDLINE, ">>= ", ">>=")
	else if InStr(ENDLINE, " >>=")
		ENDLINE := StrReplace(ENDLINE, " >>=", ">>=")
	
	if InStr(ENDLINE, " << ")
		ENDLINE := StrReplace(ENDLINE, " << ", "<<")
	else if InStr(ENDLINE, "<< ")
		ENDLINE := StrReplace(ENDLINE, "<< ", "<<")
	else if InStr(ENDLINE, " <<")
		ENDLINE := StrReplace(ENDLINE, " <<", "<<")
	
	if InStr(ENDLINE, " >> ")
		ENDLINE := StrReplace(ENDLINE, " >> ", ">>")
	else if InStr(ENDLINE, ">> ")
		ENDLINE := StrReplace(ENDLINE, ">> ", ">>")
	else if InStr(ENDLINE, " >>")
		ENDLINE := StrReplace(ENDLINE, " >>", ">>")
	
	
	; some additionaly compressing..
	if InStr(ENDLINE, ", ")
		ENDLINE := StrReplace(ENDLINE, ", ", ",")
	else if InStr(ENDLINE, " , ")
		ENDLINE := StrReplace(ENDLINE, " , ", ",")
	if InStr(ENDLINE, " ,")
		ENDLINE := StrReplace(ENDLINE, " ,", ",")
	
	; checking whether line does contain anything
	if !ENDLINE
		continue
	
	; sometimes line can still has useless spaces
	ENDLINE := RTRIM(LTRIM(RTRim(LTRim(ENDLINE, A_SPACE), A_SPACE), A_TAB), A_TAB)
	
	_NEWLINE := _LINEINDEX != RawFileLines ? "`n" : ""
	FileAppend, % ENDLINE _NEWLINE, % OutputPath "\" FileName "_compressed.ahk", UTF-8
} ; MAIN LOOP
MsgBox,64,Successfully!,Success
return
; =================================================================================================
; =================================================================================================
; =================================================================================================
; =================================================================================================
Sleep(Delay){
	DllCall("Sleep","UInt",Delay)
}

SplitPath(string, output){
	SplitPath, % string, OutputName, OutputDir, OutputExt, OutputNameNoExt, OutputDrive
	
	if (output == "name" || output == 1)
		return OutputName
	else if (output == "dir" || output == 2)
		return OutputDir
	else if (output == "ext" || output == 3)
		return OutputExt
	else if (output == "namenoext" || output == 4)
		return OutputNameNoExt
	else if (output == "drive" || output == 5)
		return OutputDrive
}