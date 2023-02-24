#include ..
#include 1.init\0.index.ah2
#include 08.zassert.ah2
#include 03.zstack.ah2

class zz_TestResult2 {
    Test := ""
    Assertions := 0
    Time := 0
    Result := unset
    __New(test, assertions, time, result) {
        this.Test := test
        this.Assertions := assertions
        this.Time := time
        this.Result := result
    }

    isOk {
        get => this.result is Integer
    }

    isFail {
        get => this.result is zz_TestAssertionFailed
    }

    isError {
        get => this.result is Error
    }

}

class zz_Test2 {
    Title := ""
    __New(title, testThis, testFunction) {
        this._testThis := testThis
        this._testFunction := testFunction
    }

    Run() {
        
    }
}