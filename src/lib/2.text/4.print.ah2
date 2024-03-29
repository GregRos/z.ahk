zz_print(writer, v) {
    stack := Map()
    static tmpltProperty := zTemplate("[!key]{1}[!operator]:[!][!] ")
    static tmpltGui := zTemplate("[!type]Gui '{.title}' (0x{.hwnd:x})[!]")
    static tmpltGuiControl := zTemplate("[!type]GuiControl '{.name}' (0x{.hwnd:x})[!]")
    static tmpltBuffer := zTemplate("[!type]Buffer 0x{.ptr:x}, Length={.size}[!]")
    static tmpltClass := zTemplate("[!type]Class '{.name}'[!]")
    static tmpltMenu := zTemplate("[!type]Menu 0x{.handle:x}[!]")
    static tmpltMenuBar := zTemplate("[!type]MenuBar 0x{.handle:x}[!]")
    static tmpltRegExMatchInfo := zTemplate("[!type]RegExMatch [{.count}][!]")
    static tmpltFile := zTemplate("[!type]File 0x{.Handle:x}[!]")
    static tmpltInputHook := zTemplate("[!type]InputHook[!]")
    static tmpltEmptyObject := zTemplate("[!object]{{}{}}[!]")
    static tmpltEmptyArray := zTemplate("[!object][][!]")
    static tmpltEmptyMap := zTemplate("[!object]Map {{}{}}[!]")
    static tmpltProto := zTemplate("[!type]|{1}|[!]")
    static keyEntry := zTemplate("[!key]{1}[!] [!operator]🡲[!] ")
    static propGetError := zTemplate("[!getterError]‼ {1} ‼[!]")
    static tryScalar(v, writer) {
        if not IsSet(v) {
            writer.Put "[!kw]unset[!]"
            return True
        }
        if IsObject(v) {
            return False
        }
        if v is Integer {
            writer.Put(Format("[!int]{1:d}[!]", v))
        } else if v is Float {
            writer.Put Format("[!float]{1:f}[!]", v)
        } else {
            writer.Put Format('[!string]"{1}"[!]', v)
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
            writer.Put Format("[!type]{1}[!]", Type(v))
            return True
        }
        else if v is Gui {
            writer.Put tmpltGui(v)
        } else if v is Gui.Control {
            writer.Put(tmpltGuiControl(v))
        } else if v is Buffer {
            writer.Put(tmpltBuffer(v))
        } else if v is Class {
            writer.Put(tmpltClass(v))
        } else if v is RegExMatchInfo {
            writer.Put(tmpltRegExMatchInfo(v))
        } else if v is Menu {
            writer.Put(tmpltMenu(v))
        } else if v is MenuBar {
            writer.Put(tmpltMenuBar(v))
        } else if v is InputHook {
            writer.Put(tmpltInputHook(v))
        } else if v is File {
            writer.Put(tmpltFile(v))
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
        writer.Put(tmpltProto(Type(v)))
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
            writer.Put(tmpltEmptyArray(v))
            return True
        }

        if zz_arr.hasUnsetItems(v) {
            return this.tryObject(v)
        }
        stack.Set(v, v)

        writer.PutLn("[").Indent()
        loop v.Length {
            index := A_Index

            if index != 1 {
                writer.PutLn(", ")
            }
            if not v.Has(index) {
                continue
            }
            value := v[index]
            if IsSet(value) {
                recursivePrint(value)
            }
        }
        writer.PutLn().Unindent().Put("]")


        stack.Delete(v)
        return True
    }

    tryMap(v) {
        if not v is Map {
            return False
        }
        if v.Count = 0 {
            writer.Put(tmpltEmptyMap(v))
            return True
        }
        writer.PutLn("{").Indent("  ")

        stack.Set(v, v)
        if not stack.Count = 1 {
            writer.Indent().PutLn()
        }
        for key, value in v {
            if A_Index != 1 {
                writer.PutLn()
            }
            printShort(key, writer)
            writer.Put(" 🡲 ")
            recursivePrint(value)
        }
        if not stack.Count = 1 {
            writer.Unindent()
        }
        writer.Unindent().PutLn("`n}")

        stack.Delete(v)
        return True
    }

    tryError(v) {
        if not v is Error {
            return False
        }
        static errorBody := zTemplate(
            "[!errorTitle]{.type}[!]`n"
            "[!errorMessage]{.message}[!]"
        )
        static traceFileEntry := zTemplate(
            "[!errorFrame][!arrow]➜[!] [!location]{.File.Path}:{.Line}[!][!] @ [!function]{.Function}[!]`n"
            "[!quote]    >  {.Quote}[!]"
        )
        static headerRow := zTemplate(
            "{.type}: {.message}"
        )
        stack.Set(v, v)

        writer.PutLn(headerRow({
            type: Type(v),
            message: v.Message
        }))
        fst := True

        for key in ObjOwnProps(v) {
            if zz_arr.hasAny(key, "message", "stack", "file", "line") {
                continue
            }
            if fst == "" {
                writer.PutLn()
            }
            fst := False
            writeProperty(v, key)
        }
        writer.PutLn()
        frames := zz_stack.Frame.Parse(v)
        for frame in frames {
            writer.Putln()
            writer.Put(frame)
        }
        writer.PutLn()

        stack.Delete(v)
        return True
    }

    writeProperty(target, key) {
        desc := target.GetOwnPropDesc(key)
        if HasProp(desc, "Value") {
            writer.Put(tmpltProperty(key))
            recursivePrint(desc.Value)
        } else if HasProp(desc, "Get") {
            writer.Put(tmpltProperty(key))
            getPropValueOrError(v, key, &value, &err)
            if IsSet(value) {
                recursivePrint(value)
            } else {
                writer.Put(propGetError(err))
            }
        }
    }

    tryObject(v) {
        count := ObjOwnPropCount(v)
        if not count {
            writer.Put tmpltProto(Type(v))
            return True
        }
        stack.Set(v, v)
        if not stack.Count = 1 {
            writer.Indent()
        }

        if Type(v) != "Object" {
            writer.PutLn tmpltProto(Type(v))
        }
        writer.PutLn("{").Indent("  ")
        for key in ObjOwnProps(v) {
            if A_Index != 1 {
                writer.PutLn()
            }
            writeProperty(v, key)
        }
        writer.Unindent().PutLn()
        writer.Put("}")
        if not stack.Count = 1 {
            writer.Unindent()
        }
        stack.Delete(v)
        return True
    }

    recursivePrint(v) {
        if tryScalar(v, writer) or tryLeafType(v, writer) or tryError(v) or tryArray(v) or tryMap(v) or tryObject(v) {
            return
        }
        throw zz_BadInputError("The input for zPrint is invalid.")
    }
    recursivePrint(v)
    writer.Flush()
}

zPrint(v) {
    static renderer := zColor({
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
        operator: "blue",
        getterError: "bgBrightRed",
        errorTitle: "bold bgBrightRed black",
        errorMessage: "i white",
        errorFrame: "brightBlue",
        location: "u",
        function: "i green",
        quote: "d grey",
        arrow: "b",
        object: "green"
    })
    txt := zz_TextWriter(&result)
    zz_print(txt, v)
    txt.Flush()
    result := zz_str.regexReplaceEach(result, Map(
        "\[\s*\{", "[{",
        "\}\s*\]", "}]",
        "\},\s*\{", "}, {",
        "\],\s*\[", "], ["))
    return renderer(result)

}