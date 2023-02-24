#include ../lib/40.zarr.ah2


class String_operators extends zTestSuite {
    zStrRepeat() {
        this.expect(zStrRepeat("x", 3)).toEqual("xxx")
        this.expect(zStrRepeat("", 3)).toEqual("")
        this.expect(zStrRepeat("a", 0)).toEqual("")
        this.expect(zStrRepeat("a", 2, ",")).toEqual("a,a")
    }

    zStrPadRight() {
        this.expect(zStrPadRight("a", 3)).toEqual("a  ")
        this.expect(zStrPadRight("a", 0)).toEqual("a")
        this.expect(zStrPadRight("a", 1)).toEqual("a")
        this.expect(zStrPadRight("a", 3, 0)).toEqual("a00")
    }

    zStrPadLeft() {
        this.expect(zStrPadLeft("a", 3)).toEqual("  a")
        this.expect(zStrPadLeft("a", 0)).toEqual("a")
        this.expect(zStrPadLeft("a", 1)).toEqual("a")
        this.expect(zStrPadLeft("a", 3, 0)).toEqual("00a")
    }

    zStrIndexOf() {
        this.expect(zStrIndexOf("aaa", "a")).toEqual(1)
        this.expect(zStrIndexOf("aba", "b")).toEqual(2)
        this.expect(zStrIndexOf("bbb", "a")).toEqual(0)
        this.expect(zStrIndexOf("abb", "a", , 2)).toEqual(0)
        this.expect(zStrIndexOf("aba", "a" , ,3)).toEqual(3)
        this.expect(zStrIndexOf("aba", "a", , 4)).toEqual(0)
        ; ADD NEGATIVE STARTING POS
        
    }

    zStrIndexesOf() {
        this.expect(zStrIndexesOf("aaa", "a")).toEqual([1, 2, 3])
        this.expect(zStrIndexesOf("aaa", "b")).toEqual([])
        this.expect(zStrIndexesOf("aba", "a")).toEqual([1, 3])
        ; ADD NEGATIVE STARTING POS
    }

}