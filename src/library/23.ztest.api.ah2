#include 21.ztest.runner.ah2
#include 22.ztest.reporter.ah2

zz_test_runner := zz_TestRunner()

zz_test_classToSuite(cls) {
    tests := []
    inst := cls()
    for key in ObjOwnProps(cls.Prototype) {
        value := inst.%key%
        if zz_isCallable(value) {
            bound := ObjBindMethod(inst, key)
            tests.Push(zz_Test(key, bound))
        }
    }
    return zz_TestSuite(inst.Name, tests)
}

class zTestSuite extends zAssert {
    __New() {
        stack := zz_stack.capture()
        z := 1
        raise(failure) {
            throw zz_TestAssertionFailed(failure.assertion, failure.data)
        }
        super.__New(raise)
    }

    Name {
        get =>Type(this)
    }

    static __New() {
        if (this != zTestSuite) {
            zz_test_runner.AddSuite(zz_test_classToSuite(this))
        }
    }
}

zTest(config) {
    config := zz_defaults(config, {
        reporter: "debug"
    })
    config.reporter := zz_reporter.TestReporter(
        zz_writer.GetSink(config.reporter), 
        zColor({
            fail: "bgBrightRed black",
            lineFail: "brightRed",
            pass: "bgBrightGreen black",
            linePass: "brightGreen",
            failClause: "b",
            suiteHeader: "u"
            
    }))

    zz_test_runner.zzRun(config)
}