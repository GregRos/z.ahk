#include 13.zchecks.ah2

zStr_Join(delim, arr) {
    zz_checks.isString("delim", delim)
    zz_checks.isArray("arr", arr)
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
        return Format("[{1}]", zStr_Join(", ", zArr_Map(obj, zStr)))
    }
    if obj is Map {
        
    }
}

zStr_Format(template, args) {
    zz_checks.isObjectLike("args", args)
    zz_checks.isString("template", template)
    if args is Array {
        return Format(template, args*)
    }
    
}

; Returns a string that's `self` repeated `count` times, deparated by `delim`.
zStr_Repeat(self, count, delim := "") {
    zz_checks.isString("self", self)
    zz_checks.isInt("count", count)
    zz_checks.isString("delim", delim)
    return zz_str.repeat(self, count, delim)
}

; Returns a new string that's padded to the end, to the width toWidth, using the padding `padding`.
zStr_PadRight(self, toWidth, padding := " ") {
    zz_checks.isString("self", self)
    zz_checks.isInt("toWidth", toWidth)
    zz_checks.isString("padding", padding)
    myLen := StrLen(self)
    extras := toWidth - myLen
    if (extras <= 0) {
        return self
    }
    padding := zStr_Repeat(padding, extras)
    result := self padding
    return result
}

; Returns a string that's padded to the left, toWidth, using the given padding.
zStr_PadLeft(self, toWidth, padding := " ") {
    zz_checks.isString("self", self)
    zz_checks.isInt("toWidth", toWidth)
    zz_checks.isString("padding", padding)
    myLen := StrLen(self)
    extras := toWidth - myLen
    if (extras <= 0) {
        return self
    }
    padding := zStr_Repeat(padding, extras)
    result := padding self 
    return result
}

; Returns the positions of substring `what` in `this`.
zStr_IndexesOf(self, what, cs := false) {
    zz_checks.isString("self", self)
    zz_checks.isString("what", what)
    zz_checks.isBool("cs", cs)
    arr := []
    occur := 1
    last := ""
    Loop {
        if (last != "") {
            arr.Push(last)
        }
        last := gStr_IndexOf(self, what, cs, A_Index)
    } until last = 0
    return arr
}

; Returns the position of the first occurence of `what`.
zStr_IndexOf(self, what, caseSensitivity := False, pos := 1) {
    return InStr(self, what, caseSensitivity, pos)
}

; Returns a reversed string.
zStr_Reverse(self) {
    zz_checks.isString("self", self)
    str := ""
    Loop Parse self {
        str := A_LoopField str
    }

    return str
}

; Returns the last position of `what` in `self`.
zStr_LastIndexOf(self, what, cs := false, pos := 1) {
    zz_checks.isString("self", self)
    zz_checks.isString("what", what)
    zz_checks.isBool("cs", cs)
    zz_checks.isInt("pos", pos)
    cur := 0
    indexes := zStr_IndexesOf(self, what, pos)
    return indexes[indexes.Length]
}

zStr_Slice(self, start := 1, end := unset) {
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
zStr_SplitAt(self, pos) {
    zz_checks.isString("self", self)
    zz_checks.isInt("pos", pos)
    pos := zz_normIndex(pos, StrLen(self))
    first := zStr_Slice(self, pos - 1)
    last := zStr_Slice(self, pos + 1)
    return [first, last]
}

zStr_Len(self) {
    return StrLen(self)
}

; Returns from an array of numeric char codes.
zStr_OfCodes(wArray) {
    zz_checks.isArray("wArray", wArray)
    result := ""
    for i, x in wArray {
        result .= chr(x)
    }
    return result
}

; Returns a string from an array of strings.
zStr_OfChars(cArray) {
    zz_checks.isArray("cArray", cArray)
    result := ""
    for i, x in cArray {
        result .= x
    }
    return result
}

; True if `what` is in `self`
zStr_Has(self, what, caseSensitive := false, start := 1) {
    return zStr_IndexOf(self, what, caseSensitive, start) > 0
}

; Returns the character at position `pos`.
zStr_At(self, pos) {
    return SubStr(self, pos, 1)
}

