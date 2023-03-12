
#include 90.order.ah2
#include 1.util\0.index.ah2
/**
 * Determines if the left value is structurally equal to the right value.
 * @param left The left value.
 * @param right The right value.
 * @param deep If false, only the top-level values are compared. Default is true.
 * @param caseSense If true, comparisons are case-sensitive. Default is false.
 * @param noCoerce If true, numbers aren't coerced into strings. Default is false.
 * @example
 * ; Primitives:
 * zEqual(1, 1) ; True
 * zEqual(1, 2) ; False
 * ; Strings and numbers are compared after coercion:
 * zEqual(1, "1") ; True
 * ; Objects are deeply compared:
 * zEqual({a: {b: 1}}, {a: {b: 1}}) ; True 
 * ; Arrays are compared by element:
 * zEqual([1, 2], [1, 2]) ; True
 * ; Maps are also compared:
 * zEqual(Map("a", 1), Map("a", 1)) ; True"
 * ; Prototypes must match:
 * zEqual(zz_Kvp(1, 2), {Key: 1, Value: 2}) ; False (different prototypes)
 * ; Comparisons are case-insensitive:
 * zEqual({a: "A"}, {a: "a"}) ; True
 * ; You can enable case-sensitivity:
 * zEqual({a: "A"}, {a: "a"}, True) ; False
 * ; You can also disable AHK's string coercion:
 * zEqual(1, "1", , True) ; False
 * 
 */
zEqual(left, right, caseSense := False, coerce := True) {
    if not deep {
        if not coerce and not Type(left) = Type(right) {
            return False
        }
        return caseSense ? left == right : left = right
    }
    return zz_obj.equal(left, right, caseSense, coerce)
}

/**
 * Returns True if the left collection or string starts with the right collection or string.
 * @param {`Enum` or `String`} left The left value. 
 * @param {`Enum` or `String`} right The right value.
 * 
 */
zStartsWith(left, right, caseSense := False) {
    if left is String {
        return zz_str.startsWith(left, right, caseSense)
    }
    zExpectArg(left, "left").toBeArrayLike()
    zExpectArg(right, "right").toBeArrayLike()
    leftSeq := left.__Enum(1)
    rightSeq := right.__Enum(1)
    while rightSeq(&right) {
        if not leftSeq(&left) {
            return False
        }
        if not caseSense {
            right := zz_str.lower(right)
            left := zz_str.lower(left)
        }
        if right != left {
            return False
        }
    }
}