#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetControlDelay, 0
SetBatchLines, -1

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .anmファイルを選択してください, モーションファイル(*.anm)
	}
	if (ErrorLevel == 1) {
		ExitApp
	}
	if (FileExist(file_path) == "") {
		Msgbox, ファイルが存在しません
		file_path := ""
	}
	else {
		break
	}
}
file := FileOpen(file_path, "r")
if (file.Read(file.ReadChar()) != "CM3D2_ANIM") {
	MsgBox, これはカスタムメイド3D2のモーションファイルではありません
	ExitApp
}

data := Object()

data["version"] := file.ReadInt()

if (file.ReadChar() == 1) {
	Loop, 9999 {
		bone_index := A_Index
		data[bone_index, "path"] := ReadString(file)
		Loop, 9999 {
			type_index := A_Index
			type := file.ReadChar()
			if (type <= 1) {
				break
			}
			data[bone_index, type_index, "type"] := type
			frame_count := file.ReadInt()
			data[bone_index, type_index, "frame_count"] := frame_count
			Loop, %frame_count% {
				data[bone_index, type_index, A_Index, "frame"] := file.ReadFloat()
				data[bone_index, type_index, A_Index, 1] := file.ReadFloat()
				data[bone_index, type_index, A_Index, 2] := file.ReadFloat()
				data[bone_index, type_index, A_Index, 3] := file.ReadFloat()
			}
		}
		if (type == 0) {
			break
		}
	}
}
file.Close()



SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Text, Center xm0 ym0 W600, %OutFileName%
Gui, Add, Text, Center x+0 yp+0 W50 H20, Version
val := data["version"]
Gui, Add, Edit, x+0 yp+0 W150 H20 ReadOnly, %val%


Gui, Add, TreeView, xm0 y+0 W800 H600 vVmainTV
;GuiControl, -Redraw, VmainTV
bone_count := GetMaxIndex(data)
Loop, %bone_count% {
	bone_index := A_Index
	bone_id := TV_Add(data[bone_index, "path"])
	type_count := GetMaxIndex(data[bone_index])
	Loop, %type_count% {
		type_index := A_Index
		txt := data[bone_index, type_index, "type"] . " " . data[bone_index, type_index, "frame_count"]
		type_id := TV_Add(txt, bone_id)
		frame_count := GetMaxIndex(data[bone_index, type_index])
		Loop, %frame_count% {
			frame_index := A_Index
			txt := "frame: " . data[bone_index, type_index, frame_index, "frame"]
			frame_id := TV_Add(txt, type_id, "Expand")
			txt := data[bone_index, type_index, frame_index, 1] . " " . data[bone_index, type_index, frame_index, 2] . " " . data[bone_index, type_index, frame_index, 3]
			TV_Add(txt, frame_id)
		}
	}
}
;GuiControl, +Redraw, VmainTV

Gui, Show, AutoSize
return



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

GetMaxIndex(obj) {
	value := obj.MaxIndex()
	if (value == "") {
		return 0
	}
	return value
}

GuiEscape:
GuiClose:
	PID := DllCall("GetCurrentProcessId")
	Process, Close, %PID%
return
