#SingleInstance Off
#ErrorStdOut 'UTF-8'
#Warn All, Off
#include library/07.ztemplate.ah2
#include library/10.zoops.ah2
#include library/23.ztest.api.ah2
#include library/05.zprocess.ah2
#include library/06.zcolor.ah2
#include library/12.zprint.ah2
zSystemOops()

#include library/13.zchecks.ah2
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