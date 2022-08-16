#include 01.zinit.ah2
#include 06.zcolor.ah2
#include 07.ztemplate.ah2
#include 08.zwriter.ah2
zz_test_expandReporter(reporter) {
    stdout(text) {
        FileAppend(text, "*", "`n UTF-8")
    }
    stderr(text) {
        FileAppend(text, "**", "`n UTF-8")
    }

    if reporter = "debug" {
        textWriterImpl := OutputDebug
    } else if reporter = "stderr" {
        textWriterImpl := stderr
    } else if reporter = "stdout" {
        textWriterImpl := stdout
    } else if zz_isCallable(reporter) {
        textWriterImpl := reporter
    } else if HasProp(reporter, "WriteLine") {
        return reporter
    } else {
        throw zNotImplementedError("Reporter: " reporter)
    }
    return zz_TestReporter(zTextWriter(textWriterImpl))
}

class zz_TestReporter {
    __New(writer) {
        this._writer := writer
    }

    suite(event) {
        onEnd() {
        }
        static suiteLine := zz_test_colorTemplate("[!bold black]📁 {suite}[!]")
        this._writer.WriteLine(suiteLine(event))
        return zz_TestStatusReporter(this._writer, onEnd)
    }
}

class zz_TestStatusReporter {
    __New(writer, onClose) {
        this._writer := writer
        this._onClose := onClose
    }

    _ok(obj) {

    }

    running(event) {
        ; This event is not implemented here
    }

    _oneLiner(event) {
        static errorLine := zz_test_colorTemplate("[!b bgBrightMagenta black] ERR  [!] [!red]{test}[!]")
        static okLine := zz_test_colorTemplate("[!bgGreen black b] PASS [!] [!green]{test}[!]")
        static failLine := zz_test_colorTemplate(
            "[!bgRed black b] FAIL [!] [!red]{test}[!]"
        )
        if event.isOk {
            return okLine(event)
        } else if event.isError {
            return errorLine(event)
        } else {
            return failLine(event)
        }

    }

    result(event) {
        _writer := this._writer
        _writer.WriteLine(this._oneLiner(event))
    }

    finish(results) {
        static passKeyword := zColor("[!bgGreen b black] PASS [!]")
        static failKeyword := zColor("[!bgBrightRed b black] FAIL [!]")
        _writer := this._writer
        _writer.WriteLine(" ")
        anyFails := False
        for r in results {
            if r.isOk {
                continue
            }
            anyFails := True
            _writer.WriteLine(zColor("[!b i]" this._oneLiner(r) "[!]"))
            _writer.Indent()
            if r.isError {
                writeError(_writer, r.result)
            }

            _writer.Unindent()

        }
        if anyFails {
            _writer.WriteLine(failKeyword)
        } else {
            _writer.WriteLine(passKeyword)
        }
    }
}

zz_test_colorTemplate(templateLines*) {
    return zTemplate(zColor(zz_str_join(templateLines, "`n")))
}

writeTrace(writer, frames) {
    static traceFileEntry := zz_test_colorTemplate(
        "[!brightBlue]➜ [!u]{File}:{Line}[!][!] @ [!i green]{Function.Display}[!]",
        "    > [!d black]{Quote}[!]"
    )
    static traceAutoExecEntry := zz_test_colorTemplate("[!b red]➜ Auto-execute[!]")
    for frame in frames {
        if frame.isScript {
            writer.WriteLine(traceFileEntry(frame))
        } else {
            writer.WriteLine(traceAutoExecEntry(frame))
        }
    }
}

writeError(writer, err) {

    static errorBody := zz_test_colorTemplate(
        "[!bold red]💥 {type}[!]",
        "{message}",
        ""
    )
    writer.WriteLine(errorBody({
        type: Type(err),
        message: err.message
    })).WriteLine()
    frames := zz_stack_parseTrace(err)
    infraRegexp := "i)zz_.*\.zzRun$|Func.Prototype.Call$"
    writeTrace(writer, frames)
}

; AHK Quick Object Format
; |Type|
; key =
;   |Whatever|
;   arrow = 123
;   bigone = 1000
;   haha = blah
;   Array = 
;       * Item1
;       * Item2
;   abcde = 
;       |Test|
;       Stuff happening        
;   @inherited() {...}

; key = value
; prop = !! EXCEPTION !!
; 

; We want something to output lots of information about failed tests
; In case of failure:
;   X ${assertion}
;   real     = ....
;   expected = ....   
;
;       5 | hello.whatever()
;       6|| hello.nope()
;       7 | hello.other()

;
;
;;
;