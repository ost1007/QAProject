'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ModifySite
' Purpose	 	 : 	Function to enter values in Site Page for modify order
' Author	 	 : Vamshi Krishna G
' Creation Date    : 06/08/2013
' Parameters	 :              					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_ModifySite(CustomerRequiredDate,CustomerSignDate)

	'Declaration of variables
	Dim strCountry,dtCustomerRequiredDate,dtCustomerSignDate
	Dim strRetrivedText
		
	'Assignment of values
	dtCustomerRequiredDate = CustomerRequiredDate
	dtCustomerSignDate = CustomerSignDate


	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retriving the product name at the site
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstProductNameAtThisSite").GetROProperty("value")
	If strRetrivedText<> " " Then
		Call ReportLog("Site Page","Product Name should be retrived","Product Name is populated with value -"&strRetrivedText,"PASS","")
	Else
		Call ReportLog("Site Page","Product Name should be retrived","Product Name is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If


	'Retriving the country
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstCountry").GetROProperty("value")
	If strRetrivedText<> " " Then
		Call ReportLog("Site Page","Country should be retrived","Country is populated with value -"&strRetrivedText,"PASS","")
	Else
		Call ReportLog("Site Page","Country should be retrived","Country is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	'Clicking on Clear button
	blnResult = clickButton("btnClear")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Customer Required date

	blnResult = clickImage("imgClickForCalendar_CustReqdDate")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	If blnResult Then
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Sync
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtCustomerRequiredDate
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
    	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerRequiredDate").GetROProperty("value")
	Call ReportLog("CustomerRequiredDate","CustomerRequiredDate should be populated","CustomerRequiredDate is populated with value"&strRetrievedText ,"PASS","")
	
	Wait 10
    	'Enter  Customer  Sign date - Site page
	blnResult = clickImage("imgClickForCalendar_CustSignDate")
	For intCounter = 1 to 10
		blnResult = Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").Exist(5)
		If blnResult = "True" Then
			Exit For
		Else 
			Wait 5
		End If
	Next

	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Sync
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtCustomerSignDate

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	wait 2
	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerSignDate").GetROProperty("value")
	Call ReportLog("CustomerSignDate","CustomerSignDate should be populated","CustomerSignDate is populated with value"&strRetrievedText ,"PASS","TRUE")

	'Retriving the IPMS Corporate  Id value
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtIPMSCorporateId").GetROProperty("value")
	If strRetrivedText<> " " Then
		Call ReportLog("Site Page","IPMS Corporate Id should be retrived","IPMS Corporate Id is populated with value -"&strRetrivedText,"PASS","TRUE")
	Else
		Call ReportLog("Site Page","IPMS Corporate Id should be retrived","IPMS Corporate Id is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	'Checking for the existence of alert notification in the browser
	If Browser("brweDCAPortal").Dialog("dlgSiteAlert").exist then
		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved is retrived","PASS","TRUE")
		'Click on OK button		
		Browser("brweDCAPortal").Dialog("dlgSiteAlert").WinButton("btnOk").Click
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved not retrived","PASS","")
	End IF 
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site Location Details Page
	Set objMsg = objpage.Webelement("webElmSiteLocationDetails")
	'objMsg.WaitProperty "visible", True, 1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSiteLocationDetails")
		Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function

'***********************************************************************************************************************************************************************************************************
'End of the function
'*************************************************************************************************************************************************************************************************************
