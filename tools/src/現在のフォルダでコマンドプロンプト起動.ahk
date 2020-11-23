SetWorkingDir, %A_ScriptDir%
argc = %0%
if (1 <= argc) {
	arg = %1%
	SplitPath, arg, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	SetWorkingDir, %OutDir%
}
Run, cmd.exe
