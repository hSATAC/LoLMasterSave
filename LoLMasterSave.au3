#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=LoL Masteries Set by nvn.
#AutoIt3Wrapper_Res_Fileversion=1.6.1.274
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=nvn
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_After=del /f /q LoLMasterSave_Obfuscated.au3
#Obfuscator_Parameters=/cs=0 /cn=0 /cf=1 /cv=1 /sf=1 /sv=1
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Debug_Mode=n
#AutoIt3Wrapper_UseAnsi=n
#include-once
#include <Misc.au3>

Global $ini = @ScriptDir & "\LoLMasterSet.ini"
Func ini($key, $def,$ver=0)
	Local $isint = IsInt($def)
	if $ver>0 and $ver == IniRead($ini, "main", "version", "") Then
		Local $val = ''
	Else
		Local $val = IniRead($ini, "main", $key, "")
	EndIf
	If $val == '' Then
		;IniWrite($ini, "main", $key, $def)
		$val = $def
	EndIf
	If $isint Then Return Int($val)
	Return $val
EndFunc   ;==>ini
; settings


OnAutoItExitRegister('OnAutoItExit')
;disable end key feature for PTT users
;HotKeySet(ini('Key_Exit','{end}'), 'AutoItExit')
;HotKeySet(ini('Key_ShiftWinRun','+{home}'), 'shiftWinRun')
;HotKeySet(ini('Key_IpFarm','+{ins}'), 'createIPfarm')

Func AutoItExit()
	Exit
EndFunc   ;==>AutoItExit
Func OnAutoItExit()
	;bye bye procedure
EndFunc   ;==>OnAutoItExit


; setup options and locale globals
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("PixelCoordMode", 0)
AutoItSetOption("MouseClickDelay", ini('MouseClickDelay',3))
AutoItSetOption("MouseClickDownDelay", ini('MouseClickDownDelay',3))
AutoItSetOption("WinTitleMatchMode", 2)
AutoItSetOption("SendKeyDelay", 2)
AutoItSetOption("SendKeyDownDelay", 2)

Global $selfTitle = 'LoL Masteries Save by nvn'
Global $selfAutoStart = 'You can also put ' & $selfTitle & ' in the same folder as "lol.launcher.exe" so the tool auto-lunches LoL.'


Global $clientEN = "PVP.net Client"
Global $clientGR = "PVP.net-Client"
Global $clientFR = "client PVP.net"
Global $clientGuess = ini('LoLwinClientNameGuess',"PVP.net")
Global $client = 0
Global $luncherPath = ini('luncherPathFull',"C:\Riot Games\League of Legends\lol.launcher.exe")
Global $lolPath = ini('luncherPath',"C:\Riot Games\League of Legends")
Global $luncherFileName = ini('luncherExeName',"lol.launcher.exe")
Global $lunchTimeout = ini('lunchTimeout',300) ; secounds
Global $lunchMsgTimeout

; ini correction
ini('','false','255')

; assumptions out of the way
If _Singleton("lolmastersv", 1) == 0 Then
	MsgBox(0, $selfTitle, 'Already running, Press '&ini('Key_Exit','+{end}')& ' to exit or close LoL Luncher.', 5)
	Exit
EndIf

update()
func update(); check if the version is current
	Return ; disable official update check
	if not @Compiled then Return
	HttpSetUserAgent("Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13)")

	; gets size of the file in bytes whitch is a current version build number
	local $current = InetGetSize('http://gg.fileave.com/LoLMasterSaveVersion.txt', 1)
	local $version = StringRight(FileGetVersion(@AutoItExe,'FileVersion'),3)
	ini('version',$version)

	c($current,$version)
	if $current<>369 and $current<>0 and $current>$version Then
		if 6 == MsgBox(51,$selfTitle,'New version available. Do you want to open a download page?') Then
			ShellExecute('http://gg.fileave.com/LoLMasterSaveUpdate.html')
			Exit
		EndIf
	EndIf
EndFunc

