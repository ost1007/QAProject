'==============================================================================================================================
' Description: On Product Selection for Conferencing Facility Required = Yes Scenario
' Author: Nagaraj Venkobasa || 06-Feb-2016 || v1.0
'==============================================================================================================================
Public function fn_eDCA_ProdSelectOneVoiceDet_Conferencing(TypeOfOrder, eDCAOrderId, ProductName, VoiceTrafficReportsRequested,_
	CentralizedBillingReportingRequired, InvoicingOption, IsNewInclusiveTariff, ConferencingFacilityRequired, ConferencingType, ConferencingSiteLocation,_
	ConferBridgeTrunk, ConferBridgeID, ConferVPNCode, ConferAccountID, ConferAccountName, OneVoiceAnywhereRequired)

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Product Selection
	If objPage.WebList("lstProductName").Exist(60) Then
		strEnabled = objPage.WebList("lstProductName").GetROProperty("disabled") 
		If strenabled = 1 Then
			strListValue = objPage.WebList("lstProductName").GetROProperty("Value") 
			Call ReportLog("Product Name","Product Name List Should be Enaled","Product Name List default value is -  "&strListValue,"PASS","")
		Else
			blnResult = selectValueFromPageList("lstProductName", ProductName)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End If

	'Enter Capacity Planning reference number
	strCapacityPlanningReferenceNumber = eDCAOrderId & "CRPN"
	If objPage.WebEdit("txtCapacityPlanningReferenceNumber").Exist(10) Then
		strRetrivedText = objPage.WebEdit("txtCapacityPlanningReferenceNumber").GetROProperty("Value")
		If  strRetrivedText = "" Then
			blnResult = enterText("txtCapacityPlanningReferenceNumber",strCapacityPlanningReferenceNumber)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Else
			Call ReportLog("Capacity Planning Reference Number","Capacity Planning Reference Number should display","Capacity Planning Reference Number is: -"&strRetrivedText ,"Information", True)
		End If
	End If
	
	'Select Voice Traffic Reports Requested
	If objPage.WebList("lstVoiceTrafficReportsRequested").Exist(10) Then
		blnResult = selectValueFromPageList("lstVoiceTrafficReportsRequested", VoiceTrafficReportsRequested)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Select Centralized Billing Reporting Required
	If objPage.WebList("lstCentralizedBillingReportingRequired").Exist(10) Then
		blnResult = selectValueFromPageList("lstCentralizedBillingReportingRequired", CentralizedBillingReportingRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Select Invoicing Option
	If objPage.WebList("lstInvoicingOption").Exist(10) Then
		blnResult = selectValueFromPageList("lstInvoicingOption", InvoicingOption)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Set Is New Inclusive Tariff
	blnResult = setCheckBox("chkIsNewInclusiveTariff", IsNewInclusiveTariff)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Select Inclusive Country List
	If IsNewInclusiveTariff = "ON" Then
		strInclusiveCountryList = objPage.WebList("lstInclusiveCountryList").GetROProperty("all items")
		arrInclusiveCountryList = Split(strInclusiveCountryList,";")
		objPage.WebList("lstInclusiveCountryList").Select arrInclusiveCountryList(2)
		objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(3)
		objPage.WebList("lstInclusiveCountryList").ExtendSelect arrInclusiveCountryList(5)
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Select Conferencing Facility Required
	If objPage.WebList("lstConferencingFacilityRequired").Exist(10) Then
		blnResult = selectValueFromPageList("lstConferencingFacilityRequired", ConferencingFacilityRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If objPage.WebEdit("txtConferBridgeTrunk").Exist(10) Then
		blnResult = enterText("txtConferBridgeTrunk", ConferBridgeTrunk)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If UCase(ConferencingFacilityRequired) = "YES" Then
		
		'Select Conferencing Type
		blnResult = selectValueFromPageList("lstConferencingType", ConferencingType)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		'Select Conferencing Site Location
		blnResult = selectValueFromPageList("lstConferencingSiteLocation", ConferencingSiteLocation)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'================================= Set Conferencing Bridge ID and VPN Code ========================================= 
		With objPage.WbfGrid("html id:=UsrTahitiProductSelection_tblconfbridgevpn", "index:=0")
				If Not .Exist(60) Then
					Call ReportLog("Conferencing", "Conferencing Bridge ID and VPN Code containing table should exist", "Conferencing Bridge ID and VPN Code containing table doesn't exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
				
				arrConferencingBridgeIDs = Split(ConferBridgeID, "|")
				arrConferencingCPNCode = Split(ConferVPNCode, "|")
				If UBound(arrConferencingBridgeIDs) <> UBound(arrConferencingCPNCode) Then
					Call ReportLog("Conferencing", "ConferBridgeID and ConferVPNCode Split content should match", "ConferBridgeID and ConferVPNCode Split content doesn't match</RR>" &_
					"ConferBridgeID - " & UBound(arrConferencingBridgeIDs) + 1 & "</BR>" & "ConferVPNCode - " & UBound(arrConferencingCPNCode) + 1, "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
				
				intRows = .RowCount()
				For intCounter = LBound(arrConferencingBridgeIDs) To UBound(arrConferencingCPNCode)
					.SetCellData (intCounter + 2), 2, arrConferencingBridgeIDs(intCounter)
					.SetCellData (intCounter + 2), 3, arrConferencingCPNCode(intCounter)
					If (intCounter + 2) >  intRows Then Exit For
				Next '#intCounter
		End With '#tblconfbridgevpn
		'================================= End Conferencing Bridge ID and VPN Code ========================================= 
		
		'================================= Set Conferencing Account ID and Name ========================================= 
		With objPage.WbfGrid("html id:=UsrTahitiProductSelection_tblConfAccDetails", "index:=0")
				If Not .Exist(60) Then
					Call ReportLog("Conferencing", "Conferencing Account ID and Account Name containing table should exist", "Conferencing Account ID and Account Name containing table doesn't exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
				
				arrConferencingAccountID = Split(ConferAccountID, "|")
				arrConferencingAccountName = Split(ConferAccountName, "|")
				If UBound(arrConferencingAccountID) <> UBound(arrConferencingAccountName) Then
					Call ReportLog("Conferencing", "ConferAccountID and ConferAccountName Split content should match", "ConferAccountID and ConferAccountName Split content doesn't match</RR>" &_
					"ConferAccountID - " & UBound(arrConferencingAccountID) + 1 & "</BR>" & "ConferAccountName - " & UBound(arrConferencingAccountName) + 1, "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
				
				intRows = .RowCount()
				For intCounter = LBound(arrConferencingAccountID) To UBound(arrConferencingAccountID)
					.SetCellData (intCounter + 2), 2, arrConferencingAccountID(intCounter)
					.SetCellData (intCounter + 2), 3, arrConferencingAccountName(intCounter)
					If (intCounter + 2) >  intRows Then Exit For
				Next '#intCounter
				'================================= End Conferencing Account ID and Name ========================================= 
			End With '#tblConfAccDetails
	End If '#ConferencingFacilityRequired

	'Select OneVoice Anywhere Required
	If objPage.WebList("lstOneVoiceAnywhereRequired").Exist(10) Then
		If UCase(OneVoiceAnywhereRequired) = "YES" Then
			Call ReportLinerMessage("One Voice Anywhere = [Yes] is not handled in this function")
			Environment("Action_Result") = False : Exit Function
		End If
		
		blnResult = selectValueFromPageList("lstOneVoiceAnywhereRequired", OneVoiceAnywhereRequired)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

     'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if Navigated to Sites Page
	Set objMsg = objpage.Webelement("webElmSites")
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
