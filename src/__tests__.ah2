#SingleInstance Off
#ErrorStdOut 'UTF-8'
#Warn All, Off
#include lib/1.util/0.index.ah2
#include lib/2.text/0.index.ah2
#include lib/3.system/0.index.ah2
#include lib/4.assert/0.index.ah2
#include lib/5.test/0.index.ah2
#include lib/88.zfunction.ah2
#include lib/98.regex.ah2
zSystemOops()

#include tests\find.test.ah2
#include tests\order.test.ah2
#include tests\function.test.ah2
#include tests\fold.test.ah2
#include tests\create.test.ah2
#include tests\mutate.test.ah2
#include tests\project.test.ah2
; class Example_tests extends zTestSuite {
;     should_throw() {
;         throw zz_InvalidCallError("This is a test error")
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

