





zz_options_parse(optionsString) {
    optionsMap := Map()
    optionsMap.CaseSense := False
    optionsMap.Default := 0
    split := StrSplit(optionsString, " ")
    for option in split {
        firstChar := SubStr(option, 1, 1)
        if firstChar = "+" {
            properName := SubStr(option, 2)
            optionsMap[properName] := 1
        } else if firstChar = "-" {
            properName := SubStr(option, 2)
            optionsMap[properName] := -1
        } else {
            optionsMap[option] := 1
        }
    }
    return optionsMap
}


