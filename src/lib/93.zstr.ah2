


zStrFormat(template, args) {
    zExpectArg(args, "args").toBeObjectLike()
    zExpectArg(template, "template").toBeStringLike()
    if args is Array {
        return Format(template, args*)
    }
}

; Returns a string that's `self` repeated `count` times, deparated by `delim`.
zStrRepeat(self, count, delim := "") {
    zExpectArg(self, "self").toBeStringLike()
    zExpectArg(count, "count").toBeIntLike()
    zExpectArg(delim, "delim").toBeStringLike()
    return zz_str.repeat(self, count, delim)
}

; Returns a new string that's padded to the end, to the width toWidth, using the padding `padding`.
zStrPadRight(self, toWidth, padding := " ") {
    zExpectArg(self, "self").toBeStringLike()
    zExpectArg(toWidth, "toWidth").toBeIntLike()
    zExpectArg(padding, "padding").toBeStringLike()
    return zz_str.padEnd(self, toWidth, padding)
}

; Returns a string that's padded to the left, toWidth, using the given padding.
zStrPadLeft(self, toWidth, padding := " ") {
    zExpectArg(self, "self").toBeStringLike()
    zExpectArg(toWidth, "toWidth").toBeIntLike()
    zExpectArg(padding, "padding").toBeStringLike()
    myLen := StrLen(self)
    extras := toWidth - myLen
    if (extras <= 0) {
        return self
    }
    padding := zStrRepeat(padding, extras)
    result := padding self 
    return result
}

; Returns the positions of substring `what` in `this`.
zStrIndexesOf(self, what, cs := false) {
    zExpectArg(self, "self").toBeStringLike()
    zExpectArg(what, "what").toBeStringLike()
    zExpectArg(cs, "cs").toBeBool()
    arr := []
    occur := 1
    last := 0
    Loop {
        if (last != 0) {
            arr.Push(last)
        }
        last := zStrIndexOf(self, what, cs, last + 1)
    } until last = 0
    return arr
}

; Returns the position of the first occurence of `what`.
zStrIndexOf(self, what, caseSensitivity := False, pos := 1) {
    return InStr(self, what, caseSensitivity, pos)
}

; Returns a reversed string.
zStrReverse(self) {
    zExpectArg(self, "self").toBeStringLike()
    str := ""
    Loop Parse self {
        str := A_LoopField str
    }

    return str
}

; Returns the last position of `what` in `self`.
zStrLastIndexOf(self, what, cs := false, pos := 1) {
    zExpectArg(self, "self").toBeStringLike()
    zExpectArg(what, "what").toBeStringLike()
    zExpectArg(cs, "cs").toBeBool()
    zExpectArg(pos, "pos").toBeIntLike()
    cur := 0
    indexes := zStrIndexesOf(self, what, pos)
    if indexes.Length == 0 {
        return 0
    }
    return indexes[indexes.Length]
}

zStrSlice(self, start := 1, end := unset) {
    if not IsSet(end) or end == 0 {
        return SubStr(self, start)
    }
    if end < 0 {
        return SubStr(self, start, end)
    }
    end := zz_normIndex(end, StrLen(self))
    start := zz_normIndex(start, StrLen(self))
    return SubStr(self, start, zz_normIndex(end, StrLen(self)) - zz_normIndex(start, StrLen(self)))
}

; Returns from an array of numeric char codes.
zStrOfCodes(wArray) {
    zExpectArg(wArray, "wArray").toBeArray()
    result := ""
    for i, x in wArray {
        result .= chr(x)
    }
    return result
}

; True if `what` is in `self`
zStrHas(self, what, caseSensitive := false, start := 1) {
    return zStrIndexOf(self, what, caseSensitive, start) > 0
}

; Returns the character at position `pos`.
zStrAt(self, pos) {
    return SubStr(self, pos, 1)
}

