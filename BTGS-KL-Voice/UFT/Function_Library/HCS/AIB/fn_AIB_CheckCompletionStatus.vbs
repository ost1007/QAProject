'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CheckCompletionStatus
'
' Purpose					: 			Function to check for task completion status
'
' Author					:		  	Linta CK
' Creation Date   		: 			24/06/2014
' Modified 				  	:		Nagaraj V || 08/12/2014 || Row Number changes if it is in Open and then gets moved to Complete Status
' Parameters	 		 :			RowCnt,objTbl,ByRef strOrderNumber
'                  					     
' Return Values	 		: 			Boolean
'****************************************************************************************************************************

Public Function fn_AIB_CheckCompletionStatus(RowCnt,objTbl,dExpectedStatus,ByRef strOrderNumber)

	'Declaration of variables
	Dim intRowCnt
	Dim objTable
	Dim strExpectedStatus

	'Assigning variables
	Set objTable = objTbl
	intRowCnt = RowCnt
	strExpectedStatus = dExpectedStatus
	blnAcquiredStatus = False

	strTaskName = objTable.GetCellData(intRowCnt,2)

	If strExpectedStatus = "Open" Then
		'Wait till status changes to Open for manual task before closure in Flow
		For intCounter = 1 to 30
			objTable.RefreshObject
			intRowCnt = objTable.GetRowWithCellText(strTaskName)
			objTable.RefreshObject
			strStatus = objTable.GetCellData(intRowCnt,4)
			strSubStatus = objTable.GetCellData(intRowCnt,5)
			strOrderNumber = objTable.GetCellData(intRowCnt,1)
			strSubStatus = Replace(strSubStatus, " ", "")
			If strStatus = "Open" And strSubStatus = "InProgress" Then
				strTaskName = objTable.GetCellData(intRowCnt,2)
				strServer = objTable.GetCellData(intRowCnt,3)					
				strDependency = objTable.GetCellData(intRowCnt,6)
				Call ReportLog("Order Details","Order Details should be retrived and order status should be 'Open'.","Order details retrieved - <br> Order number : " &strOrderNumber&"<br> Product : "&strTaskName&" <br> Server : "&strServer&" <br> Status : "&strStatus&" <br>  Sub-Status : "&strSubStatus&" <br> Dependency : "&strDependency,"PASS","")
				blnAcquiredStatus = True
				Exit For

			ElseIf strStatus = "Open" And strSubStatus = "ACTIVATE" Then
				strTaskName = objTable.GetCellData(intRowCnt,2)
				strServer = objTable.GetCellData(intRowCnt,3)					
				strDependency = objTable.GetCellData(intRowCnt,6)
				Call ReportLog("Order Details","Order Details should be retrived and order status should be 'Open'.","Order details retrieved - <br> Order number : " & strOrderNumber &"<br> Product : " & strTaskName & " <br> Server : "&strServer&" <br> Status : "&strStatus&" <br>  Sub-Status : "&strSubStatus&" <br> Dependency : "&strDependency,"PASS","")
				blnAcquiredStatus = True
				Exit For

			ElseIf strStatus = "Failed" OR (strSubStatus = "Flaggedforattention" OR strSubStatus = "SomeLineItemsFailed") Then
				Call ReportLog("Order Details","Order Details should be retrived and order status should be " & strStatus,"Order details retrieved - <br> Order number : " & strOrderNumber &"<br> Product : " & strTaskName & " <br> Server : "&strServer&" <br> Status : "&strStatus&" <br>  Sub-Status : "&strSubStatus&" <br> Dependency : "&strDependency,"FAIL", True)
				Call fCreateAndSendMail(Environment("ToList"), Environment("CcList"), Environment("BCcList"), "Required Attention on " & dAIBSearchData & " - " & strTaskName,_
							"Order has been failed due to Status:= <B>" & strStatus & "</B> Sub Status:= <B>" & strSubStatus & "</B>", "")
				Environment("Action_Result") = False : fn_AIB_CheckCompletionStatus = False : Exit Function
			Else
				Wait 15
				Call fn_SIB_SearchAgain_Refresh1()
				blnAcquiredStatus = False
			End If
		Next

	ElseIf strExpectedStatus = "Complete" Then
		'Wait till status changes to Complete for automatic task/for manual task after closure in Flow
		For intCounter = 1 to 30
			objTable.RefreshObject
			intRowCnt = objTable.GetRowWithCellText(strTaskName)
			objTable.RefreshObject
			strStatus = objTable.GetCellData(intRowCnt,4)
			strSubStatus = objTable.GetCellData(intRowCnt,5)
			strOrderNumber = objTable.GetCellData(intRowCnt,1)
