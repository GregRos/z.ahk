class zz_str {

    static padEnd(self, toWidth, padding := " ") {
        myLen := StrLen(self)
        extras := toWidth - myLen
        if (extras <= 0) {
            return self
        }
        padding := zz_str.repeat(padding, extras)
        result := self padding
        return result
    }
    static regexReplaceEach(haystack, needleObject) {
        kvpIter := needleObject.HasProp("__Enum") ? needleObject.__Enum() : ObjOwnProps(needleObject)
        for key, value in kvpIter {
            haystack := RegExReplace(haystack, key, value)
        }
        return haystack
    }
    static hasAny(haystack, needles*) {
        for needle in needles {
            if InStr(haystack, needle) {
                return True
            }
        }
        return False
    }

    static startsWith(haystack, needle, caseSense := False) {
        subhaystack := SubStr(haystack, StrLen(needle))
        if caseSense {
            return subhaystack == needle
        } else {
            return subhaystack = needle
        }
    }
    static trimEach(arr) {
        newArr := []
        for x in arr {
            x := Trim(x)
            if not x {
                continue
            }
            newArr.Push(x)
        }
        return newArr
    }

    static repeat(self, count, delim := "") {
        result := ""
        Loop count {
            if (A_Index != 1) {
                result .= delim
            }
            result .= self
        }
        return result
    }

    static split(haystack, needle, matchAction := False, startingPos := 1, omitEmpty := False) {
        results := []
        oldMatchEnd := startingPos
        matches := zz_str.matchAll(haystack, needle, startingPos)
        inspector := zz_Inspect()
        for match in matches {
            matchStart := match.Pos
            slice := SubStr(haystack, oldMatchEnd, matchStart - oldMatchEnd)
            if slice != "" {
                results.Push(slice)
            }
            if inspector.next(matchAction).isCallable() {
                result := matchAction(match)
            } else if IsObject(matchAction) {
                zz_throw.badParam("matchAction", "a value or a callable object", matchAction)
            } else if matchAction {
                result := match[matchAction]
            }
            if IsSet(result) {
                if not omitEmpty or result != "" {
                    results.Push(result)
                }
            }
            oldMatchEnd := matchStart + match.Len
        }
        results.Push(SubStr(haystack, oldMatchEnd))

        return results
    }

    static matchAll(haystack, needle, startingPos := 1) {
        pos := startingPos
        matches := []
        while (pos := RegExMatch(haystack, needle, &match, pos)) {
            matches.Push(match)
            pos += Max(1, match.Len)
        }
        return matches
    }

    static join(arr, delim := "") {
        result := ""
        for x in arr {
            if A_Index != 1 {
                result .= delim
            }
            result .= String(x)
        }
        return result
    }

    static splice(self, position, strs*) {
        before := SubStr(self, 1, position)
        after := SubStr(self, position + 1)
        return before this.join(strs, "") after
    }

    static slice(self, start := 1, end := 0) {
        end := end == 0 ? StrLen(self) : end
        end := zz_normIndex(end, StrLen(self))
        start := zz_normIndex(start, StrLen(self))
        zExpectArg(end, "end").toBeAtLeast(start)

        return SubStr(self, start, end - start + 1)
    }

    static snip(self, position, radius := 10) {
        position := zz_normIndex(position, StrLen(self))
        extraFromRight := position + radius - StrLen(self)
        extraFromLeft := 1 - (position - radius)
        start := Max(1, position - radius - Max(extraFromRight, 0))
        end := Min(StrLen(self), position + radius) + Max(extraFromLeft, 0)
        slice := this.slice(self, start, end)
        if start != 1 {
            slice := "…" slice
        }
        if end != StrLen(self) {
            slice := slice "…"
        }
        return slice
    }

}