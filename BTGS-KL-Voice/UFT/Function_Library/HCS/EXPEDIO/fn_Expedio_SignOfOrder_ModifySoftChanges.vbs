'****************************************************************************************************************************
' Function Name 		:		fn_Expedio_SignOfOrder_ModifySoftChanges
' Purpose				: 		Function to Add Products to the Quote
' Author				:		 Anil
' Creation Date  		 : 			  04/7/2014
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_SignOfOrder_ModifySoftChanges(ByVal dQuoteID)
	On Error Resume Next
		Dim intCounter, intMOPSent
		Dim strStatus
		
		intMOPSent = 0
		
		'Loop to check whether the page has been loaded or not
		For intCounter = 1 to 5
			blnExist = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebElement("webElmSearchOrder").Exist
			If blnExist Then
				Exit For
			End If
		Next

		'Build Track Order Reference
		blnResult = BuildWebReference("brwIPSDKTrackOrder", "pgIPSDKTrackOrder", "")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		
		For intCounter = 1 To 5
			'Enter Quote ID
			blnResult = enterText("txtQuoteID", dQuoteID)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Click on Search Link
			blnResult = clickLink("lnkSearch")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Check the Status of Quote
			strStatus = objPage.WebEdit("txtOrderStatus").GetROProperty("value")
			If UCase(strStatus) = "OPEN"  Then
				Call ReportLog("Check Status", "Quote Status should in Open", "Quote Status is Open", "PASS", False)
			Else
				Call ReportLog("Check Status", "Quote Status should in Open", "Quote Status is found to be " & strStatus, "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	
			blnExist = objPage.WebTable("tblBaseQuoteTable").Exist(10)
			If Not blnExist Then
				Call ReportLog("tblBaseQuoteTable", "tblBaseQuoteTable table should exist", "tblBaseQuoteTable table doesn't exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			intRows = objPage.WebTable("tblBaseQuoteTable").RowCount()
			If intMOPSent = 0 Then
				arrColumns = Split(objPage.WebTable("tblBaseQuoteTable").GetROProperty("column names"), ";")
				For index = 0 TO UBound(arrColumns)
					If arrColumns(index) = "MOPSent" Then
						intMOPSent = index + 1
						Exit For '#index
					End If
				Next	
			End If
			
			If intMOPSent = 0 Then
				Call ReportLog("MOPSent Column", "MOPSent column should exist", "MOPSent Column doesn't exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			intQuoteIDRow = objPage.WebTable("tblBaseQuoteTable").GetRowWithCellText(dQuoteID)
			If intQuoteIDRow > 0 Then
				blnMOPPopulated = True
				For iRow = 1 To intRows
					objPage.WebTable("tblBaseQuoteTable").RefreshObject
					strMOPSent = Trim(objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, intMOPSent))
					If strMOPSent = "" Then
						blnMOPPopulated = False
					End If
				Next '#iRow
				
				If blnMOPPopulated Then 
					Exit For '#intCounter
				Else
					Wait 60
				End If
			Else
				Wait 60
			End If
		Next '#intCounter
		
		If intQuoteIDRow <= 0 OR Not blnMOPPopulated Then
			Call ReportLog("Check MOP", "Either Quote Search is unsuccessful or MOP is not populated for the quote", "Either Quote Search is unsuccessful or MOP is not populated for the quote", "FAIL", True)
			Environment("Action_Result") = False
			If objPage.Link("lnkLogout").Exist(5) Then
				objPage.Link("lnkLogout").Click
			End If
	
			If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) Then
				objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
			End If
	
			Browser("creationtime:=0").Close
			Exit Function
		End If
		
		For iRow = 1 To intRows
			objPage.WebTable("tblBaseQuoteTable").RefreshObject
			strMOPSent = Trim(objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, intMOPSent))
			If strMOPSent = "No" Then
				blnExist = objPage.WebTable("tblBaseQuoteTable").Exist(10)
				For intCounter = 1 To 5
					If iRow > 1 Then
						objPage.WebTable("tblBaseQuoteTable").Object.rows(iRow-1).cells(1).Click
						Wait 5
						Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").Link("lnkAssign").Object.Click
						Set oPopUp = objPage.Frame("title:=BMC Remedy User - (Error|Note)")
						If oPopUp.Exist(60) Then
							strTitle = Time(oPopUp.GetROProperty("title"))
							If strTitle = "BMC Remedy User - Error" Then
								If objPage.Frame("frmBMCRemedyUserError").WebElement("elmOrderAlreadyAssignedError").Exist(0) Then
									objPage.Frame("frmBMCRemedyUserError").Link("lnkOK").Click
									objPage.Sync
									Exit For '#intCounter
								ElseIf objPage.Frame("frmBMCRemedyUserError").WebElement("elmOrderAssignmentError").Exist(0) Then
									objPage.Frame("frmBMCRemedyUserError").Link("lnkOK").Click
									objPage.Sync
								End If
							Else
								If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) Then
									objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
									objPage.Sync
									Exit For '#intCounter
								End If
							End If
						
						End If					
					Else 
						Call ReportLog("Quote Table", "Quote Base Table should be loaded", "Quote Base Table is not loaded", "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End if
				Next '#intCounter
				
				Wait(5)
				Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").Link("lnkOrderList").Object.Click
				Set objElm = objPage.WebTable("tblBaseQuoteTable").ChildItem(iRow, 1, "WebElement", 1)
				If objElm.Exist Then
					objElm.HighLight
					objElm.FireEvent "ondblclick",,,micLeftBtn 
					For intCounter = 1 to 30
						If objPage.Link("lnkOrderDetails").Exist Then
							Exit For
						Else
							Wait (15)
						End If
					Next
				Else
					Call ReportLog("Quote Table", "Search QUote ID", "Quote table was not loaded", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				End If	
		
				objPage.Link("lnkCustomerDetails").Object.Click
				Wait(2)
		
				strBillingID = Trim(objPage.WebEdit("txtRFVBillingID").GetROProperty("value"))
				If strBillingID = "" Then
					Call ReportLog("Check Billing ID", "Billing ID should be populated", "Billing ID is not auto populated for Site Change", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				Else
					Call ReportLog("Check Billing ID", "Billing ID should be populated", "Billing ID is auto populated for Site Change", "PASS", True)
				End If
		
				strOrderSignDate = Trim(objPage.WebEdit("txtRFVOrderFormSignDate").GetROProperty("value"))
				If strOrderSignDate = "" Then
					Call ReportLog("Check Order Form Sign Date", "Check Order Form Sign Date should be populated", "Check Order Form Sign Date is not populated", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				Else
					Call ReportLog("Check Order Form Sign Date", "Check Order Form Sign Dateshould be populated", "Check Order Form Sign Date is found to be " & strOrderSignDate, "PASS", False)
				End If  
															
				strCRD = Trim(objPage.WebEdit("txtRFVCustReqdDate").GetROProperty("value"))
				If strCRD = "" Then
					Call ReportLog("Check CRD", "CRD should be populated", "CRD is not populated", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				Else
					Call ReportLog("Check CRD", "CRD should be populated", "CRD is found to be " & strCRD, "PASS", False)
				End If      
		
				objPage.Link("lnkBillofMaterials").Object.Click
				Wait 5
		
				intRow = objPage.WebTable("tblSiteName").RowCount
				Set objElm =  objPage.WebTable("tblSiteName").ChildItem(intRow, 1, "WebElement", 0)
				objElm.Object.Click
				Wait 5
				For intCounter = 1 to 10
					blnExist = objPage.WebTable("tblProduct").Exist
					If blnExist Then
						intRowCount = objPage.WebTable("tblProduct").RowCount 
						If intRowCount > 0 Then
							Call ReportLog("Check Product Table", "Product Table should be Loaded", "Product Table is loaded", "PASS", True)
							Exit For
						End If
					End If
				Next	
							
				If Not blnExist And intRowCount < 1 Then
					Call ReportLog("Check Product Table", "Product Table should be Loaded", "Product Table is loaded", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				End If
				
				objPage.Link("lnkActions").Object.click			
				Wait 5
				
				objPage.WebElement("elmCalculatedCCD").WebEdit("txtCaluculatedCCD").Set CStr(DateAdd("d", 15, Now))
				objPage.WebElement("elmAccessRequiredByDate").WebEdit("txtAccessRequiredByDate").Set CStr(DateAdd("d", 15, Now))
				objPage.WebElement("elmCPERequiredByDate").WebEdit("txtCPERequiredByDate").Set CStr(DateAdd("d", 15, Now))
				
				blnResult = clickLink("lnkSignoff&Submit")
				If Not blnResult Then
					Environment("Action_Result") = False
					Exit Function
				End If
		
				Wait 60
		
				For intCounter = 1 to 10
					If objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Exist Then
						objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
						If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) And Not objPage.Frame("frmBMCRemedyUserNote").WebElement("elmOrderSubmissionNote").Exist(10) Then
							objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
						End If
						Exit For
					End If
				Next  
		
				Wait 30
		
				'Capture Expedio ID
				With Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder")
						For intCounter = 1 to 7
							If .Frame("frmBMCRemedyUserNote").WebElement("elmOrderSubmissionNote").Exist(10) Then
									strText = .Frame("frmBMCRemedyUserNote").WebElement("elmOrderSubmissionNote").GetROProperty("innertext")
									Call getCountOfRegExpPattern("EXP\d+", strText, False, strExpedioID)
									If strExpedioID = "" Then
										Call ReportLog("Capture Expedio ID", "Expedio ID should be generated", "Expedio ID is not generated", "FAIL", True)
										Environment("Action_Result") = False
											If .Link("lnkOK").Exist Then
												.Link("lnkOK").Object.Click
											End If
										Exit For
									Else
										Call ReportLog("Capture Expedio ID", "Expedio ID should be generated", "Expedio ID is found to be " & strExpedioID, "PASS", True)
										Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dExpedioID", strExpedioID)
										Environment("Action_Result") = True
											If .Link("lnkOK").Exist Then
												.Link("lnkOK").Object.Click
											End If
										Exit For
									End If
		
							ElseIf .WebElement("elmBMCRemedyUserError").Exist(10) Then
									Call ReportLog("Capture Expedio ID", "Encountered Error while submitting", "Encountered Error while submitting", "WARNINGS", True)
									If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) Then
										objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
									End If
									If .WebElement("innertext:=Expedio Order ID\d+").Exist(5) Then
										.WebElement("innertext:=Expedio Order ID\d+").HighLight
										Wait 3
										strOrder = .WebElement("innertext:=Expedio Order ID\d+").GetROProperty("innertext")
										Call getCountOfRegExpPattern("\d+", strOrder, False, strExpedioID)
										If strExpedioID = "" Then
											Call ReportLog("Capture Expedio ID", "Expedio ID should be generated", "Expedio ID is not generated", "FAIL", True)
											Environment("Action_Result") = False
											Exit For
										Else
											Call ReportLog("Capture Expedio ID", "Expedio ID should be generated", "Expedio ID is found to be EXP" & strExpedioID, "PASS", True)
											Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dExpedioID", "EXP" & strExpedioID)
											Environment("Action_Result") = True
											Exit For
										End If
									End If
							End If
						Next
				End With
			End If
			
			If Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").Link("lnkOrderList").Exist(60) Then
				Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").Link("lnkOrderList").Object.Click
				Browser("brwIPSDKTrackOrder").fSync
			End if
			
		Next '#iRow
		

		Wait 10

		If objPage.Link("lnkLogout").Exist(5) Then
			objPage.Link("lnkLogout").Click
		End If

		If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) Then
			objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
		End If

		Browser("creationtime:=0").Close
End Function
