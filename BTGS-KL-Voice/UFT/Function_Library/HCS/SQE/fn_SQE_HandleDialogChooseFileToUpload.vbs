'****************************************************************************************************************************
' Function Name	: fn_SQE_HandleDialogChooseFileToUpload 
' Purpose		: Function to Handle Dialog to type the File and Open It
' History 			:		Author				Date		Version		Changes implemented
	' Created By	: BT Automation Test Team 24/05/16 		v1.0				N/A
	' Modified By	:
' Parameters 		: FileLocation
' Return Values : Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_HandleDialogChooseFileToUpload(ByVal FileLocation)

	Dim intCounter
	Dim blnExist
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 20
	blnExist = objBrowser.Dialog("dlgChooseFile2Upload").Exist(5)
		If blnResult Then Exit For
	Next
	
	If Not blnExist Then
		Call ReportLog("Dialog Choose File 2 Upload", "Dialog Box should appear to choose the file to upload", "Dialog Box [Choose File to Upload] doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	objBrowser.Dialog("dlgChooseFile2Upload").Activate
	objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").HighLight
	objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").Click
	objBrowser.Dialog("dlgChooseFile2Upload").WinEdit("txtFileName").Set ""
	CreateObject("Mercury.DeviceReplay").SendString FileLocation
	Wait 5 'Typing on Control with lengthier path will take time
	'objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").Type FileLocation
	blnResult = objBrowser.Dialog("dlgChooseFile2Upload").WinEdit("txtFileName").WaitProperty("text", FileLocation, 1000*60*1)
	If Not blnResult Then
		Call ReportLog("Type File Path", FileLocation & " - path should be typed", "Unable to set the path", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		objBrowser.Dialog("dlgChooseFile2Upload").Activate
		objBrowser.Dialog("dlgChooseFile2Upload").WinButton("btnOpen").Click
	End If	
End Function


