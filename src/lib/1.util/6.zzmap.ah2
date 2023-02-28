class zz_map {
    static keys(mp) {
        arr := []
        for key, val in mp {
            arr.Push(key)
        }
        return arr
    }

    static wrapJoinIteratee(dimension, f) {
        f := zz_func.getIsVariadic(f)
        ; Variadic functions don't need to be 
        if f {
            return f
        }
        
    }

}