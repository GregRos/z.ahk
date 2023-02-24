zz_normIndex(index, len) {
    if index <= 0 {
        return len + index + 1
    }
    return index
}

class zz_arr {
    static mergeSort(arr, work, comparer) {
        ; Merge sort because it's a stable sort
        merge(arr, begin, middle, end, work) {
            count := end - begin
            begin2 := begin
            end2 := middle
            Loop count {
                ix := A_Index + begin - 1
                if ix >= end {
                    break
                }
                if begin2 < middle and (end2 >= end or comparer(arr[begin2], arr[end2]) <= 0) {
                    work[ix] := arr[begin2]
                    begin2++
                } else {
                    work[ix] := arr[end2]
                    end2++
                }
            }
        }

        splitMerge(work, begin, end, arr) {
            if (end - begin <= 1) {
                ; One-item run7
                return
            }

            middle := Integer((end + begin) / 2)
            splitMerge(arr, begin, middle, work)
            splitMerge(arr, middle, end, work)
            merge(work, begin, middle, end, arr)
        }

        splitMerge(work, 1, arr.Length + 1, arr)
    }

    static take(arr, start := 1, count := -1) {
        newArr := []
        start := zz_normIndex(start, arr.Length)
        count := count == -1 ? arr.Length - start + 1 : count
        loop count {
            curIndex := start + A_Index - 1
            if curIndex > arr.Length {
                return newArr
            }
            newArr.Push(arr[curIndex])
        }

        return newArr
    }

    static slice(arr, start := 1, end := -1) {
        start := zz_normIndex(start, arr.Length)
        end := zz_normIndex(end, arr.Length + 1)
        count := end - start
        return this.take(arr, start, count)
    }

    static findIndex(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        for i, x in self {
            if predicate(i, x) {
                return i
            }
        }
        return 0
    }

    static first(self, predicate?) {
        if not IsSet(predicate) {
            return self[1]
        }
        ix := this.findIndex(self, predicate)
        return self[ix]
    }

    static findLastIndex(self, predicate) {
        predicate := zz_func.wrapIteratee(predicate)
        found := 0
        for i, x in self {
            if predicate(i, x) {
                found := i
            }
        }
        return found
    }

    static filter(self, predicate) {
        newArr := []
        predicate := zz_func.wrapIteratee(predicate)
        for index, item in self {
            if predicate(index, item) {
                newArr.Push(item)
            }
        }
        return newArr
    }


    static hasUnsetItems(arr) {
        lastIndex := 0
        for index, item in arr {
            if index != lastIndex + 1 {
                return True
            }
            lastIndex := index
        }
        return False
    }

    static repeat(value, count) {
        arr := []
        loop count {
            arr.Push(value)
        }
        return arr
    }

    static has(arr, item, caseMode := False) {
        for x in arr {
            if item == x {
                return True
            } else if not caseMode and item = x {
                return True
            }
        }
        return False
    }

    static map(self, projection) {
        projection := zz_func.wrapIteratee(projection)
        newArr := []
        for index, item in self {
            newArr.Push(projection(index, item))
        }
        return newArr
    }


    static hasAny(arr, options*) {
        return zz_arr.has(options, arr, False)
    }

    static reverse(self) {
        newArr := []
        Loop self.Length {
            newArr.Push(self[self.Length - A_Index + 1])
        }
        return newArr
    }
}

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
        subhaystack := SubStr(haystack, StrLen(needle.Count))
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
        for match in matches {
            matchStart := match.Pos
            slice := SubStr(haystack, oldMatchEnd, matchStart - oldMatchEnd)
            if slice {
                results.Push(slice)
            }
            if zz_func.isCallable(matchAction) {
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
        for i, x in arr {
            if i != 1 {
                result .= delim
            }
            result .= x
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