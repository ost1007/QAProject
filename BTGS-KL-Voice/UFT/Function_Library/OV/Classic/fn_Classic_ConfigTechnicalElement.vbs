Public Function fn_Classic_ConfigTechnicalElement()
	
	Dim intCounter
	
	For intCounter = 1 To 3
		If Window("AmdocsCRM").Window("QuoteWindow").WinTab("tbHeader").Exist(60) Then
			Window("AmdocsCRM").Window("QuoteWindow").WinTab("tbHeader").Select "Technical Elements"
			Wait 5
		End If
		
		'If Not found then below code will fail
		If Window("AmdocsCRM").Window("QuoteWindow").WinTable("grdTechElmServices").Exist(60) Then
			Exit For '#intCounter
		End If
	Next '#intCounter

	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "QuoteWindow")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Service/Subproject from WinTab
	blnResult = selectItemFromWinTab("tbHeader", "Technical Elements")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Wait For Grid Technical Element Services to appear
	Set oWndControl = oChildWindow.WinTable("grdTechElmServices")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select the Row
	'oWndControl.SelectRow "#1"
	
	intTechElmServicesRow = oChildWindow.WinTable("grdTechElmServices").RowCount
	
	For iElmServRow = 1 To intTechElmServicesRow
			'Build Amdocs Reference
			blnResult = BuildAmdocsWindowReference("AmdocsCRM", "QuoteWindow")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			oChildWindow.WinTable("grdTechElmServices").SelectRow "#" & iElmServRow
			strServiceType = oChildWindow.WinTable("grdTechElmServices").GetCellData("#" & iElmServRow, "#1")
			
			Call ReportLog("Check CRUD", "Checking CRUD for <B>" & strServiceType, strServiceType & " - is being checked", "Information", False)
			
			If Not oChildWindow.WinTable("grdTechnicalElements").Exist(60) Then
				Call ReportLog("Technical Element Grid", "Grid should exist", "Grid doesn't exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				Wait 10
				'Row is selected to enable Config tech Element Table
				oChildWindow.WinTable("grdTechnicalElements").SelectRow "#1"
				Wait 2
			End If
			
			'Check whether Config Tech Elm button exists or not
			blnResult = oChildWindow.WinButton("btnConfigTechElements").Exist(60)
			If Not blnResult Then
				Call ReportLog("Config Tech Elm", "Config Tech Elm button should exist", "Config Tech Elm button doesn't exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Wait until Config Tech Elm button gets enabled and then click on it
			blnResult = oChildWindow.WinButton("btnConfigTechElements").WaitProperty("enabled", True, 1000*60*2)
			If Not blnResult Then
				Call ReportLog("Config Tech Elm", "Config Tech Elm button should be enabled", "Config Tech Elm button is disabled", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				blnResult = clickChildWindowButton("btnConfigTechElements")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
			
			'Wait For btnCheckCRUD to appear
			Set oWndControl = oParentWindow.Window("ItemConfiguration").WinButton("btnCheckCRUD")
			blnResult = waitForWindowControl(oWndControl, 120)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Build Amdocs Reference
			blnResult = BuildAmdocsWindowReference("", "ItemConfiguration")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			
			If Not oChildWindow.WinTable("grdItems").Exist(60) Then
				Call ReportLog("Item Config", "Technical Item Grid should exist", "Technical Items Grid doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				Wait 30				
				oChildWindow.WinTable("grdItems").SelectRow "#1"
				Wait 2
			End If
			
			Wait 60
			oParentWindow.Activate
			
			'Click on Check CRUD
			blnResult = clickChildWindowButton("btnCheckCRUD")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			'Wait For Validation MsgBox to Appear
			Set oWndControl = oParentWindow.Dialog("DialogValidation").WinObject("msgValidationResult")
			blnResult = waitForWindowControl(oWndControl, 180)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			strValidationMessage = oWndControl.GetROProperty("text")
			If Instr(strValidationMessage, "The technical elements are properly configured.") > 0 Then
					Call ReportLog("Check CRUD", "All Technical elements should be configured properly", "All Technical Elements are configured", "PASS", True)
					oParentWindow.Dialog("DialogValidation").WinButton("btnOk").Click
					blnValidated = True
			Else
					oParentWindow.Dialog("DialogValidation").WinButton("btnOk").Click
					Wait 10
					ProductName = "" : AtrributeName = ""
					If getCountOfRegExpPattern("- Product Name: '.*'", strValidationMessage, False, ProductName) = 0 Then
						Call ReportLog("Check CRUD", "Expecting Product Name and Attributes for checking CRUD", "Invalid Message appeared", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					If getCountOfRegExpPattern("Attribute: '.*'", strValidationMessage, False, AtrributeName) = 0 Then
						Call ReportLog("Check CRUD", "Expecting Product Name and Attributes for checking CRUD", "Invalid Message appeared", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					'ProductName = "BT MPLS Dedicated Access" & vbCrLf & "CPE"	AtrributeName = "Access circuit required by date" & vbCrLf & "Required Date"
					arrProductName = Split(ProductName, vbCrLf)
					arrAttributeName = Split(AtrributeName, vbCrLf)
					
					Call fn_Classic_ExpandItemsTable()
					Wait 10
				
					For index = LBound(arrProductName) To UBound(arrProductName)
						iLeft = Instr(arrProductName(index), "'") + 1
						iRight = InstrRev(arrProductName(index), "'")
						arrProductName(index) = Mid(arrProductName(index), iLeft, iRight - iLeft)
						
						iLeft = Instr(arrAttributeName(index), "'") + 1
						iRight = InstrRev(arrAttributeName(index), "'")
						arrAttributeName(index) = Mid(arrAttributeName(index), iLeft, iRight - iLeft)
												
					
						intRows = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").RowCount
						For iRow = 1 To intRows
							strCapturedProductName = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").GetCellData("#" & iRow, "#5")
							If strCapturedProductName = arrProductName(index) Then
								Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").SelectRow "#" & iRow	
								blnLoaded = False
								For iRowCounter = 1 To 5
									If Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdAttributes").Exist(60) Then
										intRows = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdAttributes").RowCount
										If intRows > 1 Then
											blnLoaded = True
											Exit For
										Else
											Wait 30
										End If
									End If
								Next '#iRowCounter
								
								If Not blnLoaded Then
									Call ReportLog("Attribute Table", "Attribute Table should be loaded", "Attribute table is not loaded", "FAIL", True)
									Environment("Action_Result") = False ': Exit Function
								Else
									Call fn_Classic_FillAttributeValue(arrAttributeName(index))
									Exit For
								End If
							End If
						Next '#iRow
					Next '#index
					
					
					'Click on Check CRUD
					blnResult = clickChildWindowButton("btnCheckCRUD")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
					'Wait For Validation MsgBox to Appear
					Set oWndControl = oParentWindow.Dialog("DialogValidation").WinObject("msgValidationResult")
					blnResult = waitForWindowControl(oWndControl, 180)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
					strValidationMessage = oWndControl.GetROProperty("text")
					If Instr(strValidationMessage, "The technical elements are properly configured.") > 0 Then
						Call ReportLog("Check CRUD", "All Technical elements should be configured properly", "All Technical Elements are configured", "PASS", True)
						oParentWindow.Dialog("DialogValidation").WinButton("btnOk").Click
						blnValidated = True
					Else
						Call ReportLog("Check CRUD", "All Technical elements should be configured properly", strValidationMessage, "FAIL", True)
						oParentWindow.Dialog("DialogValidation").WinButton("btnOk").Click
						Environment("Action_Result") = False : Exit Function
					End If
					
					'Wait For Save/Done button to appear
					Set oWndControl = Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnSave/Done")
					blnResult = waitForWindowControl(oWndControl, 120)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
						
					'Wait for button to be enabled
					blnResult = Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnSave/Done").WaitProperty("enabled", True, 1000*60*2)
					If Not blnResult Then
						Call ReportLog("Config TE", "Button Save/Done should be enable to click", "Button Save/Done disabled to click", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					'Click on Done
					blnResult = clickChildWindowButton("btnSave/Done")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
						
					'Wait For Configuration Saved Dialog to Appear			
					If oParentWindow.Dialog("WindowDialogs").Static("msgConfigurationSaved").Exist(180) Then
						oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
					End If
				
			End If '#Instr(strValidationMessage, "The technical elements are properly configured.")
			
			'Click on Done
			If Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnDone").Exist(60) Then
				Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnDone").Click
			End If
			'blnResult = clickChildWindowButton("btnDone")
			'	If Not blnResult Then Environment("Action_Result") = False : Exit Function

			'Wait For Grid Technical Element Services to appear
			Set oWndControl = Window("AmdocsCRM").Window("QuoteWindow").WinTable("grdTechElmServices")
			blnResult = waitForWindowControl(oWndControl, 120)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
	Next '#iElmServRow
	
	Wait 10
	
'		'Wait For Configuration Saved Dialog to Appear
'		Set oWndControl = oParentWindow.Dialog("WindowDialogs").Static("msgConfigurationSaved")
'		blnResult = waitForWindowControl(oWndControl, 120)
'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
'		
'		If oParentWindow.Dialog("WindowDialogs").Static("msgConfigurationSaved").Exist(0) Then
'			oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
'		End If
	
	'Wait for the Quote Window Screen to be visible
	Window("AmdocsCRM").Window("QuoteWindow").WaitProperty "visible", True, 1000*60*3
		
End Function

'*****************************************************************************************************************************************************************************************************************
' Description: Function to activate cell and expand its content
'*****************************************************************************************************************************************************************************************************************
Function fn_Classic_ExpandItemsTable()
	iRow = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").RowCount
	Do
		strCellData = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").GetCellData("#" & iRow, "#4")
		If Left(strCellData,1) = "+" Then
			Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").SelectCell "#" & iRow, "#4"
			Wait 10
			Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").ActivateCell "#" & iRow, "#4"
			Wait 10
			Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdItems").RefreshObject
			Wait 5
		Else
			iRow = iRow - 1
		End If
	Loop While iRow <> 1	
End Function


'*****************************************************************************************************************************************************************************************************************
' Description: Function to set the Attributes to Item Attributes
'*****************************************************************************************************************************************************************************************************************
Function fn_Classic_FillAttributeValue(AtrributeName)
	intRows = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdAttributes").RowCount
	For iRow = 1 To intRows
		strCellData = Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdAttributes").GetCellData("#" & iRow, 1)
		If strCellData = AtrributeName Then
			Window("AmdocsCRM").Window("ItemConfiguration").WinTable("grdAttributes").SelectRow "#" & iRow
			Call ReportLog("Acting on Attribute", "Acting on Attibute - " & AtrributeName, "Acting on Attibute - " & AtrributeName, "Information", False)
			Select Case AtrributeName
					Case "Access circuit required by date", "Required Date"
						For intCounter = 1 To 5
							If Not Window("AmdocsCRM").Dialog("DateTimeEntry").Exist(60) Then
								Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnAttributeDate").Click	
							Else						
								blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
							End If
						Next
						
						Select Case AtrributeName
							Case "Required Date"
								Call fn_Classic_SetDialogDate(Date + 1)
							Case "Access circuit required by date"
								Call fn_Classic_SetDialogDate(Date)
						End Select
						
						'Call fn_Classic_SetDialogDate(Date)
						If Not Environment("Action_Result") Then
							Call ReportLog("Set Date", "Set Date should be successful", "Set Date is not successful", "FAIL", True)
							Exit Function
						Else
							Wait 60
						End If
						
						If Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnSaveConfiguration").Exist(180) Then
							Window("AmdocsCRM").Window("ItemConfiguration").WinButton("btnSaveConfiguration").Click
						End If
						
						For intCounter = 1 To 50
							If Window("AmdocsCRM").Dialog("WindowDialogs").Static("msgConfigurationSaved").Exist(10) Then
								Window("AmdocsCRM").Dialog("WindowDialogs").WinButton("btnOK").Click
								Wait 60
								Exit For
							End If
						Next '#intCounter

						fn_Classic_FillAttributeValue = True
						Exit Function
				End Select
		End If
	Next
	
	Call ReportLog("Atrribute Search", AtrributeName & " - should be visible in Attribute Table", AtrributeName & " - is not displayed in Attribute Table", "FAIL", True)
	fn_Classic_FillAttributeValue = False
End Function
