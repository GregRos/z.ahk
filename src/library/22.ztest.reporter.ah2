#include 01.zinit.ah2
#include 06.zcolor.ah2
#include 07.ztemplate.ah2
#include 08.zwriter.ah2

class zz_reporter {
    class ColoringSink extends zz_sink.Sink {
        __New(inner, renderer) {
            this.inner := inner
            this.renderer := renderer
        }

        PutLn(text := "") {
            text := this.renderer.Call(text)
            split := StrSplit(text, "`n")
            for line in split {
                this.inner.PutLn(line)
            }
            return this
        }

        Put(text) {
            this.inner.Put(this.renderer.Call(text))
        }
    }

    class TestReporter {
        __New(sink, renderer) {
            this._writer := zz_TextWriter(zz_reporter.ColoringSink(sink, renderer))
        }

        suite(event) {
            onEnd() {
            }
            event.suite := StrReplace(event.suite, "_", " ")
            static suiteLine := zTemplate("[!suiteHeader]📁 {.suite}[!]")
            this._writer.PutLn(suiteLine(event))
            return zz_reporter.StatusReporter(this._writer, onEnd)
        }
    }

    class StatusReporter {
        __New(writer, onClose) {
            this._writer := writer
            this._onClose := onClose
        }

        _ok(obj) {

        }

        running(event) {
            ; This event is not implemented here
        }

        _statusLine(event) {
            static failStatus := zTemplate("[!lineFail][!fail] FAIL [!] {.test}[!]")
            static okStatus := zTemplate("[!linePass][!pass] PASS [!] {.test}[!]")
            if event.isOk {
                return okStatus(event)
            } else {
                return failStatus(event)
            }
        }

        result(event) {
            _writer := this._writer
            _writer.PutLn(this._statusLine(event))
        }


        quoteSourceCode(userFrame) {
            static lineFormat := zTemplate("[!grey]{1}|[!] [!white]{2}[!]")
            static centerFormat := zTemplate("[!bgRed]{1}[!]")
            lines := userFrame.File.Lines
            lines := zz_arr.map(lines, (i, x) => lineFormat(i, zz_color.verbatim(x)))
            lines := zz_arr.slice(lines, userFrame.Line - 1, 3)
            middleIndex := (lines.Length + 1) / 2
            lines[middleIndex] := centerFormat(lines[middleIndex])
            return zz_str.join(lines, "`n")
        }

        finish(results) {
            _writer := this._writer
            static pathFormat := zTemplate("[!grey]➜ [!blue]{.Function}[!] ([!cyan]{.File.Path}:{.Line}[!][!])")
            _writer.PutLn(" ")
            anyFails := False
            for r in results {
                if r.isOk {
                    continue
                }
                if anyFails {
                    _writer.PutLn()
                }
                anyFails := True
                _writer.PutLn("[!black bold]{1}[!]", this._statusLine(r))
                _writer.Indent("[!red]▐  [!]")
                if r.isError {
                    _writer.PutLn("[!brightYellow][!b]🗲 {.type}[!][!d] was unhandled[!][!]`n[!brightYellow][!i]{.message}[!][!]", {
                        type: Type(r.result),
                        message: r.result.message
                    })
                    bottomFrame := r.result.Stack[1]
                    _writer.PutLn(this.quoteSourceCode(bottomFrame))
                } else {
                    _writer.PutLn(r.result.assertion)
                    _writer.PutLn(this.quoteSourceCode(r.result.Bottom))
                }
                for i, frame in r.result.Stack {
                    _writer.PutLn(pathFormat(frame)).Indent("   ")
                    _writer.PutLn("[!brightGreen dim]❯ {1}[!]", zz_color.verbatim(frame.Quote))
                    _writer.Unindent()
                }
                _writer.Unindent().PutLn(" ")

            }
        }
    }
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
