' See the "Author guidelines" tab at 
' http://www.ibm.com/developerworks/aboutdw/
' for more information on how to use this program.
' © Copyright IBM Corporation 2004, 2005. All rights reserved.
Option Explicit

' Define global objects and variables.
Dim fso, pgmname, filepath, toolpath, dwVersion, errorFound

Function HelpInfo
    dim helptext
    helptext = vbNewLine & _
    "About:" & vbTab & pgmname & " is an XML file validator." & vbNewLine & _
    vbNewLine & _
    "Syntax:" & vbTab & pgmname & " [input_file]" & vbNewLine & _
    vbNewLine & _
    "Where:" & vbTab & "input_file is an xml file." & vbNewLine & vbNewLine & _
    "If input_file is omitted, it defaults to index.xml.  " & _
    "If input_file is a directory," & vbNewLine & "then " & pgmname & _
    " will attempt to process index_file\index.xml" & vbNewLine & _
    "Results are returned in a console message." & vbNewLine & vbNewLine
    HelpInfo = helptext
End Function

Function SplitText(inText, maxlen)
    Dim remainder, outText, piecelen, thisPos, thisLine
    remainder = inText
    outText = ""
    while (len(remainder) > maxlen)
        thisPos = InstrRev(remainder, vbNewLine, maxlen, vbTextCompare)
        if (thisPos > 0) Then
            thisLine = left(remainder, thisPos - 1) ' will add newline later
            remainder = ltrim(right(remainder, len(remainder) - thisPos - 1)) ' 2 pos for cRLF 
        Else
            thisLine = remainder
            remainder = ""
        End If
        while (len(thisLine) > maxlen)
            thisPos = InstrRev(thisLine, " ", maxlen)
            if (thisPos = 0) Then
                thisPos = maxlen
            End If
            outText = outText & Rtrim(Left(ThisLine, thisPos)) & vbNewLine
            thisline = Right(thisLine, len(thisLine) - thisPos)
        wend
        outText = outText & Rtrim(thisLine) & vbNewLine
    wend
    SplitText= outText & remainder
End Function

Function GetScriptVersion
   GetScriptVersion = ScriptEngine & " Version " & ScriptEngineMajorVersion & "." & _
   ScriptEngineMinorVersion & "." & ScriptEngineBuildVersion
End Function

