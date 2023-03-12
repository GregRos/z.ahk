zz_setFlag(input, flag, value) {
    if value {
        return StrReplace(input, flag, "")
    } else {
        return input flag
    }
}

class zRegEx {

    /**
     * Creates a new regex object.
     * @param pattern The regex pattern to use. May include flags embedded in the beginning, like `i)pattern`.
     * @param moreFlags Any additional flags to use.
     * @example
     * ; Regex that matches a number:
     * zRegEx("[0-9]+") ; "123abc" => "123"
     * ; Regex that matches a word, case-insensitive, using embedded flags:
     * zRegEx("i)hello") ; "HELLO world" => "HELLO"
     * ; Regex that matches a word, case-insensitive using flags parameter:
     * zRegEx("hello", "i") ; "HELLO world" => "HELLO"
     */
    __New(pattern, moreFlags := "") {
        zExpectArg(pattern, "pattern").toBeStringLike()
        zExpectArg(moreFlags, "moreFlags").toBeStringLike()
        flags := moreFlags
        split := StrSplit(pattern, ")", , 2)
        if split.Length = 2 and not InStr(pattern, "(") {
            flags .= split[1]
            pattern := split[2]
        }
        this.Pattern := pattern
        this.Flags := flags
    }

    /**
     * Returns a new regex with the given flags set or unset.
     * @param flags The flags to set. A string of characters.
     * @param value Whether to set or unset the flags.
     * @returns A new `zRegEx` object with the flags set or unset.
     * @example
     * regex := zRegEx("hello")
     * ; Set the "i" flag:
     * newRegex := regex.SetFlags("i")
     * ; Set the "g" flag:
     * newRegex := regex.SetFlags("g")
     * ; Set the "i" and "g" flags:
     * newRegex := regex.SetFlags("ig")
     */
    SetFlags(flags, value := True) {
        zExpectArg(flags, "flag").toBeStringLike()
        zExpectArg(value, "value").toBeBool()
        flags := this.Flags
        for flag in StrSplit(flags) {
            flags := zz_setFlag(flags, flag, value)
        }
        return zRegEx(this.Pattern, flags)
    }

    /**
     * Returns the first match of this regex in the input string, as a MatchObject.
     * @param input The string to search.
     * @param start The index to start searching from.
     * @returns {MatchObject} A match object, or `""` if no match was found.
     * @example
     * ; Match a number:
     * zRegEx("([0-9]+)").First("123abc").Match[1] ; => "123"
     * ; First two numbers separated by a comma:
     * zRegEx("([0-9]+),([0-9]+)").First("123,456").Match[2] ; => "456"
     */
    First(input, start := 1) {
        zExpectArg(input, "input").toBeStringLike()
        zExpectArg(start, "start").toBeNumberLike()
        input := String(input)
        start := Number(start)
        for x in this.Enumerate(input, start) {
            return x
        }
        return ""
    }

    /**
     * Splits a string into an array of substrings, using this regex as a delimiter. Any capture groups are included in the result.
     * @param input The string to split.
     * @param count Maximum number of splits to perform. Defaults to -1, which means all matches.
     * @example
     * ; Split a string into an array of words:
     * zRegEx("\s+").Split("hello world") ; => ["hello", "world"]
     * ; Split a string into an array of words, including the spaces:
     * zRegEx("(\s+)").Split("hello world") ; => ["hello", " ", "world"]
     * ; Split a string into an array of words, including the spaces, but only the first two:
     * zRegEx("(\s+)").Split("hello world", 2) ; => ["hello", " "]
     */
    Split(input, count := -1) {
        zExpectArg(input, "input").toBeStringLike()
        zExpectArg(count, "count").toBeNumberLike()
        input := String(input)
        count := Number(count)
        result := []
        start := 1
        for match in this.Enumerate(input) {
            if A_Index = count {
                break
            }
            result.Push(zz_str.slice(input, start, match.Pos - 1))
            start := match.Pos + match.Len + 1
            loop match.Count {
                result.Push(match.Match[A_Index])
            }
        }
        result.Push(zz_str.slice(input, start))
        return result
    }

    /**
     * Returns a string with all matches of this regex replaced with a replacement string or function.
     * @param input The string to search.
     * @param replacer A string to replace matches with, or a replacement function that takes a `MatchObject` and returns a `string`.
     * @param start The index to start searching from.
     * @param count The number of matches to replace. Defaults to -1, which means all matches.
     * @example
     * ; Replace all numbers with "X":
     * zRegEx("([0-9]+)").Replace("123abc", "X") ; => "Xabc"
     * ; Replace all numbers with "X", but only the first two:
     * zRegEx("([0-9]+)").Replace("123 456 789 abc", "X", 1, 2) ; => "X X 789 abc"
     * ; Replace words beginning with "h" with uppercase:
     * zRegEx("(h[a-z]+)", "i").Replace("hello world", StrUpper) ; => "HELLO world"
     */
    Replace(input, replacer, start := 1, count := -1) {
        result := ""
        replacer := zIsCallable(replacer) ? replacer : zConst(replacer)

        for match in this.Enumerate(input, start) {
            if count = 0 {
                break
            }
            if not count == -1 {
                count -= 1
            }
            replaced := replacer(match)
            result .= zz_str.slice(input, start, match.Pos - 1) replaced
            start := match.Pos + match.Len + 1
        }
        return result
    }

    /**
     * Returns an object that enumerates all the matches of this regex in the input string.
     * @param input The string to search.
     * @param start The index to start searching from.
     * @returns {Enum(MatchObject)}
     * @example
     * ; Match and output all numbers in a string:
     * regex := zRegEx("([0-9]+)")
     * for match in regex.Enumerate("123abc456") {
     *    zOut(match.Match[]) ; => "123", "456"
     * }
     */
    Enumerate(input, start := 1) {
        __Enum(n) {
            current := start
            pattern := this.Pattern
            flags := this.Flags
            EnumerateMatches(args*) {
                found := RegExMatch(input, this.Flags ")" this.Pattern, &out, current)
                if not found {
                    return False
                }
                %args[-1]% := out
                current := found + 1
                return True
            }
            return EnumerateMatches
        }
        return {
            __Enum: __Enum
        }
    }
}