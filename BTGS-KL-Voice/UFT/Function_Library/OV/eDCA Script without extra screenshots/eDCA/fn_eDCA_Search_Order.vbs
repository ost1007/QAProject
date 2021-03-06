'****************************************************************************************************************************
' Function Name	 : fncSearch Existing Order
' Purpose	 	 : Function to  search existing order
' Author	 	 : Anil Pal
' Creation Date  	 : 12/08/2014      					     
'****************************************************************************************************************************
Public Function fn_eDCA_Search_Order(deDCAOrderId,dSearch)

	'Variable Declaration Section
	Dim strMessage,strOrderIdText,streDCAOrderId,strState
	Dim objMsg
	Dim blnResult
	strState= "ON"
	strOrderId = deDCAOrderId
	strSearch = dSearch

    
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	' Click on Order List Link
	blnResult = clickLink("lnkOrderList")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	' Selecting the value from Order ID List
     blnResult =selectValueFromPageList("lstSearch", strSearch)
	 If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	' Entering the Order Id in Search Order Text Box
	blnResult = enterText("txtSearch",strOrderId)
	If blnResult= False Then
		Call ReportLog("Contract ID","Contract ID should be entered","Contract ID is not entered","FAIL","TRUE")
        Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	' Selecting the "Search in All Queues check box
	blnResult = setCheckBox("chkSearchAllRecords", strState)
	If blnResult= False Then
		Call ReportLog("Contract ID","Contract ID should be entered","Contract ID is not entered","FAIL","TRUE")
        Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	' Clicking on "Search" button
	blnResult =clickButton("btnSearch")
	If blnResult= False Then
		Call ReportLog("Contract ID","Contract ID should be entered","Contract ID is not entered","FAIL","TRUE")
        Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	' Clicking on Searched order
	If  objPage.WebTable("dtOrderSearchResults").Exist Then 
		strcelldata = objPage.WebTable("dtOrderSearchResults").GetCellData(3,1)
		If  strcelldata =  cstr(strOrderId) Then
			Call ReportLog("Order ID","Order ID should exist in Table","Order ID is displayed","PASS","TRUE")
			Set strLink = objPage.WebTable("dtOrderSearchResults").ChildItem(3,1,"Link",0)
			strLink.click
		Else
			Call ReportLog("Order ID","Order ID should exist in Table","Order ID is not searched","FAIL","TRUE")
		End If
	End If

	'Check if navigated to Perform Action page
	Set objMsg = objpage.Webelement("webElmPerformAction")
    objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist = False Then
		Call ReportLog("Search Order Id","User should be able to click on 'Searched Order' link and navigate to Perform Action Page","Clicking on 'Searched  Order' link and navigation to Customer details page was not successful","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmPerformAction")
		Call ReportLog("Searched Order","Searched Order should be clicked and navigated to Perform Action page","Navigated to the Perform Action page - "&strMessage,"PASS","")
	End If

	'Click on Read Order Link
	blnResult = clickLink("lnkReadOrder")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Set objMsg = objpage.Webelement("webElmPerformAction")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Search Order Id","User should be able to click on 'Searched Order' link and navigate to Perform Action Page","Clicking on 'Searched  Order' link and navigation to Customer details page was not successful","FAIL","TRUE")
	Else
		strMessage = GetWebElementText("webElmPerformAction")
		Call ReportLog("Searched Order","Searched Order should be clicked and navigated to Perform Action page","Navigated to the Perform Action page - "&strMessage,"PASS","")
	End If


End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
