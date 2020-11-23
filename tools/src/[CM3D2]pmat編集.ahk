#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetFormat, float, 0.10
#NoTrayIcon

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .pmatファイルを選択してください, メニューファイル(*.pmat)
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
if (file.Read(file.ReadChar()) != "CM3D2_PMATERIAL") {
	MsgBox, これはカスタムメイド3D2のpmatファイルではありません
	ExitApp
}

data := Object()

version := file.ReadInt()
int := file.ReadInt()
name := ReadString(file)
float := SetFloat(file.ReadFloat())
shader := ReadString(file)

SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
Gui, Add, Text, xm0 ym0 W300 H20 Center, %A_Space%%OutFileName%

Gui, Add, Text, xm0 y+0 W100 H20 Center, ファイルバージョン
Gui, Add, Edit, x+0 yp+0 W200 H20 vVversion, %version%

Gui, Add, Text, xm0 y+0 W100 H20 Center, 名前のハッシュ
Gui, Add, Edit, x+0 yp+0 W200 H20 vVint ReadOnly, %int%

Gui, Add, Text, xm0 y+0 W100 H20 Center, マテリアル名
Gui, Add, Edit, x+0 yp+0 W200 H20 vVname gGname, %name%

Gui, Add, Text, xm0 y+0 W100 H20 Center, 優先度？
Gui, Add, Edit, x+0 yp+0 W200 H20 vVfloat, %float%

Gui, Add, Text, xm0 y+0 W100 H20 Center, シェーダー
Gui, Add, Edit, x+0 yp+0 W200 H20 vVshader, %shader%

Gui, Add, Button, xm0 y+5 W300 H50 GMySubmit, 上書き保存

Gui, Show, AutoSize
return



Gname:
	Gui, Submit, NoHide
	hash := string_hash(Vname)
	GuiControl, Text, Vint, %hash%
return

MySubmit:
	Gui, Submit, NoHide
	
	file := FileOpen(file_path, "w")
	WriteString(file, "CM3D2_PMATERIAL")
	file.WriteInt(Vversion)
	file.WriteInt(Vint)
	WriteString(file, Vname)
	file.WriteFloat(Vfloat)
	WriteString(file, Vshader)
	file.close()
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

SetFloat(f) {
	f := RegExReplace(f, "(\.0)0+$", "$1")
	f := RegExReplace(f, "([1-9])0+$", "$1")
	return f
}

string_hash(s) {
	h = 0
	Loop, Parse, s
	{
		c := A_LoopField
		h := (31 * h + Asc(c)) & 0xFFFFFFFF
	}
	return ((h + 0x80000000) & 0xFFFFFFFF) - 0x80000000
}

GuiEscape:
GuiClose:
	ExitApp
return
