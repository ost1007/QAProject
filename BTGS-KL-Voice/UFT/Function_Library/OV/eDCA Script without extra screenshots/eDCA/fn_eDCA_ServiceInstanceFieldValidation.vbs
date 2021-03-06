'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ServiceInstanceFieldValidation(PrimarySiteFirstName,PrimarySiteLastName,PrimarySiteEmail,PrimarySitePhone)
' Purpose	 	 : Function to enter Site Contact Details
' Author	 	 : Anil Pal
' Creation Date  	 : 16/08/2014	     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_ServiceInstanceFieldValidation(dOrderType,dServiceType,dSubServiceType,dVoiceVPNRequired,dPSTNRequired,dDirectAccessType,dNoOfChannels,dSiteResiliency,dDirectAccessTariff,dSLACategory)

	Dim strServiceType,strSubServiceType,strVoiceVPNRequired,strPSTNRequired,strDirectAccessType,strNoOfChannels,strSiteResiliency
	Dim strSLACategory,strDirectAccessTariff
	

	'Assignment of variables
	strServiceType = dServiceType
	strSubServiceType =dSubServiceType
    strVoiceVPNRequired = dVoiceVPNRequired
	strPSTNRequired = dPSTNRequired
    strDirectAccessType = dDirectAccessType
    strNoOfChannels=dNoOfChannels
    strSiteResiliency=dSiteResiliency
    strDirectAccessTariff = dDirectAccessTariff
	strSLACategory = dSLACategory


	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter /Valdation of  Service Type Field
	If objpage.WebList("lstServiceType").Exist Then 
		strState = objpage.WebList("lstServiceType").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstServiceType").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Service type is disabled ","Value of Field Service Type is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstServiceType", strServiceType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if

	'Enter /Valdation of  Sub Service Type Field
	If objpage.WebList("lstSubServiceType").Exist Then 
		strState = objpage.WebList("lstSubServiceType").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstSubServiceType").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Sub Service type is disabled ","Value of Field Sub Service Type is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstSubServiceType", strSubServiceType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	
				End If
			End if
	End if

	'Enter /Valdation of  Voice VPN Required Field
	If objpage.WebList("lstVoiceVPNRequired").Exist Then 
		strState = objpage.WebList("lstVoiceVPNRequired").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstVoiceVPNRequired").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Voice VPN Required  is disabled ","Value of Field Voice VPN Required  is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstVoiceVPNRequired", strVoiceVPNRequired)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if


	'Enter /Valdation of  PSTN Required Field
	If objpage.WebList("lstPSTNRequired").Exist Then 
		strState = objpage.WebList("lstPSTNRequired").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstPSTNRequired").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field PSTN Required  is disabled ","Value of Field PSTN Required  is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstPSTNRequired", strPSTNRequired)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	
				End If
			End if
	End if

	'Enter /Valdation of  Direct Access Type Field
	If objpage.WebList("lstDirectAccessType").Exist Then 
		strState = objpage.WebList("lstDirectAccessType").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstDirectAccessType").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Direct Access Type is disabled ","Value of Field Direct Access Type   is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstDirectAccessType", strDirectAccessType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if

	'Enter /Valdation of  Number of channels Field
	If objpage.WebEdit("txtNumberofChannels").Exist Then 
		strState = objpage.WebEdit("txtNumberofChannels").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebEdit("txtNumberofChannels").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Direct Access Type is disabled ","Value of Field Direct Access Type   is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = enterText("txtNumberofChannels", strNoOfChannels)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if

	'Enter /Valdation of  Access Resiliency  Field
	If objpage.WebList("lstAccessResiliency").Exist Then 
		strState = objpage.WebList("lstAccessResiliency").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstAccessResiliency").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Access Resiliency Type is disabled ","Value of Field Access Resiliency Type   is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstAccessResiliency", strSiteResiliency)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter /Valdation of  Direct Access Tariff  Field
	If objpage.WebList("lstDirectAccessTariff").Exist Then 
		strState = objpage.WebList("lstDirectAccessTariff").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstDirectAccessTariff").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field Direct Access Tariff  is disabled ","Value of Field Direct Access Tariff is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstDirectAccessTariff", strDirectAccessTariff)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if

	'Enter /Valdation of  SLA Category  Field
	If objpage.WebList("lstSLACategory").Exist Then 
		strState = objpage.WebList("lstSLACategory").GetROProperty("disabled")
			If strState = 1 Then
				strRetrievedText = objpage.WebList("lstSLACategory").GetROProperty("Value")
				If Cstr(strRetrievedText) <> "" Then
					Call ReportLog("Service Instance page","Field SLA Category  is disabled ","Value of Field SLA Category  is  - "&strRetrievedText,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstSLACategory", strSLACategory)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
				End If
			End if
	End if
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function


	Wait(30)
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Service Instance Page
	Set objMsg = objpage.Webelement("webElmServiceInstance")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Contact Details","Should be navigated to Service Instance page on clicking Next Buttton","Not navigated to Service Instance page on clicking Next Buttton","FAIL","TRUE")
		Environment.Value("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmServiceInstance")
		Call ReportLog("Site Contact Details","Should be navigated to Service Instance page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If


End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
