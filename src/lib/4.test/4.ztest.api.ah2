

zz_test_runner := zz_TestRunner()

class zTestSuite extends zAssert {
    AssertionCount := 0
    __New() {
        stack := zz_stack.capture()
        z := 1

        super.__New()
    }

    onTestStart() {
        this.AssertionCount := 0
    }

    onFailedAssertion(failure) {
        throw zz_TestAssertionFailed(failure.assertion, failure.data)
    }

    onSuccessfulAssertion(text) {
        this.AssertionCount++
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
                exec_test(value, inst) {
                    inst.AssertionCount := 0
                    value.Call(inst)
                    return inst.AssertionCount
                }
                bound := ObjBindMethod(inst, key)
                tests.Push(zz_Test(key, exec_test.Bind(value, inst)))
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
            lineErr: "brightYellow",
            failClause: "",
            err: "bgBrightYellow black b",
            errClause: "b",
            suiteHeader: "brightBlue bold",
            real: "brightRed",
            expected: "brightGreen",
            operator: "brightBlue",
            kw: "brightBlue",
            type: "green"
        }))

    zz_test_runner.zzRun(config)
}