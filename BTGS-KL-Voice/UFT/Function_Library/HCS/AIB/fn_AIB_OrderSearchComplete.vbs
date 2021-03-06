'****************************************************************************************************************************
' Function Name	 : fn_AIB_OrderSearchComplete
' Purpose	 	 : Function to search completion status of order in AIB
' Author	 	 : Linta
' Creation Date  : 25/6/2014
' Parameters	 :OrderRefNum             					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_AIB_OrderSearchComplete(dAIBSearchData)
	On Error Resume Next
	'Declaration of variables
	Dim strOrderRefNum
	Dim strProductName,strItemStatus,strItemSubStatus
	Dim strColumnName,strColumnValue
	Dim blnFlagHCS : blnFlagHCS = False

	'Assigningof values to variables
	strOrderRefNum = dAIBSearchData

	'Build  web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function		

	blnAttain = False

	For intCounter = 1 to 10
		'Retriving Main Order Number status 
		objPage.WebTable("tblOrderNumber").RefreshObject
		Set objTable = objPage.WebTable("tblOrderNumber")
		intCols = objTable.GetROProperty("cols")
		strResult = ""
		ReDim strColumnName(intCols-1)
		ReDim strColumnValue(intCols-1)
		For i = 1 to intCols
			strColumnName(i-1) = objTable.GetCellData(1,i)
			strColumnValue(i-1) = objTable.GetCellData(2,i)
			If Trim(strColumnName(i-1)) = "Order Status"  Then
				If Trim(strColumnValue(i-1)) <> "Complete" Then
					Call ReportLog("Order Status","Order status should be retrived and should be 'Complete'.","Order Status retrieved is <B>" &strColumnValue(i-1) &"</B>","INFORMATION","")
					blnAttain = False
					'Exit Function
				Else
					blnAttain = True
				End If
			End If
			
			If Trim(strColumnName(i-1)) = "Order Sub-status"  Then
				If Trim(strColumnValue(i-1)) <> "AllLineItemsComplete" Then
					Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'AllLineItemsComplete'.","Order Sub-status retrieved is <B>" &strColumnValue(i-1) &"</B>","INFORMATION","")
					blnAttain = False
					'Exit Function
				Else
					blnAttain = True
				End If
			End If

			If Trim(strColumnName(i-1)) = "Customer Name"  Then
				Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dCustomerName", strColumnValue(i-1))
			End If
	
			If strResult = "" Then
				strResult =  strColumnName(i-1) & " : " & strColumnValue(i-1) 
			Else
				strResult = strResult & "<br>" & strColumnName(i-1) & " : " & strColumnValue(i-1) 
			End If
		Next 'i

		If Not blnAttain Then
			Wait 5
			Call fn_SIB_SearchAgain_Refresh()
		Else
			Exit For
		End If
	Next 'intCounter

	If Not blnAttain Then
		Call ReportLog("Order Status","Order status should be retrived and should be 'Complete'.","Order Status retrieved is <B>" &strColumnValue(i-1) &"</B>","FAIL", True)
		Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'AllLineItemsComplete'.","Order Sub-status retrieved is <B>" &strColumnValue(i-1) &"</B>","FAIL",True)
		Environment("Action_Result") = False
		Browser("brwAIB").Close
		Exit Function
	End If

	Call ReportLog("Order Number","Order Number Details should be retrived" , "<B>"&strResult& "</B>","PASS", True)
					
	'Retriving Main Order Item status 
	condCounter = 0
	Set objTable = objPage.WebTable("tblOrderItem")
	RowCnt = objTable.RowCount
	NumberOfProducts = RowCnt - 1
	
	For i = 1 to NumberOfProducts
		intCnt = i
		Do
			objTable.RefreshObject
			strProductName = objTable.GetCellData(intCnt+1,2)
			strItemStatus = objTable.GetCellData(intCnt+1,7)
			strItemSubStatus = objTable.GetCellData(intCnt+1,8)
			strAction=objTable.GetCellData(intCnt+1,3)
			If strAction="Modify" Then
				Call ReportLog("Item Status","Item status should be retrived","For the Product" &strProductName & "Item Status is " &strItemStatus & "and Item sub status is" &strItemSubStatus& "  Same order is Modified Successfully" ,"PASS","")
			End If

			'Particular to HCS Area
			If strProductName = "One Cloud Cisco" Then
				strServiceID = objTable.GetCellData(intCnt+1, 4)
				If strServiceID <> "" Then
					Call ReportLog("Capture Service ID", "Service ID should be populated", "Service ID is populated and found to be  " & strServiceID, "PASS", True)
					Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dServiceID", strServiceID)
					blnFlagHCS = True
				Else
					Call ReportLog("Capture Service ID", "Service ID should be populated", "Service ID is not populated","Warnings", True)
					objBrowser.Close
					'Environment("Action_Result") = False
					Exit Function
				End If
			End If
	
			If strItemStatus<> "Complete" and strItemSubStatus <> "Closed" Then
				'Click on plus symbol
				blnResult = clickWebElement("ElmAddDetails")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function

				   'Page synchronize
				   For intCounter = 1 to 40
					  'Check if the login was successful
					  Set objMsg =objpage.WebElement("ElmOrderSearch")
					  If objMsg.Exist And  CInt(objMsg.GetROProperty("height")) > 0Then
						  Exit For
					  Else
						  Wait 2
					  End If
				  Next
			
				  Call fn_AIB_OrderSearch(dAIBSearchData)
				  condCounter = condCounter+1
			Else
				Call ReportLog("Item Status and Sub-status","Item status and Sub-status should be retrived","For the Product <B>" &strProductName & "<B> Item Status is <B>" &strItemStatus & "<B> and Item sub status is <B> " &strItemSubStatus &"<B>","PASS", True)
				condCounter = 0
				Exit Do
			End If

			If condCounter = 60 Then
				If Trim(strItemStatus) <> "Complete" or Trim(strItemSubStatus) <> "Closed" Then
					Call ReportLog("Item Status and Sub-status","Item Status and item sub status should be Complete and  Closed","For the Product <B>" &strProductName & "Item Status is <B> " &strItemStatus & "and Item sub status is <B>" &strItemSubStatus ,"FAIL","TRUE")
					condCounter = 0
				End If
			End If

		Loop Until strItemStatus="Complete" or condCounter = 60
	Next

	'To Capture Index on Main Order Item Table
	Set objTable = objPage.WebTable("tblOrderItem")
	MainOrderItemTable= GetWebTableIndex (objTable)

	Set objTable = objPage.WebTable("tblOrderItem")
	strOrderItemNumber = objTable.GetCellData(2,1)
	Set objDesc = Description.Create
	objDesc("micClass").value = "WebElement"
	objDesc("innertext").value = strOrderItemNumber

	Set objOrderItemNumber = objTable.ChildObjects(objDesc)
	If objOrderItemNumber.Count >= 1 Then
		objOrderItemNumber(0).Click
		Wait 3
	End If

	dataTableIndex=MainOrderItemTable+1
	Set objTable = objPage.WebTable("index:=" & dataTableIndex)

	'Capture the valus inside that inner table.
	intCols = objTable.GetROProperty("cols")
	intRows = objTable.GetROProperty("rows")
	ReDim strColumnName(intCols-1)
	ReDim strColumnValue(intCols-1)
	For i = 2 to introws
		blnIncrement = False
		strResult = ""
		objTable.RefreshObject
		If objTable.ColumnCount(i) <> 8 Then
			Exit For
		End If
		For j = 1 to intCols
			strColumnName(j-1) = objTable.GetCellData(1,j)
			strColumnValue(j-1) = objTable.GetCellData(i,j)

			If Trim(strColumnName(j-1)) = "Item Status"  Then
				If Trim(strColumnValue(j-1)) <> "Complete" Then
					Call ReportLog("Item Status","Item status should be retrived and should be 'Completed'.","Item Status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
					Exit Function
				End If
			End If

			If Trim(strColumnName(j-1)) = "Item Sub-status"  Then
				If Trim(strColumnValue(j-1)) <> "Closed" Then
					Call ReportLog("Item Sub-status","Item Sub-status should be retrived and should be 'Closed'.","Item Sub-status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
					Exit Function
				End If
			End If

			'Particular to HCS Area
			If Trim(strColumnName(j-1)) = "Product Name"  Then
				If Trim(strColumnValue(j-1)) = "Trunk Group - OCC" Then
					strTrunkGroupServiceID = objTable.GetCellData(i, 4)
					objTable.ChildItem(i, 1, "WebElement", 0).Click : Wait 2
					Call fn_AIB_CaptureTrunkServiceID(strTrunkServiceID)
					objTable.ChildItem(i, 1, "WebElement", 0).Click
					introws = introws + 2 : blnIncrement = True
					objTable.RefreshObject
				End If
			End If

			If strResult = "" Then
				strResult =  strColumnName(j-1) & " : " & strColumnValue(j-1) 
			Else
				strResult =  strResult & "<br>" & strColumnName(j-1) & " : " & strColumnValue(j-1) 
			End If

		Next
		Call ReportLog("Inner Order Item table","Order Item Details should be retrived" ,"<B>"& strResult& "</B>","PASS", True)
		If blnIncrement Then i = i + 1
	Next

	objOrderItemNumber(0).Click
	Wait 3

	If ( strTrunkGroupServiceID = "" Or strTrunkServiceID = "" ) And blnFlagHCS  Then
		Call ReportLog("Capture Trunk Details", "Trunk Group and Trunk OCC should be populated","Trunk Group [" & strTrunkGroupServiceID & "] Trunk OCC[" & strTrunkServiceID & "] either one of the value is missing", "Information", True)
		Environment("Action_Result") = True
	ElseIf blnFlagHCS Then
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dTrunkGroupServiceID", strTrunkGroupServiceID)
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dTrunkServiceID", strTrunkServiceID)
		Call ReportLog("Capture Trunk Details", "Trunk Group and Trunk OCC should be populated","Trunk Group [" & strTrunkGroupServiceID & "] Trunk OCC[" & strTrunkServiceID& "]", "PASS", True)
	End If

	If Browser("brwAIB").Exist(2) Then
		Browser("brwAIB").Close
	End If
End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************




'****************************************************************************************************************************
'															START OF FUNCTION
'						Used to Refresh and Search Again to get the status populated in WebTable
'****************************************************************************************************************************
Function fn_SIB_SearchAgain_Refresh()
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
'				oPage.Image("file name:=loading\.gif").HighLight
				Wait 2
			Else
				Exit For
			End If
		Next

		oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").ChildItem(2, 1, "Link", 0).Click
		For intCounter = 1 to 10
			If oPage.Image("file name:=loading\.gif").Exist(2) Then
'				oPage.Image("file name:=loading\.gif").HighLight
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
'				oPage.Image("file name:=loading\.gif").HighLight
				Wait 2
			Else
				Exit For
			End If
		Next

	End If
End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************
Public Function fn_AIB_CaptureTrunkServiceID(TrunkServiceID)
	Set objTrunkTable = objPage.WebTable("innertext:=.*Trunk - OCC.*", "index:=0")
	If Not objTrunkTable.Exist(10) Then	Exit Function
	intRowCount = objTrunkTable.RowCount
	For iRow = 2 to intRowCount Step 1
		If strServiceID = "" Then
			strServiceID = objTrunkTable.GetCellData(iRow, 4)
		Else
			strServiceID = strServiceID & "|" & objTrunkTable.GetCellData(iRow, 4)
		End If
	Next

	TrunkServiceID = strServiceID
End Function
