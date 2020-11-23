#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetControlDelay, -1
SetWinDelay, -1
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

data["version"] := file.ReadInt()

data["name1"] := ReadString(file)
data["name2"] := ReadString(file)

num := file.ReadInt()
Loop, %num% {
	data["bones", A_Index, "name"] := ReadString(file)
	data["bones", A_Index, "unknown1"] := file.ReadChar()
}
Loop, %num% {
	parent_index := file.ReadInt()
	if (parent_index == -1) {
		data["bones", A_Index, "parent"] := ""
	}
	else {
		data["bones", A_Index, "parent"] := data["bones", parent_index+1, "name"]
	}
}
Loop, %num% {
	data["bones", A_Index, "float1"] := file.ReadFloat()
	data["bones", A_Index, "float2"] := file.ReadFloat()
	data["bones", A_Index, "float3"] := file.ReadFloat()
	data["bones", A_Index, "float4"] := file.ReadFloat()
	data["bones", A_Index, "float5"] := file.ReadFloat()
	data["bones", A_Index, "float6"] := file.ReadFloat()
	data["bones", A_Index, "float7"] := file.ReadFloat()
}

data["vertex_count"] := file.ReadInt()
data["object_count"] := file.ReadInt()
data["local_bones_count"] := file.ReadInt()

num := data["local_bones_count"]
Loop, %num% {
	data["local_bones", A_Index, "name"] := ReadString(file)
}

num := data["local_bones_count"]
Loop, %num% {
	data["local_bones", A_Index, "float1"] := file.ReadFloat()
	data["local_bones", A_Index, "float2"] := file.ReadFloat()
	data["local_bones", A_Index, "float3"] := file.ReadFloat()
	data["local_bones", A_Index, "float4"] := file.ReadFloat()
	
	data["local_bones", A_Index, "float5"] := file.ReadFloat()
	data["local_bones", A_Index, "float6"] := file.ReadFloat()
	data["local_bones", A_Index, "float7"] := file.ReadFloat()
	data["local_bones", A_Index, "float8"] := file.ReadFloat()
	
	data["local_bones", A_Index, "float9"] := file.ReadFloat()
	data["local_bones", A_Index, "float10"] := file.ReadFloat()
	data["local_bones", A_Index, "float11"] := file.ReadFloat()
	data["local_bones", A_Index, "float12"] := file.ReadFloat()
	
	data["local_bones", A_Index, "float13"] := file.ReadFloat()
	data["local_bones", A_Index, "float14"] := file.ReadFloat()
	data["local_bones", A_Index, "float15"] := file.ReadFloat()
	data["local_bones", A_Index, "float16"] := file.ReadFloat()
}

num := data["vertex_count"]
Loop, %num% {
	data["vertex", A_Index, "float1"] := file.ReadFloat()
	data["vertex", A_Index, "float2"] := file.ReadFloat()
	data["vertex", A_Index, "float3"] := file.ReadFloat()
	data["vertex", A_Index, "float4"] := file.ReadFloat()
	data["vertex", A_Index, "float5"] := file.ReadFloat()
	data["vertex", A_Index, "float6"] := file.ReadFloat()
	data["vertex", A_Index, "float7"] := file.ReadFloat()
	data["vertex", A_Index, "float8"] := file.ReadFloat()
}

data["unknown_int1"] := file.ReadInt()
num := data["unknown_int1"]
Loop, %num% {
	file.Seek(4 * 4, 1)
}

num := data["vertex_count"]
Loop, %num% {
	data["vertex", A_Index, "weight_name1"] := file.ReadShort()
	data["vertex", A_Index, "weight_name2"] := file.ReadShort()
	data["vertex", A_Index, "weight_name3"] := file.ReadShort()
	data["vertex", A_Index, "weight_name4"] := file.ReadShort()
	data["vertex", A_Index, "weight1"] := file.ReadFloat()
	data["vertex", A_Index, "weight2"] := file.ReadFloat()
	data["vertex", A_Index, "weight3"] := file.ReadFloat()
	data["vertex", A_Index, "weight4"] := file.ReadFloat()
}

num := data["object_count"]
Loop, %num% {
	face_index := A_Index
	num := file.ReadInt() / 3
	Loop, %num% {
		data["face", face_index, A_Index, 1] := file.ReadShort()
		data["face", face_index, A_Index, 2] := file.ReadShort()
		data["face", face_index, A_Index, 3] := file.ReadShort()
	}
}

