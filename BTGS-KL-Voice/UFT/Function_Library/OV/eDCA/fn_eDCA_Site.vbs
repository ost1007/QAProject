'****************************************************************************************************************************
' Function Name	 : fn_eDCA_Site
' Purpose	 	 : 	Function to enter values in Site Page
' Author	 	 : Sathish Lakshminarayana
' Creation Date    : 29/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_Site(dOrderType,dProductNameAtThisSite,dCountry,dCustomerRequiredDate,dCustomerSignDate)

	'Variable Declaration Section
	Dim  strProductNameAtThisSite,strCountry,dtCustomerRequiredDate,dtCustomerSignDate
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	 strProductNameAtThisSite = dProductNameAtThisSite
	strCountry = dCountry
	dtCustomerRequiredDate = dCustomerRequiredDate
	dtCustomerSignDate = dCustomerSignDate

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstProductNameAtThisSite").Exist(10) Then
		'Select  Product name at this site value  from drop down list-  Site page
        strEnabled = objPage.WebList("lstProductNameAtThisSite").GetROProperty("disabled")
		If strEnabled =  1 Then
			strRetrivedText = objPage.WebList("lstProductNameAtThisSite").GetROProperty("Value")
			Call ReportLog("Site","Field Product Name At This Site","is disabled and value of field is  - " & strMessage,"PASS","")
		Else
			blnResult = selectValueFromPageList("lstProductNameAtThisSite",strProductNameAtThisSite)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			wait 5
		End If
	End if	

	If objPage.WebList("lstCountry").Exist(10) Then
		'Select  Country  from drop down list -  Site page
		strEnabled = objPage.WebList("lstCountry").GetROProperty("disabled")
		If strEnabled =  1 Then
			strRetrivedText = objPage.WebList("lstCountry").GetROProperty("Value")
			Call ReportLog("Site","Field Country","is disabled and value of field is  - "&strMessage,"PASS","")
		Else
			blnResult = selectValueFromPageList("lstCountry",strCountry)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if
	End if

	'Clicking on clear button
	If objPage.Webbutton("btnClear").Exist(10) Then
		strEnabled = objPage.Webbutton("btnClear").GetROProperty("disabled")
		If strEnabled =  1 Then
            		Call ReportLog("Site","Field Customer required by date","is disabled and not clickable- ","PASS","")
		Else
			blnResult = clickButton("btnClear")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			'Enter  Customer  required by date - Site page
			blnResult = clickImage("imgClickForCalendar_CustReqdDate")

			For intCounter = 1 to 10
				blnResult = Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").Exist(5)
				If blnResult = "True" Then
					Exit For
				Else
					Wait 5
				End If
			Next

			If blnResult Then
				Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtCustomerRequiredDate
			End If

			Wait 3
			'Checking for existence of close button in calendar
			blnResult = Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").Exist(5)
			If blnResult = "True"  then
				'Click Close button in calendar
				Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").click    
			End If	

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if
	End if

	wait 2
	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerRequiredDate").GetROProperty("value")
	Call ReportLog("CustomerRequiredDate","CustomerRequiredDate should be populated","CustomerRequiredDate is populated with value "&strRetrievedText ,"PASS","")
	
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
	
	If blnResult Then
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WbfCalendar("CdrDatePicker").SetDate dtCustomerSignDate
	End If

	'Checking for existence of close button in calendar
	Wait 5
	blnResult = Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").Exist(5)
	If blnResult = "True"  then
		'Click Close button in calendar
		Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebButton("btnClose").click    
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	wait 2
	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCustomerSignDate").GetROProperty("value")
	
	'Checking for the existence of alert notification in the browser
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	If Browser("brweDCAPortal").Dialog("dlgSiteAlert").Exist(10) then
		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved is retrived","PASS","TRUE")
		Browser("brweDCAPortal").Dialog("dlgSiteAlert").WinButton("btnOk").Click
	Else
		Call ReportLog("Alert Notification In SIte Page","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved should be retrived","Alert Notifiaction# Customer Sign Date can not be changed after the page gets saved not retrived","PASS","")
	End IF 

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Navigating to Site Location Details if  ProductNameAtThisSite = "BT ONEVOICE" for Ethernet
	If strProductNameAtThisSite = "BT ONEVOICE"  or dOrderType = "CEASE" or dOrderType = "MODIFY"Then

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		'Check if Navigated to Site Location Details Page
		Set objMsg = objpage.Webelement("webElmSiteLocationDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmSiteLocationDetails")
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","PASS","")
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details  page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		End If
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
