Public Function fn_Classic_FillDetailsAndCreateAccount(ByVal TradingEntity, ByVal MainContactFirstName, ByVal MainContactLastName, ByVal MainContactPhone, ByVal StreetNumber, _
	ByVal CountryName, ByVal City, ByVal PostalCode, ByVal Currncy, ByVal InfoCurrency, ByVal CreditClass)
	
	Const NORECORDFOUND = "No records have been found. Please redefine your seaich criteria."
	Const INVALIDCITY = "This city is not included in the list of valid cities for ORION."
	Const HIERARCHYACCOUNT = "This Account will  be saved without any hierarchy. Do you wish to continue?"
	Const BACINVENTORYING = "The account has not any billing accounts. This account cannot be inventoried. Please review/complete the data."
	
	'Wait For Trading Entity WinEdit to appear
	Set oWndControl = Window("AmdocsCRM").Window("AccountDetails").WinComboBox("cmbLegalID")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "AccountDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function		
	
	'Select Legal ID as NA
	blnResult = selectFromChildWindowComboBox("cmbLegalID", "NA")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Trading Entity Button
	blnResult = clickChildWindowButton("btnTradingEntity")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For Trading Entity WinEdit to appear
	Set oWndControl = oParentWindow.Window("TradingEntity").WinEdit("txtTradingEntity")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "TradingEntity")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Trading Entiry
	blnResult = enterChildWindowText("txtTradingEntity", TradingEntity)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Find Button
	blnResult = clickChildWindowButton("btnFind")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check if Searching Trading Entity was successful or not
	If oParentWindow.Dialog("WindowDialogs").Exist(30) Then
		strMessage = oParentWindow.Dialog("WindowDialogs").Static("msgGeneral").GetROProperty("text")		
		If Instr(strMessage, NORECORDFOUND) > 0 Then
			Call ReportLog("Search Trading Entity", "<B>" & TradingEntity & "</B> search should be successful", strMessage, "FAIL", True)
			Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	blnFound = False
	intRows = 0
	Err.Clear
	On Error Resume Next
		intRows = oChildWindow.WinTable("grdResults").RowCount
		For iRow = 1 To intRows
			strCellData = 	UCase(Trim(oChildWindow.WinTable("grdResults").GetCellData("#" & iRow, "#2")))
			If strCellData = UCase(TradingEntity) Then
				oChildWindow.WinTable("grdResults").SelectRow "#" & iRow
				blnFound = True
				Exit For '#iRow
			End If
		Next '#iRow

		If Err.Number <> 0 Then
			Call ReportLog("Results GRID", "Table should contain Row for selection", "Table contains no rows", "FAIL", True)
			Environment("Action_Result") = False ': Exit Function
		End If
	On Error Goto 0
		
	'Click on Use/Done Button
	blnResult = clickChildWindowButton("btnUseDone")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For Trading Entity WinEdit to appear
	Set oWndControl = oParentWindow.Window("AccountDetails").WinEdit("txtTradingEntity")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "AccountDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	strTradingEntity = oChildWindow.WinEdit("txtTradingEntity").GetROProperty("text")
	If strTradingEntity = "" Then
		Call ReportLog("Trading Entity", "Trading Entity should be set with <B>" &  TradingEntity & "</B>", "Trading Entity should be set with <B>#BLANK</B>", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Trading Entity", "Trading Entity should be set with <B>" &  TradingEntity & "</B>", "Trading Entity should be set with <B>" &  strTradingEntity & "</B>", "Information", False)
	End If

	'Enter Main Contact FirstName
	blnResult = enterChildWindowText("txtFirstName", MainContactFirstName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Main Contact LastName
	blnResult = enterChildWindowText("txtLastName", MainContactLastName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Main Contact Phone
	blnResult = enterChildWindowText("txtPhone", MainContactPhone)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Central Site Street/Number
	blnResult = enterChildWindowText("txtStreetNumber", StreetNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Country
	blnResult = selectFromChildWindowComboBox("cmbCountry", CountryName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Select Country
	blnResult = selectFromChildWindowComboBox("cmbCountry1", CountryName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter City
	blnResult = enterChildWindowText("txtCity", """" & City & """")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on City Button
	blnResult = clickChildWindowButton("btnCity")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check if Searching Trading Entity was successful or not
	If oParentWindow.Dialog("WindowDialogs").Exist(30) Then
		strMessage = oParentWindow.Dialog("WindowDialogs").Static("msgGeneral").GetROProperty("text")
		If Instr(strMessage, INVALIDCITY) > 0 Then
			Call ReportLog("Search City", "<B>" & City & "</B> search should be successful", strMessage, "Information", True)
			Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
		
			Wait 5
			
			'Enter City
			blnResult = enterChildWindowText("txtCity", City)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Click on City Button
			blnResult = clickChildWindowButton("btnCity")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			If oParentWindow.Dialog("WindowDialogs").Exist(30) Then
				strMessage = oParentWindow.Dialog("WindowDialogs").Static("msgGeneral").GetROProperty("text")
				If Instr(strMessage, INVALIDCITY) > 0 Then
					Call ReportLog("Search City", "<B>" & City & "</B> search should be successful", strMessage, "FAIL", True)
					Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
					Environment("Action_Result") = False : Exit Function
				End If
			End If
		End If
	End If
	
	'Enter Postal Code
	blnResult = enterChildWindowText("txtPostalCode", PostalCode)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Add Button
	blnResult = clickChildWindowButton("btnAdd")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	If oParentWindow.Dialog("WindowDialogs").Static("msgAccountSaveWithoutHierarchy").Exist(60) Then
		Call ReportLog("Confirmation", HIERARCHYACCOUNT & "</BR> Message should exist", HIERARCHYACCOUNT & "</BR>Message Exists", "PASS", True)
		oParentWindow.Dialog("WindowDialogs").WinButton("btnYes").Click
	Else
		Call ReportLog("Confirmation", HIERARCHYACCOUNT & "</BR> Message should exist", HIERARCHYACCOUNT & "</BR>Message doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Pop Occurs if Contact Already Exists in Data Base
	If oParentWindow.Dialog("WindowDialogs").Static("msgContactAlreadyExists").Exist(60) Then
		oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
	End If
	
	blnNotInventories =  oParentWindow.Dialog("WindowDialogs").Static("msgBACNotInventoried").Exist(60)
	If blnNotInventories Then
		Call ReportLog("BAC Inventoring", BACINVENTORYING & "</BR>Message should exist", BACINVENTORYING & "</BR>Message Exists", "PASS", True)
		oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
		'Click on Add Button
		blnResult = clickChildWindowButton("btnBillingAccount")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Enter Billing Account Details and Inventory it
		Call fn_Classic_EnterBillingAccountDetails(Currncy, InfoCurrency, CreditClass)
			If Not Environment("Action_Result") Then Exit Function
		
		
		Set oWndControl = Window("AmdocsCRM").Window("AccountDetails").WinButton("btnSave")
		blnResult = waitForWindowControl(oWndControl, 60)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Build Amdocs Reference
		blnResult = BuildAmdocsWindowReference("AmdocsCRM", "AccountDetails")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function		
		
		'Click on Save Button
		blnResult = clickChildWindowButton("btnSave")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	Wait 60
	
	strClassicID = Window("AmdocsCRM").Window("AccountDetails").WinEdit("txtCustomerClassicID").GetROProperty("text")
	If strClassicID <> "" Then
		Call ReportLog("Customer Classic ID", "Customer Classic ID should be generated", "Customer Classic ID is found to be <B>" & strClassicID & "</B>", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Customer Classic ID", "Customer Classic ID should be generated", "Customer Classic ID is not generated", "FAIL", True)
		Environment("Action_Result") = False
	End If
	'Call ReportLog("BAC Inventoring", BACINVENTORYING & "</BR>Message should exist", HIERARCHYACCOUNT & "</BR>Message doesn't exist", "FAIL", True)
	
	Window("AmdocsCRM").Close
End Function
