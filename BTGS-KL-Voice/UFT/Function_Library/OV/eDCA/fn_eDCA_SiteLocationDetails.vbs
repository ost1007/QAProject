'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SiteLocationDetails
' Purpose	 	 : Function to enter values in Site Location Details
' Author	 	 : Sathish Lakshminarayana
' Creation Date    : 29/05/2013
' Parameters	 : SiteName : Name of the site to be entered               					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_SiteLocationDetails(dOrderType,deDCAOrderId,dSiteName)

	'Variable Declaration Section
	Dim  strSiteName,streDCAOrderId,strState
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	streDCAOrderId = deDCAOrderId
	strSiteName = streDCAOrderId&dSiteName

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If


	'Enter Site name  -  Site Location details  page
	If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
		If  ObjPage.WebEdit("txtSiteName").GetROProperty("disabled") = 1 then 
			strValue = ObjPage.WebEdit("txtSiteName").GetROProperty("Value")
			Call ReportLog("Site Location Details page","Filed Site Name is autopopulated and disabled ","Value in site Name is - "&strValue,"PASS","")
		Else
			blnResult = enterText("txtSiteName",strSiteName)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
	Else
		blnResult = enterText("txtSiteName",strSiteName)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

	' Capture the  value of  Site level Billing ID
	If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
		If  ObjPage.WebList("lstSiteLevelBillingId").GetROProperty("disabled") = 1 then 
			'strSiteLevelBillingId = objpage.WebList("lstSiteLevelBillingId").GetROProperty("default value")
			strSiteLevelBillingId = objpage.WebList("lstSiteLevelBillingId").GetROProperty("Value")
			Call ReportLog("Site Location Details page","Field Site level Billing ID is disabled and Default value displayed in Site level Billing ID  list","Default value is  - "&strSiteLevelBillingId,"PASS","")
		End If
	Else
		strSiteLevelBillingId = objpage.WebList("lstSiteLevelBillingId").GetROProperty("Value")
		Call ReportLog("Site Location Details page","Field Site level Billing ID is disabled and Default value displayed in Site level Billing ID  list","Default value is  - "&strSiteLevelBillingId,"PASS","")
	End If

	' Capture the  value of   Local Business Customer name
	If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
		If  ObjPage.WebEdit("txtLocalBusinessCustomerName").GetROProperty("disabled") = 1 then 
			'strLocalBCN= objpage.WebEdit("txtLocalBusinessCustomerName").GetROProperty("default value")
			strLocalBCN= objpage.WebEdit("txtLocalBusinessCustomerName").GetROProperty("Value")
			Call ReportLog("Site Location Details page","Default value displayed in Local Business Customer Name","Default value is - "&strLocalBCN,"PASS","")
		End If
	Else
		strLocalBCN= objpage.WebEdit("txtLocalBusinessCustomerName").GetROProperty("Value")
		Call ReportLog("Site Location Details page","Default value displayed in Local Business Customer Name","Default value is - "&strLocalBCN,"PASS","")
	End if
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site Address Page
	Set objMsg = objpage.Webelement("webElmSiteAddress")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Address page","Should be navigated to Site Address  page on clicking Next Buttton","Not navigated to Site Address page on clicking Next Buttton","FAIL","TRUE")
	Else
		strMessage = GetWebElementText("webElmSiteAddress")
    	Call ReportLog("Site Address page","Should be navigated to Site Address page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
