'****************************************************************************************************************************
' Function Name	 : fn_eDCA_CustomerDetails
' Purpose	 	 : Function to select Order type in Customer details Page
' Author	 	 : Linta CK
' Creation Date  	 : 14/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_CustomerDetails(deDCAOrderId,dOrderType,dCustomerAlreadyExists,dDistributorLegalName,dFullLegalCompanyName,dContractId,dCurrencyName,dSiebelId,dServiceCentre,dContractTerm,dOrderFormSignDate,dCountry,dClassicSiteId,dClassicSiteIdCustomerDetails)

	'Variable Declaration Section
	Dim strOrderId,strOrderType,strCustomerAlreadyExists,strDistributorLegalName,strFullLegalCompanyName,strClassicSiteId,strServiceID
	Dim strRetrievedText,strListBoxItemValue,strContractId,strCurrency,strSiebelId,strServiceCentre,strContractTerm,strMessage
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
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Order Type
	If  UCase(strOrderType) = "PROVIDE" Then
		blnResult = selectValueFromPageList("lstOrderType", "ADD")
	Else
		blnResult = selectValueFromPageList("lstOrderType",strOrderType)
	End If
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

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
		If  strDistributorLegalName1 <>  "" Then
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Name is populated with the value -" &strDistributorLegalName1,"PASS","TRUE")
        Else 
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Name is not populated with the value - "&strDistributorLegalName1,"FAIL","TRUE")
			blnResult = selectValueFromPageList("lstDistributorLegalName",strDistributorLegalName)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
	End if
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Select Full Legal Company Name
	blnResult = selectValueFromPageList("lstDistributorLegalName",strDistributorLegalName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function


	For intCounter = 1 To 5
			'Click on Search button
			If objPage.WebButton("btnSearch").Exist(60) Then
				blnResult = clickButton("btnSearch")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
			Call ReportLog("Customer Details","User should be able to Search","Search successfully","PASS","TRUE")
			
			'Select Full Legal Company Name
			blnResult = fn_eDCA_SearchFullLegalCompanyName(strFullLegalCompanyName)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Wait 10
			
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtFullLegalCompanyName").GetROProperty("value")
			If Trim(strRetrievedText) <> "" Then
				blnResult = True
				Exit For
			Else
				blnResult = False
				Wait 30
			End If
	Next '#intCounter
		
	If blnResult Then
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
		Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Contract Id
	If strOrderType = "PROVIDE"  Then
		strContractId = streDCAOrderId& dContractId
	
		blnResult = enterText("txtContractId",strContractId)
		If blnResult= False Then
			Call ReportLog("Contract ID","Contract ID should be entered","Contract ID is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False : Exit Function
		End If

		'Enter currency
		blnResult = selectValueFromPageList("lstCurrencyName",strCurrency)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter Siebel Id
		strSiebelId = streDCAOrderId & dSiebelId
	
		blnResult = enterText("txtSiebelId",strSiebelId)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Select Customer Service Center
		blnResult = selectValueFromPageList("lstServiceCentre",strServiceCentre)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Enter Contract Terms
		blnResult = enterText("txtContractTerm",strContractTerm)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on clear button
		blnResult = clickButton("btnClear")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Enter Order Form Sign date
		blnResult = clickImage("imgClickForCalendar")
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtOrderFormSignDate
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		For intCounter = 1 To 5 Step 1
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderFormSignDate").GetROProperty("value")	
			If strRetrievedText = "" Then
				Wait 10
			Else
				Exit For '#intCounter
			End If
		Next '#intCounter
		
		If DateDiff("d", CDate(dtOrderFormSignDate), CDate(strRetrievedText)) <> 0 Then
			Call ReportLog("Order Form Sign Date","OrderFormSignDate should be populated","Order Form Sign Date is not populated with required value","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If

		'Checking for existence of close button in calendar
		If Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").Exist(0) then
			'Click Close button in calendar
			Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").click    
			Call ReportLog("Customer Details","User should be able to complete Customer Details page","Customer Details Page Completed successfully","PASS","TRUE")
		End If	
	End If
	
	If strOrderType <> "PROVIDE" Then
		'Select Country form Country List
		blnResult =  selectValueFromPageList("lstCountryCustomerDetails", strCountry)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		blnResult = enterText("txtClassicSiteIdCustomerDetails", strClassicSiteId)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Click on btn Get Sites from Classic 
		blnResult = clickButton("btnGetSitesFromClassic")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Wait(60)
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		If ObjPage.WebTable("tblSiteDetails").Exist Then
			strRetrievedText = ObjPage.WebTable("tblSiteDetails").GetCellData(2,2)
			If strRetrievedText =  strClassicSiteId Then
				Call ReportLog("Classic Sitd ID","Classic Sitd ID should be populated","Classic Sitd ID is populated with value"&strRetrievedText ,"PASS","TRUE")
				blnResult = clickButton("btnSelect")
				If blnResult = False Then
					Environment.Value("Action_Result")=False 
					Call EndReport()
					Exit Function
				End If
				If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist Then
					Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").HighLight
					Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
				End If
			Else
				Call ReportLog("Classic Site ID","Classic Site ID should be populated","Classic Site ID is not populated with value" ,"PASS","TRUE")
			End If
		End If

		Wait(90)
	
		If ObjPage.WbfGrid("grdService").Exist Then
			strRowcount = ObjPage.WbfGrid("grdService").RowCount
			For intCounter = 2 to strRowcount
				strRetrivedText = ObjPage.WbfGrid("grdService").GetCellData(intCounter,2)
				If  strRetrivedText = strServiceID Then
						Call ReportLog("Service ID","Service ID should be populated","Service ID is populated with value"&strRetrivedText ,"PASS","TRUE")
						ObjPage.WbfGrid("grdService").ClickCell intCounter,1
						If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist Then
							Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").HighLight
							Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
						End If
				Else
						Call ReportLog("Service ID","Service ID should be populated","Service ID is Not populated with value" ,"FAIL","TRUE")
						Environment("Action_Result") = False : Exit function
				End If
			Next
		End if
	
		Wait(40)

		strContractId = streDCAOrderId& dContractId
	
		blnResult = enterText("txtContractId",strContractId)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter currency
		blnResult = selectValueFromPageList("lstCurrencyName",strCurrency)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter Siebel Id
		strSiebelId = streDCAOrderId & dSiebelId
		blnResult = enterText("txtSiebelId",strSiebelId)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Select Customer Service Center
		blnResult = selectValueFromPageList("lstServiceCentre",strServiceCentre)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter Contract Terms
		blnResult = enterText("txtContractTerm",strContractTerm)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Clicking on clear button
		blnResult = clickButton("btnClear")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter Order Form Sign date
		blnResult = clickImage("imgClickForCalendar")
		If blnResult  = False Then
			arrdt = Split(dtOrderFormSignDate,"-")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If		
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Sync

		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtOrderFormSignDate
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderFormSignDate").GetROProperty("value")
		Call ReportLog("Order Form Sign Date","OrderFormSignDate should be populated","Order Form Sign Date is populated with required value"&strRetrievedText,"PASS","TRUE")
	
			
		'Checking for existence of close button in calendar
		If Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").Exist(0) then
			'Click Close button in calendar
			Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").click 	
		End If	
	End if 

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Customer Contact Details Page
	Set objMsg = objpage.Webelement("webElmCustomerContactDetails")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Not navigated to Customer contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmCustomerContactDetails")
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
