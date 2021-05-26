@echo off

SET "_INPUT_FILE=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\CompareTo-Parent.bat"

checksum -f="%_INPUT_FILE%" 





set directory=.
dir /s "%directory%" >"%temp%\filelist"
md5 "%temp%\filelist" >> output.txt
del/q "%temp%\filelist"



