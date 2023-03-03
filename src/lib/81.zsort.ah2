#include 1.util\0.index.ah2
#include 4.assert\0.index.ah2

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