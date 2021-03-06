'****************************************************************************************************************************
' Function Name	 : fn_eDCA_PerformAction
' Purpose	 	 :  Retriving the order details and amending the order when logged in with Service Delivery
' Author	 	 : Vamshi Krishna Guddeti
' Creation Date  : 13/06/2013			               					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_PerformAction(dTypeOfOrder,dSearch,deDCAOrderId)

	'Variable declaration section
	Dim blnResult,strMessage,objMsg
	Dim strSearch,streDCAOrderId

	'Assignment of variables
	strSearch = dSearch
	streDCAOrderId = deDCAOrderId

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Selecting orderId to search the order
	blnResult = selectValueFromPageList("lstSearch",strSearch)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Enter the order id into search
	blnResult = enterText("txtSearch",streDCAOrderId)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").WebCheckBox("chkSearchAllRecords").Set "ON"	

	'Click on Search button
	blnResult = clickButton("btnSearch")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on Order Id link retrived
	blnResult = clickLink("lnkOrderId")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

   	blnResult = clickLink("lnkWrite/AmendOrder")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to Customer details page
	If dTypeOfOrder <> "GSIPCEASE" Then
		Set objMsg = objpage.WebElement("webElmCustomerDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("PerformAction","Should be navigated to CustomerDetails page on clicking Write/Amend Order lilnk","Not navigated to CustomerDetails page on clicking Write/Amend Order link","FAIL","TRUE")
			Environment.Value("Action_Result")=False
			Exit Function
		Else
			strMessage = GetWebElementText("webElmCustomerDetails")
			Call ReportLog("PerformAction","Should be navigated to CustomerDetails page on clicking Write/Amend Order link","Navigated to the page - "&strMessage,"PASS","")
		End If
	End if
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
