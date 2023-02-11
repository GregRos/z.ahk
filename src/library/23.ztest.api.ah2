#include 21.ztest.runner.ah2
#include 22.ztest.reporter.ah2

zz_test_runner := zz_TestRunner()

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
        get => Type(this)
    }

    static fromClass(cls) {
        tests := []
        inst := cls()
        for key in ObjOwnProps(cls.Prototype) {
            value := inst.%key%
            if zz_func.isCallable(value) {
                bound := ObjBindMethod(inst, key)
                tests.Push(zz_Test(key, bound))
            }
        }
        return zz_TestSuite(inst.Name, tests)
    }

    static __New() {
        if (this != zTestSuite) {
            zz_test_runner.AddSuite(zTestSuite.fromClass(this))
        }
    }
}

zTest(config) {
    config := zz_obj.defaults(config, {
        reporter: "debug"
    })
    config.reporter := zz_reporter.TestReporter(
        zz_sink.GetSink(config.reporter),
        zColor({
            fail: "bgRed black bold",
            lineFail: "brightRed",
            pass: "bgGreen black bold",
            linePass: "brightGreen",
            failClause: "b",
            suiteHeader: "u bold"
        }))

    zz_test_runner.zzRun(config)
}
