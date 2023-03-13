
/**
 * Picks the first element for which a predicate returns True. Returns its key and value.
 * @param {Collection} self A map or an array.
 * @param {`val => bool` or `(key, val) => bool`} predicate Whether to pick the element. If omitted, the first element is picked.
 * @returns {`{Key, Value}` or `""`} A Key-Value pair or an empty string if not found.
 * @remarks For an array, a value's index is its key.
 * @example
 * ; Find a string that has length 3:
 * kvp := zFirst( ["a", "bb", "ccc"], x => StrLen(x) == 3) ; {Key: 3, Value: "ccc"}
 * ; It's returned as a key-value pair. Usually you'll want to get the value out:
 * kvp.Value ; "ccc"
 * ; Find the first kvp that has the value 2:
 * zFirst(Map("a", 1, "b", 2), (k, v) => v == 2) ; {Key: "b", Value: 2}
 * ; Try to find 5 in an array that doesn't have it:
 * zFirst([1, 2, 3], x => x = 5) ; ""
 * ; Use an `if` with an assignment:
 * if kvp := zFirst(arr, x => x.IsSomething) {
 *  zOut("Key: {.Key}, Value: {.Value}", kvp)
 * }
 * ; Or, if you're brave, skip the `if`:
 * key := zFirst([1, 2, 3], x => Mod(x, 2) == 0).Key
 * ; To just get the first element:
 * zFirst(arr).Value
 */
zFirst(self, predicate?) {
    zExpectArg(self, "self").toBeCollection()
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)

    return zz_arr.find(self, predicate ?? x => True)
}

/**
 * Picks the last element for which a predicate returns True. Returns its key and value.
 * @param {Collection} self A collection.
 * @param {`val => bool` or `(key, val) => bool`} predicate Whether to pick the element. If omitted, the last element is picked.
 * @returns {`{Key, Value}` or `""`} A Key-Value pair or an empty string if not found.
 * @example
 * ; Find the last string with length 2:
 * zLast( ["a", "bb", "ccc", "dd"], x => StrLen(x) == 2 ) ; {Key: 4, Value: "dd"}
 * ; Find the last kvp (silly):
 * zLast( Map("a", 1, "b", 2), (k, v) => True ) ; {Key: "b", Value: 2}
 * ; Try to find 5 in an array that doesn't have it:
 * zLast( [1, 2, 3], x => x = 5 ) ; ""
 * ; Use an `if` with an assignment:
 * if kvp := zLast( arr, x => x.IsTrue ) {
 *  zOut( "Key: {.Key}, Value: {.Value}", kvp)
 * }
 * ; Or, if you're brave, skip the `if`:
 * key := zLast( [1, 2, 3], x => Mod( x, 2 ) == 0 ).Key ]
 * ; To just get the last element:
 * zLast( arr ).Value
 */
zLast(self, predicate?) {
    zExpectArg(self, "self").toBeCollection()
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.findLast(self, predicate ?? x => True)
}

/**
 * Gets the value at a key or index.
 * @param {Collection or String} self An array, map, or string.
 * @param {Number or String} key The key or index to get.
 * @example
 * ; Gets a character at an index from a string:
 * zAt("hello", 2) ; "e"
 * ; Gets an element at an index from an array:
 * zAt([1, 2, 3], 2) ; 2
 * ; Gets a value at a key for a Map:
 * zAt(Map("a", 1, "b", 2), "b") ; 2
 * 
 */
zAt(self, key) {
    if self is String {
        zExpectArg(key, "key").toBeIntLike()
        return SubStr(self, key, 1)
    }
    if zIsIndexed(self, 1) {
        return self[key]
    }
    if zIsCollection(self) {
        zExpectArg(key, "key").toBeIntLike()
        for k, v in self {
            if A_Index = key {
                return x
            }
        }
        throw UnsetItemError(Format("Key or index '{1}' not found."), key)
    }
    zExpectArg(key, "key").fail("to be a string, indexable, or enumerable")
}