#include 03.zstack.ah2
global zzutils__oopsSetup := False
global zzutils__currentError := ""
global zzutils__vsCodeProcess := ""
global zzutils__wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2") 
global zzutils__errorBox := ""
; Get the current PID.
zSys_Pid() {
    return DllCall("GetCurrentProcessId")	
}

; Returns info about process with `pid`, or the current process.
zSys_GetProcessInfo(pid := "") {
    if (pid = "") {
        pid := zSys_Pid()
    }
    query := "Select * From Win32_Process where ProcessId = " pid
    results := zzutils__wmi.ExecQuery(query)._NewEnum()
    if results(&proc) {
        return {Name: proc.Name
            ,PID: proc.ProcessId
            ,ParentPID: proc.ParentProcessId
            ,Path: proc.ExecutablePath}
    }
}

zzutils__formatError(error, trace) {
    joinedTrace := ""
    for i, frame in trace {
        if (i != 1) {
            joinedTrace .= "`n"
        }
        joinedTrace .= "at " frame.ToString()
    }
    return Format("
(
# {2}
{3}
# Trace
{4}
@{1}    
)", A_ScriptName, Type(error), error.Message, joinedTrace)
}

zzutils__detectVsCode() {
    global zzutils__vsCodeProcess
    ; We need to get the topmost vscode process...
    processInfo := zSys_GetProcessInfo()
    ; Find the outermost code.exe process that's the parent of this process
    Loop {
        last := processInfo
        processInfo := zSys_GetProcessInfo(processInfo.ParentPid)
    } until (!(processInfo && processInfo.Name = "code.exe"))
    zzutils__vsCodeProcess := last
}

class zzutils__ExceptionGui extends Gui {
    _trace := ""
    _error := ""
    result := "pending"
    __New(error) {
        this._error := error
        super.__New("-DPIScale -MinimizeBox -MaximizeBox", Format("Error in AHK script « {1} »", A_ScriptName), this)
        this._trace := zz_stack_parse(error)
        this.Setup()
    }

    whileDisabled(f) {
        this.Opt("+Disabled")
        try {
            f()
        } finally {
            this.Opt("-Disabled")
        }
    }

    stop(btn, empty) {
        this.result := "exit"
        this.Destroy()
    }

    ignore(btn, empty) {
        this.result := "cont"
        this.Destroy()
    }

    clickedFrameRow(lv, row) {
        navigateVsCode() {
            global zzutils__vsCodeProcess
            entry := this._trace[row]
            WinActivate("ahk_pid " zzutils__vsCodeProcess.Pid)
            sourceLocation := entry.File
            SendInput "^P{Backspace}" entry.File
            Sleep 150
            SendInput ":" entry.Line "{Enter}"
        }
        entry := this._trace[row]
        if entry.IsReal {

        }
        this.whileDisabled(navigateVsCode)
    }

    copy(btn, empty) {
        A_Clipboard := zzutils__formatError(this._error, this._trace)
    }

    Setup() {
        imageList := ""
        if (zzutils__vsCodeProcess) {
            imageList := IL_Create()
            Loop 10 {
                IL_add(imageList, zzutils__vsCodeProcess.Path, 1)
            }
        }
        this.Opt("+AlwaysOnTop")
        this.SetFont("S10 cTeal", "Segoe UI")
        this.BackColor := 0xF89D07

        this.AddText(
            "x0 y8 w584 h42 ReadOnly", 
            "AutoHotKey script had an unhandled error"
        ).SetFont("s14 w600 q5 cNavy")

        this.AddText(
            "x0 y56 w78 h36",
            "Script"
        ).SetFont(
            "s12 w600"
        )
        this.AddEdit(
            "x80 y56 w616 h36 +ReadOnly BackgroundWhite",
            A_ScriptFullPath
        ).SetFont(
            "s11 bold q5",
            "Consolas"
        )

        this.AddText(
            "x0 y96 w76 h32",
            "Type"
        ).SetFont(
            "s12 w600"
        )

        this.AddEdit(
            "x80 y96 w616 h36 +ReadOnly BackgroundWhite", 
            Type(this._error)
        ).Setfont(
            "S11 bold q5",
            "Consolas"
        )

        this.AddEdit(
            "x0 y136 w648 h164 +ReadOnly +Multi -VScroll BackgroundWhite",
            this._error.Message
        ).SetFont(
            "s9 q5",
            "Consolas"
        )

        this.AddButton(
            "x648 y136 w51 h43",
            "📋"
        ).OnEvent("Click", "copy")

        this.AddButton(
            "x648 y256 w51 h43",
            "🌐"
        ).OnEvent("Click", "search")

        this.AddText(
            "x0 y304 w56 h24",
            "What"
        ).SetFont(
            "s10 w600"
        )

        this.AddEdit(
            "x64 y304 w238 h30 +ReadOnly BackgroundWhite", 
            this._error.What
        ).SetFont(
            "s10 norm",
            "Consolas"
        )

        this.AddText(
            "x312 y304 w56 h24",
            "Extra"
        ).SetFont(
            "s10 w600"
        )

        this.AddEdit(
            "x376 y304 w322 h31 +ReadOnly BackgroundWhite",
            this._error.Extra
        ).SetFont(
            "s10 Norm",
            "Consolas"
        )

        this.AddText(
            "x0 y344 w152 h38",
            "Call Stack"
        ).SetFont(
            "s14 w600 cNavy"
        )

        this.AddButton(
            "x0 y752 w270 h67",
            "Ignore"
        ).OnEvent("Click", "ignore")

        this.AddButton(
            "x272 y752 w427 h66",
            "Close"
        ).OnEvent("Click", "stop")

        lvCols := [
            "#",
            "Location",
            "Code"
        ]

        lvStackTrace := this.AddListView("x0 y386 w696 h363 NoSortHdr +Grid -Multi +LV0x4000", lvCols)
        lvStackTrace.SetFont(
            "s10 q5",
            "Consolas"
        )
        lvStackTrace.OnEvent("DoubleClick", "clickedFrameRow")

        if (imageList) {
            lvStackTrace.SetImageList(imageList)
        }

        for ix, frame in this._trace {
            if not frame.isScript {
                lvStackTrace.Add("", ix, "Auto-execute")
                continue
            }
            SplitPath(frame.File, &filename)
            quote := frame.Quote and "> " frame.Quote or ""
            lvStackTrace.Add("", ix, Format("{1}:{2}", filename, frame.Line), quote)
        }

        Loop lvCols.Length {
            lvStackTrace.ModifyCol(A_Index, "AutoHdr")
        }
    }
}
zzutils__openExceptionGui(ex, mode) {
    global zzutils__currentError, zzutils__vsCodeProcess, zzutils__errorBox
    if (zzutils__currentError) {
        return
    }
    zzutils__currentError := ex
    handler := zzutils__ExceptionGui(zzutils__currentError)
    handler.Show("w696 h817")
    WinWaitClose "ahk_id " handler.hwnd
    if handler.result == "exit" {
        return 1
    } else {
        return -1
    }
}

global zzutils__oopsSetup := False

zOops() {
    global zzutils__oopsSetup
    if (zzutils__oopsSetup) {
        return
    }
    zzutils__oopsSetup := True
    zzutils__detectVsCode()
    OnError(zzutils__openExceptionGui)
}
