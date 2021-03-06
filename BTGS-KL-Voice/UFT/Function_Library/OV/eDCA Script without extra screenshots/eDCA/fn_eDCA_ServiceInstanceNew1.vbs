'*****************************************************************************************************************************************************************************************************************
' Function Name	 : fn_eDCA_ServiceInstance1
' Description		: Function to Add New OneVoice Service under Service Instance Page
' Return Values	 : Not Applicable
'*****************************************************************************************************************************************************************************************************************
Public function fn_eDCA_ServiceInstanceNew1(TypeOfOrder, ServiceType, SubServiceType, NonStandardOrder, ProductBidApproval, VoiceVPNRequired, PSTNRequired,_
										DirectAccessType, MPLSServiceID, MPLSType, SiteResiliency, POPDualHomed, PrimaryVoicePoP, SecondaryVoicePoP,_
										DirectAccessTariff, SLACategory, CompressionExpansionAlgorithmReqd)
										
	'Variable Declaration
	Dim iCounter
	Dim strText, strRetrievedText
	Dim objMsg

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Clilcking on SIte to expand it
	If objPage.ViewLink("treeview").Link("lnkSite").Exist Then
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSite").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Click on ServiceInstance
	If objPage.ViewLink("treeview").Link("lnkServiceInstance").Exist Then
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkServiceInstance").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	For iCounter = 1 To 5
		If objPage.WebButton("btnAddNewOnevoiceService").Exist Then
			If objPage.WebButton("btnAddNewOnevoiceService").object.disabled Then
				Wait 30
			Else
				Exit For
			End If
		End If
	Next
	
	'Click on AddNewOnevoiceService button
	blnResult = clickButton("btnAddNewOnevoiceService")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
       'Select service type from dropdownlist
	blnResult = selectValueFromPageList("lstServiceType", ServiceType)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	

	'Select  subservice type from dropdownlist
	blnResult = selectValueFromPageList("lstSubServiceType", SubServiceType)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Selecting Voice VPN Required from drop down
	blnResult = selectValueFromPageList("lstnonstandardtype", NonStandardOrder)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'If Non Standard Order = Yes - Mandate is to provide Product Bid Approval	
	If NonStandardOrder = "Yes" Then
		If ProductBidApproval = "" Then
			Call ReportLog("Product Bid Approval", "Product Bid Approval should be provided if Non Standard Order = Yes", "Product Bid Approval data is missing", "FAIL", False)
			Environment.Value("Action_Result") = False : Exit Function
		Else
			blnResult = enterText("txtProductBidApproval", ProductBidApproval)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End If
			
	'Selecting Voice VPN Required from drop down
	blnResult = selectValueFromPageList("lstVoiceVPNRequired", VoiceVPNRequired)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select PSTN Required
	blnResult = selectValueFromPageList("lstPSTNRequired", PSTNRequired)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	Wait 15
	'Select  DirectAccessType from drop down list
	blnResult = selectValueFromPageList("lstDirectAccessType", DirectAccessType)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Particulars not for Internet
	If DirectAccessType <> "Internet" Then
		'Check DSCP Cos
		If objPage.WebCheckBox("chkServiceInstanceCOS").Exist(10) Then
			blnResult = setCheckBox("chkServiceInstanceCOS", "ON")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'Enter MPLS Service ID
		blnResult = enterText("txtMPLSServiceID", MPLSServiceID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Wait 5
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(30) Then
		strText = Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Static("staticMsg").GetROProperty("text")
		Call ReportLog("Pop Up", "Pop up should exist", strText, "Information", True)
    		Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
	End If
	
	'Validate MPLS Type
	If DirectAccessType = "MPLS" Then
		strRetrievedText = objPage.WebList("lstMPLSType").GetROProperty("selection")
		If strRetrievedText = MPLSType Then
			Call ReportLog("MPLS Type", "MPLS Type should be - " & MPLSType, "MPLS Type is found to be - <B>" & strRetrievedText & "</B>", "PASS", False)
		Else
			Call ReportLog("MPLS Type", "MPLS Type should be - " & MPLSType, "MPLS Type is found to be - <B>" & strRetrievedText & "</B>", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		'Check Site Resiliency
		strRetrievedText = objPage.WebList("lstSiteResiliency").GetROProperty("selection")
		If strRetrievedText = SiteResiliency Then
			Call ReportLog("Site Resiliency", "Site Resiliency should be - " & SiteResiliency, "Site Resiliency is found to be - <B>" & strRetrievedText & "</B>", "PASS", False)
		Else
			Call ReportLog("Site Resiliency", "Site Resiliency should be - " & SiteResiliency, "Site Resiliency is found to be - <B>" & strRetrievedText & "</B>", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	Else
		'Select Site Resilency
		blnResult = selectValueFromPageList("lstSiteResiliency", SiteResiliency)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Checking number of leased lines
	If objPage.WebEdit("txtNoOfLeasedLines1stAccess").Exist Then
		strRetrievedText = objPage.WebEdit("txtNoOfLeasedLines1stAccess").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is populated with the value - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is not populated","FAIL", True)
		End If
	End If
	
	'Select One Voice POP Resiliency Required (Dual Homed)
	If objPage.WebList("lstPOPDualHomed").Exist(10) Then
		blnResult = selectValueFromPageList("lstPOPDualHomed", POPDualHomed)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Selecting Primary Pop
	strRetrievedText = objPage.WebList("lstPrimaryVoicePoP").GetROProperty("Value")
	If strRetrievedText <> strPrimaryVoicePoP Then
		blnResult = selectValueFromPageList("lstPrimaryVoicePoP", PrimaryVoicePoP)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		Call ReportLog("PrimaryVoicePoP","PrimaryVoicePoP should be populated","PrimaryVoicePoP is populated with the value - " & strRetrievedText,"PASS", False)
	End If
	
	'Handling if PoP is flagged full
	If Browser("brweDCAPortal").Window("wndDialog").Exist(15) Then
		strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
		Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Selecting Secondary POP
	If POPDualHomed = "Yes" Then
		blnResult = selectValueFromPageList("lstSecondaryVoicePoP", SecondaryVoicePoP)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		If Browser("brweDCAPortal").Window("wndDialog").Exist(15) Then
			strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
			Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
			Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End If
	
	'Selecting Site Resiliency from drop down
	blnResult = selectValueFromPageList("lstDirectAccessTariff", DirectAccessTariff)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Selecting SLA category from drop down list
	blnResult = selectValueFromPageList("lstSLACategory", SLACategory)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Selecting Route selector from drop down
	If objPage.WebList("lstRouteSelector").Exist(10) Then
		blnResult = selectValueFromPageList("lstRouteSelector", CompressionExpansionAlgorithmReqd)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
    
    
	'Clicking on Save button
	If objPage.WebButton("btnSave").Exist Then	
		blnResult =  clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'A new one voice service record would be created retriving the service Instance ID details
	If objPage.WebButton("btnSIEdit").Exist(60*5) Then
		'Clicking on Edit corresponding to product type "one voice" created
		blnResult =  clickButton("btnSIEdit")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If Browser("brweDCAPortal").Window("wndDialog").Exist(15) Then
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	If objPage.WebButton("btnNext").Exist Then
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Set objMsg = objpage.WebElement("webElmNetworkConnectionDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Not navigated to NetworkConnectionDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmNetworkConnectionDetails")
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function
