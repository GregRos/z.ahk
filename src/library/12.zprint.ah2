#include 07.ztemplate.ah2
#include 09.zset.ah2
#include 08.zwriter.ah2
zz_print(formatter, writer := zTextWriter()) {
    stack := zSet()
    writer := zTextWriter("debug")
    static tryScalar(v, writer) {
        if not IsSet(v) {
            writer.Write "[!kw]unset[!]"
            return True
        }
        if IsObject(v) {
            return False
        }
        if IsInteger(v) {
            writer.Write Format("[!int]{1}[!]", v)
        } else if IsFloat(v) {
            writer.Write Format("[!float]{1}[!]", v)
        } else {
            writer.Write Format('[!string]"{1}"[!]', v)
        }
        return True
    }

    static tryLeafType(v, writer) {
        ; Current state of writer - after 
        static tmpltGui := zTemplate("[!type]Gui '{title}' (0x{hwnd:x})[!]")
        static tmpltGuiControl := zTemplate("[!type]GuiControl '{name}' (0x{hwnd:x})[!]")
        static tmpltBuffer := zTemplate("[!type]Buffer 0x{ptr:x}, Length={size}[!]")
        static tmpltClass := zTemplate("[!type]Class '{name}'[!]")
        static tmpltMenu := zTemplate("[!type]Menu 0x{handle:x}[!]")
        static tmpltMenuBar := zTemplate("[!type]MenuBar 0x{handle:x}[!]")
        static tmpltRegExMatchInfo := zTemplate("[!type]RegExMatch [{count}][!]")
        static tmpltFile := zTemplate("[!type]File 0x{Handle:x}[!]")
        static tmpltInputHook := zTemplate("[!type]InputHook[!]")
        static tmpltEmptyObject := zTemplate("[!object]{}[!]")
        static tmpltEmptyArray := zTemplate("[!array][][!]")
        static tmpltEmptyMap := zTemplate("[!object]Map {}[!]")
        static tmpltProperty := zTemplate("[!property]{1}[!] = ")
        static proto := zTemplate("|[!type]{1}[!]|")

        if v is VarRef
            or v is Func
            or v is BoundFunc
            or v is Closure
            or v is Enumerator {
            writer.Write Format("[!type]{1}[!]", Type(v))
            return True
        }
        else if v is Gui {
            writer.Write tmpltGui(v)
        } else if v is Gui.Control {
            writer.Write(tmpltGuiControl(v))
        } else if v is Buffer {
            writer.Write(tmpltBuffer(v))
        } else if v is Class {
            writer.Write(tmpltClass(v))
        } else if v is RegExMatchInfo {
            writer.Write(tmpltRegExMatchInfo(v))
        } else if v is Menu {
            writer.Write(tmpltMenu(v))
        } else if v is MenuBar {
            writer.Write(tmpltMenuBar(v))
        } else if v is InputHook {
            writer.Write(tmpltInputHook(v))
        } else if v is File {
            writer.Write(tmpltFile(v))
        } else {
            return False
        }
        return True
    }

    static printShort(v, writer) {
        if tryScalar(v, writer) {
            return
        }
        if tryLeafType(v, writer) {
            return
        }
        writer.Write(proto(Type(v)))
        return True
    }

    static getPropValueOrError(obj, key, &value, &errString) {
        try {
            value := obj[key]
        } catch Error as e {
            errString := Type(e)
        }
    }

    tryArray(v) {
        if not v is Array {
            return False
        }
        if v.Length = 0 {
            writer.Write(tmpltEmptyArray(v))
            return True
        }
        stack.Push(v)
        static indexedArrayItem := zTemplate("({index}) ‣ ")
        hasUnsetItems := zz_array_hasUnsetItems(v)
        writer.Indent()
        for index, value in v {
            writer.Indent()
            if hasUnsetItems {
                writer.Write(indexedArrayItem(value))
            } else {
                writer.Write("‣ ")
            }  
            print(v)
        }
        writer.Unindent()
        stack.Pop()
    }

    tryMap(v) {
        if not v is Map {
            return False
        }
        if v.Length = 0 {
            writer.Write(tmpltEmptyMap(v))
            return True
        }
        static keyEntry := zTemplate("[!key]{1}[!] 🡲 ")
        stack.Push(v)
        writer.Indent()
        for key, value in v {
            writer.Write(keyEntry(key))
            print(value)
        }
        writer.Unindent()
        stack.Pop()
        return True
    }

    tryObject(v) {
        static keyedItem := zTemplate("{key} = ")
        static propGetError := zTemplate("[!error]‼ {1} ‼[!]")
        count := ObjOwnPropCount(v)
        if not count {
            writer.Write proto(, Type(v))
            return True
        }
        stack.Push(v)
        writer.Indent()
        writer.WriteLine()
        writer.WriteLine proto(, Type(v))
        for key in ObjOwnProps(v) {
            desc := v.GetOwnPropDesc(key)
            if HasProp(desc, "Value") {
                writer.Write(keyedItem(key))
                print(desc.Value)
            } else if HasProp(desc, "Get") {
                writer.Write(keyedItem(key))
                getPropValueOrError(v, key, &value, &err)
                if IsSet(value) {
                    print(value)
                } else {
                    writer.Write(propGetError(, err))
                }
            }
        }
        stack.Pop()
        return True
    }

    print(v) {
        if tryScalar(v, writer) {
            return
        }
        if tryLeafType(v, writer) {
            return
        }
        if tryArray(v) {
            return
        }
        if tryMap(v) {
            return
        }
    }

}

zPrint(v) {
    
    zz_print()
}