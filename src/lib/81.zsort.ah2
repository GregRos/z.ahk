#include 1.util\0.index.ah2
#include 4.assert\0.index.ah2
class zSorter {
    __New(how := "") {
        this._how := how
    }

    Desc {
        get {
            how := this._how
            return zSorter((b, a) => how(a, b))
        }
    }

    /**
     * Returns a sorted array containing all the items in `seq`.
     */
    Order(seq) {
        arr := zz_arr.fromSeq(seq)
        zz_arr.mergeSort(arr, arr.Clone(), this)
    }

    Sort(arrayLike) {
        zExpectArg(arrayLike, "arrayLike").toBeArrayLike()
        clone := zz_arr.fromSeq(arrayLike)
        zz_arr.mergeSort(arrayLike, clone, this)
    }

    /**
     * Gets if `left < right` via this sorter.
     * @param left Left-hand value.
     * @param right Right-hand value.
     */
    Call(left, right) {
        if this._how == "<" {
            return left < right
        } else if this._how == ">" {
            return left > right
        } else {
            return this._how.Call(left, right)
        }

    }

    /**
     * Defines a `zSorter`, which is used to compare values and sort collections. Its behavior
     * depends on the type of `how`.
     * ### Case `unset`
     * Defaults to using `<`.
     * ### Case `(a, b) => bool`
     * `how` returns `True` if `a < b`.
     * ### Case `val => ?`
     * Evaluates `how(val)` to get each value's sorting key, then uses `<`.
     * ### Case `".prop1.prop2"` prop chain
     * Evaluates the property chain on each value to get its sorting key, then uses `<`.
     * ### Case `"<"` or `""`
     * Uses `<`, giving an ascending ordering.
     * ### Case `">"`
     * Uses `>`, giving a descending ordering.
     */
    static Call(how) {
        if how == "" {
            how := "<"
        }
        if zz_func.isCallable(how, 2) {
            return super(how)
        } else if zz_func.isCallable(how, 1) {
            return super((a, b) => how(a) < how (b))
        } else if how is String and zz_str.startsWith(how, ".") {
            return this(zChain(how))
        } else if how == "<" or how == ">" {
            return super(how)
        } else {
            zExpectArg(how, "how").fail("be a valid definition for zSorter.")
        }
    }
}