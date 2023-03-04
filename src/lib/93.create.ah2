
#include 93.zstr.ah2

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
                arr.Push(thing)
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
    }
    arr := []
    for x in iterable {
        arr.Push(x)
    }
    return arr
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
    } until step < 0 ? start <= end : start >= end
    return result
}



