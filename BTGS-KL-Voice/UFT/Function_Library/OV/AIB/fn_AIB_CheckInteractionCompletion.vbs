Public function fn_AIB_CheckInteractionCompletion()

	'Declaration of variables
	Dim strOrderRefNum
	Dim strProductName,strItemStatus,strItemSubStatus
	Dim strColumnName,strColumnValue
	Dim blnAttain
	Dim intCounter, intOrderStatusCol, intSubOrderStatus

	'Build  web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	arrColumns = Split(Trim(objPage.WebTable("tblOrderNumber").GetROProperty("column names")), ";")
	For iCounter = 0 To UBound(arrColumns) Step 1
		If Trim(arrColumns(iCounter)) = "Order Status" Then
			intOrderStatusCol = iCounter + 1
		ElseIf Trim(arrColumns(iCounter)) = "Order Sub-status" Then
			intSubOrderStatus = iCounter + 1
		End If
	Next
	
	For intCounter = 1 to 45
		'Retriving Main Order Number status 
		objPage.WebTable("tblOrderNumber").RefreshObject
		Set objTable = objPage.WebTable("tblOrderNumber")
		strOrderStatus = objTable.GetCellData(2, intOrderStatusCol)
		strSubOrderStatus = objTable.GetCellData(2, intSubOrderStatus)
		
		If strOrderStatus = "Complete" And strSubOrderStatus = "AllLineItemsComplete" Then
			objPage.Link("lnkFulfilmentOrders").Click : Wait 5
			Call ReportLog("Order Status","Order status should be retrived and should be 'Complete'.","Order Status retrieved is <B>" & strOrderStatus &"</B>","Information", False)
			Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'AllLineItemsComplete'.","Order Sub-status retrieved is <B>" & strSubOrderStatus &"</B>","Information", True)
			blnAttain = True
		ElseIf strOrderStatus = "Failed" Then
			blnAttain = False
			Exit For '#intCounter
		Else
			Call ReportLog("Order Status","Order status should be retrived and should be 'Complete'.","Order Status retrieved is <B>" & strOrderStatus &"</B>","Warnings", False)
			Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'AllLineItemsComplete'.","Order Sub-status retrieved is <B>" & strSubOrderStatus &"</B>","Warnings", False)
			blnAttain = False
		End If

		If Not blnAttain Then
			Wait 60
			Call fn_SIB_SearchAgainRefresh()
		Else
			Exit For
		End If
	Next '#intCounter

	If Not blnAttain Then
		objPage.Link("lnkFulfilmentOrders").Click : Wait 5
		Call ReportLog("Order Status","Order status should be retrived and should be 'Complete'.","Order Status retrieved is <B>" & strOrderStatus &"</B>","FAIL", True)
		Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'AllLineItemsComplete'.","Order Sub-status retrieved is <B>" & strSubOrderStatus &"</B>","FAIL",True)
		fn_AIB_CheckInterationCompletion = False
		Browser("brwAIB").Close
		Exit Function
	Else
		fn_AIB_CheckInterationCompletion = True
	End If

	If Browser("brwAIB").Exist(2) Then
		Browser("brwAIB").Close
	End If
End Function

'****************************************************************************************************************************
'						Used to Refresh and Search Again to get the status populated in WebTable
'****************************************************************************************************************************
Private Function fn_SIB_SearchAgainRefresh()
	On Error Resume Next
	Set oPage = Browser("name:=AIB \| Order Tracker", "CreationTime:=0").Page("title:=AIB \| Order Tracker")
 	
	If Not oPage.Exist(5) Then
		Exit Function
	End If

	If oPage.WebElement("class:=active").Exist(5) Then
		oPage.WebElement("class:=active").Click
	End If

	If oPage.WebButton("html id:=searchBtn","name:=Search").Exist(5) Then
		oPage.WebButton("html id:=searchBtn","name:=Search").Click
		For intCounter = 1 to 10
			If oPage.Image("file name:=loading\.gif").Exist(2) Then
				Wait 2
			Else
				Exit For
			End If
		Next
		
		For intCounter = 1 To 10
			If objPage.WebElement("innertext:=No matching data available\. Please refine your search criterion\.", "index:=0").Exist(10) Then
				oPage.WebButton("html id:=searchBtn","name:=Search").Click			
			Else
				Exit For
			End If
		Next		

		oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").ChildItem(2, 1, "Link", 0).Click
		For intCounter = 1 to 10
			If oPage.Image("file name:=loading\.gif").Exist(2) Then
				Wait 2
			Else
				Exit For
			End If
		Next
		
		For intCounter = 1 to 10
			If oPage.Link("text:=Fulfilment Orders").WaitProperty("height", micGreaterThan(0), 10000) Then
				Exit For
			Else
				oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").RefreshObject
				oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").ChildItem(2, 1, "Link", 0).Click
				Wait 3
			End If
		Next

		For intCounter = 1 to 10
			If oPage.Image("file name:=loading\.gif").Exist(2) Then
				Wait 2
			Else
				Exit For
			End If
		Next

	End If
End Function
