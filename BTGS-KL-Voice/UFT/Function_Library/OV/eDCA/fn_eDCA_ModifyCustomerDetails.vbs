Public Function fn_eDCA_ModifyCustomerDetails(dTypeOfOrder, deDCAOrderId, dOrderType, dDistributorLegalName, dFullLegalCompanyName, dCountryCustomerDetails, dClassicSiteIdCustomerDetails, dMPLSPresence, dContractId, dCurrencyName, dSiebelId, dServiceCentre, dContractTerm, dOrderFormSignDate, dCountry, dClassicSiteId)

	'Variable Declaration Section
	Dim strOrderId,strOrderType,strDistributorLegalName,strFullLegalCompanyName
	Dim strRetrivedText,strListBoxItemValue,strContractId,strCurrency,strSiebelId,strServiceCentre,strContractTerm,strMessage
	Dim objMsg
	Dim dtOrderFormSignDate
	Dim arrdt
	Dim blnResult
	Dim strCountryCustomerDetails,strClassicSiteIdCustomerDetails,objTable,strMPLSPresence,strTypeOfOrder

	'Assignment of Variables
	streDCAOrderId = deDCAOrderId
	strOrderType = dOrderType
	strDistributorLegalName = dDistributorLegalName
	strFullLegalCompanyName = dFullLegalCompanyName
	strMPLSPresence = dMPLSPresence
	strContractId = dContractId
	strCurrency = dCurrencyName
	strSiebelId = dSiebelId
	strContractTerm = dContractTerm
	strServiceCentre = dServiceCentre
	dtOrderFormSignDate = dOrderFormSignDate
	strCountryCustomerDetails = dCountryCustomerDetails
	strClassicSiteIdCustomerDetails = dClassicSiteIdCustomerDetails
	strTypeOfOrder = dTypeOfOrder

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Order Type
	blnResult = objPage.WebList("lstOrderType").Exist(10)
	If blnResult = "True" Then
		blnResult = selectValueFromPageList("lstOrderType",strOrderType)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Order Type","Order type should exist","Order type does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if Distributor Legal Name is populated/not
	blnResult = objPage.WebList("lstDistributorLegalName").Exist(60)
	If blnResult Then
		strText = objPage.WebList("lstDistributorLegalName").GetROProperty("value")
		If strText <>  dDistributorLegalName Then
			blnResult = selectValueFromPageList("lstDistributorLegalName",dDistributorLegalName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		ElseIf strText = "" Then
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Nameis not populated","FAIL","TRUE")
			Environment.Value("Action_Result")=False : Exit Function
		Else			
			Call ReportLog("Distributor Legal Name","Distributor Legal Name should be populated","Distributor Legal Name is populated with value - "&strText,"PASS","TRUE")
		End If
	Else
		Call ReportLog("Distributor Legal Name","Distributor Legal Name should exist","Distributor Legal Name does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Select Full Legal Company Name
	'Click on Search button
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
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtFullLegalCompanyName").GetROProperty("value")
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Call ReportLog("Full Legal Company Name","Full Legal Company Name should be populated","Full Legal Company Name is populated with the value - "&strRetrievedText,"PASS","TRUE")
	
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerName").GetROProperty("value")
		Call ReportLog("Customer Name","Customer Name should be populated","Customer Name is populated with the value - "&strRetrievedText,"PASS","TRUE")
	
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtMasterCustomerID").GetROProperty("value")
		Call ReportLog("Master Customer ID","Master Customer ID should be populated","Master Customer ID is populated with the value - "&strRetrievedText,"PASS","")
	
		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtBillingId").GetROProperty("value")
		Call ReportLog("Billing ID","Billing ID should be populated","Billing ID is populated with the value - "&strRetrievedText,"PASS","")
	Else
		Call ReportLog("Search Full Legal company Name","Search should be able to retrieve the details","Details not retrieved successfully","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

'	'Enter classic site id
	blnResult = objPage.WebEdit("txtClassicSiteIdCustomerDetails").Exist
	If blnResult Then
		blnResult = enterText("txtClassicSiteIdCustomerDetails",strClassicSiteIdCustomerDetails)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else	
		Call ReportLog("Classic site id","Classic site id should exist","Classic site id does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Select Country from drop down
	blnResult = objPage.WebList("lstCountryCustomerDetails").Exist(10)
	If blnResult Then
		blnResult = selectValueFromPageList("lstCountryCustomerDetails",strCountryCustomerDetails)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else	
		Call ReportLog("Country","Country should exist","Country does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Click on GetSitesFromClassic button
	If objPage.WebButton("btnGetSitesFromClassic").Exist(10) Then
		blnResult = clickButton("btnGetSitesFromClassic")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else	
		Call ReportLog("GetSitesFromClassic button","GetSitesFromClassic button should exist","GetSitesFromClassic button does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	Wait 10
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Capturing the alert notification message recieved
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").webElement("webElmRequestForSites").GetROProperty("innertext")
	If strRetrivedText <> "" Then
		Call ReportLog("CustomerDetails","Notification message should be retrived","Notification message recieved -"&strRetrivedText,"PASS","TRUE")
	Else
		Call ReportLog("CustomerDetails","Notification message should be retrived","Notification message not retrived","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If
 
	'Capture the Site Details table
	For intCounter = 1 to 100
		blnResult = objPage.WebTable("tblSiteDetails").Exist(10)
			If blnResult Then Exit For
	Next

	If Not blnResult Then
		Call ReportLog("Inventory Response Status table","Inventory Response Status table should exist","Inventory Response Status table does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Click on corresponding Select button
	blnFlag = False
	Set objTable = objPage.WebTable("tblSiteDetails")
	intRows = objTable.GetROProperty("rows")
	For intCounter = 2 to intRows-1
		strRetrievedSiteId = objTable.GetCelldata(intCounter,2)
		If Trim(strRetrievedSiteId) = Trim(strClassicSiteIdCustomerDetails) Then
			blnFlag = True
			Set objButton = objTable.ChildItem(intCounter,1,"WebButton",0)
			If IsObject(objButton) Then
				objButton.Click
				blnFlag = True
				Exit for
			End If
		End If
	Next
	
	If Not blnFlag Then
		Call ReportLog("Search Classic Site Id","Classic Site Id should be retrieved on Saerch","Classic Site Id is not retrieved on Saerch","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Checking for the alert message and clicking on OK
	If Browser("brweDCAPortal").Dialog("dlgVpnalert").Exist(60) then
		strText = Browser("brweDCAPortal").Dialog("dlgVpnalert").GetVisibleText()
		Call ReportLog("Alert Notification","Alert Notification should be visible","Alert Notification # - "&strText,"PASS","TRUE")
		Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		Call ReportLog("Alert Notification","Alert Notification should be visible","Alert Notification is not visible","Warnings","True")
	End if

	'Inventory Response Status table
	For intCounter = 1 to 100
		Wait 5
		blnResult = objPage.WebTable("tblInventoryResponseStatus").Exist(20)
			If blnResult Then Exit For
	Next

	If Not blnFlag Then
		Call ReportLog("Inventory Response Status table","Inventory Response Status table should exist","Inventory Response Status table does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	'Retriving the Status of inventory
	If  Browser("brweDCAPortal").Page("pgeDCAPortal").webElement("webElmInventoryStatus").Exist(30) Then
			strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").webElement("webElmInventoryStatus").GetROProperty("innertext")
			If strRetrivedText <> "" Then
				Call ReportLog("Inventory Response Status","Status of Inventory should be retrived","Status of Inventory message recieved -"&strRetrivedText, "PASS","")
			Else
				Call ReportLog("Inventory Response Status","Status of Inventory should be retrived","Status of Inventory is not retrived","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
	End If

	blnDirect = False
	If Ucase(strTypeOfOrder) = "GSIPMODIFY" OR Ucase(strTypeOfOrder) = "GVPNBUNDLEDMODIFY" OR Ucase(strTypeOfOrder) = "GVPNCEASE" or _
		strMPLSPresence = "Yes" OR Ucase(strTypeOfOrder) = "OB_FULLPSTN_MODIFY" OR strTypeOfOrder = "GVPNUNBUNDLEDMODIFY" Then
		'Click on select  button across Onevoice
		For intCounter = 1 to 100
			blnResult = objPage.WbfGrid("tblMPLSandOnevoiceDetails").Exist(10)
				If blnResult Then Exit For

			'If the Classic Site ID does not compose of MPLS
			blnDirect = objPage.WebEdit("txtContractId").Exist(10)
				If blnDirect Then Exit For
		Next
		
		If Not blnDirect Then
			strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblMPLSandOnevoiceDetails").GetCellData(2,4)
			If strRetrivedText = "Onevoice" Then
				'Click the particular select button if the access type is Onevoice
				blnResult = clickButton("btnSelectFirstRow")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
					Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
				'Click the particular select button if acccess type retrived is not Onevoice
				blnResult = clickButton("btnSelectSecondRow")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
	
			'Checking for the alert message and clicking on OK
			If Browser("brweDCAPortal").Dialog("dlgVpnalert").exist then
				Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Highlight
				Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Click
			Else
				Call ReportLog("Alert Notification","Alert Notification should be visible","Alert Notification is not visible","Warnings","True")
			End if
		End If
	End If

	'If Ucase(strTypeOfOrder) = "TDMMODIFY" or  Ucase(strTypeOfOrder) = "CONFERMODIFY" or Ucase(strTypeOfOrder) = "OMAMODIFY" OR _
	'			strMPLSPresence = "No" or Ucase(strTypeOfOrder) = "OB_FULLPSTN_MODIFY" OR strTypeOfOrder = "ETHERNETMODIFY" Then
	For intCounter = 1 to 100
		blnResult = objPage.webEdit("txtContractId").Exist(30)
			If blnResult Then Exit For
	Next
	'End If
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Moving to customer details page back
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Contract Id
    blnResult = enterText("txtContractId",streDCAOrderId&""& strContractId)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter currency
	blnResult = selectValueFromPageList("lstCurrencyName",strCurrency)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Siebel Id
	blnResult = enterText("txtSiebelId",streDCAOrderId&""&strSiebelId)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Customer Service Center
	blnResult = selectValueFromPageList("lstServiceCentre",strServiceCentre)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Contract Terms
	blnResult = enterText("txtContractTerm",strContractTerm)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Clicking on clear button
	blnResult = clickButton("btnClear")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Order Form Sign date
	blnResult = clickImage("imgClickForCalendar")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Sync
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtOrderFormSignDate
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	wait 2

	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderFormSignDate").GetROProperty("value")
	Call ReportLog("Order Form Sign Date","OrderFormSignDate should be populated","Order Form Sign Date is populated with value"&strRetrievedText ,"PASS","")

	wait(2)
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Customer Contact Details Page
	Set objMsg = objpage.Webelement("webElmCustomerContactDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Not navigated to Customer contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmCustomerContactDetails")
		Call ReportLog("Customer Details","Should be navigated to Customer contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function
