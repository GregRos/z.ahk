#Include 4.assert\0.index.ah2


/**
 * Takes an array-like collection or a string and returns a reversed copy. 
 * @param {`ArrayLike`} self An array-like collection or a string.
 * @example
 * ; Reverses an array of numbers:
 * zReverse([1, 2, 3]) ; [3, 2, 1]
 * ; Reverses an empty array:
 * zReverse([]) ; []
 * ; Reverse a string:
 * zReverse("hello") ; "olleh"
 * 
 */
zReverse(self) {
    if self is string {
        result := ""
        len := StrLen(self)
        Loop len {
            result .= SubStr(self, -A_Index, 1)
        }
        return result
    }
    zExpectArg(self, "self").toBeArrayLike()
    newArr := []
    Loop self.Length {
        newArr.Push(self[self.Length - A_Index + 1])
    }
    return newArr
}



/**
 * Takes a collection and returns a new array with the same elements sorted in ascending order.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 */
zOrder(self) {
    if self is String {
        self := StrSplit(self)
    }
    zExpectArg(self, "self").toBeEnum(1, 2)
    return zz_Ordering().ToArray(self)
}

/**
 * Takes a collection and returns a new array with the same elements sorted in descending order.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 */
zOrderDesc(self) {
    if self is String {
        self := StrSplit(self)
    }
    zExpectArg(self, "self").toBeEnum(1, 2)
    return zz_Ordering().Flip.ToArray(self)
}

/**
 * Takes a collection and returns a new array with the same elements sorted in ascending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)` or `String`} self A collection. Strings are treated as arrays of characters.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zOrderBy(self, getOrderingKey) {
    if self is String {
        self := StrSplit(self)
    }
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).ToArray(self)
}

/**
 * Takes a collection and returns a new array with the same elements sorted in descending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zOrderByDesc(self, getOrderingKey) {
    if self is String {
        self := StrSplit(self)
    }
    zExpectArg(self, "self").toBeEnum(1, 2)
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).Flip.ToArray(self)
}

/**
 * Sorts an array-like collection in ascending order.
 * @param {`ArrayLike`} self An array-like collection.
 */
zSort(self) {
    zExpectArg(self, "self").toBeArrayLike()
    return zz_Ordering().InPlace(self)
}

/**
 * Sorts an array-like collection in descending order.
 * @param {`ArrayLike`} self An array-like collection.
 */
zSortDesc(self) {
    zExpectArg(self, "self").toBeArrayLike()
    return zz_Ordering().Flip.InPlace(self)
}

/**
 * Sorts an array-like collection in ascending order by key.
 * @param {`ArrayLike`} self An array-like collection.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zSortBy(self, getOrderingKey) {
    zExpectArg(self, "self").toBeArrayLike()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).ToArray(self)
}

/**
 * Sorts an array-like collection in descending order by key.
 * @param {`Enum1(value)` or `Enum2(key, value)`} self An array- or map-like collection or sequence.
 * @param {`getOrderingKey(val): ?`} getOrderingKey A function that gets the key of each value.
 */
zSortByDesc(self, getOrderingKey) {
    zExpectArg(self, "self").toBeArrayLike()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zz_Ordering.byKey(getOrderingKey).Flip.ToArray(self)
}




/**
 * A callable that implements a custom less-than `<` operator. Used to sort arrays, maps, and similar.
 */
class zz_Ordering {

    __New(operator?) {
        this._operator := operator ?? (left, right) => left < right
    }

    /**
     * Creates an operator that orders values by key.
     * @param {`getKey(val): bool} The key generating function.
     */
    static byKey(getKey) {
        return zz_Ordering((a, b) => getKey(a) < getKey(b))
    }


    /**
     * Flips the ordering, turning ascending into descending order (and vice versa).
     */
    Flip {
        get {
            operator := this._operator
            return zz_Ordering((b, a) => operator(a, b))
        }
    }

    /**
     * Returns a sorted array from an input array or collection.
     * @param {`Enum1(value)` or `Enum2(key, value)`} seq An array- or map-like collection or sequence.
     */
    ToArray(seq) {
        arr := zz_arr.fromSeq(seq)
        zz_arr.mergeSort(arr, arr.Clone(), this._operator)
        return arr
    }

    /**
     * Sorts an array-like collection in-place and returns it.
     * @param {`ArrayLike`} arrayLike An array-like collection. Should have `.Length`, `.__Item[index]`, and `__Enum(1)`.
     */
    InPlace(arrayLike) {
        clone := zz_arr.fromSeq(arrayLike)
        zz_arr.mergeSort(arrayLike, clone, this._operator)
        return arrayLike
    }

    /**
     * Invokes this ordering's comparison logic.
     * @param left Left-hand value.
     * @param right Right-hand value.
     */
    Compare(left, right) {
        return this._impl.Call(left, right)
    }

}