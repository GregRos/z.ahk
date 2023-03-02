class zChain {
    __New(segments, implicitCall := False) {
        this._segments := StrSplit(segments, ".")
        this._implicitCall := implicitCall
    }

    Call(target) {
        cur := target
        for segment in this._segments {
            prev := cur
            cur := cur.%segment%
            if zz_func.isCallable(cur, 1){
                cur := cur.Call(prev)
            }
        }

        return cur
    }
}

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

    static hasName(obj, name) {
        return ObjHasMethod(obj, name) or ObjHasProp(obj, name)
    }

    static hasIndexer(obj, arity?) {
        if not HasProp(obj, "__Item") {
            return False
        }
        indexer := obj.__Enum
        return zz_func.isCallable(indexer, arity?)
    }

    static isArrayLike(obj) {
        return HasProp(obj, "Length") and zz_obj.isEnum(obj, 1) and this.hasIndexer(obj, 1)
    }

    static isEnum(obj, arity?) {
        if zz_func.isCallable(obj, arity?) {
            return True
        }
        if not IsSet(arity) {
            return True
        }
        try {
            iterator := obj.__Enum(arity)
            return zz_func.isCallable(iterator, arity)
        } catch Error as e {
            return False
        }
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

    static toShortStr(self) {
        if IsObject(self) {
            if self.HasMethod("ToString") or self.HasProp("ToString") {
                return self.ToString()
            }
            return Type(self)
        } else {
            return String(self)
        }
    }

    static equal(a, b, caseMode := False) {
        if not (IsObject(a) and IsObject(b)) {
            return caseMode ? a == b : a = b
        }
        protoA := a.Base
        protoB := b.Base
        if protoA != protoB {
            return False
        }
        if protoA = Array.Prototype {
            if a.Length != b.Length {
                return False
            }

            loop a.Length {
                if not b.Has(A_Index) or not a.Has(A_Index) {
                    return a.Has(A_Index) == b.Has(A_Index)
                }
                if not zz_obj.equal(a[A_Index], b[A_Index]) {
                    return False
                }
            }
            return True
        }
        if ObjOwnPropCount(a) != ObjOwnPropCount(b) {
            return False
        }
        for key, value in ObjOwnProps(a) {
            if not b.HasProp(key) or not zz_obj.equal(a.%key%, b.%key%, caseMode) {
                return False
            }
        }
        return True
    }

}