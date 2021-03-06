'========================================================================================================================
' Function Name: fn_SQE_ConfigureModifyISA
' Purpose : Function to Modify Internet Service Access - No. of Concurrent Sessions and No. of Registrations in Bulk Configuration Page
' Created By : Nagaraj V || 13-04-2016 || v1.0     					     
' Return Values : Not Applicable
'========================================================================================================================
Public Function fn_SQE_ConfigureModifyISA(ByVal NoOfConcurrentSessions, ByVal NoOfRegistrations)
	
	'Variable Declaration
	Dim intRows, intCounter, iKeyCounter
	Dim intConcurrentSessionsCol, intRegistrationsCol, intConfiguredCol, intPricingCol, intOrderTypeCol, intProductCol
	Dim blnValid, blnUpdateConcurrentSessions, blnUpdateRegistrations, blnPricing, blnBtnCalculatePriceEnabled
	Dim arrColumnNames
	Dim strColumnName, strCellData, strCapturedQuantity
	Dim elmConcurrentSessions, elmRegistrations, elmConcurrentSessionsOldVal, elmRegistrationsOldVal, elmConcurrentSessionsNewVal, elmConcurrentSessionsTextBox, elmConcurrentSessionsUpdateVal, elmRegistrationsNewVal, elmRegistrationsTextBox, elmRegistrationsUpdateVal
	Dim oDescNewVal, oDescOldVal, oDescUpdateVal
	Dim height, width, x, y
	Dim DeviceReplay
	
	'Variable Initialization
	intConcurrentSessionsCol = -1 : intRegistrationsCol = -1
	blnUpdateConcurrentSessions = True : blnUpdateRegistrations = True
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
	
	intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText("Internet Service Access")
	If intProdRow <= 0 Then
		Call ReportLog("ISA Line Item", "Internet Service Access should exist in Line Items Table", "Internet Service Access does not exist in Line Items table", "FAIL", True)
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
		If Instr(strColumnName, "No of Concurrent Sessions") > 0 Then
			intConcurrentSessionsCol = iCounter + 1
		ElseIf Instr(strColumnName, "No of Registrations") > 0 Then
			intRegistrationsCol = iCounter + 1
		End If
	Next '#iCounter
	
	'Terminate if Column is not found
	If intConcurrentSessionsCol = -1 OR intRegistrationsCol = -1 Then
		Call ReportLog("Column Search", "No of Concurrent Sessions & No of Registrations Column should exist", "Could not find either/all specified columns", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Get the Total Number of Rows and set the values in the last Row
	intRows = objPage.WebTable("tblBaseConfig").RowCount - 1
	
	'Get the Old value and check if it is same with new val
	Set elmConcurrentSessions = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intConcurrentSessionsCol, "WebElement", 0)
	Set elmRegistrations = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intRegistrationsCol, "WebElement", 0)
	
	'Get the Old Value Object Reference
	Set elmConcurrentSessionsOldVal = elmConcurrentSessions.ChildObjects(oDescOldVal)
	Set elmRegistrationsOldVal = elmRegistrations.ChildObjects(oDescOldVal)
	
	If elmConcurrentSessionsOldVal.Count = 0 Then
		Call ReportLog("Concurrent Sessions", "Old/Previous value should be displayed", "Old/Previous value is not getting displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If elmRegistrationsOldVal.Count = 0 Then
		Call ReportLog("No. of Registrations", "Old/Previous value should be displayed", "Old/Previous value is not getting displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check whether entered and existing are same value or not
	If CInt(elmConcurrentSessionsOldVal(0).GetROProperty("innertext")) = NoOfConcurrentSessions AND CInt(elmRegistrationsOldVal(0).GetROProperty("innertext")) = NoOfRegistrations Then
		Call ReportLog("Modify Attributes", "No. of Registrations and Concurrent Sessions should be same as previous values", "Entered No. of Registrations and Concurrent Sessions are same as previous values", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Turning updation to false to restrict process updations
	If CInt(elmConcurrentSessionsOldVal(0).GetROProperty("innertext")) = NoOfConcurrentSessions Then
		blnUpdateConcurrentSessions = False
	End If
	
	If CInt(elmRegistrationsOldVal(0).GetROProperty("innertext")) = NoOfRegistrations Then
		blnUpdateRegistrations = False
	End If
	
	'=========================== Updating the values of No. of Concurrent Sessions ===========================
	If blnUpdateConcurrentSessions Then
			Set elmConcurrentSessions = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intConcurrentSessionsCol, "WebElement", 0)
			With elmConcurrentSessions
				Set elmConcurrentSessionsNewVal = .ChildObjects(oDescNewVal)
				If elmConcurrentSessionsNewVal.Count = 0 Then
					Call ReportLog("Concurrent Sessions New Value", "Concurrent Sessions New Value text box should be present", "Could not locate Concurrent Sessions New Value Text Box", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Set elmConcurrentSessionsTextBox = elmConcurrentSessionsNewVal(0)
					elmConcurrentSessionsTextBox.HighLight
					strCapturedQuantity = elmConcurrentSessionsTextBox.GetROProperty("innertext")
					Wait 2
				End If
				
				height = elmConcurrentSessionsTextBox.GetROProperty("height")
				width = elmConcurrentSessionsTextBox.GetROProperty("width")
				x = elmConcurrentSessionsTextBox.GetROProperty("abs_x") 
				y = elmConcurrentSessionsTextBox.GetROProperty("abs_y")
				
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
				
				DeviceReplay.SendString CStr(Trim(NoOfConcurrentSessions)) ' Set the Quantity
				DeviceReplay.PressKey 15 'Press Tab
				Wait 2	
			End With
			
			Set elmConcurrentSessions = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intConcurrentSessionsCol, "WebElement", 0)
			Set elmConcurrentSessionsUpdateVal = elmConcurrentSessions.ChildObjects(oDescUpdateVal)
			If elmConcurrentSessionsUpdateVal.Count = 0 Then
				Call ReportLog("Concurrent Sessions Update Value", "Concurrent Sessions Update Value text box should be present", "Could not locate Concurrent Sessions Update Value Text Box", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			strUpdateQuantity = elmConcurrentSessionsUpdateVal(0).GetROProperty("innerText")
			If CInt(strUpdateQuantity) = CInt(NoOfConcurrentSessions) Then
				Call ReportLog("Concurrent Sessions", "Concurrent Sessions should be updated with <B>" & NoOfConcurrentSessions & "</B>",  "Concurrent Sessions should be updated with <B>" & strUpdateQuantity & "</B>", "PASS", True)
			Else
				Call ReportLog("Concurrent Sessions", "Concurrent Sessions should be updated with <B>" & NoOfConcurrentSessions & "</B>",  "Concurrent Sessions should be updated with <B>" & strUpdateQuantity & "</B>", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	End If '#blnUpdateConcurrentSessions
	
	
	'=========================== Updating the values of No. of Registrations ===========================
	If blnUpdateRegistrations Then
			Set elmRegistrations = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intRegistrationsCol, "WebElement", 0)
			With elmRegistrations
				'As Property changes if there is any previous modifications
				If Not blnUpdateConcurrentSessions Then
					Set elmRegistrationsNewVal = .ChildObjects(oDescNewVal)
				Else
					Set elmRegistrationsNewVal = .ChildObjects(oDescUpdateVal)	
				End If			
				
				If elmRegistrationsNewVal.Count = 0 Then
					Call ReportLog("Concurrent Sessions New Value", "Concurrent Sessions New Value text box should be present", "Could not locate Concurrent Sessions New Value Text Box", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Set elmRegistrationsTextBox = elmRegistrationsNewVal(0)
					elmRegistrationsTextBox.HighLight
					Wait 2
					strCapturedQuantity = elmRegistrationsTextBox.GetROProperty("innertext")
				End If
				
				height = elmRegistrationsTextBox.GetROProperty("height")
				width = elmRegistrationsTextBox.GetROProperty("width")
				x = elmRegistrationsTextBox.GetROProperty("abs_x") 
				y = elmRegistrationsTextBox.GetROProperty("abs_y")
				
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
				
				DeviceReplay.SendString CStr(Trim(NoOfRegistrations)) ' Set the Quantity
				DeviceReplay.PressKey 15 'Press Tab
				Wait 2	
			End With
			
			Set elmRegistrations = objPage.WebTable("tblBaseConfig").ChildItem(intRows, intRegistrationsCol, "WebElement", 0)
			Set elmRegistrationsUpdateVal = elmRegistrations.ChildObjects(oDescUpdateVal)
			If elmRegistrationsUpdateVal.Count = 0 Then
				Call ReportLog("No. of Registrations Update Value", "No. of Registrations Update Value text box should be present", "Could not locate No. of Registrations Update Value Text Box", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			strUpdateQuantity = elmRegistrationsUpdateVal(0).GetROProperty("innerText")
			If CInt(strUpdateQuantity) = CInt(NoOfRegistrations) Then
				Call ReportLog("No. of Registrations", "No. of Registrations should be updated with <B>" & NoOfRegistrations & "</B>",  "No. of Registrations should be updated with <B>" & strUpdateQuantity & "</B>", "PASS", True)
			Else
				Call ReportLog("No. of Registrations", "No. of Registrations should be updated with <B>" & NoOfRegistrations & "</B>",  "No. of Registrations should be updated with <B>" & strUpdateQuantity & "</B>", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	End If '#blnUpdateRegistrations
	
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
		Else
			Wait 5
		End If
	Next '#intCounter
	
	If Not blnPricing Then
		Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
End Function
