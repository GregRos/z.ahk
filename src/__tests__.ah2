#SingleInstance Off
#ErrorStdOut 'UTF-8'
#Warn All, Off
#include lib/1.util/0.index.ah2
#include lib/2.text/0.index.ah2
#include lib/3.system/0.index.ah2
#include lib/4.test/0.index.ah2

zSystemOops()

#include tests\14.zmaybe.ah2
#include tests\zarr.test.ah2
#include tests\zstr.test.ah2

class Blah {
    a := 1
}

; class Example_tests extends zTestSuite {
;     should_throw() {
;         throw zInvalidCallError("This is a test error")
;     }
;     should_fail() {
;         this.isFalse(True)
;     }
;     should_pass() {
;         this.isTrue(True)
;     }
; }

zSystemHighlander()

zTest({
    reporter: "stdout"
})