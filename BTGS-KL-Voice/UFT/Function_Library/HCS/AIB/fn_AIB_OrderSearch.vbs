'****************************************************************************************************************************
' Function Name	 :   fn_AIB_OrderSearch(vAIBSearchData)
' Purpose	 	 : Function toserach order with order ID 
' Author	 	 :Vamshi Krishna G
' Creation Date  : 28/1/2014
' Parameters	 :               					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function  fn_AIB_OrderSearch(dAIBSearchData)
	On Error Resume Next
		
	'Assigningof values to variables
	strOrderRefNum =  dAIBSearchData
	Set oLink = description.Create

	'Build web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Code to Expand  Order Search  Panel if Order Number Test box is not visible
	If Not objpage.WebEdit("txtOrderNumber").Exist(60) Then
		 If  objpage.WebElement("elmExpand").Exist(60)  Then 
			blnResult= clickWebElement("elmExpand")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		 End If
	End If
	
	isOrderVisible = False
	For intCounter = 1 To 20
		'Enter Order Number
		blnResult = enterText("txtOrderNumber",strOrderRefNum)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		'Click on Search button
		blnResult = clickButton("btnSearch")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brwAIB").Page("pgAIB").Sync
	
		Wait 5

		If objPage.WebElement("elmNoMatchingDataAvailable").Exist(10) Then
			Wait 30
		Else
			oLink("micclass").value = "Link"
			oLink("innertext").Value =  Replace(strOrderRefNum, "*", ".*")
			oLink("index").Value =  0
			Set oLinkChildobj = Objpage.Link(oLink)
			If oLinkChildobj.Exist(10) Then
				isOrderVisible = True
				Exit For '#intCounter
			Else
				Wait 30
			End If
		End If
	Next
	
	If Not isOrderVisible Then
		Call ReportLog("Order Search", "Order Search for <B>" & strOrderRefNum & "</B> should be successful", "Order Search for <B>" & strOrderRefNum & "</B> was unsuccessful", "Fail", True)
		Environment("Action_Result") = False : Exit Function
	End If

	oLink("micclass").value = "Link"
	oLink("innertext").Value =  Replace(strOrderRefNum, "*", ".*")
	oLink("index").Value =  0

	Set oLinkChildobj = Objpage.Link(oLink)
	oLinkChildobj.Highlight
	oLinkChildobj.click

	'If Uncaught Error Message Exists
	If Browser("brwAIB").Dialog("dlgMsgFromWeb").Exist(10) Then
		If Instr(Browser("brwAIB").Dialog("dlgMsgFromWeb").Static("msgText").GetVisibleText, "Uncaught") > 0 Then
			Browser("brwAIB").Dialog("dlgMsgFromWeb").WinButton("btnOK").Click
			Wait 2
			Browser("brwAIB").Page("pgAIB").WebElement("elmExpand").Click
			Wait 2
			oLinkChildobj.click
		End If
	End If

	For intCounter = 1 to 10
		If objPage.Link("lnkFulfilmentOrders").WaitProperty("height", micGreaterThan(0), 10000) Then
			Exit For
		Else
			If Browser("brwAIB").Page("pgAIB").WebElement("elmExpand").Exist Then Browser("brwAIB").Page("pgAIB").WebElement("elmExpand").Click
			Wait 2
			oLinkChildobj.click
			Wait 3
		End If
	Next

    Browser("brwAIB").Page("pgAIB").Sync
		
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
