'****************************************************************************************************************************
' Function Name	 : fn_AIB_OrderSearchProgress
'
' Purpose	 	 : Function to search progress of order in AIB
'
' Author	 	 :Suresh HS
'
' Creation Date  : 15/4/2014
'
' Parameters	 :OrderRefNum
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_AIB_OrderSearchProgress(dAIBSearchData)

	'Declaration of variables
	Dim strOrderRefNum
	Dim strProductName,strItemStatus,strItemSubStatus
	Dim strColumnName,strColumnValue

	'Assigningof values to variables
	strOrderRefNum = dAIBSearchData

	'Build  web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If		

	'Retriving Main Order Number status 
	Set objTable = objPage.WebTable("tblOrderNumber")
	intCols = objTable.GetROProperty("cols")
	strResult = ""
	ReDim strColumnName(intCols-1)
	ReDim strColumnValue(intCols-1)
	For i = 1 to intCols
		strColumnName(i-1) = objTable.GetCellData(1,i)
		strColumnValue(i-1) = objTable.GetCellData(2,i)
		If Trim(strColumnName(i-1)) = "Order Status"  Then
			If Trim(strColumnValue(i-1)) <> "Open" Then
				Call ReportLog("Order Status","Order status should be retrived and should be 'Open'.","Order Status retrieved is <B>" &strColumnValue(i-1) &"</B>","FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If
		End If
		If Trim(strColumnName(i-1)) = "Order Sub-status"  Then
			If Trim(strColumnValue(i-1)) <> "InProgress" Then
				Call ReportLog("Order Sub-status","Order Sub-status should be retrived and should be 'InProgress'.","Order Sub-status retrieved is <B>" &strColumnValue(i-1) &"</B>","FAIL","")
				Exit Function
			End If
		End If

		If strResult = "" Then
			strResult =  strColumnName(i-1) & " : " & strColumnValue(i-1) 
		Else
			strResult =  strResult & "</br>" & strColumnName(i-1) & " : " & strColumnValue(i-1) 
		End If
	Next
	Call ReportLog("Order Number","Order Number Details should be retrived" , "<B>"&strResult& "</B>","PASS","")
                   	
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

			If (strAction = "Modify" OR strAction = "None") And strItemStatus = "Complete" And strItemSubStatus = "Closed" And strProductName = "OSCS Root Product" Then
				Call ReportLog("Item Status","Item status should be retrived","For the Product <B>" &strProductName & "</B> Item Status is <B>" & strItemStatus & "</B> and Item sub status is <B>" & strItemSubStatus & "</B> Same order is Modified Successfully" ,"INFORMATION", True)
				Exit For
			ElseIf strItemStatus <> "Open" and strItemSubStatus <> "Acknowledged" Then
				'Click on plus symbol
				blnResult = clickWebElement("ElmAddDetails")
				If Not blnResult Then
					Environment.Value("Action_Result") = False  
					Call EndReport()
					Exit Function
				End If

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
				Call ReportLog("Item Status and Sub-status","Item status and Sub-status should be retrived","For the Product <B>" &strProductName & "<B> Item Status is <B>" &strItemStatus & "<B> and Item sub status is <B> " &strItemSubStatus &"<B>","PASS","")
				condCounter = 0
				Exit Do
			End If

			If condCounter = 60 Then
				If Trim(strItemStatus) <> "Open" or Trim(strItemSubStatus) <> "Acknowledged" Then
					Call ReportLog("Item Status and Sub-status","Item Status and item sub status should be Open and  Acknowledged","For the Product <B>" &strProductName & "Item Status is <B> " &strItemStatus & "and Item sub status is <B>" &strItemSubStatus ,"FAIL","TRUE")
					condCounter = 0
				End If
			End If

		Loop Until strItemStatus="Open" or condCounter = 60
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
		strResult = ""
		If objTable.ColumnCount(i) <> 1 Then
			For j = 1 to intCols
				strColumnName(j-1) = objTable.GetCellData(1,j)
				strColumnValue(j-1) = objTable.GetCellData(i,j)
				If Trim(strColumnName(j-1)) = "Item Status"  Then
					If Trim(strColumnValue(j-1)) <> "Open" AND Trim(strColumnValue(j-1)) <> "Complete" Then
						Call ReportLog("Item Status","Item status should be retrived and should be 'Open/Completed'.","Item Status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
						Exit Function
					End If
				End If
				If Trim(strColumnName(j-1)) = "Item Sub-status"  Then
					If Trim(strColumnValue(j-1)) <> "In Progress" AND Trim(strColumnValue(j-1)) <> "Closed" Then
						Call ReportLog("Item Sub-status","Item Sub-status should be retrived and should be 'In Progress/Closed'.","Item Sub-status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
						Exit Function
					End If
				End If
	
				If strResult = "" Then
					strResult =  strColumnName(j-1) & " : " & strColumnValue(j-1) 
				Else
					strResult = "<br>"& strResult & "</br>" & strColumnName(j-1) & " : " & strColumnValue(j-1) 
				End If
	
			Next
		End If
		Call ReportLog("Inner Order Item table","Order Item Details should be retrived" ,"<B>"& strResult& "</B>","PASS","")
	Next

	objOrderItemNumber(0).Click
	Wait 3
End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
