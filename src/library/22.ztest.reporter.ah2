#include 01.zinit.ah2
#include 06.zcolor.ah2
#include 07.ztemplate.ah2
#include 08.zwriter.ah2

class zz_reporter {
    class ColoringSink extends zTextWriter.Sink {
        __New(inner, renderer) {
            this.inner := inner
            this.renderer := renderer
        }

        PutLn(text) {
            split := StrSplit(text, "`n")
            for line in split {
                this.inner.PutLn(this.renderer.Call(line))
            }
        }

        Put(text) {
            this.inner.Put(this.renderer.Call(text))
        }
    }

    class TestReporter {
        __New(sink, renderer) {
            this._writer := zTextWriter(zz_reporter.ColoringSink(sink, renderer))
        }

        suite(event) {
            onEnd() {
            }
            static suiteLine := zTemplate("[!suiteHeader]📁 {suite}[!]")
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
            static failStatus := zTemplate("[!lineFail][!fail] FAIL [!] {test}[!]")
            static okStatus := zTemplate("[!linePass][!pass] PASS [!] {test}[!]")
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

        finish(results) {
            _writer := this._writer
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
                _writer.PutLn("[!failClause]" this._statusLine(r) "[!]")
                _writer.Indent("▐  ")
                if r.isError {
                    _writer.PutLn("Test threw an exception!`n`n" zPrint(r.result))
                } else {
                    _writer.PutLn("Failed!!")
                }
                _writer.Unindent().PutLn()
                
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