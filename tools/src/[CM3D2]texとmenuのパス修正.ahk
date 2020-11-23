#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF

file_paths := ""
Loop, %0% {
	path := %A_Index%
	file_paths = %file_paths%%path%|
}
if (file_paths == "") {
	default_path := GetDefaultPath()
	FileSelectFile, paths, 7, %default_path%, .tex or .menuファイルを選択してください, 対応ファイル(*.tex;*.menu)
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
	
	type := ReadString(file)
	if (type == "CM3D2_TEX") {
		file.Seek(4, 1)
		top_len := file.Pos
		file.Seek(0)
		file.RawRead(top_raw, top_len)
		path := ReadString(file)
		end_len := file.Length - file.Pos
		file.RawRead(end_raw, end_len)
		file.Close()
		
		if (RegExMatch(file_path, "\\GameData\\texture[^\\]*\\texture\\") != 0) {
			SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			new_path := RegExReplace(OutDir . "\" . OutNameNoExt . ".png", "^.+\\GameData(\\texture[^\\]*\\texture\\)", "$1")
			new_path = assets%new_path%
			StringReplace, new_path, new_path, \, /, All
			MsgBox, %path%`n↓`n%new_path%
		}
		else {
			SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			InputBox, new_path, , %OutFileName%のテクスチャパスを入力してください, , 800, 130, , , , , assets/texture/texture/
			if (ErrorLevel != 0) {
				ExitApp
			}
		}
		
		file := FileOpen(file_path, "w")
		file.RawWrite(top_raw, top_len)
		WriteString(file, new_path)
		file.RawWrite(end_raw, end_len)
		file.Close()
	}
	else if (type == "CM3D2_MENU") {
		file.Seek(4, 1)
		top_len := file.Pos
		file.Seek(0)
		file.RawRead(top_raw, top_len)
		path := ReadString(file)
		end_len := file.Length - file.Pos
		file.RawRead(end_raw, end_len)
		file.Close()
		
		if (RegExMatch(file_path, "\\GameData\\menu[^\\]*\\menu\\") != 0) {
			SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			new_path := RegExReplace(OutDir . "\" . OutNameNoExt . ".txt", "^.+\\GameData(\\menu[^\\]*\\menu\\)", "$1")
			new_path = assets%new_path%
			StringReplace, new_path, new_path, \, /, All
			MsgBox, %path%`n↓`n%new_path%
		}
		else {
			SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			InputBox, new_path, , %OutFileName%のテクスチャパスを入力してください, , 800, 130, , , , , assets/menu/menu/
			if (ErrorLevel != 0) {
				ExitApp
			}
		}
		
		file := FileOpen(file_path, "w")
		file.RawWrite(top_raw, top_len)
		WriteString(file, new_path)
		file.RawWrite(end_raw, end_len)
		file.Close()
	}
}

ExitApp



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
