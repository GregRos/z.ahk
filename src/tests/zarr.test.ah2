#include ../library/40.zarr.ah2
#include ../library/23.ztest.api.ah2

my_empty := []
my_arr := [1, 2, 3]

class Array_operations extends zTestSuite {
    zArr() {
        super.isEqual(zArr(my_arr), my_arr)
        super.isEqual(zArr(), [])
    }

    zArr_Range() {
        super.isEqual(zArr_Range(0, 3), [0, 1, 2])
        super.isEqual(zArr_Range(0, -2), [0, -1])
        super.isEqual(zArr_Range(0, 5, 2), [0, 2, 4])
        super.isEqual(zArr_Range(0, -2, -2), [0])
        super.isEqual(zArr_Range(0, 0, 10), [])
        super.throws(() => zArr_Range(0, 0, 0))
    }

    zArr_From() {
        
    }

    zArr_Repeat() {
        super.isEqual(zArr_Repeat("a", 3), ["a", "a", "a"])
        super.isEqual(zArr_Repeat("a", 0), [])
        super.throws(() => zArr_Repeat("a", -1))
    }

    zArr_FindIndex() {
        arr := [0, 5, 10]
        super.isEqual(zArr_FindIndex(arr, x => x == 5), 2)
        super.isEqual(zArr_FindIndex(arr, x => x == 100), 0)
        super.throws(() => zArr_FindIndex(arr, "a"))
        ; With index:
        super.isEqual(zArr_FindIndex(arr, (i, x) => i == 1 and x == 0), 1)
    }

    zArr_IndexOf() {
        arr := [0, 5, 10]
        super.isEqual(zArr_IndexOf(arr, 5), 2)
        super.isEqual(zArr_IndexOf(arr, 0), 1)
        super.isEqual(zArr_IndexOf(arr, 100), 0)
    }

    zArr_Has() {
        arr := [0, 5, 10]
        super.isTrue(zArr_Has(arr, 5))
        super.isFalse(zArr_Has(arr, -1))
    }

    zArr_Filter() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Filter(arr, x => x == 5), [5])
        super.isEqual(zArr_Filter(arr, x => x == -1), [])
        super.isEqual(zArr_Filter(arr, x => True), arr)
        super.isEqual(zArr_Filter(arr, (i, x) => Mod(i, 2) == 0 and x == 5), [5])
    }

    zArr_Map() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Map(arr, x => x + 1), [1, 6, 11])
        super.isEqual(zArr_Map(arr, x => {}), [{}, {}, {}])
        super.isEqual(zArr_Map(arr, (i, x) => x + i), [1, 7, 13])
    }

    zArr_Find() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Find(arr, x => x == 5), 5)
        super.isEqual(zArr_Find(arr, (i, x) => x == 5 and i == 2), 5)
        super.isEqual(zArr_Find(arr, x => x == 11), "")
    }

    zArr_Exists() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Exists(arr, x => x == 5), True)
        super.isEqual(zArr_Exists(arr, x => x == 1111), False)
        super.isEqual(zArr_ExistS(arr, (i, x) => i == 2 and x == 5), True)
    }

    zArr_Every() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Every(arr, x => x == 5), False)
        super.isEqual(zArr_Every(arr, x => x < 11), True)
        super.isEqual(zArr_Every(arr, (i, x) => i < 4 and x < 11), True)
    }

    zArr_FlatMap() {
        arr := [0, 5, 10]
        super.isEqual(
            zArr_FlatMap(arr, x => [x, x]), 
            [0, 0, 5, 5, 10, 10]
        )
        super.isEqual(
            zArr_FlatMap(arr, x => []),
            []
        )
        super.isEqual(
            zArr_FlatMap(arr, (i, x) => [i, x]),
            [1, 0, 2, 5, 3, 10]
        )
        super.throws(() => zArr_FlatMap(arr, "a"))
    }

    zArr_Reverse() {
        arr := [0, 5, 10]
        super.isEqual(zArr_Reverse(arr), [10, 5, 0])
        super.isEqual(zArr_Reverse([]), [])
    }

    zArr_Prepend() {
        super.isEqual(zArr_Prepend([0], 1, 2), [1, 2, 0])
        super.isEqual(zArr_Prepend([0]), [0])
        super.isEqual(zArr_Prepend([], 1), [1])
    }

    zArr_Slice() {
        super.isEqual(zArr_Slice([1, 2], 1, 2), [1])
        super.isEqual(zArr_Slice([1, 2], -1, -1), [2])
        super.isEqual(zArr_Slice([0], 1, 2), [0])
        super.isEqual(zArr_Slice([0, 1], 1, 1), [])
        
        super.throws(() => zArr_Slice([], 100, -1))
        super.throws(() => zArr_Slice([0, 1, 2], 5, 7))
    }
}
