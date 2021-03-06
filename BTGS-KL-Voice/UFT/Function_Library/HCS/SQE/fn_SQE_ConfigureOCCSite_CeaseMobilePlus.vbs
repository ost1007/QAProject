'========================================================================================================================
' Function Name: fn_SQE_ConfigureOCCSite_CeaseMobilePlus
' Purpose : Function to Cease Mobile Plus against Line Services
' Created By : Nagaraj V || 18-Oct-2016 || v1.0                					     
' Return Values : Not Applicable
'========================================================================================================================
Public Function fn_SQE_ConfigureOCCSite_CeaseMobilePlus(ByVal StencilInput)
	On Error Resume Next
	'Variable Declaration
	Dim arrStencilInput, arrColumnNames
	Dim intProductCol, intConfiguredCol, intPricingCol, intOrderTypeCol
	Dim iProdRow
	Dim oDictStencils
	
	Setting.WebPackage("ReplayType") = 2 '# Changes to Mouse mode	
	'Initialization
	arrStencilInput = Split(StencilInput, "|")
	Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	Set oDictStencils = CreateObject("Scripting.Dictionary")
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False 
		Exit Function
	End If
		
	If Not objPage.WebTable("tblProductTableHeader").Exist(0) Then
		Call ReportLog("Table Product", "Table Column have been changed", "Table Columns have been changed: " & objPage.WebTable("tblProductTableHeader").GetTOProperty("column names"), "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
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
		Call ReportLog("Table Product Line Items", "Table should be visible", "Table is not populated", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	iProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText("One Cloud Cisco - Site", intProductCol)
	If iProdRow <= 0 Then
		Call ReportLog("One Cloud Cisco - Site", "One Cloud Cisco - Site should be populated in table", "One Cloud Cisco - Site product is not populated", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intConfiguredCol))
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
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Select All Product Line Items for Configuration
	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist(10)
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
		If Not blnResult Then
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment.Value("Action_Result") = False : Exit Function
		End If
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	'Wait for the Page to be Loaded
	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgBulkConfiguration").Exist(60)
			If blnResult Then Exit For			
	Next
	
	'Build Browser Reference
	blnResult = BuildWebReference("","pgBulkConfiguration","")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	'Wait until Loading status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loading products", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	Wait 10
	
	'Click on Line Service-OCC
	blnResult = clickWebElement("elmLineService-OCC")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	Wait 5
	
	'Updating the values under Mobile Plus
	With objPage.WebElement("elmLineService-OCC")
		
			'Under Base Configuration check for Quantity and Increase the Quantity
			If .WebElement("elmBaseConfiguration").Exist(60) Then
				.WebElement("elmBaseConfiguration").Click
				Call ReportLog("LineService-OCC > BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
			Else
				Call ReportLog("LineService-OCC > BaseConfiguration", "WebElement should exist and is to be clicked", "WebElement doesn't exist", "FAIL", True)
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Environment("Action_Result") = False : Exit Function
			End If		
			
			Wait 15
			
			'Wait until Number of outstanding saves status is not visible
			For intCounter = 1 to 25
				If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
					Wait 15
				Else
					Exit For
				End If
			Next
	
			If .WebElement("elmMobilePlus").Exist(30) Then
				Rem Click on Mobile Plus under Line Service-OCC
				.WebElement("elmMobilePlus").Click
				Call ReportLog("LineService-OCC > Mobile Plus", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
			Else
				Call ReportLog("LineService-OCC > Mobile Plus", "WebElement should exist and is to be clicked", "WebElement doesn't exist", "FAIL", True)
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Wait until Number of outstanding saves status is not visible
			For intCounter = 1 to 25
				If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
					Wait 15
				Else
					Exit For
				End If
			Next
			
			iCounter = 1 : intStencils = -1 : intMobilePlus = -1
			With objPage.WebTable("tblBaseConfig")
				
				'Terminate if Bulk Config/Base Config Table doesn't exist
				If Not .Exist(60) Then
					Call ReportLog("Bulk Config Table", "Bulk Config Table should be existing", "Bulk Config Table config doesn't exist", "FAIL", True)
					Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
					Environment("Action_Result") = False : Exit Function
				End If
			
				'Get Column Indexes
				arrColumns = Split(.GetROProperty("column names"), ";")
				For index = LBound(arrColumns) To UBound(arrColumns)
					If Instr(arrColumns(index), "Stencils") > 0 Then
						intStencils = index + 1
					ElseIf Instr(arrColumns(index), "Mobile Plus") > 0 Then
						intMobilePlus = index + 1
					ElseIf arrColumns(index) = "Action" Then
						intAction = index + 1
					End If
				Next '#index
				
				If intStencils = -1 Or intMobilePlus = -1  Then
					Call ReportLog("Bulk Config Table", "Stencil/Quantity/Mobile Plus column should be found", "Unable to find either of Stencil/Quantity/Mobile Plus under tblBaseConfig", "FAIL", True)
					Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
					Environment("Action_Result") = False : Exit Function
				End If
				
				For index = LBound(arrStencilInput) To UBound(arrStencilInput)
					
					Stencil = arrStencilInput(index)
					blnStencilFound = False
					
					intRows = .RowCount
					For iRow = 2 To intRows
						intCols = .ColumnCount(iRow)
						If intCols <> 1 Then
							Set lstStencil = .ChildItem(iRow, intStencils, "WebList", 0)
							If Not lstStencil.Exist(0) Then
								Call ReportLog("Bulk Configuration", "Stencils WebList should exist in Bulk Config Table", "Stencils WebList should doesn't exist in Bulk Config Table", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							Else
								strCapturedStencil = lstStencil.GetROProperty("selection")
								strMobilePlusConfigured = Trim(.GetCellData(iRow, intMobilePlus))
								If strCapturedStencil = Stencil Then
									If Instr(strMobilePlusConfigured, "Mobile Plus") > 0 Then
										.ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"
										oDictStencils.Add Stencil, Stencil
									Else
										Call ReportLog("Mobile Plus Configuration", "Mobile Plus should be configured to " & strCapturedStencil, "Mobile Plus is not configured for " & strCapturedStencil, "Warnings", True)
									End If
								
									blnStencilFound = True
									Exit For '#iRow
								End If '#strCapturedStencil = Stencil
							End If '#lstStencil.Exist(0)
						End If '#intCols
					Next '#iRow
				Next '#index
			End With

			If Not blnStencilFound Then
				Call ReportLog("Stencil Check", Stencil & " - should exist in Bulk Config table under Mobile Plus", Stencil & " - does not exist in Bulk Config table under Mobile Plus", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		End With
		
	'Click on Delete Asset
	blnResult = clickButton("btnDeleteAsset")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	
	intInitWaitTime = 10
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Performing deleting.*", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	'Terminate If requested Mobile Plus services are not configured to be available for ceasing
	If oDictStencils.Count = 0 Then
		Call ReportLog("Cease of Mobile Plus", "Mobile Plus should be configured for requested Line Items", "Mobile Plus was not configured for any of Line Items " & StencilInput, "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False
		Exit Function
	End If
	
	arrMobilePlusConfiguredStencil = oDictStencils.Keys
	
	With objPage.WebTable("tblBaseConfig")
		.RefreshObject
		For index = LBound(arrMobilePlusConfiguredStencil) To UBound(arrMobilePlusConfiguredStencil)	
			Stencil = arrMobilePlusConfiguredStencil(index)
			blnStencilFound = False
			
			intRows = .RowCount
			For iRow = 2 To intRows
				intCols = .ColumnCount(iRow)
				If intCols <> 1 Then
					Set lstStencil = .ChildItem(iRow, intStencils, "WebList", 0)
					If Not lstStencil.Exist(0) Then
						Call ReportLog("Bulk Configuration", "Stencils WebList should exist in Bulk Config Table", "Stencils WebList should doesn't exist in Bulk Config Table", "FAIL", True)
						Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
						Environment("Action_Result") = False : Exit Function
					Else
						strCapturedStencil = lstStencil.GetROProperty("selection")
						strAction = Trim(.GetCellData(iRow, intAction))
						
						If strCapturedStencil = Stencil Then
							If strAction = "Delete" Then
								Call ReportLog("Mobile Plus Configuration", "Mobile Plus be should ceased against " & strCapturedStencil, "Mobile Plus is ceased against " & strCapturedStencil, "PASS", True)
							Else
								Call ReportLog("Mobile Plus Configuration", "Mobile Plus be should ceased against " & strCapturedStencil, "Mobile Plus is not ceased against " & strCapturedStencil & " instead found to be " & strAction, "FAIL", True)
								Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
								Environment("Action_Result") = False
								Exit Function
							End If
							
							Exit For '#iRow
						End If '#strCapturedStencil = Stencil
					End If '#lstStencil.Exist(0)
				End If '#intCols
			Next '#iRow
		Next '#index
	End With
		
	
	'Click Quote Details Link Present on Left Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgShowingQuoteOption").Exist(60)
			If blnResult Then Exit For			
	Next
	
	blnResult = BuildWebReference("","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 5
		'Select all Product Line Items for Configuration
		objPage.WebCheckBox("html id:=selectAll").Set "ON"
		If objPage.Link("lnkCalculatePrice").waitProperty("class", "main-action actionBtnDisable", 1000*60*2) Then
			Wait 2
			Exit For
		Else
			Wait 10
		End If
	Next '#intCounter
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intConfiguredCol))
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
	
	'Select all Product Line Items for Configuration
	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intConfiguredCol))
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
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intPricingCol))
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
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False
		Exit Function
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
	
End Function
