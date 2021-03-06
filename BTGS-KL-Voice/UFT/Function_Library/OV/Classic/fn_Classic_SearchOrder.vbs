Public Function fn_Classic_SearchOrder(ByVal OrderNumber, ByVal QuoteOwner)
	Dim oWndControl
	Dim intCounter, intRows
	Dim strOrderNumber, strOrderStatus, strOwnerName
	Dim blnYankDlgVisible, blnSearch, blnYank
	
	blnYank = True
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Click on Apps from Menu
	blnResult = pressWinToolbar("StingrayMenuBar", "Apps")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	
	'Select ClearSales from Context Menu
	blnResult = selectFromWinMenu("ContextMenu", "ClearSales	Ctrl+7")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 2
	
	'Click on Select from Menu
	blnResult = pressWinToolbar("StingrayMenuBar", "Select")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	
	'Select Orders from Context Menu
	blnResult = selectFromWinMenu("ContextMenu", "Orders")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 30
	
	'Wait For Search in BFG button to appear
	Set oWndControl = oParentWindow.Window("UserBin").WinButton("btnFind")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "UserBin")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	oChildWindow.WinTable("grdOrders").SetCellData "#1", "#2", CStr(OrderNumber)
	Wait 2
	
	'Click on Find
	blnResult = clickChildWindowButton("btnFind")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnSearch = False
	For intCounter = 1 To 30
		intRows = oChildWindow.WinTable("grdOrders").RowCount
		If intRows = 2 Then
			blnSearch = True
			Exit For '#intCounter
		Else
			Wait 10
			oChildWindow.WinTable("grdOrders").RefreshObject
		End If
	Next
	
	If Not blnSearch Then
		Call ReportLog("Search Order", "Order Search for <B>" & OrderNumber & "</B> should be successful", "Order Search for <B>" & OrderNumber & "</B> was unsuccessful", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Order Search was successful or not
	strOrderNumber = oChildWindow.WinTable("grdOrders").GetCellData("#2", "#2")
	strOrderStatus = oChildWindow.WinTable("grdOrders").GetCellData("#2", "#6")
	strOwnerName = oChildWindow.WinTable("grdOrders").GetCellData("#2", "#7")
	If strOrderNumber = OrderNumber Then
		Call ReportLog("Search Order", "Order Search for <B>" & OrderNumber & "</B> should be successful", "Order Search for <B>" & OrderNumber & "</B> successful", "PASS", True)
		Call ReportLog("Search Order", "Order Search for <B>" & OrderNumber & "</B> should be successful", "Order Status is found to be <B>" & strOrderStatus & "</B>", "PASS", False)
	Else
		Call ReportLog("Search Order", "Order Search for <B>" & OrderNumber & "</B> should be successful", "Order Search for <B>" & OrderNumber & "</B> was unsuccessful", "FAIL", True)
	End If
	
	'Do 
	If UCase(strOwnerName) = UCase(QuoteOwner) Then blnYank = False
	
	oChildWindow.WinTable("grdOrders").SelectRow "#2"
	Wait 2
	oChildWindow.WinTable("grdOrders").ActivateRow "#2"
	
	'To Handle Dialog ig No Association of Price exists
	With oParentWindow.Dialog("WindowDialogs")
		If .Exist(60) Then
			If .Static("msgNoPriceAssociation").Exist(60) Then
				Call ReportLog("Classic Message", "Pop up should exist", .Static("msgNoPriceAssociation").GetROProperty("text"), "Information", True)
				.WinButton("btnOK").Click
				
				If .Static("msgNoPriceAssociatedWithCurrency").Exist(30) Then .WinButton("btnOK").Click
			Else
				Call ReportLog("Classic Message", "Encountered Pop up", "Pop up not handled", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End With
	
	'Wait For Win Tab Header to appear
	Set oWndControl = oParentWindow.Window("QuoteWindow").WinComboBox("cmbStatus")
	blnResult = waitForWindowControl(oWndControl, 120)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 10
	If Window("AmdocsCRM").Window("UserBin").Exist(0) Then 
		Window("AmdocsCRM").Window("UserBin").Close
	End If
	Wait 10
	
	'If Logged in User and Quote Owner is same then no need to Yank
	If blnYank Then
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
		
		strRetrievedText = oParentWindow.Dialog("Yank").WinEdit("txtID").GetROProperty("text")
		If strRetrievedText <> OrderNumber Then
			Call ReportLog("Yank", "Yank Dialog Text should contain " & OrderNumber, "Yank Dialog doesn't contain text " & OrderNumber, "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		'Click on Yank Button
		blnResult = clickDialogButton("Yank", "btnYank")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		Wait 5
		
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
	End If

End Function
