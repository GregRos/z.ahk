#include ../lib/0.index.ah2

class Find_operations extends zTestSuite {
    ; TODO: tests for enumerables
    zFind_array() {
        arr := [0, 5, 10]
        zExpect(zFind(arr, a => a == 5)).toBeKvp(2, 5)
        zExpect(zFind(arr, x => x == 100)).toBe("")
        zExpect(() => zFind(arr, "a")).toThrow()
        ; With index:
        zExpect(zFind(arr, (i, x) => i == 1 and x == 0).Key).toEqual(1)
    }

    zFind_string() {
        str := "abc"
        zExpect(zFind(str, x => x == "a")).toBeKvp(1, "a")
    }

    zFind_Map() {
        mp := Map("a", 1, "b", 2)
        zExpect(zFind(mp, x => x == 1)).toBeKvp("a", 1)
        zExpect(zFind(mp, (key, x) => x == 2 and key == "b")).toBeKvp("b", 2)
        zExpect(zFind(mp, x => False)).toBe("")
    }

    zKvpOf_array() {
        arr := [5, 5, 0, 10]
        zExpect(zKvpOf(arr, 5).Key).toEqual(1)
        zExpect(zKvpOf(arr, 0).Key).toEqual(3)
        zExpect(zKvpOf(arr, 100)).toBe("")
    }

    zKvpOf_map() {
        mp := Map("a", 2, "b", 2)
        zExpect(zKvpOf(mp, 2)).toBeKvp("a", 2)
        zExpect(zKvpOf(mp, 100)).toBe("")
    }

    zKvpOf_str() {
        str := "acc"
        zExpect(zKvpOf(str, "c")).toBeKvp(2, "c")
    }

    zFindLast_array() {
        arr := [1, 2, 3]
        zExpect(zFindLast(arr, x => x is Integer)).toBeKvp(3, 3)
        zExpect(zFindLasT(arr, x => x == 5)).toBe("")
    }

    zFindLast_map() {
        mp := Map("a", 2, "b", 2)
        zExpect(zFindLast(mp, x => x == 2)).toBeKvp("b", 2)

    }

    zLastKvpOf_array() {
        arr := [1, 2, 2]
        zExpect(zLastKvpOf(arr, 2)).toBeKvp(3, 2)
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