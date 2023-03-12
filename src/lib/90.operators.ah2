
#include 90.order.ah2
#include 1.util\0.index.ah2
/**
 * Determines if the left value is structurally equal to the right value.
 * @param left The left value.
 * @param right The right value.
 * @param caseSense If true, comparisons are case-sensitive. Default is false.
 * @param noCoerce If true, numbers aren't coerced into strings. Default is false.
 * @example
 * zEqual(1, 1) ; True
 * zEqual(1, 2) ; False
 * zEqual(1, "1") ; False
 * zEqual()
 */
zEqual(left, right, caseSense := False, noCoerce := False) {
    return zz_obj.equal(left, right, caseSense)
}