' See the "Author guidelines" tab at 
' http://www.ibm.com/developerworks/aboutdw/
' for more information on how to use this program.
' © Copyright IBM Corporation 2004. All rights reserved.
Option explicit

Dim rc, WshShell, toolpath, mypath, fso, dwnewproject

'Set global constants and variables.

Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")

mypath = fso.GetFile(WScript.ScriptFullName).parentFolder
toolpath = ".\tools\dw-newproject.vbs"
dwnewproject = fso.BuildPath(mypath , toolpath)
dwnewproject = fso.GetAbsolutePathName(dwnewproject)

if fso.FileExists(dwnewproject) Then
    ' change directory to my directory as wshshell.run 
    ' doesn't like directories with spaces
    WshShell.CurrentDirectory = mypath
    ' Put quotes around filespec in case of special chars like blanks
    rc = WshShell.Run(toolpath & " tutorial", 1, false)
else
    Wscript.Echo "Error: " & vbTab & "Cannot locate article creation tool" & vbNewLine & _
    vbTab & dwnewproject &vbNewLine    
End If
