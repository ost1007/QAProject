'****************************************************************************************************************************
' Function Name	 : fncModifyProductSelectionOneVoiceDetails
' Purpose	 	 : Function to enter One Voice details in Product Selection Page
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 19/08/2013
' Parameters	 :
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_ModifyProductSelectionOneVoiceDetails(TypeOfOrder, eDCAOrderId, CapacityPlanningReferenceNumber, VoiceTrafficReportsRequested, CentralizedBillingReportingRequired,_
	InvoicingOption, IsNewInclusiveTariff, ConferencingFacilityRequired, GVPNService, OVAType, OVALicenses, OVASiteCode, OVABlockStart, OVABlockSize,_
	ConferBridgeID, ConferVPNCode, ConferBridgeTrunk)

	'Declaration of variables
	Dim streDCAOrderId,strCapacityPlanningReferenceNumber,strVoiceVPNRequired,strPSTNRequired
	Dim strCentralizedBillingReportingRequired,strInvoicingOption
	Dim strIsNewInclusiveTariff,strInclusiveCountryList,strConferencingFacilityRequired
	Dim strMessage
	Dim arrInclusiveCountryList
	Dim objMsg,blnResult
	Dim strOVAType,strOVALicenses,strOVASiteLocation,strOVASiteCode,strOVABlockStart,strOVABlockSize

	'Assignment of values to variables
	streDCAOrderId = eDCAOrderId
	strVoiceTrafficReportsRequested = VoiceTrafficReportsRequested
	'strVoiceVPNRequired = VoiceVPNRequired
	'strPSTNRequired = PSTNRequired
	strCentralizedBillingReportingRequired = CentralizedBillingReportingRequired
	strInvoicingOption = InvoicingOption
	strIsNewInclusiveTariff = IsNewInclusiveTariff
	strConferencingFacilityRequired = ConferencingFacilityRequired
	strConferenceType= ConferenceType
	strConferenceSite =	ConferenceSite
	strConferBridgeTrunk = ConferBridgeTrunk
	strConferBridgeID = ConferBridgeID
	strConferVPNCode = ConferVPNCode
	strCnferBridgeID2 = CnferBridgeID2
	strConferVPNCode2 = ConferVPNCode2
	strConferAcntId = ConferAcntId
	strConferAcntName = ConferAcntName
	strOVAType = OVAType
	strOVALicenses = OVALicenses
	strOVASiteLocation = OVASiteLocation
	strOVASiteCode = OVASiteCode
	strOVABlockStart = OVABlockStart
	strOVABlockSize = OVABlockSize
	strGVPNService = GVPNService

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retrive the product name details
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstProductName").GetROProperty("value")
	Call ReportLog("ProductSelection","Product name should be retrived as BT ONEVOICE","Product name retrived - "&strRetrivedText,"PASS"," ")
	
	'Enter Capacity Planning reference number
   	If CapacityPlanningReferenceNumber <> "" Then
		strCapacityPlanningReferenceNumber = streDCAOrderId&CapacityPlanningReferenceNumber
		blnResult = enterText("txtCapacityPlanningReferenceNumber",strCapacityPlanningReferenceNumber)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	'Select Voice Traffic Reports Requested
	If strVoiceTrafficReportsRequested <>"" Then
		blnResult = selectValueFromPageList("lstVoiceTrafficReportsRequested",strVoiceTrafficReportsRequested)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Select Centralized Billing Reporting Required
	If strCentralizedBillingReportingRequired <> "" Then
		blnResult = selectValueFromPageList("lstCentralizedBillingReportingRequired",strCentralizedBillingReportingRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Select Invoicing Option
	If strInvoicingOption<>"" Then
		blnResult = selectValueFromPageList("lstInvoicingOption",strInvoicingOption)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Set Is New Inclusive Tariff
	If strIsNewInclusiveTariff <>"" Then
		blnResult = setCheckBox("chkIsNewInclusiveTariff", strIsNewInclusiveTariff)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If strIsNewInclusiveTariff = "ON" Then
			'Select Inclusive Country List
			strInclusiveCountryList = objPage.WebList("lstInclusiveCountryList").GetROProperty("all items")
			arrInclusiveCountryList = Split(strInclusiveCountryList,";")
			objPage.WebList("lstInclusiveCountryList").Select arrInclusiveCountryList(0)
			objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(1)
			objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(2)
			objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(3)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

	End If

	If UCase(TypeOfOrder) = "CONFERMODIFY" Then
		'Retrive the value for  conference Facility Required
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstConferencingFacilityRequired").GetROProperty("value")
		Call ReportLog("Product Selection","Conference Facility Required should be retrived as Yes","Conference Facility Required retrived -"&strRetrivedText,"PASS","")
		'Retrive the value for Conference Type
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstConferType").GetROProperty("value")
		Call ReportLog("Product Selection","lstConferType value  should be retrived ","lstConferType value  retrived -"&strRetrivedText,"PASS","")
		'Retrive the value for Conference Site
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstConferSite").GetROProperty("value")
		Call ReportLog("Product Selection","lstConferSite value  should be retrived ","lstConferSite value is  retrived -"&strRetrivedText,"PASS","")

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'----------------------------------------Passing  and modifying Conference detail values to the correspond Edit Box----------------------------

		blnResult=entertext("txtConferBridgeTrunk",strConferBridgeTrunk)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtConferBridgeID",strConferBridgeID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtConferVPNCode",strConferVPNCode)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtCnferBridgeID2", strCnferBridgeID2)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtConferVPNCode2", strConferVPNCode2)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtConferAcntId", strConferAcntId)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult=entertext("txtConferAcntName", strConferAcntName)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If UCase(TypeOfOrder) = "GSIPMODIFY" or  UCase(TypeOfOrder) = "GVPNBUNDLEDMODIFY" Then
		'Select Conferencing Facility Required
		If strConferencingFacilityRequired <> "" Then
			blnResult = selectValueFromPageList("lstConferencingFacilityRequired",strConferencingFacilityRequired)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End If

     'Select OneVoice Anywhere Required
	strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstOneVoiceAnywhereRequired").GetROProperty("value")
	Call ReportLog("Product Selection","OneVoiceAnywhereRequired should be retrived as No","OneVoiceAnywhereRequired retrived -"&strRetrivedText,"PASS","")

	If  UCase(TypeOfOrder) = "OVAMODIFY" Then
			'-------------------------------Select whethet GVPN exist or Not'-------------------------
			If strGVPNService <> "" Then
				blnResult = selectValueFromPageList("lstGvpnExist",strGVPNService)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
	
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
			'-------------------------------------Select  The value for OVA Type'-------------------------------------
			If strOVAType <> "" Then
					blnResult = selectValueFromPageList("lstOvaType",strOVAType)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
			'-----------------------Enter  Ova License-----------------------------------
			If strOVALicenses <> "" Then
					blnResult = enterText("txtOvaLicenses",strOVALicenses)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
			'-------------------------Check the  site location-------------------------------
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstOvaSiteLocation").GetROProperty("default value")
			Call ReportLog("Floor No","Floor No  should be populated","Floor No  is populated with the value - "&strRetrievedText,"PASS","")

			'------------------------------ Enter OVA sitecode--------------------------------
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOvasiteCode").GetROProperty("default value")
			Call ReportLog("OvasiteCode","OvasiteCode  should be populated","OvasiteCode  is populated with the value - "&strRetrievedText,"PASS","")	

			'--------------------Enter  OVA Block Size-------------------
			If strOVABlockSize <> "" Then
				blnResult = enterText("txtOvasitesSize",strOVABlockSize )
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			'----------------------- Enter OVA block Start Code-----------------
			If strOVABlockStart <> "" Then
					blnResult = enterText("txtOvasiteStart",strOVABlockStart )
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
	
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

    'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Check if Navigated to Sites Page
	Set objMsg = objpage.Webelement("webElmSites")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Product Selection","Should be navigated to Sites page on clicking Next Buttton","Not navigated to Sites page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmSites")
		Call ReportLog("Product Selection","Should be navigated to Sites page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************