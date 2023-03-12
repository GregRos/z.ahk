#Include 4.assert\0.index.ah2

/**
 * Reverses a string or an array.
 * @param {`ArrayLike`} strOrArray A string or an array.
 * @example
 * ; Reverses an array of numbers:
 * zReverse([1, 2, 3]) ; [3, 2, 1]
 * ; Reverses an empty array:
 * zReverse([]) ; []
 * ; Reverse a string:
 * zReverse("hello") ; "olleh"
 */
zReverse(strOrArray) {
    if strOrArray is string {
        result := ""
        len := StrLen(strOrArray)
        Loop len {
            result .= SubStr(strOrArray, -A_Index, 1)
        }
        return result
    }
    zExpectArg(strOrArray, "strOrArray").toBeArray()
    newArr := []
    Loop strOrArray.Length {
        newArr.Push(strOrArray[strOrArray.Length - A_Index + 1])
    }
    return newArr
}


/**
 * Sorts elements into a new array in ascending order.
 * @param {Array} arr An array or numbers or an array of strings.
 * @example
 * ; Sorts an array of numbers:
 * zOrder([3, 1, 2]) ; [1, 2, 3]
 * ; Sorts an empty array:
 * zOrder([]) ; []
 * ; Sorts an array of strings:
 * zOrder(["c", "a", "b"]) ; ["a", "b", "c"]
 */
zOrder(arr) {
    zExpectArg(arr, "arr").toBeArray()
    return zLessThan.ToArray(arr)
}

/**
 * Sorts elements into a new array in descending order.
 * @param {Array} arr An array.
 */
zOrderDesc(arr) {
    zExpectArg(arr, "arr").toBeArray()
    return zLessThan.Flip.ToArray(arr)
}

/**
 * Sorts elements into a new array in ascending order by key.
 * @param {Array} arr An array.
 * @param {`val => ?`} getOrderingKey A function that computes a key for each value.
 */
zOrderBy(arr, getOrderingKey) {
    zExpectArg(arr, "arr").toBeArray()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zLessThan.ByKey(getOrderingKey).ToArray(arr)
}

/**
 * Sorts elements into a new array in descending order by key.
 * @param {Array} arr An array.
 * @param {`val => ?`} getOrderingKey A function that computes a key for each value.
 */
zOrderByDesc(arr, getOrderingKey) {
    zExpectArg(arr, "arr").toBeArray()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zLessThan.ByKey(getOrderingKey).Flip.ToArray(arr)
}

/**
 * Sorts an array in ascending order.
 * @param {`Array`} arr An array.
 */
zSort(arr) {
    zExpectArg(arr, "arr").toBeArray()
    return zLessThan.InPlace(arr)
}

/**
 * Sorts an array in descending order.
 * @param {`Array`} arr An array.
 */
zSortDesc(arr) {
    zExpectArg(arr, "arr").toBeArray()
    return zLessThan.Flip.InPlace(arr)
}

/**
 * Sorts an array in ascending order by key.
 * @param {`Array`} arr An array.
 * @param {`val => ?`} getOrderingKey Computes a key for each value.
 */
zSortBy(arr, getOrderingKey) {
    zExpectArg(arr, "arr").toBeArrayLike()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zLessThan.ByKey(getOrderingKey).InPlace(arr)
}

/**
 * Sorts an array collection in descending order by key.
 * @param {`Array`} arr An array.
 * @param {`val => ?`} getOrderingKey Computes the key for each value.
 */
zSortByDesc(arr, getOrderingKey) {
    zExpectArg(arr, "arr").toBeArrayLike()
    zExpectArg(getOrderingKey, "getOrderingKey").toBeCallable(1)
    return zLessThan.ByKey(getOrderingKey).Flip.InPlace(arr)
}



/**
 * A callable that implements a custom less-than `<` operator. Used to sort arrays, maps, and similar.
 */
class zz_Ordering {

    static Default := zz_Ordering(zz_defaultLessThan)
    __New(operator) {
        this._operator := operator
    }


    ByKey(getKey) {
        self := this
        keyedOrdering(left, right) {
            return self(getKey(left), getKey(right))
        }
        return zz_Ordering(keyedOrdering)
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
    Call(left, right) {
        return this._operator.Call(left, right)
    }
}
zz_defaultLessThan(left, right) {
    if left is string {
        return StrCompare(left, right) < 0
    }
    return left < right
}

/**
 * The default ordering used by `z.ahk`. see `zz_Ordering` for more details.
 */
zLessThan := zz_Ordering(zz_defaultLessThan)