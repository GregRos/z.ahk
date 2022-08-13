#include 08.zassert.ah2
#include 03.zstack.ah2
#include 06.zcolor.ah2
#include 07.ztemplate.ah2
#include 12.zerror.ah2
#include 05.zprocess.ah2
#include 15.zwriter.ah2

zz_test_colorTemplate(templateLines*) {
    return zTemplate(zColor(zz_str_join(templateLines, "`n")))
}

writeTrace(writer, frames) {
    static traceFileEntry := zz_test_colorTemplate(
        "[!brightBlue]➜ [!u]{File}:{Line}[!][!] @ [!i green]{Function}[!]",
        "    > [!d black]{Quote}[!]"
    )
    static traceAutoExecEntry := zz_test_colorTemplate("[!b red]➜ Auto-execute[!]")
    for frame in frames {
        if frame.isScript {
            writer.WriteLine(traceFileEntry(frame))
        } else {
            writer.WriteLine(traceAutoExecEntry(frame))
        }
    }
}

writeError(writer, err) {

    static errorBody := zz_test_colorTemplate(
        "[!bold red]💥 {type}[!]",
        "{message}",
        ""
    )
    writer.WriteLine(errorBody({
        type: Type(err),
        message: err.message
    })).WriteLine()
    frames := zz_StackTrace.Parse(err)
    frames := zz_array_filter(frames, x => not x.isScript or not (InStr(x.Function, "zz_") or InStr(x.Function, "Func.Prototype.Call")))
    writeTrace(writer, frames)
}

class zInvalidTestError extends Error {

}

class zz_TestFail {
    __New(assertionFailure) {
        this.Stack := zz_stack_capture(1)
        block := this._findAssertCallFrame()
    }

    _findAssertCallFrame() {
        lastFrame := zz_array_findLast(this.Stack, x => x.HasOwnProp("Function") and InStr(x.Function, "zAssert.Prototype"))
        x := 1
    }

}

class zz_TestResult {
    __New(suite, test, result) {
        this.suite := suite
        this.test := test
        this.result := result
    }

    isOk {
        get => this.result = True
    }

    isFail {
        get => this.result is zz_TestFail
    }

    isError {
        get => this.result is Error
    }
}

class zz_Test {
    __New(title, definition) {
        this.title := title
        this.definition := definition
    }

    Run() {
        try {
            this.definition.Call()
            return True
        } catch Any as err {
            return err
        }
    }
}

class zz_TestSuite {
    __New(title, tests) {
        this.title := title
        this._tests := tests
    }

    Run(reporter) {
        results := []
        for test in this._tests {
            reporter.running(test.title)
            result := zz_TestResult(this.title, test.title, test.Run())
            results.Push(result)
            reporter.result(result)
        }
        reporter.finish(results)
    }
}

zz_testSuites := []



class zz_TestStatusReporter {
    __New(writer, onClose) {
        this._writer := writer
        this._onClose := onClose
    }

    _ok(obj) {

    }

    running(event) {
        ; This event is not implemented here
    }

    _oneLiner(event) {
        static errorLine := zz_test_colorTemplate("[!b bgBrightMagenta black]💥 {test}[!]")
        static okLine := zz_test_colorTemplate("[!bgGreen black b]✔️ {test}[!]")
        static failLine := zz_test_colorTemplate(
            "[!bgRed black b]❌ {test}[!]"
        )
        if event.isOk {
            return okLine(event)
        } else if event.isError {
            return errorLine(event)
        } else {
            return failLine(event)
        }

    }

    result(event) {
        _writer := this._writer
        _writer.WriteLine(this._oneLiner(event))
    }

    finish(results) {
        static passKeyword := zColor("[!bgGreen b black] PASS [!]")
        static failKeyword := zColor("[!bgBrightRed b black] FAIL [!]")
        _writer := this._writer
        _writer.WriteLine(" ")
        anyFails := False
        for r in results {
            if r.isOk {
                continue
            }
            anyFails := True
            _writer.WriteLine(this._oneLiner(r))
            _writer.Indent()
            if r.isError {
                writeError(_writer, r.result)
            }
            
            _writer.Unindent()
            
        }
        if anyFails {
            _writer.WriteLine(failKeyword)
        } else {
            _writer.WriteLine(passKeyword)
        }
    }
}

class zz_TestReporter {
    __New(writer) {
        this._writer := writer
    }

    suite(event) {
        onEnd() {
            this._writer.Unindent()
        }
        static suiteLine := zz_test_colorTemplate("[!bold black]📁 {suite}[!]")
        this._writer.WriteLine(suiteLine(event))
        this._writer.Indent()
        return zz_TestStatusReporter(this._writer, onEnd)
    }
}


zz_test_expandReporter(reporter) {
    stdout(text) {
        FileAppend(text, "*", "`n UTF-8")
    }
    stderr(text) {
        FileAppend(text, "**", "`n UTF-8")
    }
    
    if reporter = "debug" {
        textWriterImpl := OutputDebug
    } else if reporter = "stderr" {
        textWriterImpl := stderr
    } else if reporter = "stdout" {
        textWriterImpl := stdout
    } else if zz_isCallable(reporter) {
        textWriterImpl := reporter
    } else if HasProp(reporter, "WriteLine") {
        return reporter
    } else {
        throw zNotImplementedError("Reporter: " reporter)
    }
    return zz_TestReporter(zz_TextWriter(textWriterImpl))
}

class zz_TestRunner {
    _suites := []

    AddSuite(suite) {
        this._suites.Push(suite)
    }

    Run(config) {
        config.reporter := zz_test_expandReporter(config.reporter)
        for suite in this._suites {
            suiteReporter := config.reporter
            suite.Run(suiteReporter.suite({
                suite: StrReplace(suite.title, "_", " ")
            }))
        }
    }
}

zz_test_runner := zz_TestRunner()


zz_test_classToSuite(cls) {
    tests := []
    inst := cls()
    for key in ObjOwnProps(cls.Prototype) {
        value := inst.%key%
        if zz_isCallable(value) {
            bound := ObjBindMethod(inst, key)
            tests.Push(zz_Test(StrReplace(key, "_", " "), bound))
        }
    }
    return zz_TestSuite(inst.Name, tests)
}



class zTestSuite extends zAssert {
    __New() {
        raise(failure) {
            throw zz_TestFail(failure)
        }
        super.__New(raise)
    }

    Name {
        get => Type(this)
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
    
    zz_test_runner.Run(config)
}