'****************************************************************************************************************************
' Function Name	 : fn_eDCA_VPNConnection()
' Purpose	 	 : Function to add a new VPN  connection details
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 06/06/2013
' Return Values	 : Not Applicable
'******************************************************************************************************************************
Public function fn_eDCA_VPNConnection(deDCAOrderId,dVPNFriendlyName,dVPNDefinitionIPVersions,dVPNConnectionIPVersions,dRoutingType)

   'Variable declaration
    Dim blnResult
    Dim ieOk
    Dim strVPNFriendlyName,strVPNDefinitionIPVersions,strVPNConnectionIPVersions,strRoutingType,strRetrievedText
	Dim objMsg

	'Assignment of variables
	strVPNFriendlyName = dVPNFriendlyName
	strVPNDefinitionIPVersions = dVPNDefinitionIPVersions
	strVPNConnectionIPVersions = dVPNConnectionIPVersions
	strRoutingType = dRoutingType
	streDCAOrderId = deDCAOrderId

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clikcing on VPN Friendly Name
	strVPNFriendlyName = streDCAOrderId&strVPNFriendlyName
	If objPage.WebEdit("txtVPNFriendlyName").Exist Then
		blnResult = enterText("txtVPNFriendlyName",strVPNFriendlyName)
		If blnResult =False Then
			Call ReportLog("VPN Friendly Name","VPN Friendly Name should be entered","VPN Friendly Name is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

    If objPage.WebList("lstVPNDefinitionIPVersions").Exist Then
		'Selecting VPN Definition IP Versions in dropdown list 
		blnResult = selectValueFromPageList("lstVPNDefinitionIPVersions",strVPNDefinitionIPVersions)
		If blnResult =False Then
			Call ReportLog("VPNDefinitionIPVersions","VPNDefinitionIPVersions should be entered","VPNDefinitionIPVersions is not entered","FALSE","TRUE")
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

    If objPage.WebList("lstVPNConnectionIPVersions").Exist Then
		'Selecting VPN Connection IP Versions in dropdown list 
		blnResult = selectValueFromPageList("lstVPNConnectionIPVersions",strVPNConnectionIPVersions)
		If blnResult =False Then
			Call ReportLog("VPNConnectionIPVersions","VPNConnectionIPVersions should be entered","VPNConnectionIPVersions is not entered","FALSE","TRUE")
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

    If objPage.WebList("lstRoutingType").Exist Then
		'Selecting Routing Type in dropdown list 
		blnResult = selectValueFromPageList("lstRoutingType",strRoutingType)
		If blnResult =False Then
			Call ReportLog("RoutingType","RoutingType should be entered","RoutingType is not entered","FALSE","TRUE")
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstBTMPLSBGPPrefixRangeName").Exist Then
		'Check BTMPLSBGPPrefixRangeName and Multicast Services
		strRetrievedText = objPage.WebList("lstBTMPLSBGPPrefixRangeName").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("BTMPLSBGPPrefixRangeName","BTMPLSBGPPrefixRangeName should be populated","BTMPLSBGPPrefixRangeName is populated with the value - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("BTMPLSBGPPrefixRangeName","BTMPLSBGPPrefixRangeName should be populated","BTMPLSBGPPrefixRangeName is not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	If objPage.WebList("lstMulticastServices").Exist Then
		strRetrievedText = objPage.WebList("lstMulticastServices").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("MulticastServices","MulticastServices should be populated","MulticastServices is populated with the value - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("MulticastServices","MulticastServices should be populated","MulticastServices is not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	If objPage.WebButton("btnNext").Exist Then
		'Click on Next Button
		blnResult = clickButton("btnNext")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	Set objMsg = objpage.Webelement("webElmDSCPCoS")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("VPNConnection","Should be navigated to DSCPCoS page on clicking Next Buttton","Not navigated to DSCP CoS page on clicking Next Buttton To fetch MPLS VPNID","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If
	
	If objPage.WebButton("btnPrev").Exist(120) Then
		'Click on Next Button
		blnResult = clickButton("btnPrev")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	Set objMsg = objpage.WebElement("webElmVPNConnection")
    	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("VPN","Should be navigated to VPN Connection page on clicking Edit Buttton","Not navigated to VPN connection page on clicking Edit Buttton","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Capture MPLS VPN Name
	sourceindex = Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("outertext:=MSS ID / VPN ID", "index:=0").GetROProperty("source_index")
	strMPLSVPNValue = Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("source_index:=" & (sourceindex + 3)).GetROProperty("innertext")
	If strMPLSVPNValue = "" Then
		Call ReportLog("Capture MPLS VPN Name", "MPLS VPN Name should be capture", "MPLS VPN Name could not be captured", "INFORMATION", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Environment.Value("MPLSVPNName") = strMPLSVPNValue
		Call ReportLog("Capture MPLS VPN Name", "MPLS VPN Name should be capture", "MPLS VPN Name is found to be <B>[ " & strMPLSVPNValue & " ]<B>", "INFORMATION", True)
		Call SetXLSOutValue(Environment.Value("TestDataPath"), Environment("StrTestDataSheet"), StrTCID, "dMPLSVPNID", strMPLSVPNValue)
	End If
		
		
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebButton("btnNext").Exist Then
		'Click on Next Button
		blnResult = clickButton("btnNext")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to DSCP COS Page
	Set objMsg = objpage.Webelement("webElmDSCPCoS")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("VPNConnection","Should be navigated to DSCPCoS page on clicking Next Buttton","Not navigated to DSCP CoS page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmDSCPCoS")
		Call ReportLog("VPNConnection","Should be navigated to DSCPCoS page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If	

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
