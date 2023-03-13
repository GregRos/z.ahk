/**
 * Checks if every item matches a predicate.
 * @param {Collection} collection A map or array on which to apply the predicate.
 * @param {`val => bool` or `(key, val) => bool`} predicate A map 
 * @example
 * ; Check if every number in an array is less than 5:
 * zEvery([1, 2, 3, 4], x => x < 5) ; True
 * ; Check if every number in an array is even:
 * zEvery([1, 2, 3], x => Mod(x, 2) == 0) ; False
 * ; Checks if a string consists of only "a"s:
 * zEvery("aaaa", x => x == "a") ; True
 */
zEvery(collection, predicate) {
    predicate := zz_Inspect(predicate).normalizeIteratee()
    return not zFirst(collection, (k, v) => not predicate(k, v))
}

/**
 * Applies the **reduce** (also called `Fold` or `Aggregate`) operation to a collection — a generalization of `zSum`, `zProduct`, `zAvg`, `zMin`, and `zMax`. 
 * @param {Collection} collection A collection.
 * @param {`(total, current) => ?` or `(key, total, current) => ?`} accumulator A function that takes an *element* and a *total*, returning a new total.
 * @param {`?`} initial The initial value. If missing, the first value of `collection` is used.
 * @throws {`UnsetError`} If initial is not given and `collection` is empty.
 * @example
 * ; Sum numbers in an array:
 * sum := zReduce([1, 2, 3], (acc, cur) => acc + cur, 0) ; 6
 * ; sum numbers in an array, without an initial value:
 * zReduce([1, 2, 3], (acc, cur) => acc + cur) ; 6
 * ; Multiply numbers in an array:
 * product := zReduce([2, 2, 2], (acc, cur) => acc * cur, 1) ; 8
 * ; Concat strings in an array:
 * concat := zReduce(["hello", " ", "world"], (acc, cur) => acc cur, "") ; "hello world"
 * @see https://docs.python.org/3/library/functools.html#functools.reduce
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce
 */
zReduce(collection, accumulator, initial := unset) {
    zExpectArg(collection, "collection").toBeEnum(2)
    zExpectArg(accumulator, "accumulator").toBeCallable(2, 3)
    accumulator := zz_Inspect(accumulator).normalizeAccumulator()
    current := initial ?? unset
    for index, item in collection {
        if not IsSet(current) {
            current := item
            continue
        }
        current := accumulator(index, current, item)
    }
    if not IsSet(current) {
        throw UnsetError("Parameter 'initial' was unset and 'collection' was empty.")
    }
    return current
}

/**
 * Sums numbers and values in collections. Doesn't recurse.
 * @param colsAndVals One or more numbers and number-valued collections.
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
zSum(colsAndVals*) {
    flat := zSelectMany(colsAndVals, x => zIsEnumerable(x) ? zArr(x) : x)
    return zReduce(flat, (key, acc, cur) => acc + cur, 0)
}


/**
 * Multiplies numbers and values in collections. Doesn't recurse.
 * @param colsAndVals One or more numbers and number-valued collections.
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
zProduct(colsAndVals*) {
    flat := zSelectMany(colsAndVals, x => zIsEnumerable(x, 1) ? zArr(x) : x)
    return zReduce(flat, (key, acc, cur) => acc * cur, 1)
}


/**
 * Averages numbers and values in number-valued collections. Doesn't recurse.
 * @param colsAndVals One or more numbers and number-valued collections.
 * @example
 * ; Average of an array of numbers:
 * zAvg([1, 2, 3]) ; 2
 * ; Average of an empty array:
 * zAvg([]) ; 0
 * ; Average of some numbers:
 * zAvg(2, 2, 1) ; 5/3
 * ; Average of numbers and arrays of numbers:
 * zAvg(1, 1, [1, 1]) ; 1
 */
zAvg(colsAndVals*) {
    flat := zSelectMany(colsAndVals, x => zIsEnumerable(x) ? zArr(x) : x)
    len := 0
    total := zReduce(flat, (tot, cur) => len++, cur + tot)
    if len == 0 {
        return 0
    }
    return total / len
}

/**
 * Gets the minimum value between one or more numbers and values of number-valued collections.
 * @param colsAndVals One or more numbers and number-valued collections.
 * @example
 * ; Get the minimum value in an array:
 * zMin([1, 2, 3]) ; 1
 * ; Get the minimum value in a map:
 * zMin(Map("a", 1, "b", 2)) ; 1
 * ; Gets the minimum of some numbers:
 * zMin(1, 2, 3) ; 1
 * ; Gets the minimum of some numbers and arrays of numbers:
 * zMin(1, 2, [3, 4]) ; 1
 */
zMin(colsAndVals*) {
    flat := zSelectMany(colsAndVals, x => zIsEnumerable(x) ? zArr(x) : x)

    return Min(flat*)
}

/**
 * Gets the maximum value between one or more numbers and values of number-valued collections.
 * @param colOrVals One or more numbers and number-valued collections.
 * @example
 * ; Get the maximum value in an array:
 * zMax([1, 2, 3]) ; 3
 * ; Get the maximum value in a map:
 * zMax(Map("a", 1, "b", 2)) ; 2
 * ; Gets the maximum of arrays an numbers:
 * zMax(1, 2, [3, 4]) ; 4
 */
zMax(colsAndVals*) {
    flat := zSelectMany(colsAndVals, x => zIsEnumerable(x) ? zArr(x) : x)

    return Max(flat*)
}

/**
 * Computes the length of a collection or string.
 * @param {Collection or String} strOrCollection A collection or string.
 * @example
 * ; Get the length of an array (Length)
 * zLength([1, 2, 3]) ; 3
 * ; Get the length of a Map (Count):
 * zLength(Map()) ; 0
 * ; Get the length of a string (via StrLen):
 * zLength("hello") ; 5
 */
zLength(strOrCollection) {
    if strOrCollection is String {
        return StrLen(strOrCollection)
    }
    if not IsObject(strOrCollection) {
        throw zz_BadInputError("The parameter 'strOrCollection' must be an object or a string")
    }
    if HasProp(strOrCollection, "Length") {
        return strOrCollection.Length
    } else if HasProp(strOrCollection, "Count") {
        return strOrCollection.Count
    } else {
        throw zz_BadInputError("Parameter 'self' is not a valid enumerable.")
    }
    return last
}


/**
 * Stringifies every value in a collection and joins them with a delimeter.
 * @param {`Collection`} self The collection to join.
 * @param {`String`} delim The delimeter. Defaults to none.
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