#NoTrayIcon
FileEncoding, UTF-8-RAW
#SingleInstance OFF
SetWorkingDir, %A_ScriptDir%

file_path = %1%
Loop {
	if (file_path == "") {
		default_path := GetDefaultPath()
		FileSelectFile, file_path, 3, %default_path%, .presetファイルを選択してください, プリセットファイル(*.preset)
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
ext := file.Read(file.ReadChar())
if (ext != "CM3D2_PRESET") {
	MsgBox, これはカスタムメイド3D2のプリセットファイルではありません
	ExitApp
}

file := FileOpen(file_path, "r")
file.Read(file.ReadChar())
file.ReadInt()
file.ReadInt()
png_size := file.ReadInt()
file.RawRead(png_data, png_size)

thumb_path = %A_ScriptName%.png
png_file := FileOpen(thumb_path, "w")
png_file.RawWrite(png_data, png_size)
png_file.Close()

Gui, Add, Button, xm+0 ym+50 W100 H100 Gextract, 画像を抽出
Gui, Add, Picture, x+10 ym+0 W138 H200, %thumb_path%
Gui, Add, Button, x+10 ym+50 W100 H100 Ginsert, 画像を挿入
Gui, Show, AutoSize
return

extract:
	Gui, Destroy
	png_path := RegExReplace(file_path, "\.\w+$", ".png")
	if (file_path == png_path) {
		png_path = %file_path%.png
	}
	/*
	FileSelectFile, png_path, , %png_path%, pngの保存先を選択してください, PNGファイル (*.png)
	if (ErrorLevel == 1) {
		ExitApp
	}
	*/
	if (FileExist(png_path) != "") {
		MsgBox, 4, , 同名のpngファイルが存在します`n上書きしますか？
		IfMsgBox, No
		{
			ExitApp
		}
	}
	png_file := FileOpen(png_path, "w")
	png_file.RawWrite(png_data, png_size)
	
	FileDelete, %thumb_path%
	ExitApp
return

insert:
	Gui, Destroy
	png_path := RegExReplace(file_path, "\.\w+$", ".png")
	if (file_path == png_path) {
		png_path = %file_path%.png
	}
	/*
	FileSelectFile, png_path, 3, %png_path%, 挿入するpngを選択してください, PNGファイル (*.png)
	if (ErrorLevel == 1) {
		ExitApp
	}
	*/
	if (FileExist(png_path) == "") {
		MsgBox, プリセットと同名のpngを用意してください`n終了します 
		ExitApp
	}
	file := FileOpen(file_path, "r")
	file.RawRead(top_data, 21)
	file.RawRead(old_png_data, file.ReadInt())
	end_size := file.Length - file.Pos
	file.RawRead(end_data, end_size)
	png_file := FileOpen(png_path, "r")
	png_file.RawRead(png_data, png_file.Length)
	new_file := FileOpen(file_path, "w")
	new_file.RawWrite(top_data, 21)
	new_file.WriteInt(png_file.Length)
	new_file.RawWrite(png_data, png_file.Length)
	new_file.RawWrite(end_data, end_size)
	
	FileDelete, %thumb_path%
	ExitApp
return

GetDefaultPath() {
	RegRead, path, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath
	if (ErrorLevel == 0) {
		path = %path%Preset\
	}
	else {
		path := A_ScriptDir
	}
	return path
}

GuiEscape:
GuiClose:
	FileDelete, %thumb_path%
	ExitApp
return
