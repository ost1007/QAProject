'****************************************************************************************************************************'*********************************************************************************
' Function Name	 : fn_eDCA_ModifyServiceInstance_InternetAccess
' Purpose	 	 : Function to editnew voice service 
' Return Values	 : Not Applicable
'****************************************************************************************************************************'*********************************************************************************
Public function fn_eDCA_ModifyServiceInstance_InternetAccess(TypeOfOrder, VoiceVPNRequired, PSTNRequired, DirectAccessType,_
	EncryptionRequired, EncryptionApplied, AccessResiliency , POPDualHomed, SecondaryVoicePoP, DirectAccessTariff, SLACategory)

	'Declaration of variables
	Dim strFullPSTNMsgText, strRetrievedText, strHTML
	Dim intCounter

	'Variable Assignment
	strFullPSTNMsgText = "Are you sure you want to migrate 'One Voice Outbound' Service to 'Full PSTN' Service"

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Edit corresponding to product type "one voice" 
	blnResult =  clickButton("btnSIEdit")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Handle Dialog if Pop Appears stating Selected PoP is flagged as full
	If Browser("brweDCAPortal").Window("wndDialog").Exist(10) Then
		strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
		Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If '#Dialog


	'Voice VPN required
	If VoiceVPNRequired <>""  Then
		blnResult = selectValueFromPageList("lstVoiceVPNRequired", VoiceVPNRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'PSTN Required
	If PSTNRequired <>"" Then
		blnResult = selectValueFromPageList("lstPSTNRequired", PSTNRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Verify Direct Access Type
	If Not objPage.WebList("lstDirectAccessType").Exist Then
		Call ReportLog("Direct Access Type", "Direct Access Type should be displayed", "Direct Access Type is not displayed", "Information", False)
		Environment("Action_Result") = False : Exit Function
	Else
		strRetrievedText = objPage.WebList("lstDirectAccessType").GetROProperty("selection")
		If strRetrievedText =  DirectAccessType Then
			Call ReportLog("Direct Access Type", "Direct Access Type should be <B>" & DirectAccessType & "</B>", "Direct Access Type found to be <B>" & strRetrievedText & "</B>", "Information", False)
		Else
			Call ReportLog("Direct Access Type", "Direct Access Type should be <B>" & DirectAccessType & "</B>", "Direct Access Type found to be <B>" & strRetrievedText & "</B>", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'If Direct Access Type is Intenet then need to Select Encrytion Required
	If DirectAccessType = "Internet" Then
		If EncryptionRequired <> "" Then
			'Selecting Encryption Required #R41
			blnResult = selectValueFromPageList("lstEncryptionRequired", EncryptionRequired)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Verify Encryption Applied
	If Not objPage.WebList("lstEncryptionApplied").Exist Then
		Call ReportLog("Encryption Applied", "Encryption Applied should be displayed", "Encryption Applied is not displayed", "Information", False)
		Environment("Action_Result") = False : Exit Function
	Else
		strRetrievedText = objPage.WebList("lstEncryptionApplied").GetROProperty("selection")
		If strRetrievedText =  EncryptionApplied Then
			Call ReportLog("Encryption Applied", "Encryption Applied should be <B>" & EncryptionApplied & "</B>", "Encryption Applied should be <B>" & strRetrievedText & "</B>", "Information", False)
		Else
			Call ReportLog("Encryption Applied", "Encryption Applied should be <B>" & EncryptionApplied & "</B>", "Encryption Applied should be <B>" & strRetrievedText & "</B>", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'Selecting Access Resiliency
	If objPage.WebList("lstAccessResiliency").Exist(10) Then
		If Not objPage.WebList("lstAccessResiliency").Object.disabled Then
			If AccessResiliency <>"" Then
				blnResult = selectValueFromPageList("lstAccessResiliency", AccessResiliency)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If		
		Else
			strRetrievedText = objPage.WebList("lstAccessResiliency").GetROProperty("selection")
			Call ReportLog("Access Resiliency", "Access Resiliency is populated with <B>" & AccessResiliency & "</B>", "Access Resiliency is populated with <B>" & AccessResiliency & "</B>", "Information", False)
		End If
	End If
	
	'Select One Voice POP Resiliency Required (Dual Homed)
	If POPDualHomed <> "" Then
		If objPage.WebList("lstPOPDualHomed").Exist(10) Then		
			blnResult = selectValueFromPageList("lstPOPDualHomed", POPDualHomed)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
			If POPDualHomed = "Yes" Then
				blnResult = selectValueFromPageList("lstSecondaryVoicePoP", SecondaryVoicePoP)
					If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
				'Handle Dialog if Pop Appears stating Selected PoP is flagged as full
				If Browser("brweDCAPortal").Window("wndDialog").Exist(10) Then
					strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
					Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
					Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If '#Dialog
			End If '#POPDualHomed = "Yes"
		End If '#Exist
	End If '#POPDualHomed <> ""
	
	'Selecting DirectAccessTarrif from drop down list
	If DirectAccessTariff <>"" Then
		blnResult = selectValueFromPageList("lstDirectAccessTariff", DirectAccessTariff)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Wait(10)
	
	'Selecting SLA category from drop down list
	If SLACategory <>"" Then
		blnResult = selectValueFromPageList("lstSLACategory", SLACategory)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to Network Connection details page
	Set objMsg = objpage.WebElement("webElmNetworkConnectionDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Not navigated to NetworkConnectionDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmNetworkConnectionDetails")
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
