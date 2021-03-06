'========================================================================================================================
' Function Name: fn_SQE_ConfigureOCCSite_LineServiceOCC
' Purpose : Function to Modify Stencils under Line Service-OCC of OCC Site
' Created By : Nagaraj V || 16-Feb-2016 || v1.0                					     
' Return Values : Not Applicable
'========================================================================================================================
Public Function fn_SQE_ConfigureOCCSite_LineServiceOCC(ByVal StencilInput, ByVal QuantityInput)
	On Error Resume Next
	'Variable Declaration
	Dim index, intStencils, intQuantity, intRows, intCols, intManipulated_iRow, intSite, intConfiguredCol, intProductCol, intPricingCol, intOrderTypeCol
	Dim iRow, iCounter
	Dim height, width, x, y
	Dim strCapturedStencil, strCapturedQuantity, Stencil, Quantity, strSavedQuantity
	Dim arrStencilDet(), arrStencilInput, arrQuantityInput, arrColumns, arrItems
	Dim lstStencil
	Dim elmQuantity, elmInnerQuantityCell
	Dim blnAnywhereUserEncountered, blnStencilFound, blnPricing, blnValid
	Dim DeviceReplay
	
	'Initialization
	arrStencilInput = Split(StencilInput, "|")
	arrQuantityInput = Split(QuantityInput, "|")
	Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	
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
	Next
	
	If Not objPage.WebTable("tblProductLineItems").Exist(60) Then
		Call ReportLog("Table Product Line Item", "Table Product Line Item should exist", "Table Product Line Item doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText("One Cloud Cisco - Site")
		If intProdRow <= 0 Then
			Call ReportLog("Check Product", "Product should be populated in Product Line Items Table", "Product <B>One Cloud Cisco - Site</B> is not populated in table", "FAIL", True)
			Environment("Action_Result") = False : Exit Function	
		End If
	End If
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS", True)
			blnValid = True
			Exit For
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
	Next
	
	'Click on Line Service-OCC
	blnResult = clickWebElement("elmLineService-OCC")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Base Configuration under Line Service-OCC
	If objPage.WebElement("elmLineService-OCC").WebElement("elmBaseConfiguration").Exist(60) Then
		objPage.WebElement("elmLineService-OCC").WebElement("elmBaseConfiguration").Click
		Call ReportLog("LineService-OCC > BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
	Else
		Call ReportLog("LineService-OCC > BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	Wait 10
	
	Set oEleNewVal = description.Create
	oEleNewVal("micclass").value = "WebElement"
	oEleNewVal("class").value = "grid_(Add|Update)_newVal text-content linkContainer.*"
	
	iCounter = 0 : intStencils = -1 : intQuantity = -1
	With objPage.WebTable("tblBaseConfig")
		'Get Column Indexes
		arrColumns = Split(.GetROProperty("column names"), ";")
		For index = LBound(arrColumns) To UBound(arrColumns)
			If Instr(arrColumns(index), "Stencils") > 0 Then
				intStencils = index + 1
			ElseIf Instr(arrColumns(index), "Quantity") > 0 Then
				intQuantity = index + 1
			End If
		Next '#index
		
		If intStencils = -1 Or intQuantity = -1 Then
			Call ReportLog("Bulk Config Table", "Stencil and Quantity column should be found", "Unable to find under tblBaseConfig", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		blnAnywhereUserEncountered = False
		intRows = .RowCount
		For iRow = 2 To intRows
			intCols = .ColumnCount(iRow)
			If intCols <> 1 Then
				Set lstStencil = .ChildItem(iRow, intStencils, "WebList", 0)
				If Not lstStencil.Exist(0) Then
					Call ReportLog("Bulk Configuration", "Stencils WebList should exist in Bulk Config Table", "Stencils WebList should doesn't exist in Bulk Config Table", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else	
					Set elmQuantity = .ChildItem(iRow, intQuantity, "WebElement", 0)
					Set elmInnerQuantityCell = .ChildItem(iRow, intQuantity, "WebElement", 1)
					strCapturedStencil = lstStencil.GetROProperty("selection")
					strCapturedQuantity = elmQuantity.GetROProperty("innertext")
	
					'Manipulating the value to be stored as Anywhere User doesn't come under Unified Messaging
					If strCapturedStencil = "Anywhere User" Then blnAnywhereUserEncountered = True
					intManipulated_iRow = iRow
					If blnAnywhereUserEncountered Then
						intManipulated_iRow = intManipulated_iRow - 2
					End If
					
					'Update the values only for found Stencil in application versus passed as input
					blnStencilFound = False
					For index = LBound(arrStencilInput) To UBound(arrStencilInput)
						Stencil = arrStencilInput(index)
						Quantity = arrQuantityInput(index)
						If strCapturedStencil = Stencil Then
							blnStencilFound = True
							Exit For
						End If
					Next
					
					If blnStencilFound Then
						elmQuantity.HighLight
						Wait 5
						height = elmInnerQuantityCell.GetROProperty("height")
						width = elmInnerQuantityCell.GetROProperty("width")
						x = elmInnerQuantityCell.GetROProperty("abs_x") 
						y = lstStencil.GetROProperty("abs_y")
						DeviceReplay.MouseClick (x+(width/2)), (y+(height/2)), LEFT_MOUSE_BUTTON
						DeviceReplay.MouseMove (x+(width/2)), (y+(height/2))
						Wait 2
						DeviceReplay.PressKey 199 'Press HOME
						DeviceReplay.PressNKeys 211, Len(strCapturedQuantity) 'Press DELETE with N times
						Wait 2
						DeviceReplay.SendString CStr(Trim(Quantity)) ' Set the Quantity
						DeviceReplay.PressKey 15 'Press Tab
						Wait 2
						.RefreshObject
						'Verify the quantity entered
						Set oChildNewVal = .ChildItem(iRow, intQuantity, "WebElement", 0).ChildObjects(oEleNewVal)
						strSavedQuantity = oChildNewVal(0).GetROProperty("innertext")
						If Trim(strSavedQuantity) = Trim(Quantity) Then
							Call ReportLog("Line Service-OCC", "<B>" & Stencil & "</B> should be updated with quantity <B>" & Quantity & "</B>", "<B>" & Stencil & "</B> is updated with quantity <B>" & strSavedQuantity & "</B>", "PASS", False)
						Else
							Call ReportLog("Line Service-OCC", "<B>" & Stencil & "</B> should be updated with quantity <B>" & Quantity & "</B>", "<B>" & Stencil & "</B> is updated with quantity <B>" & strSavedQuantity & "</B>", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						End If
						
						'Capturing Details for Later use in Unified Messaging Table
						If strCapturedStencil <> "Anywhere User" Then
							If iCounter = 0Then
								ReDim arrStencilDet(iCounter)
							Else
								ReDim Preserve arrStencilDet(iCounter)	
							End If
							arrStencilDet(iCounter) = intManipulated_iRow & ";" & strCapturedStencil & ";" & strSavedQuantity
							iCounter = iCounter + 1
						End If '#strCapturedStencil
	
					End If '#blnStencilFound
				End If '#lstStencil.Exist(0)
			End If '#intCols
		Next '#iRow
	End With
	
	If iCounter > 1 Then
		ReDim Preserve arrStencilDet(Ubound(arrStencilDet) - 1)
	End If
	
	'Wait until Number of outstanding saves status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	Setting.WebPackage("ReplayType") = 2 '# Changes to Mouse mode
	'Updating the values under Unified Messaging
	If objPage.WebElement("elmLineService-OCC").WebElement("elmUnifiedMessaging").Exist(30) Then
		'Click on UnifiedMessaging under Line Service-OCC
		objPage.WebElement("elmLineService-OCC").WebElement("elmUnifiedMessaging").Click
		Call ReportLog("LineService-OCC > UnifiedMessaging", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
	Else
		Call ReportLog("LineService-OCC > UnifiedMessaging", "WebElement should exist and is to be clicked", "WebElement doesn't exist", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1
		Environment("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	Setting.WebPackage("ReplayType") = 1
	
	'To Check if Unified Messaging is Configured for the given stencil or not
	If Not objpage.WebTable("tblBaseConfig").Exist(60) Then
		Call ReportLog("Base Config Table", "Base Config Table should exist under Unified Messaging", "Base Congif Table doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Get Column Names under Table Base Config
	intUnifiedMessagingCol = -1 : intStencilCol = -1
	With objPage.WebTable("tblBaseConfig")
		.RefreshObject
		'Get Column Names
		arrColumns = Split(.GetROProperty("column names"), ";")
		For iCounter = LBound(arrColumns) To UBound(arrColumns)
			If Instr(arrColumns(iCounter), "Unified Messaging") > 0 Then
				intUnifiedMessagingCol = iCounter + 1
			ElseIf Instr(arrColumns(iCounter), "Stencil") > 0 Then
				intStencilCol = iCounter + 1
			End If
		Next '#iCounter
	
		If intUnifiedMessagingCol = -1 Then
			Call ReportLog("Bulk Config Table", "Unified Messaging column should be found", "Unable to find under tblBaseConfig", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End With
	
	Set oStenCilDict = CreateObject("Scripting.Dictionary")
	
	intRows = objPage.WebTable("tblBaseConfig").RowCount
	For iRow = 2 To intRows
		If objPage.WebTable("tblBaseConfig").ColumnCount(iRow) > 1 Then
			strStencilName = objPage.WebTable("tblBaseConfig").ChildItem(iRow, intStencil, "WebList", 0).GetROProperty("selection")
			strUnifiedMessaging = Trim(objPage.WebTable("tblBaseConfig").GetCellData(iRow, intUnifiedMessagingCol))
			For index = LBound(arrStencilDet) To UBound(arrStencilDet)
				If Not IsEmpty(arrStencilDet(index)) Then
					arrItems = Split(arrStencilDet(index), ";")
					If arrItems(1) = strStencilName AND Instr(strUnifiedMessaging, "Unified Messaging") > 0 Then
						oStenCilDict.Add arrStencilDet(index), arrStencilDet(index)
					End If
				End If
			Next '#index
		End If
	Next '#iRow
	
	blnConfigureUnifiedMessaging = True
	If oStenCilDict.Count = 0 Then
		blnConfigureUnifiedMessaging = False
	Else
		Erase arrStencilDet
		arrStencilDet = oStenCilDict.Keys
	End If
	
	'Configure Unified messaging
	If blnConfigureUnifiedMessaging Then
			'Click on BaseConfiguration under UnifiedMessaging under Line Service-OCC
			If objPage.WebElement("elmLineService-OCC").WebElement("elmUnifiedMessaging").WebElement("elmBaseConfiguration").Exist(30) Then
				objPage.WebElement("elmLineService-OCC").WebElement("elmUnifiedMessaging").WebElement("elmBaseConfiguration").Click
				Call ReportLog("LineService-OCC</BR>UnifiedMessaging</BR>BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
			Else
				Call ReportLog("LineService-OCC</BR>UnifiedMessaging</BR>BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Wait until Loaded 0 of 1 assets status is not visible
			For intCounter = 1 to 25
				If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
					Wait 15
				Else
					Exit For
				End If
			Next
			
			For index = LBound(arrStencilDet) To UBound(arrStencilDet)
				arrItems = Split(arrStencilDet(index), ";")
				With objPage.WebTable("tblBaseConfig")
					.RefreshObject
					'Get Column Names
					arrColumns = Split(.GetROProperty("column names"), ";")
					For iCounter = LBound(arrColumns) To UBound(arrColumns)
						If arrColumns(iCounter) =  "Site" Then
							intSite = iCounter + 1
						ElseIf Instr(arrColumns(iCounter), "Quantity") > 0 Then
							intQuantity = iCounter + 1
						End If
					Next '#iCounter
				
					If intSite = -1 Or intQuantity = -1 Then
						Call ReportLog("Bulk Config Table", "Site and Quantity column should be found", "Unable to find under tblBaseConfig", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
				End With
				
				With objPage.WebTable("tblBaseConfig")
					.RefreshObject
					intRows = .RowCount
					For iRow = 2 To intRows
						If iRow = CInt(arrItems(0)) Then
							intCols = .ColumnCount(iRow)
							If intCols <> 1 Then
								Set elmSite = .ChildItem(iRow, intSite, "WebElement", 3)
								Set elmQuantity = .ChildItem(iRow, intQuantity, "WebElement", 0)
								Set elmInnerQuantityCell = .ChildItem(iRow, intQuantity, "WebElement", 1)
								
								x = elmInnerQuantityCell.GetROProperty("abs_x")
								y = elmSite.GetROProperty("abs_y")
								
								height = elmInnerQuantityCell.GetROProperty("height")
								width = elmInnerQuantityCell.GetROProperty("width")
								strLen = Len(elmQuantity.GetROProperty("innertext"))
								
								DeviceReplay.MouseClick (x+(width/2)), (y+(height/2)), LEFT_MOUSE_BUTTON
								DeviceReplay.MouseMove (x+(width/2)), (y+(height/2))
								Wait 2
								DeviceReplay.PressKey 199 'Press HOME
								DeviceReplay.PressNKeys 211, strLen 'Press DELETE with N times
								Wait 2
								DeviceReplay.SendString CStr(arrItems(2)) ' Set the Quantity
								DeviceReplay.PressKey 15 'Press Tab
								Wait 2
								.RefreshObject
							End If '#intCols <> 1
						End If '#iRow = CInt(arrItems(0))
					Next '#iRow
				End With
			Next '#index
	
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
	
	If Not objPage.WebTable("tblProductLineItems").Exist(120) Then
		Call ReportLog("Table Product LineItem", "Table Product LineItem should be populated", "Table Product LineItem is not populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Rem Check for Configuration is Valid or Not
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
		Call ReportLog("Configure Product", "Configuration should be Valid", "Configuration is found to be - " & strCellData, "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
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
			Exit For
		Else
			Wait 5
		End If
	Next
	
	If Not blnPricing Then
		Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
End Function
