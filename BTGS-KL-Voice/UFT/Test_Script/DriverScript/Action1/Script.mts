'===================================================================================================================
'================================================== DRIVER SCRIPT ======================================================
'===================================================================================================================
Call fLoadConfiguration()
Environment("Action_Result") = True
If UCase(Environment("TestCaseLevelReporting")) = "NO" Then
	gstrReportFileName = "Automation_HTML_Log_" & Replace(Replace(Replace(Date, "/", "_"),":","_")," ","_")
End If
gstrErrFile = Environment("QTPLoggerLogDir") & "\ErrFile.txt"
gstrLogFile = Environment("QTPLoggerLogDir") & "\LogFile.txt"
gstrTempResPath = Environment("HTMLRptDir") & "\" 
Call fRunFramework()
'===================================================================================================================
'===================================================================================================================
'MsgBox "Driver Script Completed : " & Now, vbOKOnly, "Driver Script  Completion"


