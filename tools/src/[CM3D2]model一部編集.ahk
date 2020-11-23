#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetControlDelay, 0
SetBatchLines, -1
SetFormat, float, 0.99

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .modelファイルを選択してください, モデルファイル(*.model)
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
if (file.Read(file.ReadChar()) != "CM3D2_MESH") {
	MsgBox, これはカスタムメイド3D2のモデルファイルではありません
	ExitApp
}

data := Object()
seeks := Object()

data["version"] := file.ReadInt()

data["name"] := ReadString(file)
data["base_bone"] := ReadString(file)

seeks["pre_bone"] := file.Pos

num := file.ReadInt()
data["bone_count"] := num
Loop, %num% {
	ReadString(file)
	file.Seek(1, 1)
}
Loop, %num% {
	file.Seek(4, 1)
}
Loop, %num% {
	file.Seek(28, 1)
}

data["vertex_count"] := file.ReadInt()
data["faces_count"] := file.ReadInt()
data["local_bones_count"] := file.ReadInt()

num := data["local_bones_count"]
Loop, %num% {
	ReadString(file)
}
Loop, %num% {
	file.Seek(64, 1)
}

num := data["vertex_count"]
Loop, %num% {
	file.Seek(32, 1)
}

num := file.ReadInt()
Loop, %num% {
	file.Seek(16, 1)
}

num := data["vertex_count"]
Loop, %num% {
	file.Seek(24, 1)
}

num := data["faces_count"]
Loop, %num% {
	face_count := file.ReadInt()
	file.Seek(face_count * 2, 1)
}

seeks["pre_mate"] := file.Pos

num := file.ReadInt()
data["mate_count"] := num
Loop, %num% {
	mate_index := A_Index
	data["mate", mate_index, "name"] := ReadString(file)
	data["mate", mate_index, "shader1"] := ReadString(file)
	data["mate", mate_index, "shader2"] := ReadString(file)
	Loop {
		i := A_Index
		type := ReadString(file)
		if (type == "tex") {
			data["mate", mate_index, i, "type"] := type
			data["mate", mate_index, i, "name"] := ReadString(file)
			data["mate", mate_index, i, "shader"] := ReadString(file)
			if (data["mate", mate_index, i, "shader"] == "tex2d") {
				data["mate", mate_index, i, "tex_name"] := ReadString(file)
				data["mate", mate_index, i, "path"] := ReadString(file)
				data["mate", mate_index, i, "color_r"] := file.ReadFloat()
				data["mate", mate_index, i, "color_g"] := file.ReadFloat()
				data["mate", mate_index, i, "color_b"] := file.ReadFloat()
				data["mate", mate_index, i, "color_a"] := file.ReadFloat()
			}
		}
		else if (type == "col") {
			data["mate", mate_index, i, "type"] := type
			data["mate", mate_index, i, "name"] := ReadString(file)
			data["mate", mate_index, i, "color_r"] := file.ReadFloat()
			data["mate", mate_index, i, "color_g"] := file.ReadFloat()
			data["mate", mate_index, i, "color_b"] := file.ReadFloat()
			data["mate", mate_index, i, "color_a"] := file.ReadFloat()
		}
		else if (type == "f") {
			data["mate", mate_index, i, "type"] := type
			data["mate", mate_index, i, "name"] := ReadString(file)
			data["mate", mate_index, i, "float"] := file.ReadFloat()
		}
		else {
			break
		}
	}
}

seeks["pre_morph"] := file.Pos

Loop {
	type := ReadString(file)
	if (type == "morph") {
		ReadString(file)
		vert_num := file.ReadInt()
		file.Seek(vert_num * 26, 1)
	}
	else {
		break
	}
}

file.Seek(seeks["pre_bone"])
one_len := seeks["pre_mate"] - seeks["pre_bone"]
file.RawRead(one, one_len)

file.Seek(seeks["pre_morph"])
two_len := file.Length - seeks["pre_morph"]
file.RawRead(two, two_len)

file.Close()



SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Edit, xm0 ym0 W400 ReadOnly, %OutFileName%
Gui, Add, Text, Center x+0 yp+0 W100 H20, Version
val := data["version"]
Gui, Add, Edit, x+0 yp+0 W100 H20 Number vVversion, %val%

Gui, Add, Text, Center xm+0 y+10 W100 H20, Name
val := data["name"]
Gui, Add, Edit, x+0 yp+0 W200 H20 vVname, %val%
Gui, Add, Text, Center x+0 yp+0 W100 H20, BaseBone
val := data["base_bone"]
Gui, Add, Edit, x+0 yp+0 W200 H20 vVbase_bone, %val%

