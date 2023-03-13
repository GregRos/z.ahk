
#include 90.order.ah2
#include 1.util\0.index.ah2
/**
 * Checks if the left object or value is equal to the right object or value.
 * @param left The left object or value.
 * @param right The right object or value.
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
zEqual(left, right, caseSense := False, noCoerce := False) {
    return zz_obj.equal(left, right, caseSense, noCoerce)
}
