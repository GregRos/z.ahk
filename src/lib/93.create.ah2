#include 95.string.ah2

/**
 * Makes an array from a collection of things — a string, array, Map, or enumerable — OR a thing and a count.
 * @param {`?`} thing The thing to turn into an array.
 * @param {`Number`} repeat If specified, will create an array of `what` repeated this many times. If given, must be a positive integer.
 * @example
 * 
 * ; Makes a shallow clone of the input array:
 * zArr([1, 2, 3]) ; [1, 2, 3]
 * ; Returns an array of the values in a Map:
 * zArr(Map("a", 1, "b", 2)) ; [1, 2]
 * ; Returns an array of characters from a string:
 * zArr("abc") ; ["a", "b", "c"]
 * ; Enumerates and creates an array of elements:
 * zArr(enumerator) ; ["yielded", "by", "enumerator"]
 * ; Using the 2nd parameter overrides everything and just uses `thing` as a value to repeat:
 * zArr(5, 3) ; [5, 5, 5]
 * zArr("bye", 2) ; ["bye", "bye"]
 * zArr([], 2) ; [[], []]
 * zArr("dude", 0) ; []
 * ; If the `thing` parameter is empty but `count` is not, an unset array of that length will be created:
 * zArr( , 3) ; [ , , ]
 * ; This just makes an empty array:
 * zArr() ; []
 */
zArr(thing?, count?) {
    if IsSet(count) {
        zExpectArg(count, "count").toBeIntLike().toBeAtLeast(1)
        arr := []
        arr.Length := count
        if IsSet(thing) {
            loop count {
                arr[A_Index] := thing
            }
        }
        return arr
    }
    if not IsSet(thing) {
        return []
    }
    if thing is String {
        return StrSplit(thing)
    } else if thing is Array {
        ; Duplicates unset items
        arr := []
        arr.Length := thing.Length
        for i, v in thing {
            arr[i] := v
        }
        return arr
    } else if zIsEnumerable(thing, 2) {
        arr := []
        for k, v in thing {
            arr.Push(v)
        }
        return arr
    } else if zIsEnumerable(thing, 1) {
        arr := []
        for v in thing {
            arr.Push(v)
        }
        return arr
    }
    throw zz_BadInputError("Value is not an array, string, or enumerable.", thing)
}

/**
 * Makes a range of numbers in an array.
 * @param {Number} start Initial value of the range, inclusive.
 * @param {Number} end Final value of the range, also inclusive.
 * @param {Number} step The difference between a number and the next, must be greater than 0.
 * @example
 * ; Range between 1 and 5:
 * zRange(1, 5) ; [1, 2, 3, 4, 5]
 * ; A range with floats:
 * zRange(1.5, 3.5) ; [1.5, 2.5, 3.5]
 * ; Range between 1 and 5 with an increment of 3:
 * zRange(1, 5, 3) ; [1, 4]
 * ; Range between 1 and 3 with a step of 0.5:
 * zRange(1, 3, 0.5) ; [1, 1.5, 2, 2.5, 3]
 * ; If start is greater than end, the range is reversed:
 * zRange(5, 1) ; [5, 4, 3, 2, 1]
 *  ; The step is always positive no matter the direction.
 * zRange(5, 1, 2) ; [5, 3, 1]
 * ; This just gives an array with one element:
 * zRange(5, 5) ; [5]
 */
zRange(start, end, step := 1) {
    zExpectArg(start, "start").toBeNumLike()
    zExpectArg(end, "end").toBeNumLike()
    zExpectArg(step, "step").toBeNumLike().toBeMoreThan(0)
    if start > end {
        step := -step
    }
    result := []
    loop {
        result.Push(start)
        start += step
    } until step < 0 ? start < end : start > end
    return result
}

/**
 * Makees a string or array by repeating the input string or array a number of times.
 * @param strOrArray The string or array to repeat.
 * @param times The number of times to repeat it.
 * @example
 * ; Repeat a string 3 times:
 * zRepeat("abc", 3) ; => "abcabcabc"
 * ; Repeat an array 2 times:
 * zRepeat([1, 2, 3], 2) ; => [1, 2, 3, 1, 2, 3]
 * ; Repeat a string 0 times:
 * zRepeat("abc", 0) ; => ""
 * ; Repeat an array 0 times:
 * zRepeat([1, 2, 3], 0) ; => []
 */
zRepeat(strOrArray, times) {
    zExpectArg(times, "times").toBeIntLike().toBeAtLeast(0)
    zExpectArg(strOrArray, "strOrArray").toBeOneOf(String, Array)
    if strOrArray is String {
        result := ""
        loop times {
            result .= strOrArray
        }
        return result
    }
    result := []
    loop times {
        for x in strOrArray {
            result.Push(x)
        }
    }
    return result
}

/**
 * Makes a new Map from the properties of an object or the indexes and values of an array.
 * @param {Object} objOrArray An object or array.
 * @example
 * ; Create a Map from an object:
 * zMap({a: 1, b: 2}) ; => Map("a", 1, "b", 2)
 * ; Create a Map from an empty object:
 * zMap({}) ; => Map()
 * ; Create a map from an array:
 * zMap([1, 2, 3]) ; Map(1 => 1, 2 => 2, 3 => 3)
 */
zMap(objOrArray := {}) {
    zExpectArg(objOrArray, "objOrArray").toBeObj()
    dict := Map()
    if objOrArray is Array {
        for ix, val in objOrArray {
            dict[ix] := objOrArray[val]
        }
    }
    for key, val in ObjOwnProps(objOrArray) {
        dict[key] := val
    }
    return dict
}
/**
 * Makes a new Map by merging one or more input Maps. If a key is in multiple Maps, the last value is used.
 * @param {`Map*`} maps The Maps to merge.
 * @example
 * ; Merge two Maps:
 * zMerge(Map("a", 1), Map("b", 2)) ; => Map("a", 1, "b", 2)
 * ; Merge three Maps:
 * zMerge(Map("a", 1), Map("b", 2), Map("c", 3)) ; => Map("a", 1, "b", 2, "c", 3)
 * ; Merge zero maps:
 * zMerge() ; => Map()
 * ; Merge one map:
 * zMerge(Map("a", 1)) ; => Map("a", 1)
 */
zMerge(maps*) {
    newMap := Map()
    for cur in zReverse(maps) {
        for key, value in cur {
            if not newMap.Has(key) {
                newMap[key] := value
            }
        }
    }
    return newMap
}