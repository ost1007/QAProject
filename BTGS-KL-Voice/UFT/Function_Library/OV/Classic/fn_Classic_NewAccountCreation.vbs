Public Function fn_Classic_NewAccountCreation(ByVal BFGCustomerID, ByVal BFGCustomerName)
	Dim oWndControl
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on New from Menu
	blnResult = pressWinToolbar("StingrayMenuBar", "New")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	'Select Account from Context Menu
	blnResult = selectFromWinMenu("ContextMenu", "Account")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 10
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "NewAccountCreation")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Click on Create New Account Button
	blnResult = clickChildWindowButton("btnCreateNewAccount")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For Search in BFG button to appear
	Set oWndControl = oParentWindow.Window("SearchCustomerInBFG").WinButton("btnSearchInBFG")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "SearchCustomerInBFG")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Enter Customer ID
	blnResult = enterChildWindowText("txtBFGCustomerID", BFGCustomerID)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Customer Name
	blnResult = enterChildWindowText("txtBFGCustomerName", BFGCustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Search in BFG
	blnResult = clickChildWindowButton("btnSearchInBFG")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check if No Results Found Dialog is appearing
	If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgNoRecordsFound").Exist(60) Then
		Call ReportLog("BFG Search", "Search should be successful for <B>" & BFGCustomerName & "</B>", "No Records found", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check if Results Grid Exists or not
	If Not oChildWindow.WinTable("grdResults").Exist(0) Then
		Call ReporLog("BFG Search", "Results Grid should be visible", "Results Grid is not displayed in application", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Err.Clear
	On Error Resume Next
		oChildWindow.WinTable("grdResults").SelectRow "#1"
		If Err.Number <> 0 Then
			Call ReportLog("Results GRID", "Table should contain Row for selection", "Table contains no rows", "FAIL", True)
			Environment("Action_Result") = False ': Exit Function
		End If
		strBFGCustomerID = Trim(oChildWindow.WinTable("grdResults").GetCellData("#1", "#1"))
		If strBFGCustomerID = BFGCustomerID Then
			Call ReporLog("BFG Search", "Results Grid should be populated for Customer ID<B> " & BFGCustomerID & "</B>", "Results Grid is populated for Customer ID <B>" & BFGCustomerID & "</B>", "PASS", True)			
		End If	
	On Error Goto 0
	
	'Click on Continue with Account Creation
	blnResult = clickChildWindowButton("btnContinueWithAccountCreation")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check if Successfully navigated to Account Details Window
	blnResult = oParentWindow.Window("AccountDetails").Exist(180)
	If blnResult Then
		Call ReportLog("Navigation", "Should be navigated to Account Details Page", "Navigated to Account Details Page", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Navigation", "Should be navigated to Account Details Page", "Not navigated to Account Details Page", "FAIL", True)
		Environment("Action_Result") = False
	End If
End Function
