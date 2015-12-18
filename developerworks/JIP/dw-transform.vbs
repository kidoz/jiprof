' See the "Author guidelines" tab at 
' http://www.ibm.com/developerworks/aboutdw/
' for more information on how to use this program.
' © Copyright IBM Corporation 2004, 2005. All rights reserved.
Option explicit

Dim fspec, rc, WshShell, toolpath, mypath, fso, dwxmlvalidate

'Set global constants and variables.

Set fso = CreateObject("Scripting.FileSystemObject")
If Wscript.Arguments.Length > 0 Then
    fSpec = Wscript.Arguments.Item(0)
Else
    fSpec = "index.xml"
End If
Set WshShell = WScript.CreateObject("WScript.Shell")
mypath = fso.GetFile(WScript.ScriptFullName).parentFolder
toolpath = "..\tools\dwxmlxslt.vbs"
dwxmlvalidate = fso.BuildPath(mypath , toolpath)
dwxmlvalidate = fso.GetAbsolutePathName(dwxmlvalidate)

if fso.FileExists(dwxmlvalidate) Then
    ' change directory to my directory as wshshell.run 
    ' doesn't like directories with spaces
    WshShell.CurrentDirectory = mypath
    ' Put quotes around filespec in case of special chars like blanks
    rc = WshShell.Run(toolpath & " """ & fspec & """", 1, false)
Else
    Wscript.Echo "Error: " & vbTab & "Cannot locate validation file" & vbNewLine & _
    vbTab & dwxmlvalidate &vbNewLine    
End If
