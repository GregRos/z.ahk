#include ../1.util/0.index.ah2
zz_test_runner := zz_TestRunner()


class zTestSuite {
    AssertionCount := 0
    __New() {
       
    }

    expect(what) {
        expect := zz_TestExpect(what, (self, assertion) => this.AssertionCount++)
        
        return expect
    }

    onTestStart() {
        this.AssertionCount := 0
    }


    Name {
        get => Type(this)
    }

    static fromClass(cls) {
        tests := []
        inst := cls()
        inspected := zz_Inspect()
        for key in ObjOwnProps(cls.Prototype) {
            value := inst.%key%

            if inspected.next(value).isCallable() {
                execute_test(value, inst) {
                    inst.AssertionCount := 0
                    value.Call(inst)
                    return inst.AssertionCount
                }
                bound := ObjBindMethod(inst, key)
                tests.Push(zz_Test(key, execute_test.Bind(value, inst)))
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
    sink := zz_sink.GetSink(config.reporter)
    sink.PutLn("⚠️ THIS IS NOW A TEST SCRIPT ⚠️")
    config := zz_obj.defaults(config, {
        reporter: "debug"
    })
    config.reporter := zz_reporter.TestReporter(
        sink,
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