Public Function fn_Classic_YankUnderSubcase()
	
	Dim intCounter
	Dim blnYankDlgVisible
	
	Environment("Action_Result") = True
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSupport", "ReadSubcase")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Select from Menu
	blnResult = pressWinToolbar("StingrayMenuBar", "Desktop")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	
	'Select Orders from Context Menu
	blnResult = selectFromWinMenu("ContextMenu", "Yank	Ctrl+Shift+Y")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	Set oWndControl = oParentWindow.Dialog("Yank").WinButton("btnYank")
	blnResult = waitForWindowControl(oWndControl, 120)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Yank Button
	blnResult = clickDialogButton("Yank", "btnYank")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 5
	
	'Should verify the message that appears while yanking
	Set oWndControl = Dialog("dlgAmdocsCRM").Static("msgYankConfirmation")
	blnResult = waitForWindowControl(oWndControl, 120)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Call ReportLog("Yank", "Yanking confirmation Dialog with message should exist", "Yanking confirmation Dialog with message is visible", "PASS", True)
	
	Dialog("dlgAmdocsCRM").WinButton("btnOK").Click
	Wait 10
	
	blnYankDlgVisible = True
	
	'Check whether Yank Dialog is disapperared or not
	For intCounter = 1 To 20
		If Not oParentWindow.Dialog("Yank").WinButton("btnYank").Exist(10) Then
			blnYankDlgVisible = False
			Exit For
		End If
	Next
	
	If Not blnYankDlgVisible Then
		Call ReportLog("Yank", "Yanking should be successful", "Yanking was successful", "PASS", True)
		Wait 10
	Else
		Call ReportLog("Yank", "Yanking should be successful", "Yanking was unsuccessful", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
End Function
