Public Function fn_Classic_Close()
	
	If Window("AmdocsCRM-ClearSales").Exist(15) Then
		blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSales", "")
	ElseIf Window("AmdocsCRM-ClearSupport").Exist(15) Then
		blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSupport", "")
	ElseIf Window("AmdocsCRM").Exist(15) Then
		blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
	Else
		Call ReportLog("CRM Close", "New window encountere", "Closing by process name", "Information", True)
		SystemUtil.CloseProcessByName("clarify.exe")
		Environment("Action_Result") = True : Exit Function
	End If
	
	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Apps from Menu
	blnResult = pressWinToolbar("StingrayMenuBar", "File")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	
	'Select ClearSales from Context Menu
	blnResult = selectFromWinMenu("ContextMenu", "Exit	Ctrl+Q")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 2
	
	If Dialog("dlgAmdocsCRM").Static("msgOperationCancelled").Exist(10) Then
		Dialog("dlgAmdocsCRM").WinButton("btnOK").Click
		SystemUtil.CloseProcessByName("clarify.exe")
		Environment("Action_Result") = True : Exit Function
	End If
	
End Function
