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
	FileSelectFile, paths, 7, %default_path%, .tex or .pngファイルを選択してください, 対応ファイル(*.tex;*.png)
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
	
	ext := file.ReadInt()
	if (ext == 1196314761) {
		tex_path := RegExReplace(file_path, "\.\w+$", ".tex")
		if (file_path == tex_path) {
			tex_path = %file_path%.tex
		}
		/*
		if (FileExist(tex_path) != "") {
			MsgBox, 4, , 同名のtexファイルが存在します`n上書きしますか？
			IfMsgBox, No
			{
				ExitApp
			}
		}
		*/
		default_path = assets/texture/
		sub_path := RegExReplace(file_path, "\.\w+$", ".tex")
		if (file_path != sub_path) {
			if (FileExist(sub_path) != "") {
				sub_file := FileOpen(sub_path, "r")
				num := sub_file.ReadChar()
				ext := sub_file.Read(num)
				if (ext == "CM3D2_TEX") {
					sub_file.ReadInt()
					num := sub_file.ReadChar()
					default_path := sub_file.Read(num)
				}
			}
		}
		if (RegExMatch(file_path, "\\texture[^\\]*\\texture\\") != 0) {
			default_path := RegExReplace(file_path, "^.+(\\texture[^\\]*\\texture\\)", "$1")
			default_path = assets%default_path%
			StringReplace, default_path, default_path, \, /, All
		}
		SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		InputBox, path, , %OutFileName%のテクスチャパスを入力してください, , 800, 130, , , , , %default_path%
		if (ErrorLevel != 0) {
			ExitApp
		}
		tex_file := FileOpen(tex_path, "w")
		tex_file.WriteChar(9)
		tex_file.Write("CM3D2_TEX")
		tex_file.WriteInt(1000)
		tex_file.WriteChar(StrLen(path))
		tex_file.Write(path)
		tex_file.WriteInt(file.Length)
		file.Seek(0)
		file.RawRead(png_data, file.Length)
		tex_file.RawWrite(png_data, file.Length)
		
		continue
	}
	
	file.Seek(0)
	num := file.ReadChar()
	ext := file.Read(num)
	if (ext == "CM3D2_TEX") {
		png_path := RegExReplace(file_path, "\.\w+$", ".png")
		if (file_path == png_path) {
			png_path = %file_path%.png
		}
		/*
		if (FileExist(png_path) != "") {
			MsgBox, 4, , 同名のpngファイルが存在します`n上書きしますか？
			IfMsgBox, No
			{
				ExitApp
			}
		}
		*/
		ver := file.ReadInt()
		num := file.ReadChar()
		path := file.Read(num)
		size := file.ReadInt()
		file.RawRead(png_data, size)
		png_file := FileOpen(png_path, "w")
		png_file.RawWrite(png_data, size)
		/*
		MsgBox, 4, , パスをクリップボードにコピーしますか？`n(%path%)
		IfMsgBox, Yes
		{
			Clipboard := path
		}
		*/
		Clipboard := path
		
		continue
	}
	
	Msgbox, %file_path%`n不明なフォーマットのファイルです
}
ExitApp

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
