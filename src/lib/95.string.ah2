#include ./92.fold.ah2
#include ./94.project.ah2
#include ./1.util/0.index.ah2
#include ./4.assert/0.index.ah2
zz_buildPaddingString(withWhat, needed) {
    appearances := Ceil(needed / zLength(withWhat))
    what := ""
    loop appearances {
        nextLength := zLength(what) + zLength(withWhat)
        if neededLength > needed {
            what += zSlice(withWhat, 1, neededLength)
            break
        }
        what += withWhat
    }
    return what
}

/**
 * Pads a string with appearances of another string on the right
 * @param what The string to pad.
 * @param howMany The number of characters to pad to.
 * @param withWhat The string to pad with. Defaults to a space. Will truncate the string if needed to reach the length.
 */
zPadRight(what, howMany, withWhat := " ") {
    return what zz_buildPaddingString(withWhat, howMany - zLength(what))
}

/**
 * Pads a string with appearances of another string on the left
 * @param what The string to pad.
 * @param howMany The number of characters to pad to.
 * @param withWhat The string to pad with. Defaults to a space. Will truncate the string if needed to reach the length.
 */
zPadLeft(what, howMany, withWhat := " ") {
    return zz_buildPaddingString(withWhat, howMany - zLength(what)) what
}


zz_escapeSeqMap := Map(
    "``", "````",
    "`n", "``n",
    "`r", "``r",
    "`t", "``t", `
    "`b", "``b",
    "`v", "``v",
    "`f", "``f",
    "`'", "``'",
    "`"", "``",
)

zz_unescapeSeqMap := zInvert(zz_escapeSeqMap)
zz_unescapeSeqMap["`;"] := ";"
zz_unescapeSeqMap["`:"] := ":"
zz_unescapeSeqMap["`{"] := "{"
zz_unescapeSeqMap["``s"] := " "

/**
 * Returns a string escaped using AHK's escape sequences.
 * @param input The string to escape.
 * @see https://www.autohotkey.com/docs/v2/misc/EscapeChar.htm
 * @example
 * zEscape("Hello`nWorld") ; => "Hello`nWorld"
 * zEscape("Spaces are not escaped") ; => "Spaces are not escaped"
 * zEscape(":;{") ; => ":;{" Some conditional sequences are not escaped.
 * zEscape("````") ; => "````"
 */
zEscape(input) {
    for k, v in zz_escapeSeqMap {
        input := StrReplace(input, k, v)
    }
    return input
}

/**
 * Returns a string unescaped using AHK's escape sequences.
 * @param input The string to unescape.
 * @see https://www.autohotkey.com/docs/v2/misc/EscapeChar.htm
 * @example
 * zUnescape("Hello``nWorld") ; => "Hello`nWorld"
 * zUnescape("`:`;``s") ; => ":; " zUnescape supports more sequences than zEscape.
 */
zUnescape(input) {
    for k, v in zz_unescapeSeqMap {
        input := StrReplace(input, k, v)
    }
    return input
}