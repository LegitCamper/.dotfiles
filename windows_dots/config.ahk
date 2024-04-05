;#Warn  ; Recommended for catching common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
ListLines Off
SetBatchLines -1
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#KeyHistory 0
#WinActivateForce

Process, Priority,, H

SetWinDelay -1
SetControlDelay -1

; On Startup
Run python3 %A_ScriptDir%/config.py GoToWorkspace1,, Hide ; Start windows on workspace 1

; Go to Workspace
#1::Run python3 config.py GoToWorkspace1,, Hide
#2::Run python3 config.py GoToWorkspace2,, Hide
#3::Run python3 config.py GoToWorkspace3,, Hide
#4::Run python3 config.py GoToWorkspace4,, Hide
#5::Run python3 config.py GoToWorkspace5,, Hide
#6::Run python3 config.py GoToWorkspace6,, Hide
#7::Run python3 config.py GoToWorkspace7,, Hide
#8::Run python3 config.py GoToWorkspace8,, Hide
#9::Run python3 config.py GoToWorkspace9,, Hide

; Move Window to Workspace
#+1::Run python3 config.py MoveWinToWorkspace1,, Hide
#+2::Run python3 config.py MoveWinToWorkspace2,, Hide
#+3::Run python3 config.py MoveWinToWorkspace3,, Hide
#+4::Run python3 config.py MoveWinToWorkspace4,, Hide
#+5::Run python3 config.py MoveWinToWorkspace5,, Hide
#+6::Run python3 config.py MoveWinToWorkspace6,, Hide
#+7::Run python3 config.py MoveWinToWorkspace7,, Hide
#+8::Run python3 config.py MoveWinToWorkspace8,, Hide
#+9::Run python3 config.py MoveWinToWorkspace9,, Hide

; Pinning and unpinning windows
#p::Run python3 config.py PinWindow,, Hide
#u::Run python3 config.py UnpinWindow,, Hide

; Other keybinds
#t::Run alacritty 
#q:: Send !{f4} 
; Disables windows keys :)
~LWin::Send {Blind}{vkE8}
~RWin::Send {Blind}{vkE8}
#Up::Send {Blind}{vkE8}
#Down::Send {Blind}{vkE8}
#Right::Send "!{Tab}"
#Left::Send "!+{Tab}"


;;; Functions ;;;

; This functions finds out ID of current session.
getSessionId() {
	ProcessId := DllCall("GetCurrentProcessId", "UInt")
	if ErrorLevel {
		OutputDebug, Error getting current process id: %ErrorLevel%
		return
	}
	OutputDebug, Current Process Id: %ProcessId%
	SessionId := ""
	DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
	if ErrorLevel {
		OutputDebug, Error getting session id: %ErrorLevel%
		return
	}
	OutputDebug, Current Session Id: %SessionId%
	return SessionId
}

