#include ../library/40.zarr.ah2
#include ../library/23.ztest.api.ah2


class String_operators extends zTestSuite {
    zStrRepeat() {
        this.isEqual(zStrRepeat("x", 3), "xxx")
        this.isEqual(zStrRepeat("", 3), "")
        this.isEqual(zStrRepeat("a", 0), "")
        this.isEqual(zStrRepeat("a", 2, ","), "a,a")
    }

    zStrPadRight() {
        this.isEqual(zStrPadRight("a", 3), "a  ")
        this.isEqual(zStrPadRight("a", 0), "a")
        this.isEqual(zStrPadRight("a", 1), "a")
        this.isEqual(zStrPadRight("a", 3, 0), "a00")
    }

    zStrPadLeft() {
        this.isEqual(zStrPadLeft("a", 3), "  a")
        this.isEqual(zStrPadLeft("a", 0), "a")
        this.isEqual(zStrPadLeft("a", 1), "a")
        this.isEqual(zStrPadLeft("a", 3, 0), "00a")
    }

    zStrIndexOf() {
        this.isEqual(zStrIndexOf("aaa", "a"), 1)
        this.isEqual(zStrIndexOf("aba", "b"), 2)
        this.isEqual(zStrIndexOf("bbb", "a"), 0)
        this.isEqual(zStrIndexOf("abb", "a", , 2), 0)
        this.isEqual(zStrIndexOf("aba", "a" , ,3), 3)
        this.isEqual(zStrIndexOf("aba", "a", , 4), 0)
        ; ADD NEGATIVE STARTING POS
        
    }

    zStrIndexesOf() {
        this.isEqual(zStrIndexesOf("aaa", "a"), [1, 2, 3])
        this.isEqual(zStrIndexesOf("aaa", "b"), [])
        this.isEqual(zStrIndexesOf("aba", "a"), [1, 3])
        ; ADD NEGATIVE STARTING POS
    }

}