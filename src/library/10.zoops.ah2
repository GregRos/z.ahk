#include 03.zstack.ah2
#include 05.zprocess.ah2
#include 07.ztemplate.ah2

zz_oops_currentError := ""
zz_oops_vsCodeProcess := ""
; Get the current PID.
zz_error_template := zTemplate("
(
|{type}|
{message}

{stack}
)")

zz_error_print(err) {
    stack := []
    for frame in zz_stack_parseTrace(err) {
        stack.Push(String(frame))
    }
    result := zz_error_template({
            type: Type(err),
            message: err.message,
            stack: zz_str_join(stack, "`n")
        })

    return result
}
zz_oops_detectVsCode() {
    global zz_oops_vsCodeProcess
    ; We need to get the topmost vscode process...
    processInfo := zProcess.current
    ; Find the outermost code.exe process that's the parent of this process
    Loop {
        last := processInfo
        processInfo := processInfo.Parent
    } until (!(processInfo && processInfo.Name = "code.exe"))
    zz_oops_vsCodeProcess := last
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

class zz_oops_PanicGui extends Gui {
    _trace := ""
    _error := ""
    result := "exit"
    __New(error) {
        this._error := error
        super.__New("-DPIScale -MinimizeBox -MaximizeBox -0x20000 -0x30000", Format("Error in AHK script « {1} »", A_ScriptName), this)
        this._trace := zz_stack_parseTrace(error)
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
        static typeLikeAPerson(str) {
            blockSize := Integer(StrLen(str)) ** 0.75
            loop strLen(str) {
                SendInput(SubStr(str, A_Index, blockSize))
                A_Index += blockSize - 1
                Sleep 30
            }
        }
        navigateVsCode() {
            global zz_oops_vsCodeProcess
            entry := this._trace[row]
            WinActivate("ahk_pid " zz_oops_vsCodeProcess.Pid)
            Sleep 100
            sourceLocation := entry.File
            SendInput "^p{Backspace}"
            typeLikeAPerson(entry.File)
            Sleep 250
            SendInput ":" entry.Line
            SendInput "{Enter}"
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
        if (zz_oops_vsCodeProcess) {
            imageList := IL_Create()
            Loop 10 {
                IL_add(imageList, zz_oops_vsCodeProcess.Path, 1)
            }
        }
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
    global zz_oops_currentError, zz_oops_vsCodeProcess
    if (zz_oops_currentError) {
        return
    }
    zz_oops_currentError := ex
    handler := zz_oops_PanicGui(zz_oops_currentError)
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
    zz_oops_detectVsCode()
    OnError(zz_createPanicGui)
}


zz_oops_test() {
    f() {
        g() {
            h() {
                throw zInvalidCallError("zOops exception test")
            }
            h()
        }
        g()
    }
    f()
}