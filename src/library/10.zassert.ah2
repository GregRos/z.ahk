#include 01.bootstrap.ah2

zzutils_equal(a, b, caseMode := False) {
    if not (IsObject(a) and IsObject(b)) {
        return caseMode ? a == b : a = b
    }
    protoA := a.Base
    protoB := b.Base
    if protoA != protoB {
        return False
    }
    if protoA = Array.Prototype {
        if a.Length != b.Length {
            return False
        }
        loop arr1.Length {
            if not zzutils_equal(arr1[A_Index], arr2[A_Index]) {
                return False
            }
        }
        return True
    }
    if ObjOwnPropCount(a) != ObjOwnPropCount(b) {
        return False
    }
    for key, value in ObjOwnProps(a) {
        if not zzutils_equal(a[key], b[key], caseMode) {
            return False
        }
    }
    return True
}

class zAssert {
    __New(onFailCallback) {
        this._onFailCallback := onFailCallback
    }

    isArray(input, each?) {
        if not input is Array {
            this._onFailCallback("{input} is not an array", {
                input: input
            })
        }
        if IsSet(each) {
            assertion := IsObject(each) ? each : ObjBindMethod(this, each)
            for x in input {
                assertion(x)
            }
        }
    }

    isInt(input) {
        if IsInteger(input) {
            this._onFailCallback("{input} is not an integer", {
                input: input
            })
        }
    }

    isTrue(x) {
        if input != True {
            this._onFailCallback("{input} is not True", {
                input: input
            })
        }
    }

    isFalse(x) {
        if input != False {
            this._onFailCallback("{input} is not False", {
                input: input
            })
        }
    }

    isTruthy(x) {
        if not input {
            this._onFailCallback("{input} is not truthy", {
                input: input
            })
        }
    }

    isFalsy(input) {
        if input {
            this._onFailCallback("{input} is not falsy", {
                input: input
            })
        }
    }

    isEqual(real, expected, caseMode := False) {
        if not zzutils_equal(a, b, caseMode) {
            this._onFailCallback("{real} is not equal to {expected}", {
                real: real,
                expected: expected
            })
        }
    }

    isNotEqual(real, expected, caseMode := False) {
        if zzutils_equal(a, b, caseMode) {
            this._onFailCallback("{real} is equal to {expected}", {
                real: real,
                expected: expected
            })
        }
    }

    atLeast(real, lowerBound) {
        if real < lowerBound {
            this._onFailCallback("{real} is smaller than {lowerBound}", {
                real: real,
                lowerBound: lowerBound
            })
        }
    }

    atMost(real, upperBound) {
        if real > upperBound {
            this._onFailCallback("{real} is greater than {upperBound}", {
                real: real,
                upperBound: upperBound
            })
        }
    }

    has(haystack, needle, caseMode := False) {
        if IsObject(haystack) {
            if not HasMethod(haystack, "__Enum") {
                throw zBadInputError("haystack", "a string or enumerable object", haystack)
            }
            for x in haystack {
                if caseMode ? x !== needle : x != needle {
                    return this._onFailCallback("array {haystack} does not contain {needle}", {
                        haystack: haystack,
                        needle: needle
                    })
                }
            }
        } else {
            if not InStr(haystack, needle, caseMode) {
                return this._onFailCallback("string {haystack} doesn't contain {needle}", {
                    haystack: haystack,
                    needle: needle
                })
            }
        }
    }
    
}