Function ValidateFile(sFile)
    Dim f, hfile, schemaCache, schemaSpec, basename, str, seearticle, xdoc, xsl, xslspec, html, htmlfile, htmlfn
    Const ForReading = 1, ForWriting = 2, ForAppending = 8
    seearticle = "See 'Using the developerWorks XML validation tools'" & vbNewLine & _
                 "(http://www.ibm.com/developerworks/library/i-dwauthors-tools/)"  & vbNewLine & _
                 "for additional information about this tool." & vbNewLine & _
                 GetScriptVersion()

    Const maxLineLen = 100

    Set f = fso.GetFile(sfile)
    schemaSpec = fso.GetAbsolutePathName(toolpath & "/../schema/" & dwVersion  & "/dw-document-" & _
        dwVersion & ".xsd")
    if (fso.FileExists(schemaSpec)) Then
        basename = f.Name
        ' Load XML input file & validate it
        On Error Resume Next
        Set xdoc = CreateObject("Msxml2.DOMDocument.4.0")
        If err <> 0 Then
          str = "Could not create document XML parser" & vbNewLine & _
                 "Ensure you have the latest MS XML Core services" & vbNewLine & _
                 seearticle
          Err.Clear
          On Error Goto 0
          errorFound = true
        Else
          On Error Goto 0
          Set schemaCache = CreateObject("Msxml2.XMLSchemaCache.4.0")
          schemaCache.add "",schemaSpec 
          xdoc.schemas = schemaCache
          xdoc.validateOnParse = True
          xdoc.async = False
          xdoc.load(sfile)
          If xdoc.parseError.errorCode = 0 Then
	  ' Schema is valid so try to run transform
              str = basename & " is valid using schema " & schemaSpec
              xslSpec = fso.GetAbsolutePathName(toolpath & "/../xsl/" & dwVersion  & _
                  "/dw-document-html-" & dwVersion & ".xsl")
              if (fso.FileExists(xslSpec)) Then
                  Set xsl = CreateObject("Msxml2.DOMDocument.4.0")
                  xsl.async = false
                  xsl.validateOnParse = false
                  xsl.resolveExternals = false
                  xsl.load(xslSpec)
                  if xsl.parseError.errorCode = 0 Then
		  ' Transform worked OK, so write output file
                      html = xdoc.transformNode(xsl)
                      htmlfn = mid(sfile, 1, len(sFile) - 4) & ".html"
                      if (fso.FileExists(htmlfn)) Then
                         Set hfile = fso.GetFile(htmlfn)
                         hfile.attributes = 0
                         fso.DeleteFile(htmlfn)
                      End If
                      On Error Resume Next
                      Set htmlfile = fso.CreateTextFile(htmlfn, True)
                      if err <> 0 then
                        str = "Unexpected error # " & err.number & " in CreateTextFile" & vbNewLine & _ 
                            err.description & vbNewLine & _
                            err.Source & vbNewLine & _ 
                            TypeName(htmlfile) & vbNewLine & _
                            GetScriptVersion()
                        err.clear
                      Else
                        htmlfile.Write html
                        ' If writing as ASCII failed, then try writing as unicode
                        If err <> 0 then
                          err.clear
                          ' First try closing and deleting the file.
                          htmlfile.Close
                          if (fso.FileExists(htmlfn)) Then
                             Set hfile = fso.GetFile(htmlfn)
                             hfile.attributes = 0
                             fso.DeleteFile(htmlfn)
                          End If
                          Set htmlfile = fso.CreateTextFile(htmlfn, True, True)
                          if err <> 0 then
                            str = "Unexpected errore # " & err.number & " in CreateTextFile" & vbNewLine & _ 
                                err.description & vbNewLine & _
                                err.Source & vbNewLine & _ 
                                TypeName(htmlfile) & vbNewLine & _
                                GetScriptVersion()
                            err.clear
                          Else
                            htmlfile.Write html
                            if err <> 0 then
                              str = "Unexpected error # " & err.number & " in HTML file writing" & vbNewLine & _ 
                                  err.description & vbNewLine & _
                                  err.Source & vbNewLine & _ 
                                  TypeName(htmlfile) & vbNewLine & _
                                  GetScriptVersion()
                              err.clear
                            Else
                              str = str & vbNewLine & vbNewLine & "HTML output is in file " & htmlfn & vbNewLine
                            End If
                          End If
                        Else
                          str = str & vbNewLine & vbNewLine & "HTML output is in file " & htmlfn & vbNewLine
                        End If
                        htmlfile.Close
                      End If
                      On Error goto 0
                  else
	            ' Transform error
                    str = str & vbNewLine & "Error: "  & vbTab & "Line: " & xsl.parseError.line & _
                      " at position: " & xsl.parseError.linepos & vbNewLine & _
                      "URL: " & vbTab & xsl.parseError.url & vbNewLine & _
                      "Schema: " & vbTab & schemaSpec & vbNewLine & _
                      "Source: " &vbTab & vbTab & xsl.parseError.srcText & vbNewLine & _
                      xsl.parseError.reason & vbNewLine & vbNewLine & _
                      seearticle
                  End If
              Else
                  str = str & vbNewLine & vbNewline & "Can't find XSL file " & xslspec
                  errorFound = true
              End If
          ElseIf xdoc.parseError.errorCode <> 0 Then
              str = "Error: "  & vbTab & "Line: " & xdoc.parseError.line & _
                " at position: " & xdoc.parseError.linepos & vbNewLine & _
                "URL: " & vbTab & xdoc.parseError.url & vbNewLine & _
                "Schema: " & vbTab & schemaSpec & vbNewLine & _
                "Source:" &vbNewLine & SplitText(xdoc.parseError.srcText, maxLineLen ) & vbNewLine & _
                "Reason:" & vbNewLine & _
                SplitText( xdoc.parseError.reason, maxLineLen ) & vbNewLine &  _
                seearticle
'                "See 'Using the developerWorks XML validation tools'" & vbNewLine & _
'                "(http://www.ibm.com/developerworks/library/i-dwauthors-tools/)"  & vbNewLine & _
'                "for additional information about this tool."
              errorFound = true
          End If
          Set schemaCache = Nothing
          Set xdoc = Nothing
        End If
    Else
        str = vbNewLine & "Error:" & vbTab & "Schema file " & _
            schemaSpec & " not found" & vbNewLine
        errorFound = true
    End If
    ValidateFile = str
End Function


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


Sub Main
    Dim fspec, outString, filetype
    ' Main code execution starts here
    'Set global constants and variables.

    errorFound = false
    Set fso = CreateObject("Scripting.FileSystemObject")
    toolpath = fso.GetFile(WScript.ScriptFullName).parentFolder

    dwVersion = GetdWVersion()
    pgmname = mid(WScript.ScriptName, 1, len(WScript.ScriptName) - 4)
    ' Get the file to be processed
    If Wscript.Arguments.Length > 0 Then
       fSpec = Wscript.Arguments.Item(0)
       if fso.FolderExists(fspec) Then
           fspec = fso.BuildPath(fspec ,"/index.xml")
       End If
    Else
       fSpec = "index.xml"
    End If

    fspec = fso.GetAbsolutePathName(fspec)
    filetype = UCase(fso.GetExtensionName(fspec))
    if filetype = "XML" Then 
        If fso.fileExists(fspec) Then
            outString = ValidateFile(fspec) 
        Else
           outString = HelpInfo()
        End If
    Else
        outString = "Error: " & vbTab & "File " & fspec & vbNewLine & _
        "is not of type .XML" & vbNewLine & vbNewLine & _
	HelpInfo()
    End If
    Wscript.Echo outString
    ' clean up and exit
    Set fso = Nothing
End Sub

' do the real work
Main
wscript.quit(errorFound)
