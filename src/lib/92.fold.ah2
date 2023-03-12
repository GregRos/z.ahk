/**
 * Checks if every item matches a predicate.
 * @param {Collection} self A collection. A string is treated as an array of chars.
 * @param {`predicate(val): bool` or `predicate(key, val): bool`} predicate  An **iteratee** predicate.
 * @example
 * ; Check if every number in an array is less than 5:
 * zEvery([1, 2, 3, 4], x => x < 5) ; True
 * ; Check if every number in an array is even:
 * zEvery([1, 2, 3], x => Mod(x, 2) == 0) ; False
 * ; Checks if a string consists of only "a"s:
 * zEvery("aaaa", x => x == "a") ; True
 */
zEvery(self, predicate) {
    predicate := zz_Inspect(predicate).normalizeIteratee()
    return not zFind(self, (k, v) => not predicate(k, v))
}

/**
 * Applies the reduce (or fold) operation, from left to right, on a collection, starting from a given initial value.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. A string is treated as an array of chars.
 * @param {`acc(total, current) => ?` or `acc(key, total, current) => ?`} accumulator An **iteratee** accumulator.
 * @param {`?`} initial The initial value. If missing, the first value of `self` is used.
 * @throws {`UnsetError`} If initial is not given and `self` is empty.
 * @example
 * ; Sum numbers in an array:
 * sum := zReduce([1, 2, 3], (acc, cur) => acc + cur, 0) ; 6
 * ; Multiply numbers in an array:
 * product := zReduce([2, 2, 2], (acc, cur) => acc * cur, 1) ; 8
 * ; Concat strings in an array:
 * concat := zReduce(["hello", " ", "world"], (acc, cur) => acc cur, "") ; "hello world"
 * @see https://docs.python.org/3/library/functools.html#functools.reduce
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce
 */
zReduce(self, accumulator, initial := unset) {
    zExpectArg(self, "self").toBeEnum(2)
    zExpectArg(accumulator, "accumulator").toBeCallable(2, 3)
    accumulator := zz_Inspect(accumulator).normalizeAccumulator()
    current := initial ?? unset
    for index, item in self {
        if not IsSet(current) {
            current := item
            continue
        }
        current := accumulator(index, current, item)
    }
    if not IsSet(current) {
        throw UnsetError("Parameter 'initial' was unset and 'self' was empty.")
    }
    return current
}

/**
 * Sums numbers and number-valued collections. Doesn't recurse.
 * @param args One or more numbers and number-valued collections.
 * @example
 * ; Sum an array of numbers:
 * zSum([2, 4, 8]) ; 14
 * ; Sum an empty array:
 * zSum([]) ; 0
 * ; Sums several numbers:
 * zSum(1, 2, 4) ; 7
 * ; Sums numbers and arrays of numbers:
 * zSum(1, [2, 3]) ; 6
 * ; Sums values in maps:
 * zSum(Map("a", 1), Map("b", 2)) ; 3
 */
zSum(args*) {
    flat := zSelectMany(args, x => zIsEnumerable(x) ? zArr(x) : x)
    return zReduce(flat, (key, acc, cur) => acc + cur, 0)
}


/**
 * Multiplies several numbers and number-valued collections. Doesn't recurse.
 * @param args One or more numbers and number-valued collections.
 * @example
 * ; Multiply an array of numbers:
 * zProduct([1, 2, 3]) ; 6
 * ; Multiply an empty array:
 * zProduct([]) ; 1
 * ; Mutliply some numbers:
 * zProduct(1, 2) ; 2
 * ; Multiply numbers with arrays:
 * zProduct(1, [2, 3], 2) ; 12
 */
zProduct(args*) {
    flat := zSelectMany(args, x => zIsEnumerable(x, 1) ? zArr(x) : x)
    return zReduce(flat, (key, acc, cur) => acc * cur, 1)
}


/**
 * Computes an average of numbers and number-valued collections. Doesn't recurse.
 * @param args One or more numbers and number-valued collections.
 * @example
 * ; Average of an array of numbers:
 * zAvg([1, 2, 3]) ; 2
 * ; Average of an empty array:
 * zAvg([]) ; 0
 * ; Average of some numbers:
 * zAvg(2, 2, 1) ; 5/3
 */
zAvg(args*) {
    flat := zSelectMany(args, x => zIsEnumerable(x) ? zArr(x) : x)
    len := 0
    total := zReduce(flat, (tot, cur) => len++, cur + tot)
    if len == 0 {
        return 0
    }
    return total / len
}

/**
 * Gets the minimum value between one or more numbers and number-valued collections. Doesn't recurse.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self A collection of numbers.
 * @example
 * ; Get the minimum value in an array:
 * zMin([1, 2, 3]) ; 1
 * ; Get the minimum value in a map:
 * zMin(Map("a", 1, "b", 2)) ; 1
 */
zMin(args*) {
    flat := zSelectMany(args, x => zIsEnumerable(x) ? zArr(x) : x)

    return Min(flat*)
}

/**
 * Gets the maximum value in a number-valued collection.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self A collection of numbers.
 * @example
 * ; Get the maximum value in an array:
 * zMax([1, 2, 3]) ; 3
 * ; Get the maximum value in a map:
 * zMax(Map("a", 1, "b", 2)) ; 2
 * ; Gets the maximum of an empty arra
 */
zMax(args*) {
    flat := zSelectMany(args, x => zIsEnumerable(x) ? zArr(x) : x)

    return Max(flat*)
}

/**
 * Gets the length of something that has a length.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection or string. It may be enumerated.
 * @example
 * ; Get the length of an array (Length)
 * zLength([1, 2, 3]) ; 3
 * ; Get the length of a Map (Count):
 * zLength(Map()) ; 0
 * ; Get the length of a string (via StrLen):
 * zLength("hello") ; 5
 */
zLength(self) {
    if self is String {
        return StrLen(self)
    }
    if not IsObject(self) {
        throw zz_BadInputError("The parameter 'self' must be an object or a string")
    }
    if HasProp(self, "Length") {
        return self.Length
    } else if HasProp(self, "Count") {
        return self.Count
    }
    if zIsEnumerable(self, 1) {
        for x in self {
            last := A_Index
        }
    } else if zIsEnumerable(self, 2) {
        for a, b in self {
            last := A_Index
        }
    } else {
        throw zz_BadInputError("Parameter 'self' is not a valid enumerable.")
    }
    return last
}


/**
 * Turns every value in a collection into a string and then joins them up with a delimeter.
 * @param {`Enum1(val)` or `Enum2(key, val)`} self The collection to join.
 * @param {`String`} delim The delimeter to place between each string. Defaults to none.
 * @example
 * ; Joins an array of strings:
 * zJoin(["you", "are", "beautiful"], " ") ; "you are beautiful"
 * ; With no delimeter and with numbers:
 * zJoin([1, 2, 3]) ; "123"
 */
zJoin(self, delim := "") {
    zExpectArg(self, "arr").toBeEnum(1)
    zExpectArg(delim, "delim").toBeStringLike()
    delim := String(delim)
    return zz_str.join(self, delim)
}