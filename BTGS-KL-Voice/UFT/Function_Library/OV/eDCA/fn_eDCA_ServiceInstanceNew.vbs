Public Function fn_eDCA_ServiceInstanceNew(ByVal TypeOfOrder, ByVal ServiceType, ByVal SubServiceType, ByVal NonStandardType,_
			ByVal VoiceVPNRequired, ByVal PSTNRequired, ByVal DirectAccessType, ByVal NoOfChannels, ByVal ClassicServiceID,_
			ByVal DirectAccessTariff, ByVal SLACategory)

	'Variable Declaration
	Dim strRetrievedText
	Dim intCounter
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on AddNewOnevoiceService button
	If objPage.WebButton("btnAddNewOnevoiceService").Exist Then
		blnResult = clickButton("btnAddNewOnevoiceService")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select service type from dropdownlist
	blnResult = selectValueFromPageList("lstServiceType", ServiceType)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Select  subservice type from dropdownlist
	blnResult = selectValueFromPageList("lstSubServiceType", SubServiceType)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Non Standard Option
	If objPage.WebList("lstnonstandardtype").Exist(5) Then
		blnResult = selectValueFromPageList("lstnonstandardtype", NonStandardType)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
	If objPage.WebList("lstVoiceVPNRequired").Exist(10) Then
		'Selecting Voice VPN Required from drop down
		blnResult = selectValueFromPageList("lstVoiceVPNRequired", VoiceVPNRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstPSTNRequired").Exist(10) Then
		'Select PSTN Required
		blnResult = selectValueFromPageList("lstPSTNRequired", PSTNRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstDirectAccessType").Exist(10) Then
		'Select  DirectAccessType from drop down list
		blnResult = selectValueFromPageList("lstDirectAccessType", DirectAccessType)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Number of Channels
	If objPage.WebEdit("txtNumberofChannels").Exist(5) Then
		blnResult = enterText("txtNumberofChannels", NoOfChannels)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	End If
	
	'If Direct AccessType is Shared
	If DirectAccessType = "Shared Access" Or DirectAccessType = "Remote Site" Then
		blnResult = enterText("txtClassicServiceID", ClassicServiceID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If			

	If objPage.WebEdit("txtNoOfLeasedLines1stAccess").Exist(10) Then
		'Checking number of leased lines
		strRetrievedText = objPage.WebEdit("txtNoOfLeasedLines1stAccess").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is populated with the value - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("NoOfLeasedLines1stAccess","NoOfLeasedLines1stAccess should be populated","NoOfLeasedLines1stAccess is not populated","FAIL","TRUE")
			Envrironment("Action_Result") = False : Exit Function
		End If
	End If

	If objPage.WebList("lstDirectAccessTariff").Exist(10) Then
		'Selecting DirectAccessTariff from drop down list
		blnResult = selectValueFromPageList("lstDirectAccessTariff", DirectAccessTariff)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End if
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstSLACategory").Exist(10) Then
		'Selecting SLA category from drop down list
		blnResult = selectValueFromPageList("lstSLACategory",SLACategory)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End if
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 5

	If objPage.WebButton("btnSave").Exist Then
		'Clicking on Save button
		blnResult =  clickButton("btnSave")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 5

	'A new one voice service record would be created retriving the service Instance ID details
	If objPage.WebButton("btnSIEdit").Exist Then
		'Clicking on Edit corresponding to product type "one voice" created
		blnResult =  clickButton("btnSIEdit")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 5
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	If objPage.WebButton("btnNext").Exist Then
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	For intCounter = 1 To 5
		If objpage.WebElement("webElmNetworkConnectionDetails").Exist(5) Then
			Exit For
		Else
			objPage.WebButton("btnNext").Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	Next

	'Check if navigated to Network Connection
	Set objMsg = objpage.WebElement("webElmNetworkConnectionDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Not navigated to NetworkConnectionDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmNetworkConnectionDetails")
		Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function
