#include 03.zstack.ah2
global zzutils__oopsSetup := False
global zzutils__currentError := ""
global zz_vsCodeProcess := ""
global zzutils__wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2") 
global zzutils__errorBox := ""
; Get the current PID.

zz_getCurrentPid() {
    DetectHiddenWindows True
    pid := WinGetPID("ahk_id " A_ScriptHwnd)
    DetectHiddenWindows False
    return pid
}

; Returns info about process with `pid`, or the current process.
zz_queryProcessInfo(pid := unset) {
    if not IsSet(pid) {
        pid := zz_getCurrentPid()
    }
    query := "Select * From Win32_Process where ProcessId = " pid
    results := zzutils__wmi.ExecQuery(query)._NewEnum()
    if results(&proc) {
        return {
            Name: proc.Name,
            PID: proc.ProcessId,
            ParentPID: proc.ParentProcessId,
            Path: proc.ExecutablePath
        }
    }
}

zz_formatFullError(error, trace) {
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
at {1}    
)", A_ScriptName, Type(error), error.Message, joinedTrace)
}

zz_detectVscode() {
    global zz_vsCodeProcess
    ; We need to get the topmost vscode process...
    processInfo := zz_queryProcessInfo()
    ; Find the outermost code.exe process that's the parent of this process
    Loop {
        last := processInfo
        processInfo := zz_queryProcessInfo(processInfo.ParentPid)
    } until (!(processInfo && processInfo.Name = "code.exe"))
    zz_vsCodeProcess := last
}

zz_oops_formatPanicMessage(error) {
    message := error.Message
    extra := HasProp(error, "Extra") ? error.Extra : ""
    what := HasProp(error, "What") ? error.What : ""
    if extra {
        message .= "`r`nExtra: " extra
    } 
    if what {
        message .= "`r`nWhat: " what
    }
    return message
}

class zz_PanicGui extends Gui {
    _trace := ""
    _error := ""
    result := "pending"
    __New(error) {
        this._error := error
        super.__New("-DPIScale -MinimizeBox -MaximizeBox -0x20000 -0x30000", Format("Error in AHK script « {1} »", A_ScriptName), this)
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
            global zz_vsCodeProcess
            entry := this._trace[row]
            WinActivate("ahk_pid " zz_vsCodeProcess.Pid)
            sourceLocation := entry.File
            SendInput "^P{Backspace}" entry.File
            Sleep 150
            SendInput ":" entry.Line "{Enter}"
        }
        entry := this._trace[row]
        if not entry.isScript {
            return
        }
        this.whileDisabled(navigateVsCode)
    }

    copy(btn, empty) {
        A_Clipboard := zz_formatFullError(this._error, this._trace)
    }

    Setup() {
        imageList := ""
        if (zz_vsCodeProcess) {
            imageList := IL_Create()
            Loop 10 {
                IL_add(imageList, zz_vsCodeProcess.Path, 1)
            }
        }
        this.Opt("+AlwaysOnTop")
        this.SetFont("S10", "Segoe UI")

        this.AddText(
            "x144 y8 w517 h42", 
            "An AHK script encountered an error."
        ).SetFont("s14 w600 q5 cred")

        this.AddText(
            "x0 y-8 w140 h135 cred",
            "❌"
        ).SetFont("s55 cred")
        this.AddText(
            "x144 y48 w526 h23",
            "Path:"
        ).SetFont("s10 w600 cBlack")
        this.AddEdit(
            "x144 y80 w529 h37 +ReadOnly BackgroundWhite",
            A_ScriptFullPath
        ).SetFont(
            "s11 bold q5",
            "Consolas"
        )

        this.AddEdit(
            "x24 y144 w652 h33 +ReadOnly BackgroundWhite", 
            Type(this._error)
        ).Setfont(
            "S11 bold q5",
            "Consolas"
        )

        this.AddEdit(
            "x24 y184 w595 h225 +ReadOnly +Multi -VScroll BackgroundWhite",
            zz_oops_formatPanicMessage(this._error)
        ).SetFont(
            "s9 q5",
            "Consolas"
        )

        btnCopy := this.AddButton(
            "x624 y184 w51 h43",
            "📋"
        )
        btnCopy.OnEvent("Click", "copy")

        ; this.AddButton(
        ;     "x624 y232 w51 h43",
        ;     "🌐"
        ; ).OnEvent("Click", "search")

        this.AddText(
            "x24 y413 w152 h34",
            "Call Stack"
        ).SetFont(
            "s14 w600 cNavy"
        )

        btnIgnore := this.AddButton(
            "x24 y738 w270 h57",
            "Ignore"
        )
        btnIgnore.OnEvent("Click", "ignore")
        btnIgnore.SetFont("s12 w600")
        btnStop := this.AddButton(
            "x304 y738 w374 h56",
            "Close"
        )
        btnStop.OnEvent("Click", "stop")
        btnStop.SetFont("s12 w600")

        lvCols := [
            "#",
            "Location",
            "Code"
        ]

        lvStackTrace := this.AddListView("x24 y448 w651 h283 NoSortHdr +Grid -Multi +LV0x4000", lvCols)
        lvStackTrace.SetFont(
            "s9 q5",
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
zz_createPanicGui(ex, mode) {
    global zzutils__currentError, zz_vsCodeProcess, zzutils__errorBox
    if (zzutils__currentError) {
        return
    }
    zzutils__currentError := ex
    handler := zz_PanicGui(zzutils__currentError)
    handler.Show("w696 h817")
    WinWaitClose "ahk_id " handler.hwnd
    if handler.result == "exit" {
        return 1
    } else {
        return -1
    }
}

zOops() {
    static oopsSetup := False
    if oopsSetup {
        return
    }
    oopsSetup := True
    zz_detectVscode()
    OnError(zz_createPanicGui)
}
