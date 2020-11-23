SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetBatchLines, -1
#NoTrayIcon

file_paths := ""
Loop, %0% {
	path := %A_Index%
	file_paths = %file_paths%%path%|
}
if (file_paths == "") {
	default_path := GetDefaultPath()
	FileSelectFile, paths, 7, %default_path%, .menu or .txtファイルを選択してください, 対応ファイル(*.menu;*.txt)
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
	
	if (ReadString(file) == "CM3D2_MENU") {
		SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		output_path = %OutDir%\%OutFileName%.txt
		FileDelete, %output_path%
		
		version := file.ReadInt()
		FileAppend, %version%`n, %output_path%
		path := ReadString(file)
		FileAppend, %path%`n, %output_path%
		name := ReadString(file)
		FileAppend, %name%`n, %output_path%
		category := ReadString(file)
		FileAppend, %category%`n, %output_path%
		setumei := ReadString(file)
		FileAppend, %setumei%`n`n, %output_path%
		
		end_pos := file.ReadInt() + file.tell() - 1
		Loop {
			index := A_Index
			local_size := file.ReadChar()
			line := ""
			Loop, %local_size% {
				line := line . ReadString(file) . "`t"
			}
			line := RTrim(line, "`t")
			FileAppend, %line%`n, %output_path%
			data_size := index
			if (end_pos <= file.tell()) {
				break
			}
		}
		file.Close()
	}
	else {
		FileRead, data, %file_path%
		IfInString, data, .png
		{
			MsgBox, これは.mate用のtxtである可能性が高いです`n終了します
			ExitApp
		}
		
		SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		output_path = %OutDir%\%OutNameNoExt%
		output_file := FileOpen(output_path, "w")
		
		WriteString(output_file, "CM3D2_MENU")
		file.Seek(0)
		output_file.WriteInt(ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		WriteString(output_file, ReadLine(file))
		
		temp_path = %OutDir%\%OutNameNoExt%.temp
		temp_file := FileOpen(temp_path, "w")
		Loop {
			line := ReadLine(file)
			if (line == "") {
				continue
			}
			StringSplit, $, line, `t
			temp_file.WriteChar($0)
			Loop, Parse, line, `t
			{
				WriteString(temp_file, A_LoopField)
			}
			if (file.AtEOF != 0) {
				break
			}
		}
		temp_file.WriteChar(0)
		temp_file.Close()
		temp_file := FileOpen(temp_path, "r")
		output_file.WriteInt(temp_file.Length)
		temp_file.RawRead(data, temp_file.Length)
		output_file.RawWrite(data, temp_file.Length)
		
		file.Close()
		temp_file.Close()
		output_file.Close()
		FileDelete, %temp_path%
		FileDelete, %file_paths%
	}
}
ExitApp



ReadLine(file) {
	line := file.ReadLine()
	line := RTrim(line, "`r`n")
	return line
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
