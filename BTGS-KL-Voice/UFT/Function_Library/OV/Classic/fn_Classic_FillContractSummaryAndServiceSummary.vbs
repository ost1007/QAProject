Public Function fn_Classic_FillContractSummaryAndServiceSummary(ByVal BusinessManagerFirstName, ByVal BusinessManagerLastName)
	'Variable Declaaration
	Const NOEMPMSG = "No employee in the database matches your search criteria."
	Const INACTIVEEMPMSG = "This employee is inactive in the BID/Order for the selected role. It will be activated again after clicking the Add button."
	Dim intCounter
	Dim strMessage
	
	For intCounter = 1 To 5
		If Window("AmdocsCRM").Window("QuoteWindow").Exist(60) Then
			Window("AmdocsCRM").Window("QuoteWindow").Maximize
		End If
	Next
	
	For intCounter = 1 To 3
		If Window("AmdocsCRM").Window("QuoteWindow").WinTab("tbHeader").Exist(60) Then
			Window("AmdocsCRM").Window("QuoteWindow").WinTab("tbHeader").Select "Contract Summary"
			Wait 5
		End If
		
		'If Not found then below code will fail
		If Window("AmdocsCRM").Window("QuoteWindow").WinComboBox("cmbRole").Exist(60) Then
			Exit For '#intCounter
		End If
	Next '#intCounter
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "QuoteWindow")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Select Service/Subproject from WinTab
	blnResult = selectItemFromWinTab("tbHeader", "Contract Summary")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For View Project button to appear
	Set oWndControl = oChildWindow.WinComboBox("cmbRole")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Business Manager in Role
	blnResult = selectFromChildWindowComboBox("cmbRole", "Business Manager")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Business Manager Details
	blnResult = enterChildWindowText("txtFirstName", BusinessManagerFirstName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	blnResult = enterChildWindowText("txtLastName", BusinessManagerLastName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Validate Role Manager
	blnResult = clickChildWindowButton("btnValidateRoleManager")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Role that we are identifying should be validated
	If oParentWindow.Dialog("WindowDialogs").Exist(30) Then '#1 Start
		strMessage = Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgGeneral").GetROProperty("text")
		If Instr(strMessage, NOEMPMSG) > 0 Then '#2 Start
			Call ReportLog("Role Manager", "Should Validate the Contact Details entered", "Pop-up encountered</BR>" & NOEMPMSG, "FAIL", True)
			oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
			Environment("Action_Result") = False : Exit Function
		ElseIf Instr(strMessage, INACTIVEEMPMSG) > 0 Then
			Call ReportLog("Role Manager", "Should Validate the Contact Details entered", "Pop-up encountered</BR>" & INACTIVEEMPMSG, "Information", True)
			oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
		Else
			Call ReportLog("Role Manager", "Should Validate the Contact Details entered", "Pop-up encountered</BR>" & strMessage, "FAIL", True)
			oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
			Environment("Action_Result") = False : Exit Function
		End If '#2 End
	End If '#1 'End
	
	'Click on Add button
	blnResult = clickChildWindowButton("btnAdd")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5
	
	'For Reactivation of Employee
	If oParentWindow.Dialog("WindowDialogs").Static("msgReactivateEmployee").Exist(10) Then
		oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
		If oParentWindow.Dialog("WindowDialogs").Static("msgReactivateEmployeeConfirmation").Exist(10) Then
			oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
		End If
	End If
	
	'Click on Save Button
	blnResult = clickChildWindowButton("btnSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 5
	'Select Service Summary from WinTab
	blnResult = selectItemFromWinTab("tbHeader", "Service Summary")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	intRows = oChildWindow.WinTable("grdServices").RowCount
	For iRow = 1 To intRows
		oChildWindow.WinTable("grdServices").SelectRow "#" & iRow
		
		If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgSomeDataChangeSave").Exist(30) Then
			Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnYes").Click
			Wait 10
			Do
				If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgWish2PropagateDates").Exist(30) Then
					Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnNo").Click
					Wait 10
				End If
			Loop Until Not Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgWish2PropagateDates").Exist(30)
			
			oChildWindow.WinTable("grdServices").SelectRow "#" & iRow
			Wait 5
		End If

		
		'Click CRD button
		blnResult = clickChildWindowButton("btnCRD")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Wait 5
		
		Call fn_Classic_SetDialogDate(Date + 8)
		If Not Environment("Action_Result") Then
			Call ReportLog("Set CRD", "CRD Date should be Set successful", "Setting CRD Date was unsuccessful", "FAIL", True)
			Exit Function
		End If
		Wait 2
		
		If Window("AmdocsCRM").Window("QuoteWindow").WinButton("btnICD").GetROProperty("enabled") Then
			'Click ICD button
			blnResult = clickChildWindowButton("btnICD")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 5
			
			Call fn_Classic_SetDialogDate(Date + 5)
			If Not Environment("Action_Result") Then
				Call ReportLog("Set ICD", "ICD Date should be Set successful", "Setting ICD Date was unsuccessful", "FAIL", True)
				Exit Function
			End If
		End If
		
		Wait 2
		'Click CCD button
		blnResult = clickChildWindowButton("btnCCD")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Wait 5
		
		Call fn_Classic_SetDialogDate(Date + 5)
		If Not Environment("Action_Result") Then
			Call ReportLog("Set CCD", "CCD Date should be Set successful", "Setting CCD Date was unsuccessful", "FAIL", True)
			Exit Function
		End If
		
		Wait 2
		'Click ScheduledInstallationDate button
		blnResult = clickChildWindowButton("btnScheduledInstallationDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Wait 5
		
		Call fn_Classic_SetDialogDate(Date)
		If Not Environment("Action_Result") Then
			Call ReportLog("Set Scheduled Installation Date", "Scheduled Installation Date should be Set successful", "Setting Scheduled Installation Date was unsuccessful", "FAIL", True)
			Exit Function
		End If
		
		Wait 2		
		'Click PlannedCustSVCReadyDate button
		blnResult = clickChildWindowButton("btnPlannedCustSVCReadyDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Wait 5
		
		Call fn_Classic_SetDialogDate(Date)
		If Not Environment("Action_Result") Then
			Call ReportLog("Set Planned Cust SVC Ready Date", "Planned Cust SVC Ready Date should be Set successful", "Setting Planned Cust SVC Ready Date was unsuccessful", "FAIL", True)
			Exit Function
		End If
		
		'Set Failure Code as Random
		blnResult = selectFromChildWindowComboBox("cmdFailureCode", "Jeopardy")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			
		oChildWindow.WinObject("winFailureReport").Click
		Wait 2
		oChildWindow.WinObject("winFailureReport").Type "Dummy"
		Wait 5		
	Next '#iRow
	
	Wait 2
	'Click Save Service button
	blnResult = clickChildWindowButton("btnSaveService")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 30
	
	If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgSomeDataChangeSave").Exist(30) Then
		Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnYes").Click
		Wait 10
	End If
	
	Do
		If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgWish2PropagateDates").Exist(30) Then
			Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnYes").Click
			Wait 10
		End If
	Loop Until Not Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgWish2PropagateDates").Exist(30)
	Wait 5
	
End Function
