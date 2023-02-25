#include ../lib/40.zarr.ah2


class String_operators extends zTestSuite {
    zStrRepeat() {
        zExpect(zStrRepeat("x", 3)).toEqual("xxx")
        zExpect(zStrRepeat("", 3)).toEqual("")
        zExpect(zStrRepeat("a", 0)).toEqual("")
        zExpect(zStrRepeat("a", 2, ",")).toEqual("a,a")
    }

    zStrPadRight() {
        zExpect(zStrPadRight("a", 3)).toEqual("a  ")
        zExpect(zStrPadRight("a", 0)).toEqual("a")
        zExpect(zStrPadRight("a", 1)).toEqual("a")
        zExpect(zStrPadRight("a", 3, 0)).toEqual("a00")
    }

    zStrPadLeft() {
        zExpect(zStrPadLeft("a", 3)).toEqual("  a")
        zExpect(zStrPadLeft("a", 0)).toEqual("a")
        zExpect(zStrPadLeft("a", 1)).toEqual("a")
        zExpect(zStrPadLeft("a", 3, 0)).toEqual("00a")
    }

    zStrIndexOf() {
        zExpect(zStrIndexOf("aaa", "a")).toEqual(1)
        zExpect(zStrIndexOf("aba", "b")).toEqual(2)
        zExpect(zStrIndexOf("bbb", "a")).toEqual(0)
        zExpect(zStrIndexOf("abb", "a", , 2)).toEqual(0)
        zExpect(zStrIndexOf("aba", "a", , 3)).toEqual(3)
        zExpect(zStrIndexOf("aba", "a", , 4)).toEqual(0)
        zExpect(zStrIndexOf("aba", "a")).toEqual(0)

        ; ADD NEGATIVE STARTING POS

    }

    zStrIndexesOf() {
        zExpect(zStrIndexesOf("aaa", "a")).toEqual([1, 2, 3])
        zExpect(zStrIndexesOf("aaa", "b")).toEqual([])
        zExpect(zStrIndexesOf("aba", "a")).toEqual([1, 3])
    }

}