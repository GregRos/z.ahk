#include ../lib/0.index.ah2

class Find_operations extends zTestSuite {
    ; TODO: tests for enumerables
    zFind_array() {
        arr := [0, 5, 10]
        zExpect(zFirst(arr, a => a == 5)).toBeKvp(2, 5)
        zExpect(zFirst(arr, x => x == 100)).toBe("")
        zExpect(() => zFirst(arr, "a")).toThrow()
        ; With index:
        zExpect(zFirst(arr, (i, x) => i == 1 and x == 0).Key).toEqual(1)
    }

    zFind_Map() {
        mp := Map("a", 1, "b", 2)
        zExpect(zFirst(mp, x => x == 1)).toBeKvp("a", 1)
        zExpect(zFirst(mp, (key, x) => x == 2 and key == "b")).toBeKvp("b", 2)
        zExpect(zFirst(mp, x => False)).toBe("")
    }



    zLast_array() {
        arr := [1, 2, 3]
        zExpect(zLast(arr, x => x is Integer)).toBeKvp(3, 3)
        zExpect(zLast(arr, x => x == 5)).toBe("")
    }

    zLast_map() {
        mp := Map("a", 2, "b", 2)
        zExpect(zLast(mp, x => x == 2)).toBeKvp("b", 2)

    }


    zAt_array() {
        arr := [1, 2, 3]
        zExpect(zAt(arr, 2)).toBe(2)
        zExpect(zAt(arr, 3)).toBe(3)
        zExpect(() => zAt(arr, 4)).toThrow()
    }

    zAt_map() {
        mp := Map("a", 1, "b", 2)
        zExpect(zAt(mp, "a")).toBe(1)
        zExpect(zat(mp, "b")).toBe(2)
    }

    zAt_str() {
        str := "abc"
        zExpect(zAt(str, 1)).toBe("a")
    }

}