#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetFormat, float, 0.99

file_paths := ""
Loop, %0% {
	path := %A_Index%
	file_paths = %file_paths%%path%|
}
if (file_paths == "") {
	default_path := GetDefaultPath()
	FileSelectFile, paths, 7, %default_path%, .mate or .txtファイルを選択してください, 対応ファイル(*.mate;*.txt)
	if (ErrorLevel == 1) {
		ExitApp
	}
	StringSplit, $, paths, `n
	if (2 < $0) {
		Loop, Parse, paths, `n, `r
		{
			if (A_LoopField == "") {
				continue
			}
			if (A_Index == 1) {
				dir := A_LoopField
			}
			else {
				file_paths = %file_paths%%dir%\%A_LoopField%|
			}
		}
	}
	else {
		file_paths := paths
		file_paths := RTrim(file_paths, "`n`r")
	}
}
file_paths := RTrim(file_paths, "|")

Loop, Parse, file_paths, |
{
	file_path := A_LoopField
	file := FileOpen(file_path, "r")
	
	if (ReadString(file) == "CM3D2_MATERIAL") {
		SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		output_path = %OutDir%\%OutFileName%.txt
		FileDelete, %output_path%
		
		value := file.ReadInt()
		FileAppend, %value%`n, %output_path%
		value := ReadString(file)
		FileAppend, %value%`n, %output_path%
		value := ReadString(file)
		FileAppend, %value%`n, %output_path%
		value := ReadString(file)
		FileAppend, %value%`n, %output_path%
		value := ReadString(file)
		FileAppend, %value%`n`n, %output_path%
		
		Loop {
			type := ReadString(file)
			if (type == "tex") {
				FileAppend, %type%`n, %output_path%
				value := ReadString(file)
				FileAppend, `t%value%`n, %output_path%
				value := ReadString(file)
				FileAppend, `t%value%`n, %output_path%
				if (value == "tex2d") {
					value := ReadString(file)
					FileAppend, `t%value%`n, %output_path%
					value := ReadString(file)
					FileAppend, `t%value%`n, %output_path%
					f1 := SetFloatString(file.ReadFloat())
					f2 := SetFloatString(file.ReadFloat())
					f3 := SetFloatString(file.ReadFloat())
					f4 := SetFloatString(file.ReadFloat())
					FileAppend, `t%f1% %f2% %f3% %f4%`n, %output_path%
				}
			}
			else if (type == "col") {
				FileAppend, %type%`n, %output_path%
				value := ReadString(file)
				FileAppend, `t%value%`n, %output_path%
				f1 := SetFloatString(file.ReadFloat())
				f2 := SetFloatString(file.ReadFloat())
				f3 := SetFloatString(file.ReadFloat())
				f4 := SetFloatString(file.ReadFloat())
				FileAppend, `t%f1% %f2% %f3% %f4%`n, %output_path%
			}
			else if (type == "f") {
				FileAppend, %type%`n, %output_path%
				value := ReadString(file)
				FileAppend, `t%value%`n, %output_path%
				f := SetFloatString(file.ReadFloat())
				FileAppend, `t%f%`n, %output_path%
			}
			else {
				break
			}
		}
		
		file.Close()
	}
	else {
		FileRead, data, %file_path%
		IfInString, data, .txt
		{
			MsgBox, これは.menu用のtxtである可能性が高いです`n終了します
			ExitApp
		}
		
		SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		output_path = %OutDir%\%OutNameNoExt%
		output_file := FileOpen(output_path, "w")
		
		WriteString(output_file, "CM3D2_MATERIAL")
		file.Seek(0)
		output_file.WriteInt(ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		
		Loop {
			line := ReadLine(file)
			if (line == "") {
				continue
			}
			if (RegExMatch(line, "^\t") == 0) {
				if (line == "tex") {
					WriteString(output_file, "tex")
					WriteString(output_file, LTrim(ReadLine(file), "`t"))
					value := LTrim(ReadLine(file), "`t")
					WriteString(output_file, value)
					if (value == "tex2d") {
						WriteString(output_file, LTrim(ReadLine(file), "`t"))
						WriteString(output_file, LTrim(ReadLine(file), "`t"))
						floats := LTrim(ReadLine(file), "`t")
						Loop, Parse, floats, %A_Space%
						{
							output_file.WriteFloat(A_LoopField)
						}
					}
				}
				else if (line == "col") {
					WriteString(output_file, "col")
					WriteString(output_file, LTrim(ReadLine(file), "`t"))
					floats := LTrim(ReadLine(file), "`t")
					Loop, Parse, floats, %A_Space%
					{
						output_file.WriteFloat(A_LoopField)
					}
				}
				else if (line == "f") {
					WriteString(output_file, "f")
					WriteString(output_file, LTrim(ReadLine(file), "`t"))
					output_file.WriteFloat(LTrim(ReadLine(file), "`t"))
				}
				else {
					MsgBox, 不明なタイプの記述がありました`n終了します
					ExitApp
				}
			}
			if (file.AtEOF != 0) {
				break
			}
		}
		
		WriteString(output_file, "end")
		
		file.Close()
		output_file.Close()
		FileDelete, %file_paths%
	}
}
ExitApp



ReadLine(file) {
	line := file.ReadLine()
	line := RTrim(line, "`r`n")
	return line
}

SetFloatString(f) {
	f := RegExReplace(f, "([1-9])0+$", "$1")
	f := RegExReplace(f, "(\.0)0+$", "$1")
	return f
}

GetStringLength(string) {
	count = 0
	Loop, Parse, string
	{
		count += 1
		if (RegExMatch(A_LoopField, "^[^\x01-\x7E]$") != 0) {
			count += 2
		}
	}
	return count
}

ReadString(file, size=-1) {
	if (size <= -1) {
		size := 0
		chars := Object()
		Loop {
			char := file.ReadUChar()
			chars[A_Index] := char
			if (char < 128) {
				break
			}
		}
		num := GetMaxIndex(chars)
		Loop, %num% {
			char := chars[A_Index]
			multi := 256 ** (A_Index - 1)
			size += char * multi
			if (1 < A_Index) {
				size -= (multi / 2) * (char + 1)
			}
		}
	}
	string := ""
	count = 0
	Loop, 9999 {
		if (size <= count) {
			break
		}
		s := file.Read(1)
		string := string . s
		count += GetStringLength(s)
		if (GetStringLength(s) == 0) {
			pos := file.Pos
			MsgBox, ファイルの読み込みに失敗しました(場所: %pos%)`n終了します
			ExitApp
		}
	}
	return string
}

WriteString(file, string) {
	len := GetStringLength(string)
	if (128 <= len) {
		temp := Mod(len, 128) + 128
		file.WriteChar(temp)
		temp := len / 128
		file.WriteChar(temp)
	}
	else {
		file.WriteChar(len)
	}
	file.Write(string)
}

GetMaxIndex(obj) {
	value := obj.MaxIndex()
	if (value == "") {
		return 0
	}
	return value
}

GetDefaultPath() {
	RegRead, path, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath
	if (ErrorLevel == 0) {
		path = %path%GameData\
	}
	else {
		path := A_ScriptDir
	}
	return path
}
