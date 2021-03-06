'========================================================================================================================
' Function Name: fn_SQE_ConfigureOCCSite_AddModifyMobilePlus
' Purpose : Function to Modify Stencils under Line Service-OCC of OCC Site
' Created By : Nagaraj V || 16-Feb-2016 || v1.0                					     
' Return Values : Not Applicable
'========================================================================================================================
Public Function fn_SQE_ConfigureOCCSite_AddModifyMobilePlus(ByVal StencilInput, ByVal QuantityInput)
	On Error Resume Next
	'Variable Declaration
	Dim index, intStencils, intQuantity, intRows, intCols, intManipulated_iRow, intSite, intConfiguredCol, intProductCol, intPricingCol, intOrderTypeCol, intMobilePlus
	Dim iRow, iCounter
	Dim height, width, x, y
	Dim strCapturedStencil, strCapturedQuantity, Stencil, Quantity, strSavedQuantity
	Dim arrStencilDet(), arrStencilInput, arrQuantityInput, arrColumns, arrItems
	Dim lstStencil
	Dim elmQuantity, elmInnerQuantityCell
	Dim blnAnywhereUserEncountered, blnStencilFound, blnPricing, blnValid
	Dim DeviceReplay
	
	Setting.WebPackage("ReplayType") = 2 '# Changes to Mouse mode	
	'Initialization
	arrStencilInput = Split(StencilInput, "|")
	arrQuantityInput = Split(QuantityInput, "|")
	Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
	
	Set oDescOldVal = Description.Create
	oDescOldVal("micclass").Value = "WebElement"
	oDescOldVal("class").Value = "grid_None_oldVal"
	
	Set oDescNewVal = Description.Create
	oDescNewVal("micclass").Value = "WebElement"
	oDescNewVal("class").Value = "grid_None_newVal text-content linkContainer can-edit"
	
	Set oDescUpdateVal = Description.Create
	oDescUpdateVal("micclass").Value = "WebElement"
	oDescUpdateVal("class").Value = "grid_Update_newVal text-content linkContainer can-edit"
	
	Set oDescAddNewVal = Description.Create
	oDescAddNewVal("micclass").Value = "WebElement"
	oDescAddNewVal("class").Value = "grid_Add_newVal text-content linkContainer can-edit"
	
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
			
			Wait 30
			
			iCounter = 1 : intStencils = -1 : intQuantity = -1
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
					Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
					Environment("Action_Result") = False : Exit Function
				End If
				
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
							strCapturedStencil = Trim(lstStencil.GetROProperty("selection"))
						End If
						
						Set elmOuterCell = .ChildItem(iRow, intQuantity, "WebElement", 0)
						Set elmNewUpdateVal = elmOuterCell.ChildObjects(oDescNewVal)
						If elmNewUpdateVal.Count = 0 Then
							Call ReportLog("Update Qunatity", "WebElement new value object properties have been changed", "Contact Automation Team", "FAIL", True)
							Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
							Environment("Action_Result") = False : Exit Function
						End If
						
						blnUpdate = False
						intOldVal = CInt(elmNewUpdateVal(0).GetROProperty("innertext"))
						For index = LBound(arrStencilInput) To UBound(arrStencilInput)
							If arrStencilInput(index) = strCapturedStencil Then
								intUpdateVal = intOldVal + CInt(arrQuantityInput(index))
								blnUpdate = True
								Exit For '#index
							End If							
						Next
						
						If blnUpdate Then
								elmNewUpdateVal(0).HighLight
								elmNewUpdateVal(0).Click
									DeviceReplay.KeyDown 29 'Control
									DeviceReplay.PressKey 30 'A
									DeviceReplay.KeyUp 29 'Control
								Wait 5
									DeviceReplay.SendString CStr(intUpdateVal) 'Type the Quantity
									DeviceReplay.PressKey 15 'Press Tab
								Wait 5
								
								Set elmUpdateVal = elmOuterCell.ChildObjects(oDescUpdateVal)
								If elmUpdateVal.Count = 0 Then
									Call ReportLog("Update Qunatity", "WebElement new value object properties have been changed", "Contact Automation Team", "FAIL", True)
									Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
									Environment("Action_Result") = False : Exit Function
								End If
								blnUpdate = False
								For intUpdateCounter = 1 To 5
									Wait 10
									If CInt(elmUpdateVal(0).GetROProperty("innertext")) = intUpdateVal Then
										Call ReportLog("Update Line Service", strCapturedStencil & " - should be updated with " & intUpdateVal, strCapturedStencil & " - should be updated with " & elmUpdateVal(0).GetROProperty("innertext"), "Information", True)
										blnUpdate = True
										Exit For '#intUpdateCounter
									Else
										elmUpdateVal(0).RefreshObject
										elmUpdateVal(0).HighLight
										elmUpdateVal(0).Click
											DeviceReplay.KeyDown 29 'Control
											DeviceReplay.PressKey 30 'A
											DeviceReplay.KeyUp 29 'Control
										Wait 5
											DeviceReplay.SendString CStr(intUpdateVal) 'Type the Quantity
											DeviceReplay.PressKey 15 'Press Tab
									End If
								Next '#intUpdateCounter
								
								'Fail If couldn't update even after 5 try
								If Not blnUpdate Then
									Call ReportLog("Update Line Service", strCapturedStencil & " - should be updated with " & intUpdateVal, strCapturedStencil & " - should be updated with " & elmUpdateVal(0).GetROProperty("innertext"), "FAIL", True)
									Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
									Environment("Action_Result") = False : Exit Function
								End If
							
						End If '#blnUpdate
					End If '#intCols <> 1
				Next '#intRow
			End With '#objPage.WebTable("tblBaseConfig")1
			
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
			
			Wait 30
			
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
					ElseIf Instr(arrColumns(index), "Quantity") Then
						intQuantity = index + 1
					End If
				Next '#index
				
				If intStencils = -1 Or intMobilePlus = -1 Or intQuantity = -1 Then
					Call ReportLog("Bulk Config Table", "Stencil/Quantity/Mobile Plus column should be found", "Unable to find either of Stencil/Quantity/Mobile Plus under tblBaseConfig", "FAIL", True)
					Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
					Environment("Action_Result") = False : Exit Function
				End If
				
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
							blnStencilFound = False
							ReDim Preserve arrStencilDet(iCounter)
							
							For index = LBound(arrStencilInput) To UBound(arrStencilInput)
								Stencil = arrStencilInput(index)
								Quantity = arrQuantityInput(index)
								If strCapturedStencil = Stencil Then
									Set elmOuterCell = .ChildItem(iRow, intMobilePlus, "WebElement", 0)
									If fn_SQE_CheckMobilePlusLink(elmOuterCell, lnkMobilePlus) then
										strOperation = "INCREASE"
										
									ElseIf fn_SQE_CheckConfigureLink(elmOuterCell, lnkConfigure) Then
										strOperation = "ADD"
										lnkConfigure.Click
										
										If objPage.WebList("Link2New").Exist(60) Then
											If Not objPage.WebList("Link2New").Object.Disabled Then
												objPage.WebList("Link2New").Select "Mobile Plus"
												
												'Click on Add button on WebList pop up
												blnResult = clickButton("btnAdd")
												If Not blnResult Then
													Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
													Environment("Action_Result") = False : Exit Function
												End If
												
												'Click Okay Button on WebList Popup
												blnResult = clickButton("btnOk")
												If Not blnResult Then
													Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
													Environment("Action_Result") = False : Exit Function
												End If
												
												Wait 3
												
												'Wait until Number of outstanding saves status is not visible
												For intCounter = 1 to 25
													If objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10) Then	
														Wait 15
													Else
														Exit For
													End If
												Next
												
											End If
										End If '#Link2New
									End If
									
									
									blnStencilFound = True
									Exit For
								End If '#strCapturedStencil = Stencil
							Next '#index
							
							arrStencilDet(iCounter - 1) = iRow & ";" & strCapturedStencil & ";" & strOperation & ";" & Quantity
							iCounter = iCounter + 1
						End If '#lstStencil.Exist(0)
					End If '#intCols
				Next '#iRow
			End With
			
			If iCounter > 2 Then
				ReDim Preserve arrStencilDet(Ubound(arrStencilDet) - 1)
			End If
			
			'Click on BaseConfiguration under UnifiedMessaging under Line Service-OCC
			If .WebElement("elmMobilePlus").WebElement("elmBaseConfiguration").Exist(30) Then
				.WebElement("elmMobilePlus").WebElement("elmBaseConfiguration").Click
				Call ReportLog("LineService-OCC</BR>Mobile Plus</BR>Base Configuration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "Information", False)
			Else
				Call ReportLog("LineService-OCC</BR>Mobile Plus</BR>Base Configuration", "WebElement should exist and is to be clicked", "WebElement exists and is clicked", "FAIL", True)
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Environment("Action_Result") = False : Exit Function
			End If			
		End With
		
		With objPage.WebTable("tblBaseConfig")
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
			
			intRows = .RowCount
			For iRow = 2 To intRows
				For Each tmpStencil in arrStencilDet
					tmpArrStencilDetails = Split(tmpStencil, ";")
					If iRow = CInt(tmpArrStencilDetails(0)) Then
						intCols = .ColumnCount(iRow)
						If intCols <> 1 Then
							Set elmQuantityOuter = .ChildItem(iRow, intQuantity, "WebElement", 0)
							Set elmOldVal = elmQuantityOuter.ChildObjects(oDescOldVal)
							Set elmAddNewVal = elmQuantityOuter.ChildObjects(oDescAddNewVal)
							
							If elmOldVal.Count >= 1 Then
										intOldVal = CInt(elmOldVal(0).GetROProperty("innertext"))
										intUpdateVal = intOldVal + CInt(tmpArrStencilDetails(3))
									
										Set elmNewVal = elmQuantityOuter.ChildObjects(oDescNewVal)
										If elmNewVal.Count = 0 Then
											Call ReportLog("Mobile Plus", "Updating New Value field Test Object Properties is changed", "Contact Automation Team", "FAIL", True)
											Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
											Environment("Action_Result") = False : Exit Function
										Else
											elmNewVal(0).HighLight
											elmNewVal(0).Click
												DeviceReplay.KeyDown 29 'Control
												DeviceReplay.PressKey 30 'A
												DeviceReplay.KeyUp 29 'Control
											Wait 5
												DeviceReplay.SendString CStr(intUpdateVal) 'Enter the Quantity
												'Print tmpArrStencilDetails(2)
												Wait 2
												DeviceReplay.PressKey 15 'TAB
											wait 10
											
											'After clearing the contents, test object property gets changed from None to Update
											Set elmUpdateVal = elmQuantityOuter.ChildObjects(oDescUpdateVal)
											If elmUpdateVal.Count = 0 Then
												Call ReportLog("Mobile Plus", "Updating New Value field Test Object Properties is changed after clearing content", "Contact Automation Team", "FAIL", True)
												Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
												Environment("Action_Result") = False : Exit Function
											End If
											
											strUpdateValue = elmUpdateVal(0).GetROProperty("innertext")
											
											If CInt(strUpdateValue) = CInt(intUpdateVal) Then
												Call ReportLog("Updating Mobile Plus", "<B>" & tmpArrStencilDetails(1) & "</B> - should be set with <B>" & intUpdateVal & "<B>",_
													tmpArrStencilDetails(1) & "</B> - is updated with <B>" & strUpdateValue, "Information", True) 
											Else
												Call ReportLog("Updating Mobile Plus", "<B>" & tmpArrStencilDetails(1) & "</B> - should be set with <B>" & intUpdateVal & "<B>",_
													tmpArrStencilDetails(1) & "</B> - is updated with <B>" & strUpdateValue, "FAIL", True)
												Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode	
												Environment("Action_Result") = False : Exit Function
											End If
											
										End If '#elmNewVal.Count
							
							ElseIf elmAddNewVal.Count >= 1 Then
									'To be scripted
									
										elmAddNewVal(0).HighLight
										elmAddNewVal(0).Click
											DeviceReplay.KeyDown 29 'Control
											DeviceReplay.PressKey 30 'A
											DeviceReplay.KeyUp 29 'Control
										Wait 5
											DeviceReplay.SendString CStr(tmpArrStencilDetails(3)) 'Enter the Quantity
											Wait 2
											DeviceReplay.PressKey 15 'TAB
										Wait 10
										
										elmAddNewVal(0).RefreshObject
										strQuantity = elmAddNewVal(0).GetROProperty("innertext")
										
										If CInt(strQuantity) = CInt(tmpArrStencilDetails(3)) Then
											Call ReportLog("Updating Mobile Plus", "<B>" & tmpArrStencilDetails(1) & "</B> - should be set with <B>" & tmpArrStencilDetails(3) & "<B>",_
													tmpArrStencilDetails(1) & "</B> - is updated with <B>" & strQuantity, "Information", True)
										Else
											Call ReportLog("Updating Mobile Plus", "<B>" & tmpArrStencilDetails(1) & "</B> - should be set with <B>" & tmpArrStencilDetails(3) & "<B>",_
													tmpArrStencilDetails(1) & "</B> - is updated with <B>" & strQuantity, "FAIL", True)
											Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode	
											Environment("Action_Result") = False : Exit Function											
										End If
										
							End If '#elmOldVal.Count >= 1
						End If '#intCols <> 1
					End If '#iRow = tmpArrStencilDetails(0)
				Next '#tmpStencil
			Next '#iRow
		End With
	'Next '#index
	
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
		If objPage.Link("lnkCalculatePrice").waitProperty("class", "main-action actionBtnDisable", 1000*60*5) Then
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


'======================================================================================================================================
' Description: Check if Mobile Plus Link is present or not in a given Cell
' Return: Boolean (True/False)
'======================================================================================================================================
Public Function fn_SQE_CheckMobilePlusLink(ByVal elmOuterCell, ByRef elmMobilePlus)
	Dim oDescElmMobilePlusLink
	
	Set oDescElmMobilePlusLink = Description.Create
	oDescElmMobilePlusLink("micclass").Value = "WebElement"
	oDescElmMobilePlusLink("html tag").Value = "A"
	oDescElmMobilePlusLink("innertext").Value = "Mobile Plus"
	
	Set oElmMobilePlusLinks = elmOuterCell.ChildObjects(oDescElmMobilePlusLink )
	If oElmMobilePlusLinks.Count = 1 Then
		Set elmMobilePlus = oElmMobilePlusLinks(0)
		fn_SQE_CheckMobilePlusLink = True
	Else
		fn_SQE_CheckMobilePlusLink = False
	End If
End Function

'======================================================================================================================================
' Description: Check if Configure Link is present or not in a given Cell
' Return: Boolean (True/False)
'======================================================================================================================================
Public Function fn_SQE_CheckConfigureLink(ByVal elmOuterCell, ByRef elmConfigure)
	Dim oDescElmMobilePlusLink
	
	Set oDescElmConfigureLink = Description.Create
	oDescElmConfigureLink ("micclass").Value = "WebElement"
	oDescElmConfigureLink ("html tag").Value = "A"
	oDescElmConfigureLink ("innertext").Value = "Configure"
	
	Set oElmConfigureLinks = elmOuterCell.ChildObjects(oDescElmConfigureLink)
	If oElmConfigureLinks.Count = 1 Then
		Set elmConfigure = oElmConfigureLinks(0)
		fn_SQE_CheckConfigureLink = True
	Else
		fn_SQE_CheckConfigureLink = False
	End If
End Function
