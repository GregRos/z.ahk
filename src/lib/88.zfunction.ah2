/**
 * Creates a function that can be called with any params and always returns the same value.
 * @param value The value to return.
 */
zConst(value) {
    return (args*) => value
}
