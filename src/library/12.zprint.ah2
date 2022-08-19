#include 07.ztemplate.ah2
#include 09.zset.ah2
#include 08.zwriter.ah2
zz_print(writer, v) {
    stack := zSet()
    static tmpltProperty := zTemplate("[!key]{1}[!operator]:[!][!] ")
    static tmpltGui := zTemplate("[!type]Gui '{title}' (0x{hwnd:x})[!]")
    static tmpltGuiControl := zTemplate("[!type]GuiControl '{name}' (0x{hwnd:x})[!]")
    static tmpltBuffer := zTemplate("[!type]Buffer 0x{ptr:x}, Length={size}[!]")
    static tmpltClass := zTemplate("[!type]Class '{name}'[!]")
    static tmpltMenu := zTemplate("[!type]Menu 0x{handle:x}[!]")
    static tmpltMenuBar := zTemplate("[!type]MenuBar 0x{handle:x}[!]")
    static tmpltRegExMatchInfo := zTemplate("[!type]RegExMatch [{count}][!]")
    static tmpltFile := zTemplate("[!type]File 0x{Handle:x}[!]")
    static tmpltInputHook := zTemplate("[!type]InputHook[!]")
    static tmpltEmptyObject := zTemplate("[!object]{{}{}}[!]")
    static tmpltEmptyArray := zTemplate("[!object][][!]")
    static tmpltEmptyMap := zTemplate("[!object]Map {{}{}}[!]")
    static tmpltProto := zTemplate("[!type]|{1}|[!]")
    static keyEntry := zTemplate("[!key]{1}[!] [!operator]🡲[!] ")
    static propGetError := zTemplate("[!error]‼ {1} ‼[!]")
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
        writer.Write(tmpltProto(Type(v)))
        return False
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
        stack.Add(v)
        static indexedArrayItem := zTemplate("({index}) ➤ ")
        hasUnsetItems := zz_array_hasUnsetItems(v)
        if stack.Count != 1 {
            writer.Indent()
            writer.WriteLine()
        }
        for index, value in v {
            if index != 1 {
                writer.WriteLine()
            }
            if hasUnsetItems {
                writer.Write(indexedArrayItem(value))
            } else {
                writer.Write("• ")
            }  
            print(value)
        }
        if not stack.Count = 1 {
            writer.Unindent()
        }
        
        stack.Delete(v)
        return True
    }

    tryMap(v) {
        if not v is Map {
            return False
        }
        if v.Count = 0 {
            writer.Write(tmpltEmptyMap(v))
            return True
        }
        
        stack.Add(v)
        if not stack.Count = 1 {
            writer.Indent()
            writer.WriteLine()
        }
        for key, value in v {
            if A_Index != 1 {
                writer.WriteLine()
            }
            printShort(key, writer)
            writer.Write(" 🡲 ")
            print(value)
        }
        if not stack.Count = 1 {
            writer.Unindent()
        }
        stack.Delete(v)
        return True
    }

    tryObject(v) {
        count := ObjOwnPropCount(v)
        if not count {
            writer.Write tmpltProto(, Type(v))
            return True
        }
        stack.Add(v)
        if not stack.Count = 1 {
            writer.Indent()
            writer.WriteLine()
        }
        
        if Type(v) != "Object" {
            writer.WriteLine tmpltProto(, Type(v))
        }
        for key in ObjOwnProps(v) {
            if A_Index != 1 {
                writer.WriteLine()
            }
            desc := v.GetOwnPropDesc(key)
            if HasProp(desc, "Value") {
                writer.Write(tmpltProperty(key))
                print(desc.Value)
            } else if HasProp(desc, "Get") {
                writer.Write(tmpltProperty(key))
                getPropValueOrError(v, key, &value, &err)
                if IsSet(value) {
                    print(value)
                } else {
                    writer.Write(propGetError(, err))
                }
            }
        }
        if not stack.Count = 1 {
            writer.Unindent()
        }
        stack.Delete(v)
        return True
    }

    print(v) {
        if tryScalar(v, writer) {
            return
        }
        else if tryLeafType(v, writer) {
            return
        }
        else if tryArray(v) {
            return
        }
        else if tryMap(v) {
            return
        }
        else if tryObject(v) {
            return
        }
    }
    print(v)
}



zPrint(v) {
    static configureRenderer() {
        renderer := zColor()
        renderer := renderer.Aliases({
            type: "bgBlueBright whiteBright",
            error: "bgRed",
            key: "black",
            int: "blue",
            float: "green",
            string: "grey",
            kw: "blue",
            key: "bold",
            index: "bold",
            print: "black",
            operator: "blue"
        })
        return renderer
    }
    static renderer := configureRenderer()
    writeObject(writer) {
        zz_print(writer, v)
        writer.WriteLine()
    }
    
    return renderer(zTextWriter_String(writeObject))
}