Gui, Add, Text, Center xm+0 y+10 W600 H20, Materials
Gui, Add, TreeView, xm0 y+0 W600 H400 -ReadOnly vVmate
num := data["mate_count"]
Loop, %num% {
	mate_index := A_Index
	parent := TV_Add(data["mate", mate_index, "name"], 0, "Expand")
	TV_Add(data["mate", mate_index, "shader1"], parent)
	TV_Add(data["mate", mate_index, "shader2"], parent)
	tex_count := GetMaxIndex(data["mate", mate_index])
	Loop, %tex_count% {
		tex_index := A_Index
		name := data["mate", mate_index, tex_index, "name"]
		if (name == "_MainTex") {
			sub := TV_Add(name, parent, "Expand")
		}
		else if (name == "_ShadowTex") {
			sub := TV_Add(name, parent, "Expand")
		}
		else {
			sub := TV_Add(name, parent)
		}
		type := data["mate", mate_index, tex_index, "type"]
		TV_Add(type, sub)
		if (type == "tex") {
			TV_Add(data["mate", mate_index, tex_index, "shader"], sub)
			if (data["mate", mate_index, tex_index, "shader"] == "tex2d") {
				TV_Add(data["mate", mate_index, tex_index, "tex_name"], sub)
				TV_Add(data["mate", mate_index, tex_index, "path"], sub)
				TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_r"]), sub)
				TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_g"]), sub)
				TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_b"]), sub)
				TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_a"]), sub)
			}
		}
		else if (type == "col") {
			TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_r"]), sub)
			TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_g"]), sub)
			TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_b"]), sub)
			TV_Add(SetFloat(data["mate", mate_index, tex_index, "color_a"]), sub)
		}
		else if (type == "f") {
			TV_Add(SetFloat(data["mate", mate_index, tex_index, "float"]), sub)
		}
	}
}

Gui, Add, Button, xm0 y+10 W600 H50 gGsubmit, 上書き保存

Gui, Show, AutoSize
return



Gsubmit:
	Gui, Submit, NoHide
	
	file := FileOpen(file_path, "w")
	
	WriteString(file, "CM3D2_MESH")
	file.WriteInt(Vversion)
	WriteString(file, Vname)
	WriteString(file, Vbase_bone)
	
	file.RawWrite(one, one_len)
	
	file.WriteInt(data["mate_count"])
	parent_id = 0
	Loop {
		parent_id := TV_GetNext(parent_id)
		if (parent_id == 0) {
			break
		}
		
		TV_GetText(name, parent_id)
		WriteString(file, name)
		
		mate_id := TV_GetChild(parent_id)
		TV_GetText(s, mate_id)
		WriteString(file, s)
		
		mate_id := TV_GetNext(mate_id)
		TV_GetText(s, mate_id)
		WriteString(file, s)
		
		Loop {
			mate_id := TV_GetNext(mate_id)
			if (mate_id == 0) {
				break
			}
			TV_GetText(name, mate_id)
			
			child_id := TV_GetChild(mate_id)
			TV_GetText(type, child_id)
			WriteString(file, type)
			
			WriteString(file, name)
			
			if (type == "tex") {
				child_id := TV_GetNext(child_id)
				TV_GetText(string, child_id)
				WriteString(file, string)
				
				if (string == "tex2d") {
					child_id := TV_GetNext(child_id)
					TV_GetText(string, child_id)
					WriteString(file, string)
					
					child_id := TV_GetNext(child_id)
					TV_GetText(string, child_id)
					WriteString(file, string)
					
					
					child_id := TV_GetNext(child_id)
					TV_GetText(float, child_id)
					file.WriteFloat(float)
					
					child_id := TV_GetNext(child_id)
					TV_GetText(float, child_id)
					file.WriteFloat(float)
					
					child_id := TV_GetNext(child_id)
					TV_GetText(float, child_id)
					file.WriteFloat(float)
					
					child_id := TV_GetNext(child_id)
					TV_GetText(float, child_id)
					file.WriteFloat(float)
				}
			}
			else if (type == "col") {
				child_id := TV_GetNext(child_id)
				TV_GetText(float, child_id)
				file.WriteFloat(float)
				
				child_id := TV_GetNext(child_id)
				TV_GetText(float, child_id)
				file.WriteFloat(float)
				
				child_id := TV_GetNext(child_id)
				TV_GetText(float, child_id)
				file.WriteFloat(float)
				
				child_id := TV_GetNext(child_id)
				TV_GetText(float, child_id)
				file.WriteFloat(float)
			}
			else if (type == "f") {
				child_id := TV_GetNext(child_id)
				TV_GetText(float, child_id)
				file.WriteFloat(float)
			}
		}
		
		WriteString(file, "end")
	}
	
	file.RawWrite(two, two_len)
	
	file.Close()
	
	SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	MsgBox, %OutFileName%を上書きしました
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

SetFloat(f) {
	f := RegExReplace(f, "(\.0)0+$", "$1")
	f := RegExReplace(f, "([1-9])0+$", "$1")
	return f
}

GuiEscape:
GuiClose:
	PID := DllCall("GetCurrentProcessId")
	Process, Close, %PID%
return
