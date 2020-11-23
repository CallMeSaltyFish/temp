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
	FileSelectFile, paths, 7, %default_path%, .csファイルを選択してください, 対応ファイル(*.cs)
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

commands := ""
Loop, Parse, file_paths, |
{
	file_path := A_LoopField
	SplitPath, file_path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	
	cmd = C:\Windows\Microsoft.NET\Framework\v3.5\csc /t:library /lib:..\CM3D2x64_Data\Managed /r:UnityEngine.dll /r:UnityInjector.dll /r:Assembly-CSharp.dll /r:Assembly-CSharp-firstpass.dll %OutFileName%
	InputBox, cmd, , 実行するコマンドを入力して下さい, , 800, 150, , , , , %cmd%
	if (ErrorLevel != 0) {
		ExitApp
	}
	
	RunWait, %cmd%, %OutDir%, Hide
	MsgBox, 4, , %OutFileName%を削除しますか？
	IfMsgBox, Yes
	{
		FileDelete, %file_path%
	}
}

MsgBox, 完了しました

ExitApp



GetDefaultPath() {
	RegRead, path, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath
	if (ErrorLevel == 0) {
		path = %path%UnityInjector\
	}
	else {
		path := A_ScriptDir
	}
	return path
}
