'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ProductSelectionOneVoiceDetails
' Purpose	 	 : Function to enter One Voice details in Product Selection Page
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 27/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_ProductSelectionOneVoiceDetails(dTypeOfOrder,deDCAOrderId,dProductName,dCapacityPlanningReferenceNumber,dVoiceTrafficReportsRequested,dCentralizedBillingReportingRequired,dInvoicingOption,dIsNewInclusiveTariff,dConferencingFacilityRequired,dOneVoiceAnywhereRequired,dGVPNService,dOVAType,dOVALicenses,dOVASiteCode,dOVABlockStart,dOVABlockSize,dConferBridgeID,dConferVPNCode,dConferBridgeTrunk)

	'Declaration of variables

	Dim streDCAOrderId,strProductName,strCapacityPlanningReferenceNumber,strVoiceVPNRequired,strPSTNRequired
	Dim strCentralizedBillingReportingRequired,strInvoicingOption
	Dim strGVPNService,strOVAType,strOVALicenses,strOVASiteLocation,strOVASiteCode,strOVABlockStart,strOVABlockSize
	Dim strIsNewInclusiveTariff,strInclusiveCountryList,strConferencingFacilityRequired
	Dim strOneVoiceAnywhereRequired,strMessage,strTypeOfOrder,strConferBridgeTrunk,strConferBridgeID,strConferVPNCode
	Dim arrInclusiveCountryList
	Dim objMsg,blnResult

	'Assignment of values to variables
	streDCAOrderId = deDCAOrderId
	strProductName = dProductName
	strVoiceTrafficReportsRequested = dVoiceTrafficReportsRequested
	'strVoiceVPNRequired = VoiceVPNRequired
	'strPSTNRequired = PSTNRequired
	strCentralizedBillingReportingRequired = dCentralizedBillingReportingRequired
	strInvoicingOption = dInvoicingOption
	strIsNewInclusiveTariff = dIsNewInclusiveTariff
	strConferencingFacilityRequired = dConferencingFacilityRequired
	strOneVoiceAnywhereRequired = dOneVoiceAnywhereRequired
	strGVPNService = dGVPNService
	strOVAType = dOVAType
	strOVALicenses = dOVALicenses
	'strOVASiteLocation = dOVASiteLocation
	strOVASiteCode = dOVASiteCode
	strOVABlockStart = dOVABlockStart
	strOVABlockSize = dOVABlockSize
	strTypeOfOrder = dTypeOfOrder
	strCapacityPlanningReferenceNumber = dCapacityPlanningReferenceNumber
	strConferBridgeID = dConferBridgeID
	strConferVPNCode =dConferVPNCode
	strConferBridgeTrunk = dConferBridgeTrunk

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync


	Select Case UCase(strTypeOfOrder)
		Case "ETHERNETPROVIDE", "TDMPROVIDE", "OMAPROVIDE", "OB_FULLPSTN_MODIFY", "GSIPMODIFY", "GSIPPROVIDE", "P2PETHERNETPROVIDE", "SHAREDACCESSPROVIDE",_
			"MPLSPLUSIA"
			If objPage.WebList("lstProductName").Exist Then
				strEnabled = objPage.WebList("lstProductName").GetROProperty("disabled") 
				If strenabled = 1 Then
					strListValue = objPage.WebList("lstProductName").GetROProperty("Value") 
					Call ReportLog("Product Name","Product Name List Should be Enaled","Product Name List default value is -  "&strListValue,"PASS","")
				Else
					blnResult = selectValueFromPageList("lstProductName",strProductName)
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
				End If
			End If
		
		Case "OUTBOUNDPROVIDE", "GVPNUNBUNDLEDPROVIDE", "OVAPROVIDE"
		
		Case Else
			Call ReportLog("Product Selection", strTypeOfOrder & " :- New product encountered", "Contact Automation Team", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
	End Select

	'Enter Capacity Planning reference number
	strCapacityPlanningReferenceNumber = streDCAOrderId & strCapacityPlanningReferenceNumber
	If objPage.WebEdit("txtCapacityPlanningReferenceNumber").Exist(10) Then
			strRetrivedText = objPage.WebEdit("txtCapacityPlanningReferenceNumber").GetROProperty("Value")
			If  strRetrivedText = "" Then
				blnResult = enterText("txtCapacityPlanningReferenceNumber",strCapacityPlanningReferenceNumber)
					If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Else
				Call ReportLog("Capacity Planning Reference Number","Capacity Planning Reference Number should display","Capacity Planning Reference Number is: -"&strRetrivedText ,"PASS","TRUE")
			End If
	End If

	If objPage.WebList("lstVoiceTrafficReportsRequested").Exist(10) Then
		'Select Voice Traffic Reports Requested
		blnResult = selectValueFromPageList("lstVoiceTrafficReportsRequested",strVoiceTrafficReportsRequested)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'As per the changes for R27 - the below fields shifted  to Service Instance page

	'	'Select Voice VPN Required
	'	blnResult = selectValueFromPageList("lstVoiceVPNRequired",strVoiceVPNRequired)
	'	If blnResult= False Then
	'		Environment("Action_Result") = False
	'		Call EndReport()
	'		Exit Function
	'	End If
	'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'
	'	'Select PSTN Required
	'	blnResult = selectValueFromPageList("lstPSTNRequired",strPSTNRequired)
	'	If blnResult= False Then
	'		Environment("Action_Result") = False
	'		Call EndReport()
	'		Exit Function
	'	End If
	'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync


	If objPage.WebList("lstCentralizedBillingReportingRequired").Exist(10) Then
		'Select Centralized Billing Reporting Required
		blnResult = selectValueFromPageList("lstCentralizedBillingReportingRequired",strCentralizedBillingReportingRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstInvoicingOption").Exist Then
		'Select Invoicing Option
		blnResult = selectValueFromPageList("lstInvoicingOption",strInvoicingOption)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Set Is New Inclusive Tariff
	blnResult = setCheckBox("chkIsNewInclusiveTariff", strIsNewInclusiveTariff)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If strIsNewInclusiveTariff = "ON" Then
		'Select Inclusive Country List
		strInclusiveCountryList = objPage.WebList("lstInclusiveCountryList").GetROProperty("all items")
		arrInclusiveCountryList = Split(strInclusiveCountryList,";")
		objPage.WebList("lstInclusiveCountryList").Select arrInclusiveCountryList(3)
		objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(4)
		objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(5)
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstConferencingFacilityRequired").Exist(10) Then
		'Select Conferencing Facility Required
		blnResult = selectValueFromPageList("lstConferencingFacilityRequired",strConferencingFacilityRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	End If

	If objPage.WebList("lstOneVoiceAnywhereRequired").Exist(10) Then
		'Select OneVoice Anywhere Required
		blnResult = selectValueFromPageList("lstOneVoiceAnywhereRequired",strOneVoiceAnywhereRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebEdit("txtConferBridgeTrunk").Exist(10) Then
		blnResult = enterText("txtConferBridgeTrunk",strConferBridgeTrunk)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'----------------------------     For OVAPROVIDE ORDER   ------------------------------------
	If  UCase(strTypeOfOrder) = "OVAPROVIDE" Then
		'-------------------------------Select whethet GVPN exist or Not'-------------------------
		If objPage.WebList("lstGvpnExist").Exist Then
			blnResult = selectValueFromPageList("lstGvpnExist",strGVPNService)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		'-------------------------------------Select  The value for OVA Type'-------------------------------------
		If objPage.WebList("lstOvaType").Exist Then
			blnResult = selectValueFromPageList("lstOvaType",strOVAType)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'-----------------------Enter  Ova License-----------------------------------
		If objPage.WebEdit("txtOvaLicenses").Exist Then
			blnResult = enterText("txtOvaLicenses",strOVALicenses)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'-------------------------Check the  site location-------------------------------

		strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstOvaSiteLocation").GetROProperty("default value")
		Call ReportLog("OvaSiteLocation","OvaSiteLocation  should be populated","OvaSiteLocation  is populated with the value - "&strRetrievedText,"PASS","")

		'------------------------------ Enter OVA sitecode--------------------------------
		If objPage.WebEdit("txtOvasiteCode").Exist Then
			blnResult = enterText("txtOvasiteCode",strOVASiteCode)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
		'--------------------Enter  OVA Block Size-------------------
	
		If objPage.WebEdit("txtOvasitesSize").Exist Then
			blnResult = enterText("txtOvasitesSize",strOVABlockSize )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		'----------------------- Enter OVA block Start Code-----------------
	
		If objPage.WebEdit("txtOvasiteStart").Exist Then
			blnResult = enterText("txtOvasiteStart",strOVABlockStart )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End If

	'======================== GSIP Modify ==============
	If dTypeOfOrder = "GSIPMODIFY" Then
		strConferBridgeIDs = Split(strConferBridgeID, "|")
		strConferVPNCodes = split(strConferVPNCode, "|")

		If objPage.WebEdit("txtConferBridgeID").Exist(10) Then
			blnResult = enterText("txtConferBridgeID",strConferBridgeIDs(0) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtCnferBridgeID2").Exist(10) Then
			blnResult = enterText("txtCnferBridgeID2",strConferBridgeIDs(1) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtCnferBridgeID3").Exist(10) Then
			blnResult = enterText("txtCnferBridgeID3",strConferBridgeIDs(2) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtCnferBridgeID4").Exist(10) Then
			blnResult = enterText("txtCnferBridgeID4",strConferBridgeIDs(3) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtCnferBridgeID5").Exist(10) Then
			blnResult = enterText("txtCnferBridgeID5",strConferBridgeIDs(4) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtConferVPNCode").Exist(10) Then
			blnResult = enterText("txtConferVPNCode",strConferVPNCodes(0) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtConferVPNCode2").Exist(10) Then
			blnResult = enterText("txtConferVPNCode2",strConferVPNCodes(1) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtConferVPNCode3").Exist(10) Then
			blnResult = enterText("txtConferVPNCode3",strConferVPNCodes(2) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
    			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebEdit("txtConferVPNCode4").Exist(10) Then
			blnResult = enterText("txtConferVPNCode4",strConferVPNCodes(3) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
    
		If objPage.WebEdit("txtConferVPNCode5").Exist(10) Then
			blnResult = enterText("txtConferVPNCode5",strConferVPNCodes(4) )
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End if
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

     'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if Navigated to Sites Page
	Set objMsg = objpage.Webelement("webElmSites")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Product Selection","Should be navigated to Sites page on clicking Next Buttton","Not navigated to Sites page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSites")
		Call ReportLog("Product Selection","Should be navigated to Sites page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If
End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
