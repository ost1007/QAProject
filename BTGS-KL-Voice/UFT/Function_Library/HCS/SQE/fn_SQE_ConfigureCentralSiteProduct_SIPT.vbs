'=============================================================================================================
' Description	: Function to Configure Particulars of SIP Trunking Services
' History	  	 : Name				Date			Changes Implemented
' Created By	   :  Nagaraj			10/02/2016 				NA
' Return Values : Not Applicable
' Example: fn_SQE_ConfigureCentralSiteProduct_SIPT (ProductOffering, GroupCACLimit, TrunkGroupFriendlyName, ICCallDistribution, TrunkFriendlyName,  CACLimit, CACBandwidthLimit, IncomingCLDPFormat, IncomingCLGPFormat, TrunkGroupPriority, PresentationNumberSource, OutgoingCLGPFormat, OutgoingCLDPFormat, OutboundCLIR, TrunkHandoverFormat)
'=============================================================================================================
Public Function fn_SQE_ConfigureCentralSiteProduct_SIPT(ByVal ProductOffering, ByVal GroupCACLimit, ByVal TrunkGroupFriendlyName, ByVal ICCallDistribution, ByVal TrunkFriendlyName,_
	ByVal CACLimit, ByVal CACBandwidthLimit, ByVal IncomingCLDPFormat, ByVal IncomingCLGPFormat, ByVal TrunkGroupPriority, ByVal PresentationNumberSource,_
	ByVal OutgoingCLGPFormat, ByVal OutgoingCLDPFormat, ByVal OutboundCLIR, ByVal TrunkHandoverFormat)
	
	'Variable Declaration
	Dim intCounter, intProductCol, intConfiguredCol, intPricingStatusCol, intInitWaitTime, index, iProdRow
	Dim arrColumnNames, arrColumns
	Dim strConfigured, strCellData, strPricing
	Dim blnValid, blnPriced

	'Check whether the table has been populated or not
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").Exist(60)
		If blnResult Then
			If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Table is not loaded still","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function

	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = -1 : intConfiguredCol = -1 : intPricingStatusCol = -1
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingStatusCol = intCounter + 1
		End If
	Next
	
	'Terminate if intProductCol/intConfiguredCol/intPricingStatusCol is equal to -1
	If intProductCol = -1 OR intConfiguredCol = -1 OR intPricingStatusCol = -1 Then
		Call ReportLog("Product Table Header", "Columns have been changed", "Contact Automation Team", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	intProductRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
	If intProductRow <= 0 Then
		Call ReportLog("Line Item Table", ProductOffering & " - should be present in Line Items table", ProductOffering & " - is not present in Line Items table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 To 30
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProductRow, intConfiguredCol)
		If strConfigured = "" Then
			Wait 5
		ElseIf strConfigured = "VALID" OR  strConfigured = "INVALID" Then
			blnResult = True
			Exit For
		End If
	Next

	'Check for Configuration Status
	If blnResult Then
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProductRow,intConfiguredCol)
		If strConfigured = "INVALID" And ProductOffering = "SIP Trunk Service" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'INVALID' before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","PASS", False)
		Else
			Call ReportLog("Configure Product","Configuration Status should be shown as 'INVALID' before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","FAIL", True)
			Environment("Action_Resutl") = False : Exit Function
		End If
	End If

	'Select Checkbox
	objPage.WebTable("tblProductLineItems").ChildItem(intProductRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	'Wait for Page to be Navigated to Bulk Configuration
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").Exist(60) Then Exit For
	Next
	
	'Build Web Reference
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	intInitWaitTime = 90
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	Setting.WebPackage("ReplayType") = 2 '# Changes to Mouse mode
	
	'Below is Tree Structure Found on Bulk Conifguration Page
								'============================= '
								'SIP Trunk Service                       '
								'	>External Trunk Group           '
								'		>Base Configuration        '
								'		>External Trunk              '
								'			>Base Configuration  '
								'	>One Cloud Cisco                  '
								'============================== '
	'Check for SIP Trunk Service element exists or not
	If Not objPage.WebElement("elmSIPTrunkService").Exist(10) Then
		Call ReportLog("SIP Trunk Service", "SIP Trunk Service Parent WebElement should Exist", "SIP Trunk Service Parent WebElement doesn't exist", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check External Trunk Group exists or not, if exists then click on it
	If Not objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree").WebElement("elmExternalTrunkGroup").Exist(0) Then
		Call ReportLog("External Trunk Group", "External Trunk Group WebElement should Exist", "External Trunk Group WebElement doesn't exist", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	Else
		objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree").Click
		Call ReportLog("External Trunk Group", "External Trunk Group WebElement should Exist", "External Trunk Group exists and is clicked", "Information", False)
		Wait 5
	End If
	
	'Click on Base Configuration
	With objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree").WebElement("elmBaseConfiguration")
		If .Exist(10) Then
			.Click
			Call ReportLog("Bulk Configuration", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure should exist and is to be clicked", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure exists and is clicked", "Information", False)
		Else
			Call ReportLog("Bulk Configuration", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure should exist", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure doesn't exist", "FAIL", True)
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment("Action_Result") = False : Exit Function
		End If
	End With

	'Check if Base Config Table is present or not
	If Not objPage.WebTable("tblBaseConfig").Exist(10) Then
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Set Group CAC Limit
	Call fn_SetBulkConfigTableFieldValues(2, GroupCACLimit, "Group CAC Limit")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	'Set Trunk Group Friendly Name
	Call fn_SetBulkConfigTableFieldValues(2, TrunkGroupFriendlyName, "Trunk Group Friendly Name")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	'objList.Select IncomingCLGPFormat
	Call fn_SelectBulkConfigTableFieldValues(2, ICCallDistribution, "IC Call Distribution")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	Wait 5
	
	'Click on Base Configuration under External Trunk Group	        
	With objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree").WebElement("elmBaseConfiguration")
		If .Exist(10) Then
			.Click
			Call ReportLog("Bulk Configuration", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure should exist and is to be clicked", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure exists and is clicked", "Information", False)
		Else
			Call ReportLog("Bulk Configuration", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure should exist", "SIP Trunk Service > External Trunk Group > Base Configuration Tree structure doesn't exist", "FAIL", True)
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment("Action_Result") = False : Exit Function
		End If
	End With	

	With objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree")
		.WebElement("elmExternalTrunk").Click	
		Wait 10
		.WebElement("elmExternalTrunk").WebElement("elmBaseConfiguration").Click
	End With '#elmExternalTrunkGroupTree
	
	Call fn_SetBulkConfigTableFieldValues(2, TrunkFriendlyName, "Trunk Friendly Name")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	Call fn_SetBulkConfigTableFieldValues(2, CACLimit, "CAC Limit")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	Call fn_SetBulkConfigTableFieldValues(2, CACBandwidthLimit, "CAC Bandwidth Limit")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	Call fn_SelectBulkConfigTableFieldValues(2, IncomingCLDPFormat, "Incoming CLDP Format")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If

	Call fn_SelectBulkConfigTableFieldValues(2, IncomingCLGPFormat, "Incoming CLGP Format")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	Call fn_SetBulkConfigTableFieldValues(2, TrunkGroupPriority, "Trunk Group Priority")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	Call fn_SetBulkConfigTableFieldValues(2, PresentationNumberSource, "Presentation Number Source")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	Call fn_SetBulkConfigTableFieldValues(2, OutgoingCLGPFormat, "Outgoing CLGP Format")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	Call fn_SetBulkConfigTableFieldValues(2, OutgoingCLDPFormat, "Outgoing CLDP Format")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	Call fn_SetBulkConfigTableFieldValues(2, OutboundCLIR, "Outbound CLIR")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
	
	Call fn_SetBulkConfigTableFieldValues(2, TrunkHandoverFormat, "Trunk Handover Format")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	objPage.WebElement("elmSIPTrunkService").WebElement("elmExternalTrunkGroupTree").WebElement("elmBaseConfiguration").Click
	
	For intCounter = 1 to 50
		If objPage.WebElement("class:=status-bar","innertext:=Loading.*","visible:=True", "index:=0").Exist(2) Then
			Wait 3
		Else
			Exit For
		End If
	Next

	'Check whether it is configured or not
	Set objElmProduct = objPage.WebElement("class:=accordion-toggle ng-binding","innertext:=  SIP Trunk Service ", "index:=0")
	If Instr(objElmProduct.GetROProperty("class"), "BT_TOUCH-COMPLETE") > 0 Then
		Call ReportLog("Product Configuration", "Product should be configured", "Product is not configured", "FAIL", True)
		objBrowser.Close
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Product Configuration", "Product should be configured", "Product is configured", "PASS", True)
	End If

	Wait 2

	'Click Quote Details Link Present on Right Top
	objPage.WebElement("elmQuoteDetails").Click

	'Wait for the Page to be Navigated
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Exist(60) Then Exit For
	Next

	blnResult = BuildWebReference("brwSalesQuoteEngine", "pgShowingQuoteOption", "")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If

	index = -1
	arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	For intCounter = 0 to UBound(arrColumns)
		If arrColumns(intCounter) = "Configured" Then
			index = intCounter + 1
			Exit For
		End If
	Next
	
	If index = -1 Then
		Call ReportLog("Get Configured Column Index", "Should be able to Fetch Configured Column index using Table Header", "Unable to Get the index - check for Object Prop", "FAIL", False)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	Wait 10
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist(30)
	If blnResult Then
	 	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	 	Wait 5
	Else
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnValid = False
	For intCounter = 1 to 20
		strCellData = objPage.WebTable("tblProductLineItems").GetCellData(intProductRow, index)
		If strCellData = "VALID" Then
			blnValid = True
			Exit For
		Else
			Wait 10
		End If
	Next

	If blnValid Then
		Call ReportLog("Configure Product", "Product should be Configured after calculating Pricing", "Product is Configured and Status is <B>" & strCellData & "</B>", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False
	End If
	
	blnPriced = False	
	For intCounter = 1 to 20
		objPage.WebTable("tblProductLineItems").RefreshObject
		blnResult = objPage.WebTable("tblProductLineItems").Exist(30)
		If blnResult Then
           	iProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
			strPricing = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intPricingStatusCol))
			If strPricing = "N/A" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'N/A'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","PASS", True)
				blnPriced = True
				Exit For
			ElseIf strPricing = "ERROR" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL",True)
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Environment("Action_Result") = False : Exit Function
			ElseIf strPricing = "" Then
				Wait 20
			End If
		Else
			Wait 5
		End If
	Next '#intCounter
	
	If Not blnPriced Then
		Call ReportLog("Pricing Product","Pricing should be shown as <B>'N/A'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL","True")
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
End Function


Private Function fn_SetBulkConfigTableFieldValues(ByVal Row, ByVal Value, ByVal ColumnName)
		Dim objElm
		Dim intTextLength, intCounter, intSetCounter
		Dim strCellData
		Dim x, y
		Dim blnToggleEvent : blnToggleEvent = False
		
		If Setting.WebPackage("ReplayType") = 2 Then
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			blnToggleEvent = True
		End If
		
		Column = -1
		arrColumns = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")
		For index = LBound(arrColumns) To UBound(arrColumns)
			If Instr(arrColumns(index), ColumnName) > 0 Then
				Column = index + 1
				Exit For
			End If
		Next
		
		If Column = -1 Then
			Call ReportLog(ColumnName, ColumnName & " - Column Name should exist", ColumnName & " - Column Name doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		'Set the Concurrent Session value
		Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(Row, Column, "WebElement", 0)
		objElm.HighLight : Wait 2
		intTextLength = Len(objPage.WebTable("tblBaseConfig").GetCellData(Row, Column))
		For intCounter = 1 to intTextLength + 1
			objElm.Click
			x = objElm.GetROProperty("abs_x")
			y = objElm.GetROProperty("abs_y")
			CreateObject("Mercury.DeviceReplay").MouseMove x, y
			With CreateObject("WScript.Shell")
				.SendKeys "{HOME}", True
				.SendKeys "{DELETE}", True
			End With
		Next
	
		For intSetCounter = 1 to 5
			objElm.HighLight 
			Wait 2
			objElm.Click
			x = objElm.GetROProperty("abs_x")
			y = objElm.GetROProperty("abs_y")
			CreateObject("Mercury.DeviceReplay").MouseMove x, y
			CreateObject("WScript.Shell").SendKeys Value, True
			CreateObject("WScript.Shell").SendKeys "{TAB}"
			Wait 2
			strCellData = objPage.WebTable("tblBaseConfig").GetCellData(Row, Column)
			If Cstr(strCellData) = CStr(Value) Then
				Call ReportLog(ColumnName, ColumnName & " value <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "PASS", False)
				Environment("Action_Result") = True 
				If blnToggleEvent Then
					Setting.WebPackage("ReplayType") = 2
				End If
				Exit Function
			End If
			Wait 5
		Next '#intSetCounter
		
		Call ReportLog(ColumnName, ColumnName & " value <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "FAIL", True)
		Environment("Action_Result") = False
End Function

Private Function fn_SelectBulkConfigTableFieldValues(ByVal Row, ByVal Value, ByVal ColumnName)
	On Error Resume Next
		Dim objElm
		Dim intTextLength, intCounter, intSetCounter
		Dim strCellData
		Dim x, y
		
		Column = -1
		arrColumns = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")
		For index = LBound(arrColumns) To UBound(arrColumns)
			If Instr(arrColumns(index), ColumnName) > 0 Then
				Column = index + 1
				Exit For
			End If
		Next
		
		If Column = -1 Then
			Call ReportLog(ColumnName, ColumnName & " - Column Name should exist", ColumnName & " - Column Name doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(2, Column, "WebElement", 0)
		x = objElm.GetROProperty("abs_x")
		y = objElm.GetROProperty("abs_y")
		CreateObject("Mercury.DeviceReplay").MouseMove x, y
		Set objList = objPage.WebTable("tblBaseConfig").ChildItem(2, Column, "WebList", 0)
		objList.Select IncomingCLDPFormat	
		
		Err.Clear
		objElm.Click
		x = objElm.GetROProperty("abs_x")
		y = objElm.GetROProperty("abs_y")
		CreateObject("Mercury.DeviceReplay").MouseMove x, y
		Wait 2
		Set objList = objPage.WebTable("tblBaseConfig").ChildItem(2, Column, "WebList", 0)
		objList.Select Value
		If Err.Number = 0 Then
			Call ReportLog(ColumnName, ColumnName & " value <B>[" & Value &"]</B> value should be selected", Value & " - value is selected", "PASS", False)
			Environment("Action_Result") = True : Exit Function
		End If
		Wait 5
		
	On Error Goto 0
End Function
