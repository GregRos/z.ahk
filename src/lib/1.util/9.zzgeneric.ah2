class zz_gen {
    static contains(container, item) {
        

        if not IsObject(container) {
            return !!InStr(container, item)
        }
        
        if container is Array {
            return zz_arr.has(container, item)
        } else if container is Map {
            return container.Has(item)
        } else if container.HasMethod("IndexOf") {
            return !!container.IndexOf(item)
        }

    }
}