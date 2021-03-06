'************************************************************************************************************************************
' Function Name	 :   fn_eDCA_OvaSite
' Purpose	 	 :  Selecting Site for OVA
' Author	 	 : Biswabharati Sahoo
' Modified By	 : Linta
' Creation Date    : 12/08/2013
' Return values :	NA
'**************************************************************************************************************************************	

Public Function fn_eDCA_OvaSite(dCustomerSignDate)

	'Variable Declaration Section
	Dim dtCustomerSignDate,strConferenceSite
    Dim objMsg
	Dim blnResult

	'Assigning Values
	dtCustomerSignDate = dCustomerSignDate

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

'	---------------------Clcik on Edit Site button----------------------------------

	blnResult = clickButton("btnEdit")
	If blnResult= False Then
		Environment("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	Set objMsg = objpage.WebElement("webElmSite")
	objMsg.WaitProperty "visible", True,1000*60*5
		If objMsg.Exist = TRUE Then
			strMessage = GetWebElementText("webElmSite")
			Call ReportLog("Sites","Should be navigated to Site page on clicking Edit Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'--------------------Retrive the product name  from drop down------------------------
	strRetrievedText =  Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstProductNameAtThisSite").GetROProperty("Value")
	Call ReportLog("Product   Name","Product Name  should be populated","Product Name  is populated with the value - "&strRetrievedText,"PASS","")
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync 

	' ------------------------Selecting the sign date-----------------------------------------------------------------------------------------------------------
	blnResult = clickImage("imgClickForCalendar_CustSignDate")
	If blnResult Then
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtCustomerSignDate
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	wait 2
    strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerSignDate").GetROProperty("value")
	Call ReportLog("CustomerSignDate","CustomerSignDate should be populated","CustomerSignDate is populated with value"&strRetrievedText ,"PASS","")
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync


	'---------------------------------------------------Checking for the existence of alert notification in the browser---------------------------------------------------------------------
	
	If Browser("brweDCAPortal").Dialog("dlgSiteAlert").exist then

		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved is retrived","PASS","")
		
		'Click on OK button		
		Browser("brweDCAPortal").Dialog("dlgSiteAlert").WinButton("btnOk").Click
		If blnResult = False Then
			Environment("Action_Result") = False
			Call ndReport()
			Exit Function
		End If

	Else
		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved not retrived","PASS","")
	End If

	'--------------------------Click on Next Button-----------------------------------------
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	'-------------------------Check if Navigated to Site Location Details Page---------------------------
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Set objMsg = objpage.Webelement("webElmSiteLocationDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSiteLocationDetails")
		Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","PASS","")
		Call ReportLog("Site Location Details page","Should be navigated to Site Location Details  page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End function

'*************************************************************************************************************************************
'	End of function
'**************************************************************************************************************************************