'			strProductName = objTable.GetCellData(intRowCnt,2)
			strSubStatus = Replace(strSubStatus, " ", "")
			If strStatus = "Complete" And strSubStatus = "AllLineItemsComplete" Then
				strTaskName = objTable.GetCellData(intRowCnt,2)
				strServer = objTable.GetCellData(intRowCnt,3)					
				strDependency = objTable.GetCellData(intRowCnt,6)
				Call ReportLog("Order Details","Order Details should be retrived and order status should be 'Complete'.","Order details retrieved - <br> Order number : " &strOrderNumber&"<br> Product : "&strTaskName&" <br> Server : "&strServer&" <br> Status : "&strStatus&" <br>  Sub-Status : "&strSubStatus&" <br> Dependency : "&strDependency,"PASS","")
				blnAcquiredStatus = True
				Exit For
			ElseIf strStatus = "Failed" OR (strSubStatus = "Flaggedforattention" OR strSubStatus = "SomeLineItemsFailed") Then
				Call ReportLog("Order Details","Order Details should be retrived and order status should be " & strStatus,"Order details retrieved - <br> Order number : " & strOrderNumber &"<br> Product : " & strTaskName & " <br> Server : "&strServer&" <br> Status : "&strStatus&" <br>  Sub-Status : "&strSubStatus&" <br> Dependency : "&strDependency,"FAIL", True)
				Call fCreateAndSendMail(Environment("ToList"), Environment("CcList"), Environment("BCcList"), "Required Attention on " & dAIBSearchData & " - " & strTaskName,_
							"Order has been failed due to Status:= <B>" & strStatus & "</B> Sub Status:= <B>" & strSubStatus & "</B>", "")
				Environment("Action_Result") = False : fn_AIB_CheckCompletionStatus = False : Exit Function
			Else
				Wait 15
				Call fn_SIB_SearchAgain_Refresh1()
				blnAcquiredStatus = False
			End If
		Next
	End If

	If Not blnAcquiredStatus Then
		Call ReportLog("Order Details","Order status should be <B>" & dExpectedStatus & "</B>", "Order status is found to be <B>" & strStatus & "</B" ,"FAIL", True)
		Environment("Action_Result") = False
	End If
	fn_AIB_CheckCompletionStatus  = blnAcquiredStatus

End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************

'****************************************************************************************************************************
'															START OF FUNCTION
'						Used to Refresh and Search Again to get the status populated in WebTable
'****************************************************************************************************************************
Function fn_SIB_SearchAgain_Refresh1()
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

		Wait 2
		
		For intCounter = 1 to 10
			If oPage.Link("text:=Fulfilment Orders").WaitProperty("height", micGreaterThan(0), 10000) Then
				Exit For
			Else
				oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").RefreshObject
				oPage.WebTable("column names:=Order Number;Source;Version;Sequence Number;Created Date").ChildItem(2, 1, "Link", 0).Click
			End If
		Next

		For intCounter = 1 to 5
			If oPage.Link("text:=Fulfilment Orders").Exist Then
				oPage.Link("text:=Fulfilment Orders").Click
				Exit For
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
