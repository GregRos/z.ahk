#include 95.string.ah2

/**
 * Creates an array from collections, a string, a value to repeat and a count, and more. See examples.
 * @param {`?`} what The thing to turn into an array.
 * @param {`Number`} repeat If specified, will create an array of `what` repeated this many times. Must be 0 or higher.
 * @example
 * ; This just makes an empty array:
 * zArr() ; []
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
 */
zArr(thing?, count?) {
    if IsSet(count) {
        arr := []
        arr.Length := count
        zExpectArg(count, "repeat").toBeIntLike().toBeAtLeast(0)
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
 * Returns a range of numbers in an array.
 * @param {Number} start Initial value of the range, inclusive.
 * @param {Number} end End point, also inclusive.
 * @param {Number} step The difference between a number and the next, must be greater than 0.
 * @example
 * ; Range between 1 and 5:
 * zRange(1, 5) ; [1, 2, 3, 4, 5]
 * ; Range between 1 and 5 with an increment of 3:
 * zRange(1, 5, 3) ; [1, 4]
 * ; If start is greater than end, the range is reversed:
 * zRange(5, 1) ; [5, 4, 3, 2, 1]
 *  ; The step is always positive no matter the direction.
 * zRange(5, 1, 2) ; [5, 3, 1]
 */
zRange(start, end, step := 1) {
    zExpectArg(start, "start").toBeNumLike()
    zExpectArg(end, "end").toBeNumLike()
    zExpectArg(step, "step").toBeMoreThan(0)
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
 * Returns a string or array made of the input concatenated to itself a number of times.
 * @param input The string or array to repeat.
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
zRepeat(input, times) {
    zExpectArg(times, "times").toBeIntLike().toBeAtLeast(0)
    if input is String {
        result := ""
        loop times {
            result .= input
        }
        return result
    }
    zExpectArg(input, "input").toBeEnum(1)
    result := []
    loop times {
        for x in input {
            result.Push(x)
        }
    }
    return result
}

/**
 * Creates a Map from the properties of an object. Arrays are keyed by index.
 * @param {Object} self The object to create a Map from.
 * @example
 * ; Create a Map from an object:
 * zDict({a: 1, b: 2}) ; => Map("a", 1, "b", 2)
 * ; Create a Map from an empty object:
 * zDict({}) ; => Map()
 */
zDict(self := {}) {
    zExpectArg(self, "self").toBeObj()
    dict := Map()
    if self is Array {
        Loop self.Length {
            dict[A_Index] := self[A_Index]
        }
    }
    for key, val in ObjOwnProps(self) {
        dict[key] := val
    }
    return dict
}
/**
 * Creates a new collection by merging the input collections by key into a Map. Arrays are keyed by index.
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