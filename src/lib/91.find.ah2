
/**
 * Searches a collection for the first value that fulfills a predicate.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection or string. A string is treated as an array of chars.
 * @param {`predicate(val): bool` or `predicate(key, val): bool`} predicate  An **iteratee** search predicate.
 * @returns {`{Key, Value}` or `""`} A key-value pair or `""` if not found.
 * @remarks For an array, a value's index is its key.
 * @example
 * ; Find a string that has length 3:
 * zFind( ["a", "bb", "ccc"], x => StrLen(x) == 3) ; {Key: 3, Value: "ccc"}
 * ; Find the first kvp that has the value 2:
 * zFind(Map("a", 1, "b", 2), (k, v) => v == 2) ; {Key: "b", Value: 2}
 * ; Try to find 5 in an array that doesn't have it:
 * zFind([1, 2, 3], x => x = 5) ; ""
 * ; Use an `if` with an assignment:
 * if kvp := zFind(arr, x => x.IsTrue) {
 *  zOut("Key: {.Key}, Value: {.Value}", kvp)
 * }
 * ; Or, if you're brave, skip the `if`:
 * key := zFind([1, 2, 3], x => Mod(x, 2) == 0).Key
 *  
 */
zFind(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)

    return zz_arr.find(self, predicate)
}

/**
 * Searches a collection for the last value that fulfills a predicate.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection or string. A string is treated as an array of chars.
 * @param {`predicate(val): bool` or `predicate(key, val): bool`} predicate  An **iteratee** search predicate.
 * @returns {`{Key, Value}` or `""`} A key-value pair or `""` if not found.
 * @example
 * ; Find the last string with length 2:
 * zFindLast( ["a", "bb", "ccc", "dd"], x => StrLen(x) == 2) ; {Key: 4, Value: "dd"}
 * ; Find the last kvp (silly):
 * zFindLast(Map("a", 1, "b", 2), (k, v) => True) ; {Key: "b", Value: 2}
 * ; Try to find 5 in an array that doesn't have it:
 * zFindLast([1, 2, 3], x => x = 5) ; ""
 * ; Use an `if` with an assignment:
 * if kvp := zFindLast(arr, x => x.IsTrue) {
 *  zOut("Key: {.Key}, Value: {.Value}", kvp)
 * }
 * ; Or, if you're brave, skip the `if`:
 * key := zFindLast([1, 2, 3], x => Mod(x, 2) == 0).Key
 */
zFindLast(self, predicate) {
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(predicate, "predicate").toBeCallable(1, 2)
    return zz_arr.findLast(self, predicate)
}

/**
 * Searches a collection for the first appearance of a value, or a string for the first appearance of a substring. 
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection or string.
 * @param {`?`} value A value or substring to look for.
 * @param {`bool`} caseSense Whether the search is case-sensitive (False).
 * @returns {`{Key, Value}` or `""`} A key-value pair or `""` if not found.
 * @example
 * ; Find the index of the value "c":
 * zPairOf(["a", "b", "c"], "c").Key ; 3
 * ; Check if an array doesn't have "c":
 * not zPairOf(["a", "b"], "c") ; True
 * ; Get the position of the first "@" symbol in a string:
 * zPairOf("hello@world.com", "@").Key ; 6
 */
zPairOf(self, value, caseSense := False) {
    if self is String {
        pos := InStr(self, value, caseSense)
        return pos ? zz_Kvp(pos, value) : ""
    }
    return zFind(self, x => caseSense ? x == value : x = value)
}

/**
 * Searches a collection for the last appearance of a value, or a string for the last appearance of a substring. 
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection or string.
 * @param {`?`} value A value to look for.
 * @param {`bool`} caseSense Whether the search is case-sensitive (False).
 * @returns {`{Key, Value}` or `""`} A key-value pair or `""` if not found.
 * @example
 * ; Find the last index of the value "c":
 * zLastPairOf(["c", "b", "c"], "c").Key ; 3
 * ; Find the last occurence of the world "very":
 * zLastPairOf("a very very very big rock", "very").Key ; 13
 * 
 */
zLastPairOf(self, value, caseSense := False) {
    if self is String {
        pos := InStr(self, value, caseSense, -1)
        return pos ? zz_Kvp(pos, value) : ""
    }
    return zFindLast(self, x => caseSense ? x == value : x = value)
}

/**
 * Gets the value at a certain key (or index) from a collection, string, or enumerable.
 * @param {`Enum1(val)` or `Enum2(key, val)` or `String`} self A collection, enumerable, or string.
 * @param {Number or String} key The key or index which to get.
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
    if zIsEnumerable(self, 1) {
        zExpectArg(key, "key").toBeIntLike()
        for x in self {
            if A_Index = key {
                return x
            }
        }
    }
    zExpectArg(key, "key").fail("to be a string, indexable, or enumerable")
}