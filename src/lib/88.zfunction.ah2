/**
 * Creates a function that can be called with any params and always returns the same value.
 * @param value The value to return.
 * @example
 * zOut(zConst(1)(2, 3, 4)) ; 1
 * zOut(zConst("abc")(2, 3, 4)) ; "abc"
 */
zConst(value) {
    return (args*) => value
}
