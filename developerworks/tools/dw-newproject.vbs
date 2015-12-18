' See the "Author guidelines" tab at 
' http://www.ibm.com/developerworks/aboutdw/
' for more information on how to use this program.
' © Copyright IBM Corporation 2004, 2005. All rights reserved.
Option explicit

Dim toolpath, fso, dwVersion

Function GetdWVersion()
'  Read current dwVersion from dwversion.txt file
   Const ForReading = 1
   Dim f: set f = fso.OpenTextFile(fso.BuildPath(toolpath,"dwversion.txt"),ForReading)
   Dim s: s = Trim(f.ReadLine())
   if s = "" then
       s = "5.2"
   End If
   f.close()
   GetdWVersion = s
End Function


Function GetProjectName(projtype)
    Dim resp1, projname, projparent, projprompt, foldername, retryMsg, defaultname
    resp1 = vbRetry
    projprompt = "Please provide a name for your new project folder" & vbNewLine & _
                 "Do not include path elements (\) in the name."

    If projtype = "tutorial" Then
        defaultname = "my-tutorial"
    Else
        defaultname = "my-article"
    End if
    while (resp1 = vbRetry)
        projname = InputBox(projprompt , "IBM developerWorks", defaultname )


        if projname = "" Then
            resp1 = vbCancel
        ElseIf resp1 = vbCancel Then
            projname = ""
        Else
            projparent = fso.GetParentFolderName(projname)
            If (projparent = "") Then
                foldername = fso.BuildPath(toolpath, "../" & projname )
                foldername = fso.GetAbsolutePathName(foldername)
                If (fso.FileExists(foldername) Or fso.FolderExists(foldername))  Then
                    retryMsg = "Error:" & vbTab & projname & " exists"    
                Else
                    resp1 = vbOK
                End if
            Else
                retryMsg = "Error:" & vbTab & "You must specify a simple name without path elements (\)"    
            End If

            if resp1 = vbRetry Then
                resp1 = MsgBox(retryMSg, _
                    vbRetryCancel + vbQuestion + vbDefaultButton1, _
                        "IBM developerWorks")
            End If
        End If
        if resp1 = vbCancel Then 
            projname = ""
        End If
    Wend
    GetProjectName = projname
End Function

Function CopyProjectFiles(projname, projtype)
    Dim basefolder, infile, outfile, inpath, outpath, f
    basefolder = fso.GetParentFolderName(toolpath)
    inpath = fso.BuildPath(basefolder, "tools")

    outpath = fso.BuildPath(basefolder,projname)
    fso.CreateFolder outpath

    If projtype = "tutorial" Then
        infile = fso.BuildPath(inpath, "template-dw-tutorial-" & dwVersion & ".xml")
    Else
        infile = fso.BuildPath(inpath, "template-dw-article-" & dwVersion & ".xml")
    End if
    outfile = fso.BuildPath(outpath, "index.xml")
    fso.CopyFile infile, outfile

    infile = fso.BuildPath(inpath, "dw-transform.vbs")
    outfile = fso.BuildPath(outpath, "dw-transform.vbs")
    fso.CopyFile infile, outfile

    CopyProjectFiles = projname
End Function

Sub Main
    Dim pname, errorCode, ptype
    If Wscript.Arguments.Length > 0 Then
        ptype= Wscript.Arguments.Item(0)
    else
        ptype="article"
    end if
    Set fso = CreateObject("Scripting.FileSystemObject")
    toolpath = fso.GetFile(WScript.ScriptFullName).parentFolder
    dwVersion = GetdWVersion()
    pname = GetProjectName(ptype)
    if pname <> "" Then
        CopyProjectFiles pname, ptype
        errorCode = false
    Else
        errorCode = true
    End If
    wscript.quit(errorCode)
End sub

Main