num := file.ReadInt()
Loop, %num% {
	mate_index := A_Index
	data["material", mate_index, "str1"] := ReadString(file)
	data["material", mate_index, "str2"] := ReadString(file)
	data["material", mate_index, "str3"] := ReadString(file)
	Loop {
		type := ReadString(file)
		if (type == "end") {
			break
		}
		data["material", mate_index, A_Index, "type"] := type
		if (type == "tex") {
			data["material", mate_index, A_Index, "str1"] := ReadString(file)
			data["material", mate_index, A_Index, "str2"] := ReadString(file)
			if (data["material", mate_index, A_Index, "str2"] != "null") {
				data["material", mate_index, A_Index, "str3"] := ReadString(file)
				data["material", mate_index, A_Index, "str4"] := ReadString(file)
				data["material", mate_index, A_Index, "float1"] := file.ReadFloat()
				data["material", mate_index, A_Index, "float2"] := file.ReadFloat()
				data["material", mate_index, A_Index, "float3"] := file.ReadFloat()
				data["material", mate_index, A_Index, "float4"] := file.ReadFloat()
			}
		}
		else if (type == "col") {
			data["material", mate_index, A_Index, "str1"] := ReadString(file)
			data["material", mate_index, A_Index, "float1"] := file.ReadFloat()
			data["material", mate_index, A_Index, "float2"] := file.ReadFloat()
			data["material", mate_index, A_Index, "float3"] := file.ReadFloat()
			data["material", mate_index, A_Index, "float4"] := file.ReadFloat()
		}
		else if (type == "f") {
			data["material", mate_index, A_Index, "str1"] := ReadString(file)
			data["material", mate_index, A_Index, "float1"] := file.ReadFloat()
		}
	}
}

Loop {
	misc_index := A_Index
	type := ReadString(file)
	if (type == "end") {
		break
	}
	else if (type == "morph") {
		data["misc", misc_index, "type"] := type
		data["misc", misc_index, "name"] := ReadString(file)
		vert_num := file.ReadInt()
		Loop, %vert_num% {
			data["misc", misc_index, A_Index, "short1"] := file.ReadShort()
			data["misc", misc_index, A_Index, "float1"] := file.ReadFloat()
			data["misc", misc_index, A_Index, "float2"] := file.ReadFloat()
			data["misc", misc_index, A_Index, "float3"] := file.ReadFloat()
			data["misc", misc_index, A_Index, "float4"] := file.ReadFloat()
			data["misc", misc_index, A_Index, "float5"] := file.ReadFloat()
			data["misc", misc_index, A_Index, "float6"] := file.ReadFloat()
		}
	}
}
file.Close()



SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Text, Center xm0 ym0 W400, %OutFileName%
Gui, Add, Text, Center x+0 yp+0 W50 H20, Version
val := data["version"]
Gui, Add, Edit, x+0 yp+0 W150 H20 ReadOnly, %val%

val := data["name1"]
Gui, Add, Edit, xm+100 y+0 W200 H20 ReadOnly, %val%
val := data["name2"]
Gui, Add, Edit, x+100 yp+0 W200 H20 ReadOnly, %val%

bone_count := GetMaxIndex(data["bones"])
vertex_count := data["vertex_count"]
object_count := data["object_count"]
local_bones_count := data["local_bones_count"]

Gui, Add, Text, xm0 y+5 W300, %A_Space%%A_Space%bones (%bone_count%)
Gui, Add, Text, xm300 yp+0 W300, %A_Space%%A_Space%local bones (%local_bones_count%)

Gui, Add, TreeView, xm0 y+0 W300 H150 vVbones
;GuiControl, -Redraw, Vbones
Loop, %bone_count% {
	parent := TV_Add(data["bones", A_Index, "name"], 0)
	TV_Add("unknown: " . data["bones", A_Index, "unknown1"], parent)
	TV_Add("parent: " . data["bones", A_Index, "parent"], parent)
	loc := TV_Add("location", parent, "Expand")
	TV_Add(SetFloat(data["bones", A_Index, "float1"]), loc)
	TV_Add(SetFloat(data["bones", A_Index, "float2"]), loc)
	TV_Add(SetFloat(data["bones", A_Index, "float3"]), loc)
	quat := TV_Add("quaternion", parent, "Expand")
	TV_Add(SetFloat(data["bones", A_Index, "float4"]), quat)
	TV_Add(SetFloat(data["bones", A_Index, "float5"]), quat)
	TV_Add(SetFloat(data["bones", A_Index, "float6"]), quat)
	TV_Add(SetFloat(data["bones", A_Index, "float7"]), quat)
}