; handle luncher and entery point
Global $hwnd
Global $alreadyRunning = 0
luncher()
Func luncher()
	If WinExists($clientEN, "") Then
		$client = $clientEN
	ElseIf WinExists($clientGR, "") Then
		$client = $clientGR
	ElseIf WinExists($clientFR, "") Then
		$client = $clientFR
	ElseIf WinExists($clientGuess, "") Then
		$client = WinGetTitle($clientGuess)
		if @error or StringCompare($clientGuess, $client) or StringInStr($client,'Patcher')==0 Then
			$client = 0
		EndIf
		if $client then
			$client = $clientGuess
			c(1,$client)
		EndIf
	EndIf
	If Not $client Then
		Select
			case FileExists($luncherPath)
				Run($luncherPath, $lolPath)
			Case FileExists(@ScriptDir&'\'&$luncherFileName)
				Run(@ScriptDir&'\'&$luncherFileName, @ScriptDir)
			case Else
				MsgBox(0, $selfTitle, 'Start Leage Of Legends first' &@CRLF& $selfAutoStart)
				Exit
		EndSelect

		Sleep(500)
		$lunchTimer = TimerInit()
		$lunchTimeout = $lunchTimeout * 1000
		While True ; bissy loop
			;process
			;If Not ProcessExists($luncherFileName) Then
			;	MsgBox(0, $selfTitle, 'Start Leage Of Legends first')
			;	Exit
			;EndIf
			; ENGlish?
			If WinExists($clientEN, "") Then
				$client = $clientEN
			ElseIf WinExists($clientGR, "") Then
				$client = $clientGR
			ElseIf WinExists($clientFR, "") Then
				$client = $clientFR
			ElseIf WinExists($clientGuess) Then
				$client = WinGetTitle($clientGuess)
				if @error or StringCompare($clientGuess, $client) or StringInStr($client,'Patcher')==0 Then
					$client = 0
				EndIf
				if $client then
					$client = $clientGuess
					c(2,$client)
				EndIf
			EndIf
			If $client Then ExitLoop
			; timeout?
			if (TimerDiff($lunchTimer) > $lunchTimeout) Then
				MsgBox(0, $selfTitle & ' ' &'Timeout', 'Start LoL then run me again.'& $selfAutoStart)
				Exit
			EndIf
			; sleep
			Sleep(1000)
		WEnd
	Else
		$alreadyRunning = 1
	EndIf
	Sleep(500)
	$hwnd = WinGetHandle($client, "")
	if @error or $client == '' Then
		MsgBox(0,$selfTitle,'Can not find a LoL Launcher window using a title. Let me know about this one.')
		Exit
	EndIf
	sleep(1000)
	SendKeepActive($hwnd, "")
	local $tempP = ini('AutoLoginUser','null')
	if not $alreadyRunning and $tempP <> 'null' then Send($tempP&'{tab}')
	local $tempP = ini('AutoLoginPass','null')
	if not $alreadyRunning and $tempP <> 'null' then Send($tempP&'{enter}')
EndFunc   ;==>luncher

Global $winName = ini('LoLwinName',"League of Legends (TM) Client")
Global $shifted = 0

Global $so
Global $s = WinGetPos($hwnd)
Global $wndw = 210
Global $wndh = 317
Global $tp = 0
Global $show = 1
Global $zord = 0
Global $db[1000][2]
Global $dbsize = 0
Global $dbfn = ini('fileMasteries','lolMasterSet.dat')
Global $dbf = @ScriptDir & '\' & $dbfn
Global $place = 0
Global $frz = 1
Global $frztab = 0
Global $rez = 0
Global $ipgames = -1

Global $debugS = 0
Global $debugC = 1

; deal with luncher size
luncherSize()
Func luncherSize()
	if (($s[2] <> 1280) or ($s[3] <> 800)) or $debugS Then
		If @DesktopWidth < 1280 Or @DesktopHeight < 800 or $debugS then
			if (($s[2] <> 1024) or ($s[3] <> 640)) and Not $debugS Then
				if @DesktopWidth < 1024 Or @DesktopHeight < 640 Then
					msgbox(0,$selfTitle,'Sorry, your monitor rezolution is too small.')
					Exit
				EndIf
				WinMove($hwnd, '', 0, 0, 1024, 640)
				WinSetState($hwnd, '', @SW_HIDE)
				WinSetState($hwnd, '', @SW_SHOW)
				$s = WinGetPos($hwnd)
				if (($s[2] <> 1024) or ($s[3] <> 640)) Then
					$msg = 'No luck resising. (Monitor resolution too small?)'
					If 6 <> MsgBox(51, $selfTitle, $msg & @CRLF & 'Current Luncher Size: ' & $s[2] & 'x' & $s[3] & @CRLF & 'Do you want to continue?') Then
						Exit
					EndIf
				EndIf
			EndIf
			$rez = 1
		Else
			If 6 == MsgBox(51, $selfTitle, 'LoL Lancher is not sized 1280x800.' & @CRLF & 'Current Luncher Size: ' & $s[2] & 'x' & $s[3] & @CRLF & 'Do you want to try resizing a luncher to default size? (not recomended)') Then
				WinMove($hwnd, '', 0, 0, 1280, 800)
				WinSetState($hwnd, '', @SW_HIDE)
				WinSetState($hwnd, '', @SW_SHOW)
				Sleep(500)
				$s = WinGetPos($hwnd)
				$msg = ''
				if (($s[2] <> 1280) or ($s[3] <> 800)) Then
					$msg = 'No luck resising. (Monitor resolution too small?)'
				Else
					$msg = 'LoL Luncher resized.'
				EndIf
				If 6 <> MsgBox(51, $selfTitle, $msg & @CRLF & 'Current Luncher Size: ' & $s[2] & 'x' & $s[3] & @CRLF & 'Do you want to continue?') Then
					Exit
				EndIf
			Else
				Exit
			EndIf
			$rez = 0
		EndIf
	EndIf
EndFunc   ;==>luncherSize



Dim $env[2][6] = [ [141, 254, 10576732, 13284473, 120, 280], _; [0] 1280x800
				   [119, 168, 10848317, 6495254, 70, 180] ]; [1] 1024x640
#cs Data Structure Documentation
[0] 1280x800
	[0] X coord
	[1] Y coord
	[2] pre-game color
	[3] in-game color
	[4] X me relative position to lol
	[5] Y relative position
[1] 1024x640
	[0-3] same structure as for 1280x800
#ce

Dim $act[2][2][8][3] = _
[[ _; [0] 1280x800
	[[167, 668, 1983342],[581, 497, 2115448],[163, 700, 2444926],[611, 517, 2248323], _
	[467, 524, 77387],[696, 524, 77387],[923, 524, 77387],[1152, 524, 77387]], _; [1] in-game tree
	[[161, 633, 2247032],[587, 467, 10859201],[-1, -1, -1],[-1, -1, -1], _
	[-1, -1, -1],[-1, -1, -1],[-1, -1, -1],[-1, -1, -1]] _; [0] pre-game tree
], [ _; [1] 1024x640
	[[127, 534, 1983343],[587, 498, 2182013],[127, 561, 2180722],[553, 480, 2049912], _
	[373, 420, 77387],[557, 420, 77387],[738, 419, 77387],[922, 421, 77387]], _; [1] in-game tree
	[[123, 509, 1325412],[496, 472, 2247805],[-1, -1, -1],[-1, -1, -1], _
	[-1, -1, -1],[-1, -1, -1],[-1, -1, -1],[-1, -1, -1]] _; [0] pre-game tree
]]
#cs Data Structure Documentation
[0] 1280x800
	[0] pre-game tree
		[0]	reset
			[0] X coord
			[1] Y coord
			[2] Color
		[1] reset confirm
			[0] X coord
			[1] Y coord
			[2] Color
		[2] save
			[0] X coord
			[1] Y coord
			[2] Color
		[3] save confirm
			[0] X coord
			[1] Y coord
			[2] Color
		[4-7] msg win minimize
			[0] X coord
			[1] Y coord
			[2] Color
	[1] in-game tree
		[0-2] same structure as pre-game tree
[1] 1024x640
	[0-3] same structure as for 1280x800
#ce

Dim $ocr[2][2][9] = [[[592932, 6443799, 14924293, 11308556, 10059791, 1008672, 1284638, 1631004, 0],[0,1,3,4,2,1,2,3,0]], _
					 [[592932, 9073425, 14201350, 5654809, 10585614, 1215263, 1352222, 1628188, 0], [0,1,3,4,2,1,2,3,0]]]
#cs Optimisation statistics:
	most are 0
	most are maxed
	19 max out at 1
	15 max out at 3
	6 max out at 4
	3 max out at 2
	(g0 y1 y3 y4 y2 g1 g2 g3)
#ce
#cs Data Structure Documentation
[0] 1280x800
	[0] color
		[0-7] g0 y1 y3 y4 y2 g1 g2 g3 (green yellow)
	[1] number
		[0-7] g0 y1 y3 y4 y2 g1 g2 g3 (green yellow)
[1] 1024x640
	[0-1] same structure as for 1280x800
#ce

Dim $da[2][2][2][43][2] ; yay baby! 5 dimentional array
#cs Data Structure Documentation
[0] 1280x800
	[0] pre-game tree
		[1] read coords
			[0-42] coords
				[0] X coord
				[1] Y coord
		[2] write coords
			[0-42] coords
				[0] X coord
				[1] Y coord
	[1] in-game tree
		[0-2] same structure as pre-game tree
[1] 1024x640
	[0-1] same structure as for 1280x800
#ce


LoadData()
func LoadData()
	local $cord1raw = '393,273;456,273;519,273;582,273;456,353;519,353;393,431;456,431;519,431;582,431;456,511;456,589;519,589;456,669;666,273;729,273;792,273;855,273;729,353;792,353;729,431;792,431;855,431;729,511;792,511;729,589;792,589;729,669;939,273;1002,273;1065,273;1128,273;1002,353;1065,353;939,431;1002,431;1065,431;1128,431;1065,511;1128,511;1002,589;1065,589;1002,669'
	local $cord2raw = '314,218;365,218;415,218;466,218;365,281;415,281;314,344;365,344;415,344;466,344;365,408;365,471;415,471;365,534;533,218;583,218;634,218;684,218;583,281;634,281;583,344;634,344;684,344;583,408;634,408;583,471;634,471;583,534;751,218;802,218;852,218;902,218;802,281;852,281;751,344;802,344;852,344;902,344;852,408;902,408;802,471;852,471;802,534'
	local $allxy = StringSplit($cord1raw, ';', 2)
	c(UBound($allxy))
	For $i = 0 To 42; for each coord set
		$xy = StringSplit($allxy[$i], ',')
		$da[0][0][0][$i][0] = $xy[1]
		$da[0][0][0][$i][1] = $xy[2]
		$da[0][0][1][$i][0] = $xy[1] - 5
		$da[0][0][1][$i][1] = $xy[2] - 25
		$da[0][1][0][$i][0] = $xy[1]
		$da[0][1][0][$i][1] = $xy[2] - 33
		$da[0][1][1][$i][0] = $xy[1] - 5
		$da[0][1][1][$i][1] = $xy[2] - 25 - 25; shift from this read + shift for set
	Next
	$allxy = StringSplit($cord2raw, ';', 2)
	c(UBound($allxy))
	For $i = 0 To 42; for each coord set
		$xy = StringSplit($allxy[$i], ',')
		$da[1][0][0][$i][0] = $xy[1]
		$da[1][0][0][$i][1] = $xy[2]
		$da[1][0][1][$i][0] = $xy[1] - 5
		$da[1][0][1][$i][1] = $xy[2] - 12
		$da[1][1][0][$i][0] = $xy[1]
		$da[1][1][0][$i][1] = $xy[2] - 26
		$da[1][1][1][$i][0] = $xy[1] - 5
		$da[1][1][1][$i][1] = $xy[2] - 26 - 12; shift from this read + shift for set
	Next
EndFunc


Global $wndx = $s[0] + $env[$rez][4]
Global $wndy = $s[1] + $env[$rez][5]



#region ; GUI

; business includes
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
Opt("GUIOnEventMode", 1)


$guColorBg = ini('guiColorBackground',0xC9B170)
$guColorCtrlBg = ini('guiColorCtrlBackground',0xECDEB6);0xF8E9C1
$guColorText = ini('guiColorText',0x601212);0x2B271A;0x6F100A
$guFont = ini('guiFont',"Microsoft Sans Serif")

$wnd = GUICreate($selfTitle, 210, 318, 240, 166, $WS_POPUP, $WS_EX_TOOLWINDOW)
GUISetFont(ini('guiFontSize',11), 400, 0, $guFont);Microsoft Sans Serif
GUISetBkColor($guColorBg)
GUISetOnEvent($GUI_EVENT_CLOSE, "wndClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "wndMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "wndMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "wndRestore")

;$list1 = _GUICtrlListBox_Create($wnd, "", 0, 128, 204, 173)

$name = GUICtrlCreateInput("Select below", 0, 0, 209, 19, BitOR($ES_CENTER, $ES_AUTOHSCROLL), 0)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetTip(-1, "Type the name here")
GUICtrlSetOnEvent(-1, "nameChange")


$Label2 = GUICtrlCreateLabel("0-0-0", 0, 32, 80, 20,BitOR(0x01,0x0100))
GUICtrlSetTip(-1, "Copy current masteries code")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "Label2Click")

#cs
$bCopy = GUICtrlCreateButton("Copy", 15, 40, 50, 20, $WS_GROUP)
GUICtrlSetTip(-1, "Copy current masteries code to clipboard")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "btnCopy")
#ce

$lClink = GUICtrlCreateLabel("link", 0, 55, 80, 20,BitOR(0x01,0x0100))
GUICtrlSetTip(-1, "Copy current masteries link")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "btnLClink")

