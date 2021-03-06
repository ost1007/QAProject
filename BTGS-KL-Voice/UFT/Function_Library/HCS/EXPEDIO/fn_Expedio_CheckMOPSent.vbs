'=============================================================================================================
'Description: Function to Sign off the Order using Quote ID
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			08/10/2014 	v1.0
'Example: fn_Expedio_SignOfOrder(dQuoteID)
'=============================================================================================================
Public Function fn_Expedio_CheckMOPSent(ByVal dQuoteID)
	On Error Resume Next
		Dim intCounter
		Dim strStatus

		'Loop to check whether the page has been loaded or not
		For intCounter = 1 to 5
			blnExist = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebElement("elmSearchOrder").Exist
			If blnExist Then Exit For
		Next

		'Build Track Order Reference
		blnResult = BuildWebReference("brwIPSDKTrackOrder", "pgIPSDKTrackOrder", "")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		For intCounter = 1 to 10
			'Enter Quote ID
			blnResult = enterText("txtQuoteID", dQuoteID)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'Click on Search Link
			blnResult = clickLink("lnkSearch")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			blnExist = objPage.WebTable("tblBaseQuoteTable").Exist(10)
			If Not blnExist Then
				Wait 50
			Else
				Exit For
			End If
		Next
		
		If Not blnExist Then
			Call ReportLog("Quote Table", "Quote Base Table should be loaded", "Quote Base Table is not loaded", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
		
		objPage.WebTable("tblBaseQuoteTable").RefreshObject
		arrColumnNames = Split(objPage.WebTable("tblBaseQuoteTable").GetROProperty("column names"), ";")
		intRowCount = objPage.WebTable("tblBaseQuoteTable").RowCount
		
		intMOPSentCol = -1 : intExpedioOrderIDCol = -1
		For iCol = 0 To UBound(arrColumnNames)
			If Trim(arrColumnNames(iCol)) = "MOPSent" Then
				intMOPSentCol = iCol + 1
			ElseIf Trim(arrColumnNames(iCol)) = "Expedio Order Id" Then
				intExpedioOrderIDCol = iCol + 1
			End If
		Next
		
		If intMOPSentCol = -1 OR intExpedioOrderIDCol = -1 Then
			Call ReportLog("Check Column", "MOP Sent/Expedio Order Id column should exist", "Column doesn't exist - Check for Table Property", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		For intCounter = 1 To 5
			blnMOPSent = True
			intRow = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebTable("tblBaseQuoteTable").GetRowWithCellText(dQuoteID)
			If intRow > 0 Then
				Set objElm = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebTable("tblBaseQuoteTable").ChildItem(intRow, 1, "WebElement", 0)
				If objElm.Exist(5) Then
					objElm.Object.Click
				End If
			Else
				Call ReportLog("Quote Table", "Quote Base Table should be loaded with Searched Quote ID", "Quote Base Table is not loaded with Quote ID", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If
			
			For iRow = 2 To intRowCount
				strExpedioOrderId = objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, intExpedioOrderIDCol)
				strMOPSent = objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, intMOPSentCol)
				objPage.WebTable("tblBaseQuoteTable").ChildItem(iRow, intMOPSentCol, "WebElement", 0).HighLight : Wait 5
				If Ucase(strMOPSent) = "YES" Then	
					Call ReportLog("Check MOP", "MOP Should be sent for Order ID - " & strExpedioOrderId, "MOP is sent successfully for Expedio Order Id - " & strExpedioOrderId, "PASS", True)
					Environment("Action_Result") = True
				Else
					Call ReportLog("Check MOP", "MOP Should be sent for Order ID - " & strExpedioOrderId, "MOP is not sent for Expedio Order Id - " & strExpedioOrderId, "Warnings", True)
					blnMOPSent = False
					'Environment("Action_Result") = False
				End If
			Next
			
			If blnMOPSent Then
				Exit For '#intCounter
			Else
				Wait 60
				For intCounterInner = 1 to 10
					'Enter Quote ID
					blnResult = enterText("txtQuoteID", dQuoteID)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
					'Click on Search Link
					blnResult = clickLink("lnkSearch")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
						
					blnExist = objPage.WebTable("tblBaseQuoteTable").Exist(10)
					If Not blnExist Then
						Wait 50
					Else
						Exit For '#intCounterInner
					End If
				Next
			End If
			
		Next '#intCounter
		
		If Not blnMOPSent Then
			Call ReportLog("Check MOP", "MOP Should be sent for Order ID - " & strExpedioOrderId, "MOP is not sent for Expedio Order Id - " & strExpedioOrderId, "Fail", True)
			Environment("Action_Result") = False
		End If
		
		
		If objPage.Link("lnkLogout").Exist(5) Then
			objPage.Link("lnkLogout").Click
		End If

		'		If objPage.WebButton("class:=Close  right","html tag:=BUTTON").Exist(5) Then
		'			objPage.WebButton("class:=Close  right","html tag:=BUTTON").Click
		'		End If

		Browser("creationtime:=0").Close
End Function
