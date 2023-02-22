#include ../library/40.zarr.ah2
#include ../library/23.ztest.api.ah2

my_empty := []
my_arr := [1, 2, 3]

class Array_operations extends zTestSuite {
    zArr() {
        super.isEqual(zArr(my_arr), my_arr)
        super.isEqual(zArr(), [])
    }

    zArrRange() {
        super.isEqual(zArrRange(0, 3), [0, 1, 2])
        super.isEqual(zArrRange(0, -2), [0, -1])
        super.isEqual(zArrRange(0, 5, 2), [0, 2, 4])
        super.isEqual(zArrRange(0, -2, -2), [0])
        super.isEqual(zArrRange(0, 0, 10), [])
        super.throws(() => zArrRange(0, 0, 0))
    }

    zArrFrom() {
        
    }

    zArrRepeat() {
        super.isEqual(zArrRepeat("a", 3), ["a", "a", "a"])
        super.isEqual(zArrRepeat("a", 0), [])
        super.throws(() => zArrRepeat("a", -1))
    }

    zArrFindIndex() {
        arr := [0, 5, 10]
        super.isEqual(zArrFindIndex(arr, x => x == 5), 2)
        super.isEqual(zArrFindIndex(arr, x => x == 100), 0)
        super.throws(() => zArrFindIndex(arr, "a"))
        ; With index:
        super.isEqual(zArrFindIndex(arr, (i, x) => i == 1 and x == 0), 1)
    }

    zArrIndexOf() {
        arr := [0, 5, 10]
        super.isEqual(zArrIndexOf(arr, 5), 2)
        super.isEqual(zArrIndexOf(arr, 0), 1)
        super.isEqual(zArrIndexOf(arr, 100), 0)
    }

    zArrHas() {
        arr := [0, 5, 10]
        super.isTrue(zArrHas(arr, 5))
        super.isFalse(zArrHas(arr, -1))
    }

    zArrFilter() {
        arr := [0, 5, 10]
        super.isEqual(zArrFilter(arr, x => x == 5), [5])
        super.isEqual(zArrFilter(arr, x => x == -1), [])
        super.isEqual(zArrFilter(arr, x => True), arr)
        super.isEqual(zArrFilter(arr, (i, x) => Mod(i, 2) == 0 and x == 5), [5])
    }

    zArrMap() {
        arr := [0, 5, 10]
        super.isEqual(zArrMap(arr, x => x + 1), [1, 6, 11])
        super.isEqual(zArrMap(arr, x => {}), [{}, {}, {}])
        super.isEqual(zArrMap(arr, (i, x) => x + i), [1, 7, 13])
    }

    zArrFind() {
        arr := [0, 5, 10]
        super.isEqual(zArrFind(arr, x => x == 5), 5)
        super.isEqual(zArrFind(arr, (i, x) => x == 5 and i == 2), 5)
        super.isEqual(zArrFind(arr, x => x == 11), "")
    }

    zArrExists() {
        arr := [0, 5, 10]
        super.isEqual(zArrExists(arr, x => x == 5), True)
        super.isEqual(zArrExists(arr, x => x == 1111), False)
        super.isEqual(zArrExistS(arr, (i, x) => i == 2 and x == 5), True)
    }

    zArrEvery() {
        arr := [0, 5, 10]
        super.isEqual(zArrEvery(arr, x => x == 5), False)
        super.isEqual(zArrEvery(arr, x => x < 11), True)
        super.isEqual(zArrEvery(arr, (i, x) => i < 4 and x < 11), True)
    }

    zArrFlatMap() {
        arr := [0, 5, 10]
        super.isEqual(
            zArrFlatMap(arr, x => [x, x]), 
            [0, 0, 5, 5, 10, 10]
        )
        super.isEqual(
            zArrFlatMap(arr, x => []),
            []
        )
        super.isEqual(
            zArrFlatMap(arr, (i, x) => [i, x]),
            [1, 0, 2, 5, 3, 10]
        )
        super.throws(() => zArrFlatMap(arr, "a"))
    }

    zArrReverse() {
        arr := [0, 5, 10]
        super.isEqual(zArrReverse(arr), [10, 5, 0])
        super.isEqual(zArrReverse([]), [])
    }

    zArrPrepend() {
        super.isEqual(zArrPrepend([0], 1, 2), [1, 2, 0])
        super.isEqual(zArrPrepend([0]), [0])
        super.isEqual(zArrPrepend([], 1), [1])
    }

    zArrSlice() {
        super.isEqual(zArrSlice([1, 2], 1, 2), [1])
        super.isEqual(zArrSlice([1, 2], -1, -1), [2])
        super.isEqual(zArrSlice([0], 1, 2), [0])
        super.isEqual(zArrSlice([0, 1], 1, 1), [])
        
        super.throws(() => zArrSlice([], 100, -1))
        super.throws(() => zArrSlice([0, 1, 2], 5, 7))
    }
}
