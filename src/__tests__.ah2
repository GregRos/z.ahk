#SingleInstance Off
#ErrorStdOut 'UTF-8'
#Warn All, Off
#include library/07.ztemplate.ah2
#include library/10.zoops.ah2
#include library/23.ztest.api.ah2
#include library/05.zprocess.ah2
#include library/06.zcolor.ah2
#include library/12.zprint.ah2
zOops()
zOops()
#include library/13.zchecks.ah2
class Blah {
    a := 1
}

class Example_tests extends zTestSuite {
    test_throws() {
        throw zInvalidCallError("This is a test error")
    }
    test_fails() {
        this.isFalse(True)
    }
    test_passes() {
        this.isTrue(True)
    }
}

zHighlander()

zTest({
    reporter: "stdout"
})