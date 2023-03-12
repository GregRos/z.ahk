

class zz_obj {
    static assign(self, sources*) {
        for i, source in sources {
            for k, v in source.OwnProps() {
                if self.HasProp(k) {
                    self[k] := v
                } else {
                    self.DefineProp(k, {
                        value: v
                    })
                }

            }
        }
        return self
    }

    static toMap(obj) {
        if not obj {
            return {}
        }
        if obj is Map {
            return obj
        }
        objMap := Map()
        objMap.CaseSense := False
        for key in ObjOwnProps(obj) {
            objMap[key] := obj.%key%
        }
        return objMap
    }

    static defaults(target, sources*) {
        if not target {
            target := {}
        } else if not IsObject(target) {
            zz_throw.badParam("target", "an object", target)
        }
        for source in sources {
            for k in ObjOwnProps(source) {
                v := source.%k%
                if not HasProp(target, k) {
                    target.DefineProp(k, {
                        value: v
                    })
                }
            }
        }
        return target
    }


    static equal(a, b, caseSense := False, coerce := False) {
        if not (IsObject(a) and IsObject(b)) {
            if not coerce and Type(a) != Type(b) {
                return False
            }
            return caseSense ? a == b : a = b
        }
        protoA := a.Base
        protoB := b.Base
        if protoA != protoB {
            return False
        }
        if a is Array {
            if a.Length != b.Length {
                return False
            }

            loop a.Length {
                if not b.HasProp(A_Index) or not a.HasProp(A_Index) {
                    return a.HasProp(A_Index) == b.HasProp(A_Index)
                }
                if not zz_obj.equal(a[A_Index], b[A_Index], caseSense, coerce) {
                    return False
                }
            }
            return True
        }
        if a is Map {
            if a.Count != b.Count {
                return False
            }

            for key, value in a {
                if not zz_obj.equal(value, b[key], caseSense, coerce) {
                    return False
                }
            }
            return True
        }
        if ObjOwnPropCount(a) != ObjOwnPropCount(b) {
            return False
        }
        for key, value in ObjOwnProps(a) {
            if not b.HasProp(key) or not zz_obj.equal(a.%key%, b.%key%, caseSense, coerce) {
                return False
            }
        }
        return True
    }

}