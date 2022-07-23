#include gstack.ah2

global z__gutils_oopsSetup := False
global z__gutils_currentError := ""
global z__gutils_vsCodeProcess := ""
global z__gutils_wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2") 
global z__gutils_errorBox := ""
; Get the current PID.
gSys_Pid() {
    return DllCall("GetCurrentProcessId")	
}

; Returns info about process with `pid`, or the current process.
gSys_GetProcessInfo(pid := "") {
    if (pid = "") {
        pid := gSys_Pid()
    }
    query := "Select * From Win32_Process where ProcessId = " pid
    results := z__gutils_wmi.ExecQuery(query)._NewEnum()
    if results(&proc) {
        return {Name: proc.Name
            ,PID: proc.ProcessId
            ,ParentPID: proc.ParentProcessId
            ,Path: proc.ExecutablePath}
    }
}

z__gutils_formatError(error, trace) {
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

z__gutils_detectVsCode() {
    global z__gutils_vsCodeProcess
    ; We need to get the topmost vscode process...
    processInfo := gSys_GetProcessInfo()
    ; Find the outermost code.exe process that's the parent of this process
    Loop {
        last := processInfo
        processInfo := gSys_GetProcessInfo(processInfo.ParentPid)
    } until (!(processInfo && processInfo.Name = "code.exe"))
    z__gutils_vsCodeProcess := last
}

class ExceptionGui extends Gui {
    _trace := ""
    _error := ""
    result := "pending"
    __New(error) {
        this._error := error
        super.__New(, "An error has occurred!", this)
        this._trace := z__gutils_parse(error.Stack)
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
            global z__gutils_vsCodeProcess
            entry := this._trace[row]
            WinActivate("ahk_pid " z__gutils_vsCodeProcess.Pid)
            sourceLocation := entry.File
            SendInput "^P{Backspace}" entry.File
            Sleep 150
            SendInput ":" entry.Line "{Enter}"
        }
        this.whileDisabled(navigateVsCode)
    }

    copyDetails(btn, empty) {
        A_Clipboard := z__gutils_formatError(this._error, this._trace)
    }

    Setup() {
        imageList := ""
        if (z__gutils_vsCodeProcess) {
            imageList := IL_Create()
            Loop 10 {
                IL_add(imageList, z__gutils_vsCodeProcess.Path, 1)
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
z_goops_openExceptionGui(ex, mode) {
    global z__gutils_currentError, z__gutils_vsCodeProcess, z__gutils_errorBox
    if (z__gutils_currentError) {
        return
    }
    z__gutils_currentError := ex
    handler := ExceptionGui(z__gutils_currentError)
    handler.Show("w477 h505")
    WinWaitClose "ahk_id " handler.hwnd
    if handler.result == "exit" {
        return 1
    } else {
        return -1
    }
}

global z__gutils_oopsSetup := False

gOops_Setup() {
    global z__gutils_oopsSetup
    if (z__gutils_oopsSetup) {
        return
    }
    z__gutils_oopsSetup := True
    z__gutils_detectVsCode()
    OnError(z_goops_openExceptionGui)
}
