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
        super.__New(, "An error has occurred!", this)
        this._trace := zzutils__parseStack(error.Stack)
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

    cont(btn, empty) {
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
        this.whileDisabled(navigateVsCode)
    }

    copyDetails(btn, empty) {
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
        this.SetFont("S10 CDefault", "Verdana")
        this.AddText("x12 y9 w240 h20", "An error has occurred in the script:")
        this.AddEdit("x272 y9 w190 h20 ReadOnly", A_ScriptName)
        this.AddText("x13 y33 w82 h20", "Error Type:")
        this.AddEdit("x101 y34 w361 h20 ReadOnly", Type(this._error))
        this.AddText("x12 y56 w68 h16", "Error Type:")
        this.AddEdit("x11 y76 w453 h103 ReadOnly", this._error.Message)
        btnOk := this.AddButton("x375 y466 w89 h25 Default", "Exit")
        btnOk.OnEvent("Click", "stop")
        btnContinue := this.AddButton("x280 y466 w89 h25", "Resume")
        btnContinue.OnEvent("Click", "cont")
        stackTraceLabel:="Stack Trace:"
        if (A_IsCompiled) {
            stackTraceLabel.= " (is compiled)"
        }
        this.AddText("x12 y293 w500 h17", stackTraceLabel)
        cols := ["Pos", "File", "Ln#"]
        lv := this.AddListView("x12 y313 w453 h146", cols)
        lv.OnEvent("DoubleClick", "clickedFrameRow")
        btnCopy := this.AddButton("x12 y466 w89 h25", "Copy Details")
        btnCopy.OnEvent("Click", "copyDetails")
        if (imageList) {
            lv.SetImageList(imageList)
        }

        for ix, entry in this._trace {
            SplitPath(entry.File, &filename)
            lv.Add("", ix, filename, entry.Line)
        }
        Loop cols.Length {
            lv.ModifyCol(A_Index, "AutoHdr")
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
    handler.Show("w477 h505")
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
