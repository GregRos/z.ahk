#include ../lib/91.zarr.ah2


class String_operators extends zTestSuite {
    zStrRepeat() {
        zExpect(zStrRepeat("x", 3)).toBe("xxx")
        zExpect(zStrRepeat("", 3)).toBe("")
        zExpect(zStrRepeat("a", 0)).toBe("")
        zExpect(zStrRepeat("a", 2, ",")).toBe("a,a")
    }

    zStrPadRight() {
        zExpect(zStrPadRight("a", 3)).toBe("a  ")
        zExpect(zStrPadRight("a", 0)).toBe("a")
        zExpect(zStrPadRight("a", 1)).toBe("a")
        zExpect(zStrPadRight("a", 3, 0)).toBe("a00")
    }

    zStrPadLeft() {
        zExpect(zStrPadLeft("a", 3)).toBe("  a")
        zExpect(zStrPadLeft("a", 0)).toBe("a")
        zExpect(zStrPadLeft("a", 1)).toBe("a")
        zExpect(zStrPadLeft("a", 3, 0)).toBe("00a")
    }

    zStrIndexOf() {
        zExpect(zStrIndexOf("aaa", "a")).toBe(1)
        zExpect(zStrIndexOf("aba", "b")).toBe(2)
        zExpect(zStrIndexOf("bbb", "a")).toBe(0)
        zExpect(zStrIndexOf("abb", "a", , 2)).toBe(0)
        zExpect(zStrIndexOf("aba", "a", , 3)).toBe(3)
        zExpect(zStrIndexOf("aba", "a", , 4)).toBe(0)
        zExpect(zStrIndexOf("aba", "a")).toBe(1)

        ; ADD NEGATIVE STARTING POS
    }

    zStrLastIndexOf() {
        zExpect(zStrLastIndexOf("aab", "b")).toBe(3)
        zExpect(zStrLastIndexOf("", "a")).toBe(0)
        zExpect(zStrLastIndexOf("zzz", "a")).toBe(0)
        zExpect(zStrLastIndexOf("aba", "a")).toBe(3)
    }

    zStrIndexesOf() {
        zExpect(zStrIndexesOf("aaa", "a")).toEqual([1, 2, 3])
        zExpect(zStrIndexesOf("aaa", "b")).toEqual([])
        zExpect(zStrIndexesOf("aba", "a")).toEqual([1, 3])
    }

    zStrReverse() {
        zExpect(zStrReverse("aab")).toBe("baa")
        zExpect(zStrReverse("")).toBe("")
        zExpect(zStrReverse(700)).toBe("007")
        
    }

    zStrSlice() {
        zExpect(zStrSlice("aab", 3)).toBe("b")
        zExpect(zStrSlice("aab", 4)).toBe("")
        zExpect(zStrSlice("aaa", 1)).toBe("aaa")
        zExpect(zStrSlice("aba", 1, 1)).toBe("")
        zExpect(zStrSlice("aba", 2, 3)).toBe("b")
        zExpect(zStrSlice("aaa", 1, 3)).toBe("aa")
        zExpect(zStrSlice("aaa", 1, 4)).toBe("aaa")
        zExpect(zStrSlice("aaa", 1, -1)).toBe("aa")
        zExpect(zStrSlice("abc", -2, -1)).toBe("b")
        zExpect(zStrSlice("abc", -3, 0)).toBe("abc")
        zExpect(zStrSlice("", 5, 10)).toBe("")
        zExpect(zStrSlice("abc", 5, 10)).toBe("")
    }

    zStrOfCodes() {
        zExpect(zStrOfCodes([Ord("a"), Ord("b")])).toBe("ab")
        zExpect(zStrOfCodes([])).toBe("")
    }

    zStrHas() {
        zExpect(zStrHas("a", "a")).toBeTrue()
        zExpect(zStrHas("abc", "bc")).toBeTrue()
        zExpect(zStrHas("hello", "a")).toBeFalse()
        
    }

}