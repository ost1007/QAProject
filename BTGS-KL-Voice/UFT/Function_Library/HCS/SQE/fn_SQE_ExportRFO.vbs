'=============================================================================================================
'Description: Function to Export RFO and save File
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			30/09/2014 	v1.0
'Example: fn_SQE_ExportRFO(dRFOLocation)
'=============================================================================================================
Public Function fn_SQE_ExportRFO(ByVal dRFOLocation)

	'Declaring of variables
	Dim blnResult, blnDone
	Dim intCounter
	Dim strFileName, strSaveFileName

	If Not CreateObject("Scripting.FileSystemObject").FolderExists(dRFOLocation) Then
		Call ReportLog("RFO Download Location", dRFOLocation & " - should be present in local system", dRFOLocation & " - location could not be found", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Export RFO
	blnResult = objPage.Image("imgExportRFO").Exist(180)
	If blnResult Then
		blnResult = clickImage("imgExportRFO")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Export RFO","Export RFO image should exist","Export RFO image does not exist","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Sync
	
	'Click on OK button that gets populated on Clicking Export Option
	For intCounter = 1 To 3
		If objPage.WebElement("elmDownloadOK").Exist(30) Then
			objPage.WebElement("elmDownloadOK").Click
			Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Sync
			Exit For
		End If
	Next
	
	'======================================================================================================================================
	blnDone = fn_SQE_HandleNotificationBar()
	If Not blnDone Then
		Call ReportLog("Notification Bar", "Notification Bar should be handled successfully", "Could not be handled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	'======================================================================================================================================
	strFileName = fn_SQE_SaveFile(dRFOLocation)
	If Not Environment("Action_Result") Then
		Exit Function
	Else
		Call ReportLog("Download RFO Sheet", "RFO Sheet must be downloaded", "RFO File Name is " & strFileName, "PASS", False)
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dRFOFilePath", strFileName)
		Environment("Action_Result") = True
		fn_SQE_ExportRFO = strFileName
	End If

End Function
'===========================================================================================================================================================
' Description: Saving a File
'===========================================================================================================================================================
Public Function fn_SQE_SaveFile(ByVal DownloadPath)
	Dim intCounter
	Dim strFileName
	Dim oFSO
	Set oFSO = CreateObject("Scripting.FileSystemObject")

	For intCounter = 1 to 60
		If Dialog("dlgSaveAs").Exist(5) Then
			Exit For
		End If
	Next

	If intCounter > 61 Then
		Call ReportLog("Save File", "Save As Dialog Box should Apear", "Save As Dialog Box is not present on Browser", "FAIL", True)
		Environment.Value("Action_Result") = False
		Exit Function
	End If

	Dialog("dlgSaveAs").Activate

	'Get the FileName & Save in given Path
	strFileName = Dialog("dlgSaveAs").WinEdit("txtFileName").GetROProperty("text")
    	strSaveFileName = DownloadPath & strFileName
    	
    	'Delete the File if Already exists
    	If oFSO.FileExists(strSaveFileName) Then oFSO.DeleteFile strSaveFileName, True
	
	Dialog("dlgSaveAs").WinComboBox("cmbFileName").HighLight
	Dialog("dlgSaveAs").WinComboBox("cmbFileName").Type strSaveFileName	

	'Click on Save Button
	Dialog("dlgSaveAs").Activate
	Dialog("dlgSaveAs").WinButton("btnSave").Click

	'Replace if FileAlready Exists
	If Dialog("dlgConfirmSaveAs").Exist(5) Then
		Dialog("dlgConfirmSaveAs").WinButton("btnYes").Click
	End If
	fn_SQE_SaveFile = strSaveFileName
End Function
