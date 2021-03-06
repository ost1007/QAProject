Public Function fn_Classic_SetInstallationDate()
	Dim strServiceName
	
	'Function Call to Navigate to Project
	strServiceName = fn_Classic_Navigate2Project()
		If Not Environment("Action_Result") Then Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSales", "CommercialProject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Select GONEV Project to Proceed with
	blnResult = selectFromChildWindowComboBox("cmSubProjectName", strServiceName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select Subproject from WinTab
	blnResult = selectItemFromWinTab("tbSubHeader", "Subproject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 10

	'Wait For Installation Complete Text to appear
	Set oWndControl = oParentWindow.Window("CommercialProject").WinEdit("txtInstallationCompleteDate")
	blnResult = waitForWindowControl(oWndControl, 120)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	strInstallationDate = oChildWindow.WinEdit("txtInstallationCompleteDate").GetROProperty("text")
	If IsDate(strInstallationDate) Then
		Call ReportLog("Set Installation Date", "Installation Date has to be set", "Installation Date is set with <B>" & strInstallationDate & "</B>", "PASS", True)
		Environment("Action_Result") = False : Exit Function
		Exit Function
	End If
	
	'Click on Installation Date
	blnResult = clickChildWindowButton("btnSelectInstallationCompleteDate")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 10
	
	For intCounter = 1 To 5
		If True Then
			If Window("AmdocsCRM").Dialog("DateTimeEntry").WinButton("btnOK").Exist(60) Then
				Exit For
			Else
				Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnSelectInstallationCompleteDate").Click
			End If
		End If
	Next
	
	Call fn_Classic_SetDialogDate(Date)
	If Not Environment("Action_Result") Then
		Call ReportLog("Set Date", "Set Date should be successful", "Set Date is not successful", "FAIL", True)
		Exit Function
	End If

	'The service elements with no activation date have been updated with date .*\. Please validate the Order to make these changes effective\. message should appear
	If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgActivateDateMsgSet").Exist(120) Then
		strMessage = oParentWindow.Dialog("dlgAmdocsCRM").Static("msgActivateDateMsgSet").GetROProperty("text")
		Call ReportLog("Set Installation Date", "Installation Date has to be set", strMessage, "PASS", True)
		Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
	Else
		Call ReportLog("Set Installation Date", "Installation Date has to be set", "Message with new date has been set has not appeared", "Warnings", True)
	End If
	
	If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgServicesCannotBeActivated").Exist(60) Then
		Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
	End If
	
	Wait 5
	
	'Wait For Installation Complete Text to appear
	Set oWndControl = oChildWindow.WinEdit("txtInstallationCompleteDate")
	blnResult = waitForWindowControl(oWndControl, 180)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	oChildWindow.WinEdit("txtInstallationCompleteDate").RefreshObject
	strInstallationDate = oChildWindow.WinEdit("txtInstallationCompleteDate").GetROProperty("text")
	If IsDate(strInstallationDate) Then
		Call ReportLog("Set Installation Date", "Installation Date has to be set", "Installation Date is set with <B>" & strInstallationDate & "</B>", "PASS", True)
	Else
		Call ReportLog("Set Installation Date", "Installation Date has to be set", "Installation Date is set with <B>" & strInstallationDate & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If


End Function
