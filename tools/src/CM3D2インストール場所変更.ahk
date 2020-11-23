#NoTrayIcon
#SingleInstance OFF

RegRead, path, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath
if (ErrorLevel == 0) {
	MsgBox, レジストリ内の「CM3D2をインストールしたフォルダ」を変更します`nアップデートを複数の場所に適用する場合などに活用ください
	InputBox, path, , 変更後のパスを入力してください`n(現在：%path%), , 800, 150, , , , , %path%
	if (ErrorLevel != 0) {
		ExitApp
	}
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath, %path%
	MsgBox, レジストリを上書きしました、終了します
}
else {
	MsgBox, カスタムメイド3D2がインストールされた痕跡がありません、終了します
}
ExitApp