#cs
$Label3 = GUICtrlCreateLabel("0", 0, 44, 80, 20)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetOnEvent(-1, "Label3Click")
$Label4 = GUICtrlCreateLabel("0", 0, 60, 80, 20)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetOnEvent(-1, "Label4Click")
#ce

$code = GUICtrlCreateEdit("", 80, 24, 129, 58, $ES_WANTRETURN)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetData(-1, StringFormat("00000000000000,00000000000000,000000000000000"))
GUICtrlSetTip(-1, "Masteries Code: Tree code (right to left, top to bottom).")
GUICtrlSetOnEvent(-1, "codeChange")

$Button2 = GUICtrlCreateButton("Save", 52, 84, 50, 24, $WS_GROUP)
GUICtrlSetTip(-1, "Save to """&$dbfn&""" (portable)")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "save")
$Button3 = GUICtrlCreateButton("Delete", 0, 84, 50, 24, $WS_GROUP)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "delete")
$Button4 = GUICtrlCreateButton("Read", 104, 84, 50, 24, $WS_GROUP)
GUICtrlSetTip(-1, "Masteries into code")
GUICtrlSetCursor(-1, 0)
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetOnEvent(-1, "btnRead")
$Button1 = GUICtrlCreateButton("Apply", 156, 84, 50, 24, $WS_GROUP)
GUICtrlSetTip(-1, "Apply mastery code")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "btnApply")

$list1 = GUICtrlCreateList("", 0, 110, 209, 200, BitOR($LBS_SORT, $WS_VSCROLL));$LBS_NOTIFY)
GUICtrlSetTip(-1, "Double click to apply")
GUICtrlSetColor(-1, $guColorText)
GUICtrlSetBkColor(-1, $guColorCtrlBg)
GUICtrlSetOnEvent(-1, "list1Click")

#cs remove GUI part for now
$chk = _GUICtrlCreateCheckbox("Fix LoL Windowed Mode", 15, 288, 180, 21, $guColorText)
GUICtrlSetCursor($chk[1], 0)
GUICtrlSetTip($chk[1], "Shift LoL Window to the correct position while playing in windowed mode")
GUICtrlSetOnEvent($chk[1], "chkShiftWin")
#ce

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUISetState()
;WinSetState($wnd, "", @SW_HIDE)

; LoL windows position fix
;=================================
Func _GUICtrlCreateCheckbox($sText, $nLeft, $nTop, $nWidth, $nHeight, $nColor)
	Local $aCkBoxEx[3]
	$aCkBoxEx[1] = GUICtrlCreateCheckbox('', $nLeft, $nTop, $nHeight, $nHeight)
	$aCkBoxEx[2] = GUICtrlCreateLabel($sText, $nLeft + $nHeight, $nTop + 2, $nWidth - $nHeight, $nHeight)
	GUICtrlSetColor($aCkBoxEx[2], $nColor)
	Return $aCkBoxEx
EndFunc   ;==>_GUICtrlCreateCheckbox

#cs since GUI part removed no need to control it
chkShiftWinEnable()
func chkShiftWinEnable()
	GuiCtrlSetState($chk[1], $GUI_CHECKED)
	chkShiftWin()
EndFunc
Func chkShiftWin()
	If GUICtrlRead($chk[1]) == 1 Then
		AdlibRegister('shiftWin', 5000); check position every 5 secounds
	Else
		AdlibUnRegister('shiftWin')
	EndIf
EndFunc   ;==>chkShiftWin
#ce

if ini('runShiftWindow','false')=='true' then shiftWinRun()

func shiftWinRun()
	c('shift Window was disabled')
	;AdlibRegister('shiftWin', ini('runShiftWindowDelay',5000))
EndFunc

; fix window position while playing in windowed mode
Func shiftWin()
	local $gg = WinGetHandle($winName)
	If @error Then Return 0

	$clientSize = WinGetClientSize($gg)
	If @error Then Return 1

	ConsoleWrite($clientSize[0] & @TAB & $clientSize[1] & @CRLF)

	If @DesktopHeight <> $clientSize[1] Then Return 2

	$winSize = WinGetPos($gg)
	If @error Then Return 3

	$x = $clientSize[0] - $winSize[2] + 3
	$y = $clientSize[1] - $winSize[3] + 3
	WinMove($gg, '', $x, $y, $winSize[2], $winSize[3])
EndFunc   ;==>shiftWin
;=================================


Func WM_COMMAND($hwnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom, $iIDFrom, $iCode, $hWndListBox
	If Not IsHWnd($list1) Then $hWndListBox = GUICtrlGetHandle($list1)
	$hWndFrom = $ilParam
	$iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
	$iCode = BitShift($iwParam, 16) ; Hi Word

	Switch $hWndFrom
		Case $list1, $hWndListBox
			Switch $iCode
				Case $LBN_DBLCLK ; Sent when the user double-clicks a string in a list box
					MasteriesSet()
				Case $LBN_KILLFOCUS ; Sent when a list box loses the keyboard focus
					list1Click()
				Case $LBN_SELCANCEL ; Sent when the user cancels the selection in a list box
					list1Click()
				Case $LBN_SELCHANGE ; Sent when the selection in a list box has changed
					list1Click()
				Case $LBN_SETFOCUS ; Sent when a list box receives the keyboard focus
					list1Click()
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND


#endregion ; GUI
; end


Load()
AdlibRegister('isLive', 5000)
AdlibRegister('position', 20)
AdlibRegister('state', 100)
AdlibRegister('zorder', 50)

$frz = 0

While 1
	Sleep(10)
WEnd


#region ;GUI action
Func codeChange()
	putStat()
EndFunc   ;==>codeChange
Func btnCopy()

EndFunc   ;==>Label2Click
Func btnLClink()
	ClipPut('http://leaguecraft.com/masteries/'&StringReplace(GUICtrlRead($code),',',''))
EndFunc   ;==>Label3Click
Func statusClick()
	;ShellExecute($log)
EndFunc   ;==>statusClick
Func Label2Click()
	ClipPut(StringReplace(GUICtrlRead($code),',',''))
EndFunc   ;==>Label4Click
Func Label4Click()

EndFunc   ;==>Label4Click
Func nameChange()

EndFunc   ;==>nameChange

Func wndClose()

EndFunc   ;==>wndClose
Func wndMaximize()

EndFunc   ;==>wndMaximize
Func wndMinimize()

EndFunc   ;==>wndMinimize
Func wndRestore()

EndFunc   ;==>wndRestore
Func btnRead()
	MasterRead()
EndFunc   ;==>btnRead
Func btnApply()
	MasteriesSet()
EndFunc   ;==>btnApply
Func putStat()
	Local $clean = StringRegExpReplace(GUICtrlRead($code), '\D', '')
	Local $a = StringMid($clean,1,14)
	Local $b = StringMid($clean,15,14)
	Local $c = StringMid($clean,29,15)
	Local $aa = 0, $bb = 0, $cc = 0
	GUICtrlSetData($code, $a & ',' & $b & ',' & $c)
	For $i = 1 To 14
		$aa += Int(StringMid($a, $i, 1))
	Next
	For $i = 1 To 14
		$bb += Int(StringMid($b, $i, 1))
	Next
	For $i = 1 To 15
		$cc += Int(StringMid($c, $i, 1))
	Next
	GUICtrlSetData($Label2, $aa&'-'&$bb&'-'&$cc)
EndFunc   ;==>putStat

#endregion ;GUI action
; end


#region ;db stuff
Func Load()
	dbload()
	WinMove($wnd, '', $wndx, $wndy, $wndw, $wndh)
	WinSetOnTop($wnd, '', 0)
	db2list()
EndFunc   ;==>Load

Func dbload()
	$file = FileOpen($dbf, 0)
	; Check if file opened for reading OK
	If $file = -1 Then
		c('no file to load')
		$db[0][0] = '21-0-9 AP Offense'
		$db[0][1] = '1003440131300100000000000000013040001000000'
		$db[1][0] = 'Tank'
		$db[1][1] = '0000000000000013033421030001013040001000000'
		$db[2][0] = 'just a test'
		$db[2][1] = '3001440131300100000000000000031040100000000'
		$dbsize = 3
		Return
	EndIf
	$dbsize = 0
	; Read in lines of text until the EOF is reached
	While $dbsize < UBound($db)
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		Local $sep = StringSplit($line, '=')
		If @error Then Local $sep = StringSplit($line, ':')
		If @error Then ContinueLoop
		$sep[2] = StringRegExpReplace($sep[2], '\D', '', 0)
		If StringLen($sep[2]) <> 43 Then ContinueLoop
		$db[$dbsize][0] = $sep[1]
		$db[$dbsize][1] = $sep[2]
		$dbsize += 1
	WEnd
	FileClose($file)
EndFunc   ;==>dbload

Func dbsave()
	$file = FileOpen($dbf, 2)
	; Check if file opened for writing OK
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf
	For $i = 0 To $dbsize - 1
		FileWriteLine($file, $db[$i][0] & '=' & $db[$i][1] )
	Next
	FileClose($file)
EndFunc   ;==>dbsave

Func dbn2i($txt)
	$i = 0
	while ($i < $dbsize) and ($db[$i][0] <> $txt)
		$i += 1
	WEnd
	If $i == $dbsize Then
		c("Can't find:""" & $txt & """")
		Return -1
	Else
		Return $i
	EndIf
EndFunc   ;==>dbn2i

Func db2list()
	_GUICtrlListBox_BeginUpdate($list1)
	$i = 0
	while ($i < $dbsize)
		_GUICtrlListBox_AddString($list1, $db[$i][0])
		$i += 1
	WEnd
	_GUICtrlListBox_EndUpdate($list1)
	_GUICtrlListBox_SetCurSel($list1, 0)
	list1Click()
EndFunc   ;==>db2list

Func list1Click()
	$i = dbn2i(GUICtrlRead($list1))
	If $i == -1 Then
		c('onclick db fail')
		Return
	EndIf
	GUICtrlSetData($name, $db[$i][0])
	GUICtrlSetData($code, $db[$i][1])
	putStat()
EndFunc   ;==>list1Click

Func save()
	If StringLen(GUICtrlRead($name)) < 1 Then
		tip('Empty name?', '', 1)
		Return
	EndIf
	$i = c(dbn2i(GUICtrlRead($name)))
	$j = c(_GUICtrlListBox_FindString($list1, GUICtrlRead($name), 1))
	If $j == -1 Then
		If UBound($db) <= $dbsize Then Return
		$db[$dbsize][0] = GUICtrlRead($name)
		$db[$dbsize][1] = GUICtrlRead($code)
		$dbsize += 1
		_GUICtrlListBox_AddString($list1, GUICtrlRead($name))
		_GUICtrlListBox_SetCurSel($list1, _GUICtrlListBox_FindString($list1, GUICtrlRead($name), 1))
	Else
		$db[$i][0] = GUICtrlRead($name)
		$db[$i][1] = GUICtrlRead($code)
		_GUICtrlListBox_SetCurSel($list1, $j)
		list1Click()
	EndIf
	dbsave()
EndFunc   ;==>save

Func delete()
	$i = dbn2i(GUICtrlRead($list1))
	$j = _GUICtrlListBox_FindString($list1, GUICtrlRead($list1), 1)
	If $i == -1 Then Return
	$db[$i][0] = ''
	$db[$i][1] = ''
	_GUICtrlListBox_DeleteString($list1, $j)
	If $i > 0 Then
		$i -= 1
	Else
		$i = 0
	EndIf
	_GUICtrlListBox_SetCurSel($list1, $i)
	list1Click()
	dbsave()
EndFunc   ;==>delete

#endregion ;db stuff
; end


Func createIPfarm()
	$ipgames+=1
	Switch 0 ; if one of them returns 0 (fails) return (quit the function)
		Case ColorWaitClick(591, 35, 10224129), _
			ColorWaitClick(378, 225, 1253941, 865588), _
			ColorWaitClick(874, 703, 13662234), _
			ColorWaitClick(876, 701, 13794586), _
			ColorWaitClick(345, 549, 7474)
			Return 0
	EndSwitch
	if not ColorWaitClick(333, 549, 7218) then return 0
	Send(Random(1111111,9999999,1)&'{tab}'&Random(1111111,9999999,1)&'{Enter}')

	if not ColorWaitClick(745, 457, 8488070) then return 0
	Sleep(100)
	ColorWait(903, 600, 15527148)
	MouseClick('left',786, 623, 1, 1)
	if not ColorWaitClick(933, 459, 16244878) then return 0
#cs
	ColorWaitClick(66, 741, 16777215)

	Switch 0 ; if one of them returns 0 (fails) return (quit the function)
		Case ColorWaitClick(430, 459, 10526880)
			Return 0
	EndSwitch

	send('{down}{down}{down}{down}{down}{down}{enter}')
	ColorWaitClick(463, 460, 13413726)
#ce
	MouseMove(792, 488, 0)
	MsgBox(0,'IP games so far', $ipgames,1)
EndFunc

Func MasterRead()
	If $frz Then Return
	$frz = 1

	focus(1)
	Local $s = WinGetPos($wnd)
	ToolTip("Reading Masteries...", 44 + $s[0], 85 + $s[1])

	Local $c, $cord, $k, $out = '', $try = 0, $trymax = 5, $faults = 0, $faultsmax = 3
	$k = 0
	While $k < 43; for each cord set
		;c('dim',$rez,$place,$k)
		$c = PixelGetColor($da[$rez][$place][0][$k][0], $da[$rez][$place][0][$k][1],$hwnd)
		if $debugC == 2 Then
			MouseMove($da[$rez][$place][0][$k][0], $da[$rez][$place][0][$k][1])
			sleep(500)
		EndIf
		Switch $c
			Case $ocr[$rez][0][0]
				$out &= $ocr[$rez][1][0]
			Case $ocr[$rez][0][1]
				$out &= $ocr[$rez][1][1]
			Case $ocr[$rez][0][2]
				$out &= $ocr[$rez][1][2]
			Case $ocr[$rez][0][3]
				$out &= $ocr[$rez][1][3]
			Case $ocr[$rez][0][4]
				$out &= $ocr[$rez][1][4]
			Case $ocr[$rez][0][5]
				$out &= $ocr[$rez][1][5]
			Case $ocr[$rez][0][6]
				$out &= $ocr[$rez][1][6]
			Case $ocr[$rez][0][7]
				$out &= $ocr[$rez][1][7]
			Case Else ; error case
				If $try < $trymax And $faults < $faultsmax Then
					c('! try: ' & $try)
					$try += 1
					focus()
					ContinueLoop
				Else
					$try = 0
					$faults += 1
					$out &= '0'
					if $debugC Then
						MouseMove($da[$rez][$place][0][$k][0], $da[$rez][$place][0][$k][1],0)
						c('! PixelGetColor(' & $da[$rez][$place][0][$k][0] & ', ' & $da[$rez][$place][0][$k][1] & ') == ' & $c)
						c('$da['&$rez&']['&$place&'][0]['&$k&'][0],[1] == '&$c)
					EndIf
				EndIf
		EndSwitch
		If $k == 13 Or $k == 27 Then
			$out &= ','
		EndIf
		$k += 1
	WEnd
	c($out)
	GUICtrlSetData($code, $out)
	putStat()
	sleep(100)
	ToolTip('')
	$frz = 0
	Return $out
EndFunc   ;==>MasterRead


Func MasteriesSet()
	$frz = 1
	focus(1)

	;30014401313001,00000000000000,031040100000000
	$m = GUICtrlRead($code)
	$m = StringReplace($m, ',', '')
	If StringLen($m) <> 43 Then
		MsgBox(0, 'Materies set Tool', 'Invalid masteries code length')
		Return
	EndIf

	$frz = 1
	$tmp = MouseGetPos()
	
	Switch 0 ; if one of them returns 0 (fails) return (quit the function)
		Case ColorWaitClick($act[$rez][$place][0][0], $act[$rez][$place][0][1], $act[$rez][$place][0][2]), _
			 ColorWaitClick($act[$rez][$place][1][0], $act[$rez][$place][1][1], $act[$rez][$place][1][2])
			$frz = 0
			Return 0
	EndSwitch
	
	if not ColorWait($act[$rez][$place][0][0], $act[$rez][$place][0][1], $act[$rez][$place][0][2]) then
		$frz = 0
		Return 0
	EndIf

	For $k = 0 To 42; for each cord set
		For $i = 1 To StringMid($m, $k+1, 1) ; oh... for each mastery in the code (very smart) loop that many times
			; this makes $cord[$k] a coordinate of mastery $k
			MouseClick("left", $da[$rez][$place][1][$k][0], $da[$rez][$place][1][$k][1], 1, 0)
			;sleep(500)
		Next
	Next

	Switch 0 ; if one of them returns 0 (fails) return (quit the function)
		Case ColorWaitClick($act[$rez][$place][2][0], $act[$rez][$place][2][1], $act[$rez][$place][2][2]), _
			 ColorWaitClick($act[$rez][$place][3][0], $act[$rez][$place][3][1], $act[$rez][$place][3][2])
			 $frz = 0
			Return 0
	EndSwitch
	MouseMove($tmp[0], $tmp[1],1)
	WinActivate($wnd)
	$frz = 0
EndFunc   ;==>setM


#region ; GUI AI
;==========================================================

func isLive()
	WinGetPos($hwnd)
	If @error Then
		c('no window')
		Exit
	EndIf
EndFunc

Func position()
	If $frz Or Not $show Then Return
	;#############################
	; position handle
	$so = $s
	$s = WinGetPos($hwnd)
	;handle window positioning
	If @error Then
		c('no window')
		Exit
	EndIf
	;position relative to the folder
	If $s[0] <> $so[0] Or $s[1] <> $so[1] Then
		$wndx = $s[0] + $env[$rez][4]
		$wndy = $s[1] + $env[$rez][5]
		WinMove($wnd, '', $wndx, $wndy, $wndw, $wndh)
	EndIf
	;############################
EndFunc   ;==>position

Func state()
	If $frz Then Return
	;##############################
	; State handle
	;$po = MouseGetPos()
	;cb($po[0]&", "&$po[1])
	$px = PixelGetColor($env[$rez][0], $env[$rez][1], $hwnd)
	if $debugC == 3 then
		ConsoleWrite($px&@CRLF)
		;MouseMove($env[$rez][0], $env[$rez][1])
	EndIf
	$place = -1
	If $px == $env[$rez][2] Then
		$place = 0
	ElseIf $px == $env[$rez][3] Then
		$place = 1
	EndIf
	If $place <> -1 Then
		If $show == 0 Then
			WinSetState($wnd, "", @SW_SHOW)
			$show = 1
			c('tab here show')
		EndIf
	Else
		If $show == 1 Then
			WinSetState($wnd, "", @SW_HIDE)
			$show = 0
			c("no tab: hide")
		EndIf
		Return
	EndIf
EndFunc   ;==>state

Func zorder()
	If $frz Or Not $show Then Return
	$tpo = $tp
	$tp = WinGetTitle("[active]")
	If $tpo == $tp Then Return

	If $tp == $client Then
		If $zord == 0 Then
			WinSetOnTop($wnd, '', 1)
			WinActivate($wnd)
			WinActivate($hwnd)
			$zord = 1
			c('set top')
		EndIf
	ElseIf $tp == $selfTitle Then
		Return
	Elseif ($zord == 1) Then
		WinSetOnTop($wnd, '', 0)
		WinActivate($wnd)
		WinActivate($tp)
		$zord = 0
		c('set bot: ' & $tp)
	EndIf
EndFunc   ;==>zorder

Func focus($m=0)
	if $zord Then
		WinActivate($hwnd)
	Else
		$tp = $client
		$tpo = $client
		$zord = 1
		WinSetOnTop($wnd, '', 1)
		WinActivate($wnd)
		WinActivate($hwnd)
	EndIf
	if $m Then
		ifColorClick($act[$rez][$place][4][0], $act[$rez][$place][4][1], $act[$rez][$place][4][2])
		ifColorClick($act[$rez][$place][5][0], $act[$rez][$place][5][1], $act[$rez][$place][5][2])
		ifColorClick($act[$rez][$place][6][0], $act[$rez][$place][6][1], $act[$rez][$place][6][2])
		ifColorClick($act[$rez][$place][7][0], $act[$rez][$place][7][1], $act[$rez][$place][7][2])
	EndIf
EndFunc   ;==>focus

#endregion ; GUI AI
; end


#region ; sub funcs
Func ifColorClick($x, $y, $c)
	if $c == -1 then Return 0
	if PixelGetColor($x, $y)==$c Then
		MouseClick('left',$x, $y,1,0)
		Return 1
	EndIf
	Return 0
EndFunc   ;==>ColorWaitClick

Func ColorWaitClick($x, $y, $c,$ultc = -1)
	c('ColorWaitClick',$x, $y, $c)
	if $c == -1 then Return 1
	Local $tt = TimerInit()
	if $ultc == -1 Then
		While PixelGetColor($x, $y) <> $c
			Sleep(10)
			If TimerDiff($tt) > 5000 Then
				if $debugC then
					c('CWC fail',$x, $y, $c,'<>',PixelGetColor($x, $y))
					MouseMove($x, $y,0)
				EndIf
				Return 0
			EndIf
		WEnd
	Else
		local $tc =PixelGetColor($x, $y)
		While $tc <> $c and $tc <> $ultc
			Sleep(10)
			If TimerDiff($tt) > 5000 Then
				if $debugC then
					c('CWC fail',$x, $y, $c,'<>',PixelGetColor($x, $y))
					MouseMove($x, $y,0)
				EndIf
				Return 0
			EndIf
			$tc =PixelGetColor($x, $y)
		WEnd
	EndIf
	c('gonna do mouse click', $x, $y)
	MouseClick('left', $x, $y, 1, 0)
	Return 1
EndFunc   ;==>ColorWaitClick

Func ColorWait($x, $y, $c, $t = 5000)
	c('ColorWait',$x, $y, $c)
	if $c == -1 then Return 1
	Local $tt = TimerInit()
	While PixelGetColor($x, $y) <> $c
		Sleep(10)
		If TimerDiff($tt) > 5000 Then
			if $debugC then
				c('CW fail',$x, $y, $c)
				MouseMove($x, $y,0)
			EndIf
			Return 0
		EndIf
	WEnd
	Return 1
EndFunc   ;==>pixwait

Func c($txt,$a='',$b='',$c='',$d='',$e='')
	ConsoleWrite($txt &@TAB&$a&@TAB&$b&@TAB&$c&@TAB&$d&@TAB&$e& @CRLF)
	Return $txt
EndFunc   ;==>c
Func cb($txt = '')
	ConsoleWrite($txt)
	Return $txt
EndFunc   ;==>cb
Func ca($txt)
	Local $out, $i, $s = UBound($txt, 0)
	Switch $s
		Case 0
			ConsoleWrite($txt & @CRLF)
		Case 1
			$s = UBound($txt)
			$out = '----------' & $s & '----------' & @CRLF
			$s -= 1
			For $i = 0 To $s
				$out &= '$array[' & $i & '] = ' & $txt[$i] & @CRLF
			Next
			$out &= '---------------------' & @CRLF
			ConsoleWrite($out)
		Case 2
			$s = UBound($txt, 1)
			$s2 = UBound($txt, 2)
			$out = '---------- ' & $s & ' x ' & $s2 & ' ----------' & @CRLF
			$s -= 1
			$s2 -= 1
			For $i = 0 To $s
				$out &= '$array[' & $i & ']' & @CRLF
				For $ii = 0 To $s2
					$out &= @TAB & '$array[' & $i & '][' & $ii & '] = ' & $txt[$i][$ii] & @CRLF
				Next
			Next
			$out &= '-------------------------' & @CRLF
			ConsoleWrite($out)
	EndSwitch
	Return $txt
EndFunc   ;==>ca
Func tip($text, $title = '', $time = 10)
	If $text == '' And $title == '' Then
		ToolTip('')
		Return
	EndIf
	If $time <> 0 Then
		Opt('MouseCoordMode', 1)
		Local $mppos
		$time = $time * 1000
		While $time > 0
			$mppos = MouseGetPos()
			ToolTip($text, $mppos[0] + 16, $mppos[1], $title)
			Sleep(10)
			$time -= 9.5
		WEnd
		ToolTip('')
		Opt('MouseCoordMode', 2)
	Else
		Opt('MouseCoordMode', 1)
		$mppos = MouseGetPos()
		ToolTip($text, $mppos[0] + 16, $mppos[1], $title);, 1, 0 + 2 + 4)
		Opt('MouseCoordMode', 2)
	EndIf
EndFunc   ;==>tip


Func tInit()
	Return @YDAY * 86400 + @HOUR * 3600 + @MIN * 60 + @SEC
EndFunc   ;==>tInit
Func tGetTime($_t)
	Local $t = $_t
	Dim $out[4] = [-1, -1, -1, -1]
	If $_t < 0 Then Return $out
	$out[0] = Floor($t / 86400)
	$t -= $out[0] * 86400
	$out[1] = Floor($t / 3600)
	$t -= $out[1] * 3600
	$out[2] = Floor($t / 60)
	$t -= $out[2] * 60
	$out[3] = $t
	Return $out
EndFunc   ;==>tGetTime
Func tGetTimeSub($_t)
	Return tGetTime(tInit() - $_t)
EndFunc   ;==>tGetTimeSub
Func tGetTimeAdd($_t)
	Return tGetTime(tInit() + $_t)
EndFunc   ;==>tGetTimeAdd
Func tDiff($_t)
	Return tInit() - $_t
EndFunc   ;==>tDiff

Func _WinWaitActivate($title, $text, $timeout = 0)
	WinWait($title, $text, $timeout)
	If Not WinActive($title, $text) Then WinActivate($title, $text)
	If Not WinWaitActive($title, $text, $timeout) Then
		;msgbox(0,"lolMasterSave","Start Leage Of Legends first")
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_WinWaitActivate
#endregion ; sub funcs
; end


