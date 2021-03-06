Public Function fn_TAHITI_UpdateMNUMProvide()
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	blnResult = clickFrameLink("lnkNumberBlockExport")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Wait 10
	'On Error Resume Next
	'For intCounter = 1 to 5
	'	If Not objBrowser.Dialog("dlgSaveAs").Exist(1) Then
	'		objBrowser.WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Highlight
	'		objBrowser.WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Click
	'		Wait 1
	'		objBrowser.WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Clickontext "Save",,,,,true, micRightBtn, true
	'		Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	'		DeviceReplay.PressKey 208 'Presses 'down arrow' key
	'		DeviceReplay.PressKey 30 'Presses 'a' key
	'	End If
	'Next
	'On Error Goto 0
	
	Set oNotification = objBrowser.WinObject("text:=Do you want to open or save.*", "index:=0")
	For intCounter = 1 To 5
		If oNotification.Exist Then
			oNotification.WinButton("nativeclass:=drop down button").Click
			Wait 2
			objBrowser.WinMenu("menuobjtype:=3").Select "Save as"			
		End If
		
		
		If objBrowser.Dialog("dlgSaveAs").Exist(5) Then
			Exit For '#intCounter
		End If
	Next '#intCounter

	strFileName = fn_TAHITI_SaveFile(Left(Environment("TestDataPath"), InStrRev(Environment("TestDataPath"), "\")))
	If strFileName = "" Then
		Call ReportLog("Save File", "File Should be Saved", "File Could not be saved", "FAIL", False)
		Environment("Action_Result") = False
		fn_TAHITI_UpdateMNUMProvide = ""
		Exit Function
	Else
		Call ReportLog("Save File", "File Should be Saved", "File saved in " & strFileName, "INFORMATION", False)
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dMNUMFIleName", strFileName)
		fn_TAHITI_UpdateMNUMProvide = strFileName
	End If
		
End Function
'===========================================================================================================================================
' Description: To Save File
'===========================================================================================================================================
Public Function fn_TAHITI_SaveFile(ByVal DownloadPath)
	Dim intCounter
	Dim strFileName

	For intCounter = 1 to 60
		If Browser("brwTahitiPortal").Dialog("dlgSaveAs").Exist(5) Then
			Exit For
		End If
	Next

	If intCounter > 61 Then
		Call ReportLog("Save File", "Save As Dialog Box should Apear", "Save As Dialog Box is not present on Browser", "FAIL", True)
		Environment.Value("Action_Result") = False
		Exit Function
	End If

    Browser("brwTahitiPortal").Dialog("dlgSaveAs").Activate

	'Get the FileName & Save in given Path
	strFileName = Browser("brwTahitiPortal").Dialog("dlgSaveAs").WinEdit("txtFileName").GetROProperty("text")
    strSaveFileName = DownloadPath & strFileName
	Browser("brwTahitiPortal").Dialog("dlgSaveAs").WinComboBox("cmbFileName").HighLight
	Browser("brwTahitiPortal").Dialog("dlgSaveAs").WinComboBox("cmbFileName").Type strSaveFileName	

	'Click on Save Button
	Browser("brwTahitiPortal").Dialog("dlgSaveAs").WinButton("btnSave").Click

	'Replace if FileAlready Exists
	If Dialog("dlgConfirmSaveAs").Exist(5) Then
		Dialog("dlgConfirmSaveAs").WinButton("btnYes").Click
	End If

	fn_TAHITI_SaveFile = strSaveFileName
End Function
