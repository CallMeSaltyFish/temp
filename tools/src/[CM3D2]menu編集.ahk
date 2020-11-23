#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetFormat, float, 0.10
#NoTrayIcon

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .menuファイルを選択してください, メニューファイル(*.menu)
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
if (file.Read(file.ReadChar()) != "CM3D2_MENU") {
	MsgBox, これはカスタムメイド3D2のメニューファイルではありません
	ExitApp
}

data := Object()

version := file.ReadInt()
path := ReadString(file)
name := ReadString(file)
category := ReadString(file)
setumei := ReadString(file)

end_pos := file.ReadInt() + file.tell() - 1
Loop, 9999 {
	index := A_Index
	local_size := file.ReadChar()
	Loop, %local_size% {
		data[index, A_Index] := ReadString(file)
	}
	data_size := index
	if (end_pos <= file.tell()) {
		break
	}
}
file.Close()

SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Text, xm0 ym0 W400 H20 Center, %A_Space%%OutFileName%
Gui, Add, Text, x+0 yp+0 W100 H20 Center, コピペ用
Gui, Add, Edit, x+0 yp+0 W100 H20 ReadOnly, 《改行》

Gui, Add, Text, xm0 y+0 W100 H20 Center,  %A_Space%%A_Space%ファイルバージョン
Gui, Add, Edit, x+0 yp+0 W100 H20 VGversion, %version%
Gui, Add, Text, x+0 yp+0 W50 H20 Center, %A_Space%%A_Space%名前
Gui, Add, Edit, x+0 yp+0 W350 H20 VGname, %name%

Gui, Add, Text, xm0 y+0 W100 H20 Center,  %A_Space%%A_Space%カテゴリ
Gui, Add, Edit, x+0 yp+0 W100 H20 VGcategory, %category%
Gui, Add, Text, x+0 yp+0 W50 H20 Center, %A_Space%%A_Space%説明
Gui, Add, Edit, x+0 yp+0 W350 H20 VGsetumei, %setumei%

Gui, Add, Text, xm0 y+0 W100 H20 Center, %A_Space%%A_Space%txtパス
Gui, Add, Edit, x+0 yp+0 W500 H20 VGpath, %path%

Gui, Add, TreeView, xm0 W600 R32 -ReadOnly

Gui, Add, Button, xm0 y+5 W100 H20 GUtilAdd, 新規親
Gui, Add, Button, x+0 yp+0 W100 H20 GUtilAddChild, 新規子
Gui, Add, Button, x+300 yp+0 W100 H20 GUtilDel, 削除

Gui, Add, Button, xm0 y+5 W600 H50 GMySubmit, 上書き保存

Loop, %data_size% {
	index := A_Index
	id := TV_Add(data[index, 1], 0, "Expand")
	local_size := data[index].MaxIndex()
	Loop, %local_size% {
		if (A_Index == 1) {
			continue
		}
		TV_Add(data[index, A_Index], id)
	}
}

Gui, Show, AutoSize
return

GetStringLength(string) {
	count = 0
	Loop, Parse, string
	{
		if (RegExMatch(A_LoopField, "^[^\x01-\x7E]$") != 0) {
			count += 3
		}
		else {
			count += 1
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
		temp := Floor(len / 128)
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

UtilAdd:
	InputBox, new_name, , 新規親の名前を入力してください
	if (ErrorLevel == 0){
		TV_Add(new_name, 0, "Expand")
	}
return
UtilAddChild:
	parent := TV_GetSelection()
	if (parent == 0) {
		MsgBox, 項目を選択してください
		return
	}
	if (TV_GetParent(parent) != 0) {
		parent := TV_GetParent(parent)
	}
	InputBox, new_name, , 新規子の名前を入力してください
	if (ErrorLevel == 0){
		TV_Add(new_name, parent, "Expand")
	}
return
UtilDel:
	selected := TV_GetSelection()
	if (selected == 0) {
		MsgBox, 項目を選択してください
		return
	}
	TV_Delete(selected)
return

MySubmit:
	Gui, Submit, NoHide
	
	temp_file := FileOpen(file_path . ".temp", "w")
	parent_id = 0
	Loop {
		parent_id := TV_GetNext(parent_id)
		if (parent_id == 0) {
			break
		}
		TV_GetText(name, parent_id)
		child_id := TV_GetChild(parent_id)
		childs := Object()
		if (child_id != 0) {
			Loop {
				TV_GetText(string, child_id)
				childs[A_Index] := string
				child_id := TV_GetNext(child_id)
				if (child_id == 0) {
					break
				}
			}
		}
		max := childs.MaxIndex()
		if (max == "") {
			temp_file.WriteChar(1)
		}
		else {
			temp_file.WriteChar(max + 1)
		}
		WriteString(temp_file, name)
		Loop, %max% {
			string := childs[A_Index]
			WriteString(temp_file, string)
		}
	}
	temp_file.WriteChar(0)
	temp_file.close()
	temp_file := FileOpen(file_path . ".temp", "r")
	
	file := FileOpen(file_path, "w")
	
	file.WriteChar(10)
	file.Write("CM3D2_MENU")
	file.WriteInt(Gversion)
	
	WriteString(file, Gpath)
	WriteString(file, Gname)
	WriteString(file, Gcategory)
	WriteString(file, Gsetumei)
	
	file.WriteInt(temp_file.Length)
	temp_file.RawRead(data, temp_file.Length)
	file.RawWrite(data, temp_file.Length)
	
	file.close()
	temp_file.close()
	FileDelete, %file_path%.temp
	
	SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	MsgBox, %OutFileName%を上書きしました
return

GuiEscape:
GuiClose:
	ExitApp
return