Gui, Add, TreeView, xm300 yp+0 W300 H150 vVlocal_bones
;GuiControl, -Redraw, Vlocal_bones
Loop, %local_bones_count% {
	parent := TV_Add(data["local_bones", A_Index, "name"], 0)
	mat := TV_Add("matrix", parent, "Expand")
	text := SetFloat2(data["local_bones", A_Index, "float1"]) . " " . SetFloat2(data["local_bones", A_Index, "float2"]) . " " . SetFloat2(data["local_bones", A_Index, "float3"]) . " " . SetFloat2(data["local_bones", A_Index, "float4"])
	TV_Add(text, mat)
	text := SetFloat2(data["local_bones", A_Index, "float5"]) . " " . SetFloat2(data["local_bones", A_Index, "float6"]) . " " . SetFloat2(data["local_bones", A_Index, "float7"]) . " " . SetFloat2(data["local_bones", A_Index, "float8"])
	TV_Add(text, mat)
	text := SetFloat2(data["local_bones", A_Index, "float9"]) . " " . SetFloat2(data["local_bones", A_Index, "float10"]) . " " . SetFloat2(data["local_bones", A_Index, "float11"]) . " " . SetFloat2(data["local_bones", A_Index, "float12"])
	TV_Add(text, mat)
	text := SetFloat2(data["local_bones", A_Index, "float13"]) . " " . SetFloat2(data["local_bones", A_Index, "float14"]) . " " . SetFloat2(data["local_bones", A_Index, "float15"]) . " " . SetFloat2(data["local_bones", A_Index, "float16"])
	TV_Add(text, mat)
}

Gui, Add, Text, xm0 y+5 W300, %A_Space%%A_Space%vertex (%vertex_count%)
Gui, Add, Text, xm300 yp+0 W300, %A_Space%%A_Space%objects (%object_count%)

Gui, Add, TreeView, xm0 y+0 W300 H150 vVvertex
;GuiControl, -Redraw, Vvertex
Loop, %vertex_count% {
	parent := TV_Add(A_Index, 0)
	location := TV_Add("location", parent, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "float1"]), location)
	TV_Add(SetFloat(data["vertex", A_Index, "float2"]), location)
	TV_Add(SetFloat(data["vertex", A_Index, "float3"]), location)
	normal := TV_Add("normal", parent, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "float4"]), normal)
	TV_Add(SetFloat(data["vertex", A_Index, "float5"]), normal)
	TV_Add(SetFloat(data["vertex", A_Index, "float6"]), normal)
	uv := TV_Add("uv", parent, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "float7"]), uv)
	TV_Add(SetFloat(data["vertex", A_Index, "float8"]), uv)
	weights := TV_Add("weights", parent, "Expand")
	name := data["local_bones", data["vertex", A_Index, "weight_name1"] + 1, "name"]
	weight := TV_Add(name, weights, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "weight1"]), weight, "Expand")
	name := data["local_bones", data["vertex", A_Index, "weight_name2"] + 1, "name"]
	weight := TV_Add(name, weights, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "weight2"]), weight, "Expand")
	name := data["local_bones", data["vertex", A_Index, "weight_name3"] + 1, "name"]
	weight := TV_Add(name, weights, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "weight3"]), weight, "Expand")
	name := data["local_bones", data["vertex", A_Index, "weight_name4"] + 1, "name"]
	weight := TV_Add(name, weights, "Expand")
	TV_Add(SetFloat(data["vertex", A_Index, "weight4"]), weight, "Expand")
}

Gui, Add, TreeView, xm300 yp+0 W300 H150 vVface
;GuiControl, -Redraw, Vface
Loop, %object_count% {
	face_index := A_Index
	face_count := GetMaxIndex(data["face", face_index])
	parent := TV_Add(A_Index . " (face: " . face_count . ")")
	Loop, %face_count% {
		text := SefFaceText(data["face", face_index, A_Index, 1]) . " " . SefFaceText(data["face", face_index, A_Index, 2]) . " " . SefFaceText(data["face", face_index, A_Index, 3])
		TV_Add(text, parent)
	}
}

