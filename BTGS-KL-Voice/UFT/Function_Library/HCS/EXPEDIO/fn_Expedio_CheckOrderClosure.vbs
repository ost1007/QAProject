'=============================================================================================================
'Description: Function to Check whether Order is closed or not using Quote ID
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			12/08/2015 			
'Example: fn_Expedio_CheckOrderClosure("000000000205665")
'=============================================================================================================
Public Function fn_Expedio_CheckOrderClosure(ByVal QuoteID)

	'Variable Declaration
	Dim blnExist, blnComplete
	Dim intCounter
	Dim strOrderStatus, strOrderSubStatus

	blnComplete = False
	'Loop to check whether the page has been loaded or not
	For intCounter = 1 to 5
		blnExist = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebElement("elmSearchOrder").Exist(60)
			If blnExist Then Exit For
	Next

	'Build Track Order Reference
	blnResult = BuildWebReference("brwIPSDKTrackOrder", "pgIPSDKTrackOrder", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intLoopCounter = 1 To 10
			For intCounter = 1 To 5
					'Enter Quote ID
					blnResult = enterText("txtQuoteID", QuoteID)
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
			Next '#intCounter
		
			'Terminate If Table is not loaded on Search
			If Not blnExist Then
				Call ReportLog("Quote Table", "Quote Base Table should be loaded", "Quote Base Table is not loaded", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		
			iRow = objPage.WebTable("tblBaseQuoteTable").GetRowWithCellText(QuoteID)
			If iRow <= 0 Then
				Call ReportLog("Quote Table", "Quote Base Table should be loaded with Searched Quote ID", "Quote Base Table is not loaded with Quote ID", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				strOrderStatus = Trim(objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, 6))
				strOrderSubStatus = Trim(objPage.WebTable("tblBaseQuoteTable").GetCellData(iRow, 7))
			End If
		
			If UCase(strOrderStatus) = "COMPLETE" And ( UCase(strOrderSubStatus) = "ALLLINEITEMSCOMPLETE" OR UCase(strOrderSubStatus) = "CLOSED" ) Then
				Call ReportLog("Check Order Closure", "Order Status should be <B>Complete</B></BR>Order Sub Status should be <B>AllLineItemsComplete</B>", "Order Status found to be <B>" & strOrderStatus & "</B></BR>Order Sub Status found to be <B>" & strOrderSubStatus & "</B>", "PASS", True)
				blnComplete = True
				Exit For '#intLoopCounter
			Else
				Wait 60
			End If
	Next '#intLoopCounter
	
	If Not blnComplete Then
		Call ReportLog("Check Order Closure", "Order Status should be <B>Complete</B></BR>Order Sub Status should be <B>AllLineItemsComplete</B>", "Order Status found to be <B>" & strOrderStatus & "</B></BR>Order Sub Status found to be <B>" & strOrderSubStatus & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	Else
		Environment("Action_Result") = True
	End If

	If objPage.Link("name:=Logout","index:=0").Exist(60) Then
		objPage.Link("name:=Logout","index:=0").Click
		Wait 10
	End If

	Browser("creationtime:=0").CloseAllTabs

End Function
