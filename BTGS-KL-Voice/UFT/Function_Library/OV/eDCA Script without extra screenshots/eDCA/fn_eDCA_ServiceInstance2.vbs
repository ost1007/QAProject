'********************************************************************************************************************************************************************************************************************************************************
' Function Name	 : fn_eDCA_ServiceInstance2
' Purpose	 	 : Function to add new voice service with MPLS Service ID
' Creation Date    : 05-01-2016
' Return Values	 : Not Applicable
'********************************************************************************************************************************************************************************************************************************************************
Public function fn_eDCA_ServiceInstance2(dTypeOfOrder, dServiceType, dSubServiceType, dNonStandardType, dVoiceVPNRequired, dPSTNRequired, dDirectAccessType,_
			dNoOfChannels, dMPLSType, dMPLSServiceID, dSiteResiliency, dDirectAccessTariff, dSLACategory, dOneVoicePoPRegion, dPOPDualHomed, dPrimaryVoicePoP,_
			dSecondaryVoicePoP, dProductBidApproval, dRouteSelector, dAPEQuotePrimaryService, dNTESupplier)

	'Decalration of variables
	Dim blnResult,objMsg,strMessage
	Dim strServiceType,strSubServiceType,strNoOfChannels,strDirectAccessType,strMPLSType,strSiteResiliency,strDirectAccessTariff,strSLACategory,strRouteSelector
	Dim strVoiceVPNRequired,strPSTNRequired,strTypeOfOrder,strOneVoicePoPRegion,strPrimaryVoicePoP,strNonStandardType
	Dim arrMPLSServiceToBeLinked

	'Assignment of values to variables
	strTypeOfOrder = dTypeOfOrder
	strServiceType=dServiceType
	strNoOfChannels=dNoOfChannels
	strVoiceVPNRequired = dVoiceVPNRequired
	strPSTNRequired = dPSTNRequired
	strDirectAccessType=dDirectAccessType
	strMPLSType=dMPLSType
	strSiteResiliency = dSiteResiliency
	strDirectAccessTariff=dDirectAccessTariff
	strSLACategory=dSLACategory
	strRouteSelector=dRouteSelector
	strSubServiceType = dSubServiceType
	strOneVoicePoPRegion = dOneVoicePoPRegion
	strPrimaryVoicePoP = dPrimaryVoicePoP
	strAPEQuotePrimaryService = dAPEQuotePrimaryService
	strNTESupplier = dNTESupplier
	strNonStandardType = dNonStandardType
	strProductBidApproval = dProductBidApproval

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clilcking on SIte to expand it
	If objPage.ViewLink("treeview").Link("lnkSite").Exist Then
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSite").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		Call ReportLog("TreeView --> Site", "TreeView --> Site should exist", "TreeView --> Site doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on ServiceInstance
	If objPage.ViewLink("treeview").Link("lnkServiceInstance").Exist Then
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkServiceInstance").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		Call ReportLog("TreeView --> ServiceInstance", "TreeView --> ServiceInstance should exist", "TreeView --> ServiceInstance doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebButton("btnAddNewOnevoiceService").Exist(120)
	'Click on AddNewOnevoiceService button
	blnResult = clickButton("btnAddNewOnevoiceService")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	For intCounter = 1 To 5
		If objPage.WebButton("btnAddNewOnevoiceService").GetROProperty("disabled") = 1 Then
			Exit For '#intCounter
		Else
			Wait 60
			clickButton("btnAddNewOnevoiceService")
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	Next

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstServiceType").Exist(60) Then
        'Select service type from dropdownlist
		blnResult = selectValueFromPageList("lstServiceType",strServiceType)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If dTypeOfOrder <> "OMAPROVIDE" Then
				If objPage.WebList("lstSubServiceType").Exist(5) Then
					'Select  subservice type from dropdownlist
					blnResult = selectValueFromPageList("lstSubServiceType",strSubServiceType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
			
				If objPage.WebEdit("txtNoOfChannels").Exist(5) Then
					'Entering the value for number of channels
					blnResult = enterText("txtNoOfChannels",strNoOfChannels)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If

				If objPage.WebList("lstnonstandardtype").Exist(5) Then
					'Selecting Voice VPN Required from drop down
					blnResult = selectValueFromPageList("lstnonstandardtype",strNonStandardType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End IF
				
				If  strNonStandardType = "Yes" Then
					blnResult = enterText("txtProductBidApproval",strProductBidApproval)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
			
				If objPage.WebList("lstVoiceVPNRequired").Exist(5) Then
					'Selecting Voice VPN Required from drop down
					blnResult = selectValueFromPageList("lstVoiceVPNRequired",strVoiceVPNRequired)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End IF
			
				If objPage.WebList("lstPSTNRequired").Exist(5) Then
					'Select PSTN Required
					blnResult = selectValueFromPageList("lstPSTNRequired",strPSTNRequired)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
			
				If objPage.WebList("lstDirectAccessType").Exist(5) Then
					'Select  DirectAccessType from drop down list
					blnResult = selectValueFromPageList("lstDirectAccessType",strDirectAccessType)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					
					'If Direct Access Type is Intenet then need to Select Encrytion Required
					If strDirectAccessType = "Internet" Then
						strEncryptionRequired = Trim(GetAttributeValue("dEncryptionRequired"))
						If strEncryptionRequired = "" Then
							Call ReportLog("Encryption Required", "Test Data missing", "For [" & strDirectAccessType & "] dEncryptionRequired is missing in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						Else
							'Selecting Encryption Required #R41
							blnResult = selectValueFromPageList("lstEncryptionRequired", strEncryptionRequired)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
						End If
					End If
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End IF
			
				If objPage.WebList("lstMPLSType").Exist(10) Then
					'Select MPLS Type from dropdown list
					blnResult = selectValueFromPageList("lstMPLSType",strMPLSType)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End IF

				If strDirectAccessType <> "Internet" Then
					'Enter MPLS Service ID
					If objPage.WebEdit("txtMPLSServiceID").Exist(120) Then
						blnResult = enterText("txtMPLSServiceID",dMPLSServiceID)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End If
					Wait 5
				End If

				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

				If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(30) Then
					strText = Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Static("staticMsg").GetROProperty("text")
					Call ReportLog("Pop Up", "Pop up should exist", strText, "Information", True)
                    		Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
                    		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If

				If objPage.WebCheckBox("chkServiceInstanceCOS").Exist(30) Then
                    		blnResult = setCheckBox("chkServiceInstanceCOS", "ON")
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync					
				End If

				If objPage.WebEdit("txtNoOfLeasedLines1stAccess").Exist(30) Then
					'Checking number of leased lines
					strRetrievedText = objPage.WebEdit("txtNoOfLeasedLines1stAccess").GetROProperty("value")
					If strRetrievedText <> "" Then
						Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is populated with the value - "&strRetrievedText,"PASS","")
					Else
						Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is not populated","FAIL","TRUE")
						Environment("Action_Result") = False : Exit Function
					End If
				End If
				
				'Select One Voice POP Resiliency Required (Dual Homed)
				If objPage.WebList("lstPOPDualHomed").Exist(10) Then
					If CInt(objPage.WebList("lstPOPDualHomed").GetROProperty("disabled")) = 0 Then
						blnResult = selectValueFromPageList("lstPOPDualHomed", dPOPDualHomed)
							If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
						Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	
					End If
				End If
				
				'Selecting Primary Pop
				If objPage.WebList("lstPrimaryVoicePoP").Exist(10) Then
					strRetrievedText = objPage.WebList("lstPrimaryVoicePoP").GetROProperty("Value")
					If strRetrievedText <> strPrimaryVoicePoP Then
						blnResult = selectValueFromPageList("lstPrimaryVoicePoP", strPrimaryVoicePoP)
							If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
						Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					Else
						Call ReportLog("PrimaryVoicePoP","PrimaryVoicePoP should be populated","PrimaryVoicePoP is populated with the value - "&strRetrievedText,"PASS","")
					End If
				End If
				
				If Browser("brweDCAPortal").Window("wndDialog").Exist(30) Then
					strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
					Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
					Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
				
				If UCase(dPOPDualHomed) = "YES" Then
					'Selecting Secondary POP
					If objPage.WebList("lstSecondaryVoicePoP").Exist(10) Then
						strRetrievedText = objPage.WebList("lstSecondaryVoicePoP").GetROProperty("Value")
						If strRetrievedText <> strSecondaryVoicePoP Then
							blnResult = selectValueFromPageList("lstSecondaryVoicePoP", dSecondaryVoicePoP)
								If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						Else
							Call ReportLog("Secondary VoicePoP","Secondary VoicePoP should be populated","Secondary VoicePoP is populated with the value - "&strRetrievedText,"PASS","")
						End If
						
						If Browser("brweDCAPortal").Window("wndDialog").Exist(30) Then
							strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
							Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
							Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						End If
					End If
				End If '#dPOPDualHomed
				
				If objPage.WebList("lstDirectAccessTariff").Exist(10) Then
					'Selecting Site Resiliency from drop down
					blnResult = selectValueFromPageList("lstDirectAccessTariff",strDirectAccessTariff)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
	End If
	
	If objPage.WebList("lstSLACategory").Exist(10) Then
		'Selecting SLA category from drop down list
		blnResult = selectValueFromPageList("lstSLACategory",strSLACategory)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End if

	If Ucase(strTypeOfOrder) = "GSIPPROVIDE" or Ucase(strTypeOfOrder) = "ETHERNETPROVIDE"  Then
		If objPage.WebList("lstRouteSelector").Exist(10) Then
			'Selecting Route selector from drop down
			blnResult = selectValueFromPageList("lstRouteSelector",strRouteSelector)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End IF
	End If

	If Ucase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE"  Then
		If objPage.WebList("lstOneVoicePoPRegionServiceInstance").Exist(10) Then
			'Selecting Route selector from drop down
			blnResult = selectValueFromPageList("lstOneVoicePoPRegionServiceInstance",strOneVoicePoPRegion)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End IF

		If objPage.WebList("lstPrimaryVoicePoP").Exist(10) Then
			'Selecting Route selector from drop down
			blnResult = selectValueFromPageList("lstPrimaryVoicePoP",strPrimaryVoicePoP)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End IF
	End If '#GVPNUNBUNDLEDPROVIDE	
    
	If strDirectAccessType = "Ethernet"  Then
		If objPage.WebList("lstNTESupplier").Exist(10) Then
			'Selecting Site Resiliency from drop down
			strRetrievedText = objPage.WebList("lstNTESupplier").GetROProperty("Value")
			If strRetrievedText <> strNTESupplier Then
				Call ReportLog("NTESupplierP","NTESupplier should be populated","NTESupplier is not populated","FAIL","TRUE")
			Else
				Call ReportLog("NTESupplier","NTESupplier should be populated","NTESupplier is populated with the value - "&strRetrievedText,"PASS","")
			End If
		End If
		blnResult = entertext("txtAPEQuotePrimaryService", strAPEQuotePrimaryService)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End if

	If objPage.WebButton("btnSave").Exist(60) Then
		'Clicking on Save button
		blnResult =  clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'A new one voice service record would be created retriving the service Instance ID details
	If objPage.WebButton("btnSIEdit").Exist Then
		'Clicking on Edit corresponding to product type "one voice" created
		blnResult =  clickButton("btnSIEdit")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Handle pop up for Primary POP which is flagged as FULL
	If Browser("brweDCAPortal").Window("wndDialog").Exist(30) Then
		strRetrievedText = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.OuterHtml
		Call ReportLog("Flagged Info", "Primary POP flagged full", strRetrievedText, "Information", True)
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	If objPage.WebButton("btnNext").Exist(60) Then
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to Network Connection Or Mobile Access details page
	If strTypeOfOrder = "OMAPROVIDE" Then
		Set objMsg = objpage.WebElement("elmMobileAccessDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Mobile Access Details","Should be navigated to Mobile Access Details page on clicking Next Buttton","Not navigated to Mobile Access Details page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmNetworkConnectionDetails")
			Call ReportLog("Mobile Access Details","Should be navigated to Mobile Access Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
	Else
		Set objMsg = objpage.WebElement("webElmNetworkConnectionDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Not navigated to NetworkConnectionDetails page on clicking Next Buttton","FAIL","TRUE")
		Else
			strMessage = GetWebElementText("webElmNetworkConnectionDetails")
			Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
