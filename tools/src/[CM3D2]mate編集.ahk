#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetBatchLines, -1
SetFormat, float, 0.99

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .mateファイルを選択してください, マテリアルファイル(*.mate)
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
if (file.Read(file.ReadChar()) != "CM3D2_MATERIAL") {
	MsgBox, これはカスタムメイド3D2のマテリアルファイルではありません
	ExitApp
}

version := file.ReadInt()
value1 := ReadString(file)
value2 := ReadString(file)
value3 := ReadString(file)
value4 := ReadString(file)

tex_data := Object()
col_data := Object()
f_data := Object()
Loop {
	type := ReadString(file)
	if (type == "end") {
		break
	}
	else if (type == "tex") {
		pos := GetMaxIndex(tex_data) + 1
		tex_data[pos, 1] := ReadString(file)
		tex_data[pos, 2] := ReadString(file)
		if (tex_data[pos, 2] == "tex2d") {
			tex_data[pos, 3] := ReadString(file)
			tex_data[pos, 4] := ReadString(file)
			tex_data[pos, 5, 1] := file.ReadFloat()
			tex_data[pos, 5, 2] := file.ReadFloat()
			tex_data[pos, 5, 3] := file.ReadFloat()
			tex_data[pos, 5, 4] := file.ReadFloat()
		}
	}
	else if (type == "col") {
		pos := GetMaxIndex(col_data) + 1
		col_data[pos, 1] := ReadString(file)
		col_data[pos, 2, 1] := file.ReadFloat()
		if (col_data[pos, 2, 1] != "null") {
			col_data[pos, 2, 2] := file.ReadFloat()
			col_data[pos, 2, 3] := file.ReadFloat()
			col_data[pos, 2, 4] := file.ReadFloat()
		}
		else {
			col_data[pos, 2, 2] := ""
			col_data[pos, 2, 3] := ""
			col_data[pos, 2, 4] := ""
		}
	}
	else if (type == "f") {
		pos := GetMaxIndex(f_data) + 1
		f_data[pos, 1] := ReadString(file)
		f_data[pos, 2] := file.ReadFloat()
	}
	else {
		MsgBox, 未知のデータがありました(%type%)`n終了します
		ExitApp
	}
}
file.Close()

SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Text, xm0 ym0 W450, %A_Space%%OutFileName%
Gui, Add, Text, x+0 yp+0 W100 H20, %A_Space%%A_Space%ファイルバージョン
Gui, Add, Edit, x+0 yp+0 W50 H20 VVversion, %version%

Gui, Add, Text, xm0 y+0 W50 H20, %A_Space%%A_Space%値1
Gui, Add, Edit, x+0 yp+0 W250 H20 VVvalue1, %value1%
Gui, Add, Text, x+0 yp+0 W50 H20, %A_Space%%A_Space%値2
Gui, Add, Edit, x+0 yp+0 W250 H20 VVvalue2, %value2%

Gui, Add, Text, xm0 y+0 W50 H20, %A_Space%%A_Space%値3
Gui, Add, Edit, x+0 yp+0 W250 H20 VVvalue3, %value3%
Gui, Add, Text, x+0 yp+0 W50 H20, %A_Space%%A_Space%値4
Gui, Add, Edit, x+0 yp+0 W250 H20 VVvalue4, %value4%

Gui, Add, Text, xm0 y+5 W50, %A_Space%%A_Space%texture
Gui, Add, TreeView, xm0 y+0 W550 H200 -ReadOnly VVtex_data
size := GetMaxIndex(tex_data)
Loop, %size% {
	parent := TV_Add(tex_data[A_Index, 1], 0, "Expand")
	TV_Add(tex_data[A_Index, 2], parent)
	if (tex_data[A_Index, 2] == "tex2d") {
		TV_Add(tex_data[A_Index, 3], parent)
		TV_Add(tex_data[A_Index, 4], parent)
		vector := TV_Add("色", parent)
		TV_Add(SetFloat(tex_data[A_Index, 5, 1]), vector)
		TV_Add(SetFloat(tex_data[A_Index, 5, 2]), vector)
		TV_Add(SetFloat(tex_data[A_Index, 5, 3]), vector)
		TV_Add(SetFloat(tex_data[A_Index, 5, 4]), vector)
	}
}
Gui, Add, Button, x+0 yp+0 W50 H100 GtexAdd, ＋
Gui, Add, Button, xp+0 y+0 W50 H100 GtexDel, ×

Gui, Add, Text, xm0 y+5 W50, %A_Space%%A_Space%color
Gui, Add, TreeView, xm0 y+0 W550 H150 -ReadOnly VVcol_data
size := GetMaxIndex(col_data)
Loop, %size% {
	parent := TV_Add(col_data[A_Index, 1], 0, "Expand")
	vector := TV_Add("色", parent)
	TV_Add(SetFloat(col_data[A_Index, 2, 1]), vector)
	TV_Add(SetFloat(col_data[A_Index, 2, 2]), vector)
	TV_Add(SetFloat(col_data[A_Index, 2, 3]), vector)
	TV_Add(SetFloat(col_data[A_Index, 2, 4]), vector)
}
Gui, Add, Button, x+0 yp+0 W50 H75 GcolAdd, ＋
Gui, Add, Button, xp+0 y+0 W50 H75 GcolDel, ×

Gui, Add, Text, xm0 y+5 W50, %A_Space%%A_Space%float
Gui, Add, TreeView, xm0 y+0 W550 H100 -ReadOnly VVf_data
size := GetMaxIndex(f_data)
Loop, %size% {
	parent := TV_Add(f_data[A_Index, 1], 0, "Expand")
	TV_Add(SetFloat(f_data[A_Index, 2]), parent)
}
Gui, Add, Button, x+0 yp+0 W50 H50 GfAdd, ＋
Gui, Add, Button, xp+0 y+0 W50 H50 GfDel, ×

Gui, Add, Button, xm0 y+5 W600 H50 GMySubmit, 上書き保存

Gui, Show, AutoSize
return



MySubmit:
	Gui, Submit, NoHide
	
	file := FileOpen(file_path, "w")
	
	WriteString(file, "CM3D2_MATERIAL")
	file.WriteInt(Vversion)
	WriteString(file, Vvalue1)
	WriteString(file, Vvalue2)
	WriteString(file, Vvalue3)
	WriteString(file, Vvalue4)
	
	Gui, TreeView, Vtex_data
	parent_id = 0
	Loop {
		parent_id := TV_GetNext(parent_id)
		if (parent_id == 0) {
			break
		}
		WriteString(file, "tex")
		
		TV_GetText(string, parent_id)
		WriteString(file, string)
		
		child_id := TV_GetChild(parent_id)
		TV_GetText(string, child_id)
		WriteString(file, string)
		if (string == "null") {
			continue
		}
		
		child_id := TV_GetNext(child_id)
		TV_GetText(string, child_id)
		WriteString(file, string)
		
		child_id := TV_GetNext(child_id)
		TV_GetText(string, child_id)
		WriteString(file, string)
		
		child_id := TV_GetNext(child_id)
		child_id := TV_GetChild(child_id)
		TV_GetText(string, child_id)
		file.WriteFloat(string)
		Loop, 3 {
			child_id := TV_GetNext(child_id)
			TV_GetText(string, child_id)
			file.WriteFloat(string)
		}
	}
	
	Gui, TreeView, Vcol_data
	parent_id = 0
	Loop {
		parent_id := TV_GetNext(parent_id)
		if (parent_id == 0) {
			break
		}
		WriteString(file, "col")
		
		TV_GetText(string, parent_id)
		WriteString(file, string)
		
		child_id := TV_GetChild(parent_id)
		child_id := TV_GetChild(child_id)
		TV_GetText(string, child_id)
		file.WriteFloat(string)
		Loop, 3 {
			child_id := TV_GetNext(child_id)
			TV_GetText(string, child_id)
			file.WriteFloat(string)
		}
	}
	
	Gui, TreeView, Vf_data
	parent_id = 0
	Loop {
		parent_id := TV_GetNext(parent_id)
		if (parent_id == 0) {
			break
		}
		WriteString(file, "f")
		
		TV_GetText(string, parent_id)
		WriteString(file, string)
		
		child_id := TV_GetChild(parent_id)
		TV_GetText(string, child_id)
		file.WriteFloat(string)
	}
	
	WriteString(file, "end")
	file.close()
	
	SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	MsgBox, %OutFileName%を上書きしました
return

texAdd:
	Gui, TreeView, SysTreeView321
	InputBox, new_name, , 新規の名前を入力してください, , , , , , , , _
	if (ErrorLevel == 0){
		parent := TV_Add(new_name, 0, "Expand")
		TV_Add("tex2d", parent)
		TV_Add("XXX_XXX", parent)
		TV_Add("Assets/texture/～*.png", parent)
		vector := TV_Add("色情報？", parent)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
	}
return
texDel:
	Gui, TreeView, SysTreeView321
	parent := TV_GetSelection()
	if (parent == 0) {
		MsgBox, 項目を選択してください
		return
	}
	Loop {
		if (TV_GetParent(parent) != 0) {
			parent := TV_GetParent(parent)
		}
		else {
			break
		}
	}
	TV_Delete(parent)
return
colAdd:
	Gui, TreeView, SysTreeView322
	InputBox, new_name, , 新規の名前を入力してください
	if (ErrorLevel == 0){
		parent := TV_Add(new_name, 0, "Expand")
		vector := TV_Add("色情報", parent)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
		TV_Add(1.0, vector)
	}
return
colDel:
	Gui, TreeView, SysTreeView322
	parent := TV_GetSelection()
	if (parent == 0) {
		MsgBox, 項目を選択してください
		return
	}
	Loop {
		if (TV_GetParent(parent) != 0) {
			parent := TV_GetParent(parent)
		}
		else {
			break
		}
	}
	TV_Delete(parent)
return
fAdd:
	Gui, TreeView, SysTreeView323
	InputBox, new_name, , 新規の名前を入力してください
	if (ErrorLevel == 0){
		parent := TV_Add(new_name, 0, "Expand")
		TV_Add(1.0, parent)
	}
return
fDel:
	Gui, TreeView, SysTreeView323
	parent := TV_GetSelection()
	if (parent == 0) {
		MsgBox, 項目を選択してください
		return
	}
	Loop {
		if (TV_GetParent(parent) != 0) {
			parent := TV_GetParent(parent)
		}
		else {
			break
		}
	}
	TV_Delete(parent)
return

GetMaxIndex(obj) {
	value := obj.MaxIndex()
	if (value == "") {
		return 0
	}
	return value
}

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

SetFloat(f) {
	f := RegExReplace(f, "(\.0)0+$", "$1")
	f := RegExReplace(f, "([1-9])0+$", "$1")
	return f
}

GuiEscape:
GuiClose:
	ExitApp
return
