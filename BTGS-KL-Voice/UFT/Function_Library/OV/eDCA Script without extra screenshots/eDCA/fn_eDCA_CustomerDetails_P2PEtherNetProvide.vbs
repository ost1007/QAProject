'****************************************************************************************************************************
' Function Name	 : fn_eDCA_CustomerDetails
' Purpose	 	 : Function to select Order type in Customer details Page
' Author	 	 : Linta CK
' Creation Date  	 : 14/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_CustomerDetails_P2PEtherNetProvide(deDCAOrderId,dOrderType,dCustomerAlreadyExists,dDistributorLegalName,dFullLegalCompanyName,dContractId,dCurrencyName,dSiebelId,dServiceCentre,dContractTerm,dOrderFormSignDate,dCountry,dClassicSiteId,dClassicSiteIdCustomerDetails)

	'Variable Declaration Section
	Dim strOrderId,strOrderType,strCustomerAlreadyExists,strDistributorLegalName,strFullLegalCompanyName,strClassicSiteId,strServiceID
	Dim strRetrievedText,strListBoxItemValue,strContractId,strCurrency,strSiebelId,strServiceCentre,strContractTerm,strMessage,strDistributorLegalName1
	Dim objMsg
	Dim dtOrderFormSignDate
	Dim arrdt
	Dim blnResult

	'Assignment of Variables
	streDCAOrderId = deDCAOrderId
	strOrderType = dOrderType
	strCustomerAlreadyExists = dCustomerAlreadyExists
	strDistributorLegalName = dDistributorLegalName
	strFullLegalCompanyName = dFullLegalCompanyName
	strContractId = dContractId
	strCurrency = dCurrencyName
	strSiebelId = dSiebelId
	strContractTerm = dContractTerm
	strServiceCentre = dServiceCentre
	dtOrderFormSignDate = dOrderFormSignDate
	strClassicSiteId =dClassicSiteId
	strCountry = dCountry
	strServiceID = dClassicSiteIdCustomerDetails

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Order Type
	blnResult = selectValueFromPageList("lstOrderType",strOrderType)
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	For intCounter = 1 to 10
		If objPage.WebList("lstDistributorLegalName").Exist(30) Then
			Exit For
		Else
			Wait 5
		End If
	Next
	
	'Select Distributor Legal Name
	If ObjPage.WebList("lstDistributorLegalName").Exist Then
		strDistributorLegalName1 = ObjPage.WebList("lstDistributorLegalName").GetROProperty("Value")
		If  strDistributorLegalName1 <>  ""Then
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Name is populated with the value -" &strDistributorLegalName1,"PASS","TRUE")
        Else 
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Name is not populated with the value - "&strDistributorLegalName1,"FAIL","TRUE")
			blnResult = selectValueFromPageList("lstDistributorLegalName",strDistributorLegalName)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
	End if
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Full Legal Company Name
	blnResult = selectValueFromPageList("lstDistributorLegalName",strDistributorLegalName)
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Click on Search button
	If objPage.WebButton("btnSearch").Exist Then
		blnResult = clickButton("btnSearch")
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

'Select Full Legal Company Name
	blnResult = fn_eDCA_SearchFullLegalCompanyName(strFullLegalCompanyName)
	If blnResult = "True" Then
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtFullLegalCompanyName").GetROProperty("text")
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Call ReportLog("Full Legal Company Name","Full Legal Company Name should be populated","Full Legal Company Name is populated with the value - "&strRetrievedText,"PASS","")
	
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerName").GetROProperty("value")
		Call ReportLog("Customer Name","Customer Name should be populated","Customer Name is populated with the value - "&strRetrievedText,"PASS","")
	
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtMasterCustomerID").GetROProperty("value")
		Call ReportLog("Master Customer ID","Master Customer ID should be populated","Master Customer ID is populated with the value - "&strRetrievedText,"PASS","")

		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtBillingId").GetROProperty("value")
		Call ReportLog("Billing ID","Billing ID should be populated","Billing ID is populated with the value - "&strRetrievedText,"PASS","")
	Else
		Call ReportLog("Search Full Legal company Name","Search should be able to retrieve the details","Details not retrieved successfully","FAIL","TRUE")
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Contract Id
		strContractId = streDCAOrderId& dContractId

	blnResult = enterText("txtContractId",strContractId)
	If blnResult= False Then
		Call ReportLog("Contract ID","Contract ID should be entered","Contract ID is not entered","FAIL","TRUE")
        Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End if
	
	'Enter currency
	blnResult = selectValueFromPageList("lstCurrencyName",strCurrency)
    If blnResult= False Then
		Call ReportLog("Currency","Currency should be entered","Currency is not entered","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Enter Siebel Id
		strSiebelId = streDCAOrderId & dSiebelId

	blnResult = enterText("txtSiebelId",strSiebelId)
	If blnResult= False Then
		Call ReportLog("Siebel ID","Siebel ID should be entered","Siebel ID is not entered","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Select Customer Service Center
	blnResult = selectValueFromPageList("lstServiceCentre",strServiceCentre)
    If blnResult= False Then
		Call ReportLog("Customer Service Center","Customer Service Center should be entered","Customer Service Center is not entered","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Enter Contract Terms
	blnResult = enterText("txtContractTerm",strContractTerm)
	If blnResult= False Then
		Call ReportLog("Contract Term","Contract Term should be entered","Contract Term is not entered","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Clicking on clear button
	blnResult = clickButton("btnClear")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Enter Order Form Sign date
	blnResult = clickImage("imgClickForCalendar")
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtOrderFormSignDate
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderFormSignDate").GetROProperty("value")
	Call ReportLog("Order Form Sign Date","OrderFormSignDate should be populated","Order Form Sign Date is not populated with required value","FAIL","TRUE")

	'Checking for existence of close button in calendar
	If Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").exist(5) then
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").click    
	End If	

	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Customer Contact Details Page
	Set objMsg = objpage.Webelement("webElmCustomerContactDetails")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Not navigated to Customer contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result")=False  : Exit Function
	Else
		strMessage = GetWebElementText("webElmCustomerContactDetails")
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************