Public Function fn_Classic_SelectStatus_SetPlannedBIDDate()
	Dim intCounter
	Dim oWndControl

	'Wait For Trading Entity Combobox to appear
	Set oWndControl = Window("AmdocsCRM").Window("QuoteWindow").WinComboBox("cmbStatus")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "QuoteWindow")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Status
	blnResult = selectFromChildWindowComboBox("cmbStatus", "In Progress")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5
	
	intCounter = 0
	Do
		intCounter = intCounter + 1
		'Click on Planned BID Date button
		blnResult = clickChildWindowButton("btnPlannedBIDDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function	
		If intCounter = 5 Then Exit Do
	Loop Until oParentWindow.Dialog("DateTimeEntry").Exist(10)
		
	Call fn_Classic_SetDialogDate(Date)
	If Not Environment("Action_Result") Then
		Call ReportLog("Set Date", "Set Date should be successful", "Set Date is not successful", "FAIL", True)
		Exit Function
	End If
	
	'Click on Save Button
	blnResult = clickChildWindowButton("btnSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Hard Code wait to Save the attributes Set
	If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgForecastIssue").Exist(60) Then
		Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnYes").Click
		Wait 15
	End If

End Function