mate_count := GetMaxIndex(data["material"])
misc_count := GetMaxIndex(data["misc"])
Gui, Add, Text, xm0 y+5 W300, %A_Space%%A_Space%material (%mate_count%)
Gui, Add, Text, xm300 yp+0 W300, %A_Space%%A_Space%misc (%misc_count%)

Gui, Add, TreeView, xm0 y+0 W300 H150 vVmaterial
;GuiControl, -Redraw, Vmaterial
Loop, %mate_count% {
	mate_index := A_Index
	parent := TV_Add(data["material", mate_index, "str1"], 0)
	TV_Add(data["material", mate_index, "str2"], parent)
	TV_Add(data["material", mate_index, "str3"], parent)
	sub_count := GetMaxIndex(data["material", mate_index])
	Loop, %sub_count% {
		type := data["material", mate_index, A_Index, "type"]
		sub := TV_Add(type, parent)
		if (type == "tex") {
			TV_Add(data["material", mate_index, A_Index, "str1"], sub)
			TV_Add(data["material", mate_index, A_Index, "str2"], sub)
			if (data["material", mate_index, A_Index, "str2"] != "null") {
				TV_Add(data["material", mate_index, A_Index, "str3"], sub)
				TV_Add(data["material", mate_index, A_Index, "str4"], sub)
				color := weight := TV_Add("color", sub, "Expand")
				TV_Add(SetFloat(data["material", mate_index, A_Index, "float1"]), color)
				TV_Add(SetFloat(data["material", mate_index, A_Index, "float2"]), color)
				TV_Add(SetFloat(data["material", mate_index, A_Index, "float3"]), color)
				TV_Add(SetFloat(data["material", mate_index, A_Index, "float4"]), color)
			}
		}
		else if (type == "col") {
			TV_Add(data["material", mate_index, A_Index, "str1"], sub)
			color := weight := TV_Add("color", sub, "Expand")
			TV_Add(SetFloat(data["material", mate_index, A_Index, "float1"]), color)
			TV_Add(SetFloat(data["material", mate_index, A_Index, "float2"]), color)
			TV_Add(SetFloat(data["material", mate_index, A_Index, "float3"]), color)
			TV_Add(SetFloat(data["material", mate_index, A_Index, "float4"]), color)
		}
		else if (type == "f") {
			TV_Add(SetFloat(data["material", mate_index, A_Index, "str1"]), sub)
			TV_Add(SetFloat(data["material", mate_index, A_Index, "float1"]), sub)
		}
	}
}

Gui, Add, TreeView, xm300 yp+0 W300 H150 vVmisc
;GuiControl, -Redraw, Vmisc
Loop, %misc_count% {
	misc_index := A_Index
	morph_count := GetMaxIndex(data["misc", misc_index])
	parent := TV_Add(data["misc", misc_index, "type"] . ": " . data["misc", misc_index, "name"] . " (" . morph_count . ")")
	if (data["misc", misc_index, "type"] == "morph") {
		;TV_Add(data["misc", misc_index, "name"], parent)
		Loop, %morph_count% {
			sub := TV_Add(A_Index, parent)
			TV_Add("vertex index : " . data["misc", misc_index, A_Index, "short1"], sub)
			subb := TV_Add("location", sub, "Expand")
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float1"]), subb)
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float2"]), subb)
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float3"]), subb)
			subb := TV_Add("normal", sub, "Expand")
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float4"]), subb)
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float5"]), subb)
			TV_Add(SetFloat(data["misc", misc_index, A_Index, "float6"]), subb)
		}
	}
}

/*
GuiControl, +Redraw, Vbones
GuiControl, +Redraw, Vlocal_bones
GuiControl, +Redraw, Vvertex
GuiControl, +Redraw, Vface
GuiControl, +Redraw, Vmaterial
GuiControl, +Redraw, Vmisc
*/

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

SetFloat(f) {
	f := RegExReplace(f, "(\.0)0+$", "$1")
	f := RegExReplace(f, "([1-9])0+$", "$1")
	return f
}
SetFloat2(f) {
	f := RegExReplace(f, "^(.{7}).+$", "$1")
	return f
}

SefFaceText(f) {
	f := "                                     " . f
	f := RegExReplace(f, "^.+(.{5})$", "$1")
	return f
}

GuiEscape:
GuiClose:
	PID := DllCall("GetCurrentProcessId")
	Process, Close, %PID%
return
