'****************************************************************************************************************************
' Function Name	 : fncCreateNewOrder
' Purpose	 	 : Function to click on Create New Order link
' Author	 	 : Linta CK
' Creation Date  	 : 14/05/2013
' Parameters	 : Not Applicable                					     
' Return Values	 : NA
'****************************************************************************************************************************

Public Function fn_eDCA_CreateNewOrder()

	'Variable Declaration Section
	Dim strMessage,strOrderIdText,streDCAOrderId
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
    
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

    'Click on Create New Order Link
	blnResult = clickLink("lnkCreateNewOrder")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to View Pending order page
	Set objMsg = objpage.Webelement("webElmCustomerDetails")
    objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist Then
		Call ReportLog("Create New Order","User should be able to click on 'create New Order' link and navigate to Customer details page","Clicking on 'Create New Order' link and navigation to Customer details page was not successful","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmCustomerDetails")
		Call ReportLog("Create New Order","Create New Order should be clicked and navigated to Customer details page","Navigated to the page - "&strMessage,"PASS","")
	End If

	'Fetch the newly created Order Id
	strOrderIdText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("webElmOrderID").GetRoProperty("innertext")
	streDCAOrderId = Trim(Split(strOrderIdText,"=")(1))

	'Writing data to Excel file
	call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"deDCAOrderId",streDCAOrderId)

	Call ReportLog("Create New Order","Order Id should be generated","Order Id generated - "&streDCAOrderId,"PASS","")


End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
