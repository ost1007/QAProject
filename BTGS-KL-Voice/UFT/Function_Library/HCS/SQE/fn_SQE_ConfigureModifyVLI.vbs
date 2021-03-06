'========================================================================================================================
' Function Name: fn_SQE_ConfigureModifyVLI
' Purpose : Function to Modify Voice Lynv integration - Quantity
' Return Values : Not Applicable
'========================================================================================================================
Public Function fn_SQE_ConfigureModifyVLI(ByVal Quantity)

	'Variable Declaration
	Dim DeviceReplay
	Dim oDescOldVal, oDescNewVal, oDescUpdateVal
	
	'Variable Initialization
	Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	
	'Description for Old Value
	Set oDescOldVal = Description.Create
	oDescOldVal("micclass").Value = "WebElement"
	oDescOldVal("class").Value = "grid_None_oldVal"
	
	'Description for NewVal
	Set oDescNewVal = Description.Create
	oDescNewVal("micclass").Value = "WebElement"
	oDescNewVal("class").Value = "grid_None_newVal text-content linkContainer can-edit"
	
	'Description for UpdateVal
	Set oDescUpdateVal = Description.Create
	oDescUpdateVal("micclass").Value = "WebElement"
	oDescUpdateVal("class").Value = "grid_Update_newVal text-content linkContainer can-edit"
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	If Not objPage.WebTable("tblProductTableHeader").Exist(0) Then
		Call ReportLog("Table Product", "Table Column have been changed", "Table Columns have been changed: " & objPage.WebTable("tblProductTableHeader").GetTOProperty("column names"), "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
		
	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0 : intPricingCol = 0 : intOrderTypeCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Order Type" Then
			intOrderTypeCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		End If
	Next '#intCounter
	
	'Terminate if Column names have been changed
	If intProductCol = 0 OR intConfiguredCol = 0 OR intPricingCol = 0 OR intOrderTypeCol = 0 Then
		Call ReportLog("Check Columns", "Configured/Pricing Status/Order Type/Product columns should be present", "One or more column names have been changed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText("Voice Lync Integration")
	If intProdRow <= 0 Then
		Call ReportLog("ISA Line Item", "Voice Lync Integration should exist in Line Items Table", "Voice Lync Integration does not exist in Line Items table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
		
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS", True)
			blnValid = True
			Exit For '#intCounter
		Else
			Wait 5
		End If
	Next
		
	'Check for Configuration Status
	If Not blnValid Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as '" & strConfigured & "' before bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
		
	'Select All Product Line Items for Configuration
	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist(10)
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
		
	'Wait for the Page to be Loaded
	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgBulkConfiguration").Exist(60)
			If blnResult Then Exit For			
	Next
		
	'Build Browser Reference
	blnResult = BuildWebReference("","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next '#intCounter
	
	'Check whether Base Config table exists or not
	If Not objPage.WebTable("tblBaseConfig").Exist(60) Then
		Call ReportLog("Base Config Table", "Base Config Table should exist", "Base Config Table doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Get the Column Names
	arrColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")
	For iCounter = LBound(arrColumnNames) To UBound(arrColumnNames)
		strColumnName = arrColumnNames(iCounter)
		If Instr(strColumnName, "Quantity") > 0 Then
			intQuantityCol = iCounter + 1
			Exit For
		End If
	Next '#iCounter
	
	'Terminate if Column is not found
	If intQuantityCol = -1 Then
		Call ReportLog("Column Search", "Quantity Column should exist", "Could not find either/all specified columns", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Get the Total Number of Rows and set the values in the last Row
	intRows = objPage.WebTable("tblBaseConfig").RowCount - 1
	
	'Get the Old value and check if it is same with new val
	Set elmQuantityCol = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intQuantityCol, "WebElement", 0)
	
	'Get the Old Value Object Reference
	Set elmQuantityColOldVal = elmQuantityCol.ChildObjects(oDescOldVal)
	
	If elmQuantityColOldVal.Count = 0 Then
		Call ReportLog("Quantity", "Old/Previous value should be displayed", "Old/Previous value is not getting displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check whether entered and existing are same value or not
	If CInt(elmQuantityColOldVal(0).GetROProperty("innertext")) = Cint(Quantity) Then
		Call ReportLog("Modify Attributes", "Quantity should not be same as previous values", "Entered VLI Quantity are same as previous values", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	
	'=========================== Updating the values of No. of Quantity ===========================
			Set elmQuantity = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intQuantityCol, "WebElement", 0)
			With elmQuantity
				Set elmQuantityNewVal = .ChildObjects(oDescNewVal)
				If elmQuantityNewVal.Count = 0 Then
					Call ReportLog("Quantity New Value", "Quantity New Value text box should be present", "Could not locate Quantity New Value Text Box", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Set elmQuantityTextBox = elmQuantityNewVal(0)
					elmQuantityTextBox.HighLight
					strCapturedQuantity = elmQuantityTextBox.GetROProperty("innertext")
					Wait 2
				End If
				
				height = elmQuantityTextBox.GetROProperty("height")
				width = elmQuantityTextBox.GetROProperty("width")
				x = elmQuantityTextBox.GetROProperty("abs_x") 
				y = elmQuantityTextBox.GetROProperty("abs_y")
				
				For iKeyCounter = 1 To Len(strCapturedQuantity)
					DeviceReplay.MouseClick (x+(width/2)), (y+(height/2)), LEFT_MOUSE_BUTTON
					DeviceReplay.MouseMove (x+(width/2)), (y+(height/2))
					Wait 2
					DeviceReplay.PressKey 199 'Press HOME
					Wait 2
					DeviceReplay.PressKey 211 'Press DELETE
					Wait 2
				Next '#iKeyCounter
				
				DeviceReplay.MouseClick (x+(width/2)), (y+(height/2)), LEFT_MOUSE_BUTTON
				DeviceReplay.MouseMove (x+(width/2)), (y+(height/2))
				
				DeviceReplay.SendString CStr(Trim(Quantity)) ' Set the Quantity
				DeviceReplay.PressKey 15 'Press Tab
				Wait 2	
			End With
			
			Set elmQuantity = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intQuantityCol, "WebElement", 0)
			Set elmQuantityUpdateVal = elmQuantity.ChildObjects(oDescUpdateVal)
			If elmQuantityUpdateVal.Count = 0 Then
				Call ReportLog("Concurrent Sessions Update Value", "Concurrent Sessions Update Value text box should be present", "Could not locate Concurrent Sessions Update Value Text Box", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			strUpdateQuantity = elmQuantityUpdateVal(0).GetROProperty("innerText")
			If CInt(strUpdateQuantity) = CInt(Quantity) Then
				Call ReportLog("Quantity", "Quantity should be updated with <B>" & Quantity & "</B>",  "Quantity should be updated with <B>" & strUpdateQuantity & "</B>", "PASS", True)
			Else
				Call ReportLog("Quantity", "Quantity should be updated with <B>" & Quantity & "</B>",  "Quantity should be updated with <B>" & strUpdateQuantity & "</B>", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	
	Wait 5
	
		blnResult = clickWebElement("elmSIPTrunkServiceVLI")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			
		objPage.WebElement("elmSIPTrunkServiceVLI").Click
		intInitWaitTime = 90
		'Wait until Loaded 0 of 1 assets status is not visible
		For intCounter = 1 to 50
			If objPage.WebElement("innertext:=Loading Grid", "index:=0").Exist(intInitWaitTime) Then	
				Wait 5
				intInitWaitTime = 3
			Else
				Exit For
			End If
		Next
			
		blnResult = clickWebElement("elmBaseConfig")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			
		Wait 5
		
		objPage.WebTable("tblBaseConfig").RefreshObject
		
		strAction = fn_GetBulkConfigTableFieldValue(intRows, "Action")
		strPricingStatus = fn_GetBulkConfigTableFieldValue(intRows, "Pricing Status")
		
		If strAction = "Update" AND strPricingStatus = "Not Priced" Then
			Call ReportLog("Check Attributes", "Action should be 'Update' and Pricing Status should be 'Not Priced'", "Action is <B>" & strAction &"</B> and Pricing Status is <B>" & strPricingStatus &"</B>", "PASS", True)
		Else
			Call ReportLog("Check Attributes", "Action should be 'Update' and Pricing Status should be 'Not Priced'", "Action is <B>" & strAction &"</B> and Pricing Status is <B>" & strPricingStatus &"</B>", "FAIL", True)
			Environment.Value("Action_Result") = False : Exit Function
		End If
	
	'Click Quote Details Link Present on Left Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgShowingQuoteOption").Exist(60)
			If blnResult Then Exit For			
	Next
	
	blnResult = BuildWebReference("","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	blnResult = objPage.Link("lnkCalculatePrice").Exist(120)
	If Not blnResult Then
		Call ReportLog("Calculate Price", "Calculate Price button should be visible", "Calculate Price button is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnBtnCalculatePriceEnabled = False
	For intCounter = 1 To 5
		'Select all Product Line Items for Configuration
		objPage.WebCheckBox("html id:=selectAll").Set "ON"
		Wait 5
		
		If objPage.Link("lnkCalculatePrice").Object.disabled Then
			Wait 30
		Else
			blnBtnCalculatePriceEnabled = True
			Exit For '#intCounter
		End If		
	Next
	
	If Not blnBtnCalculatePriceEnabled Then
		Call ReportLog("Calculate Price", "Calculate Price button should be enabled", "Calculate Price button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		'Click on Calculate Button
		blnResult = clickLink("lnkCalculatePrice")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product", "Configuration should be <B>VALID</B>", "Product Configuration is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnValid = True
			Exit For
		Else
			Wait 5
		End If
	Next

	If Not blnValid Then
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Environment("Action_Result") = False
	End If
	
	'Check for Pricing is Firm or Not
	blnPricing = False
	For intCounter = 1 to 20
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intPricingCol))
		If strCellData = "Firm" Then
			Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnPricing = True
			Exit For '#intCounter
		ElseIf strCellData = "ERROR" Then
			Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
			blnPricing = False
			Exit For '#intCounter
		Else
			Wait 10
		End If
	Next '#intCounter
	
	If Not blnPricing Then
		Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
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
		objList.Select Value	
		
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


Private Function fn_GetBulkConfigTableFieldValue(ByVal Row, ByVal ColumnName)
	On Error Resume Next
		Dim objElm
		Dim intTextLength, intCounter, intSetCounter
		Dim strCellData
		
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
		
		Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(Row, Column, "WebElement", 0)
		fn_GetBulkConfigTableFieldValue = Trim(objElm.GetROProperty("innertext"))
		
	On Error Goto 0
End Function
