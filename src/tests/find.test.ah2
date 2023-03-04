
class Find_operations extends zTestSuite {

    zFind_array() {
        arr := [0, 5, 10]
        zExpect(zFind(arr, a => a == 5)).toEqual(zz_Kvp(2, 5))
        zExpect(zFind(arr, x => x == 100)).toBe("")
        zExpect(() => zFind(arr, "a")).toThrow()
        ; With index:
        zExpect(zFind(arr, (i, x) => i == 1 and x == 0).Key).toEqual(1)
    }

    zFind_string() {
        str := "abc"
        zExpect(zFind(str, x => x == "a")).toEqual(zz_Kvp(1, "a"))
    }

    zFind_Map() {
        mp := Map("a", 1, "b", 2)
        zExpect(zFind(mp, x => x == 1)).toEqual(zz_Kvp("a", 1))
        zExpect(zFind(mp, (key, x) => x == 2 and key == "b")).toEqual(zz_Kvp("b", 2))
    }

    zKvpOf() {
        arr := [0, 5, 10]
        zExpect(zKvpOf(arr, 5).Key).toEqual(2)
        zExpect(zKvpOf(arr, 0).Key).toEqual(1)
        zExpect(zKvpOf(arr, 100)).toBe("")

    }

}
