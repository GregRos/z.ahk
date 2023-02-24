#include 13.zchecks.ah2

zStrJoin(delim, arr) {
    zCheck(delim, "delim").isString()
    zCheck(arr, "arr").isArray()
    return zz_str.join(arr, delim)
}

; zStr(x) - Stringifies 
zStr(obj*) {

    if not IsObject(obj) {
        return Format('"{1}"', obj)
    }
    if HasMethod(obj, "ToString") {
        return String(obj)
    }
    if obj is Array {
        return Format("[{1}]", zStrJoin(", ", zArrMap(obj, zStr)))
    }
    if obj is Map {
        
    }
}

zStrFormat(template, args) {
    zCheck(args, "args").isObjectLike()
    zCheck(template, "template").isString()
    if args is Array {
        return Format(template, args*)
    }
    
}

; Returns a string that's `self` repeated `count` times, deparated by `delim`.
zStrRepeat(self, count, delim := "") {
    zCheck(self, "self").isString()
    zCheck(count, "count").isInt()
    zCheck(delim, "delim").isString()
    return zz_str.repeat(self, count, delim)
}

; Returns a new string that's padded to the end, to the width toWidth, using the padding `padding`.
zStrPadRight(self, toWidth, padding := " ") {
    zCheck(self, "self").isString()
    zCheck(toWidth, "toWidth").isInt()
    zCheck(padding, "padding").isString()
    return zz_str.padEnd(self, toWidth, padding)
}

; Returns a string that's padded to the left, toWidth, using the given padding.
zStrPadLeft(self, toWidth, padding := " ") {
    zCheck(self, "self").isString()
    zCheck(toWidth, "toWidth").isInt()
    zCheck(padding, "padding").isString()
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
    zCheck(self, "self").isString()
    zCheck(what, "what").isString()
    zCheck(cs, "cs").isBool()
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
    zCheck(self, "self").isString()
    str := ""
    Loop Parse self {
        str := A_LoopField str
    }

    return str
}

; Returns the last position of `what` in `self`.
zStrLastIndexOf(self, what, cs := false, pos := 1) {
    zCheck(self, "self").isString()
    zCheck(what, "what").isString()
    zCheck(cs, "cs").isBool()
    zCheck(pos, "pos").isInt()
    cur := 0
    indexes := zStrIndexesOf(self, what, pos)
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



; Splits `self` in two at `pos` and returns the two parts.
zStrSplitAt(self, pos) {
    zCheck(self, "self").isString()
    zCheck(pos, "pos").isInt()
    pos := zz_normIndex(pos, StrLen(self))
    first := zStrSlice(self, pos - 1)
    last := zStrSlice(self, pos + 1)
    return [first, last]
}

zStrLen(self) {
    return StrLen(self)
}

; Returns from an array of numeric char codes.
zStrOfCodes(wArray) {
    zCheck(wArray, "wArray").isArray()
    result := ""
    for i, x in wArray {
        result .= chr(x)
    }
    return result
}

; Returns a string from an array of strings.
zStrOfChars(cArray) {
    zCheck(cArray, "cArray").isArray()
    result := ""
    for i, x in cArray {
        result .= x
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

