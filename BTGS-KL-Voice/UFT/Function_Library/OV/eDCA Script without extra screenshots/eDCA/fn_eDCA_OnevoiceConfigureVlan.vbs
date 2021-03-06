'****************************************************************************************************************************
' Function Name	 : fn_eDCA_OnevoiceConfigureVlan
' Purpose	 	 :  Checking the presence of  ConfigureVlan avialability and entering the details if required
' Author	 	 : Vamshi Krishna G
' Creation Date    : 10/06/2013
' Return values :	Nil
'****************************************************************************************************************************		
Public function fn_eDCA_OnevoiceConfigureVlan(dTypeOfOrder,dBandwidthEthernet)

	'Declaration of variables
	Dim objMsg,strMessage
	Dim strBandwidthEthernet

	'Assignment of variables
	strBandwidthEthernet = dBandwidthEthernet

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Entering particulars for Ethernet Product
	
	If  UCase(dTypeOfOrder) = "ETHERNETPROVIDE" or dTypeOfOrder = "P2PEtherNetProvide" OR  UCase(dTypeOfOrder) = "ETHERNETMODIFY" Then

		If CInt(objPage.WebButton("btnAddVLAN").GetROProperty("disabled")) = 1 Then
			'Click on Add edit button
			blnResult = clickButton("btnEdit")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Else
			'Click on Add VLAN button
			blnResult = clickButton("btnAddVLAN")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync		
		End If	
		

		'Select Bandwidth from drop down
		blnResult = selectValueFromPageList("lstBandwidthEthernet",strBandwidthEthernet)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Click on Save Button
		blnResult = clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	End If

	'Checking the VLAN  notrfication message for GSIP Product and TDM  product
	If  UCase(dTypeOfOrder) = "GSIPPROVIDE" or UCase(dTypeOfOrder) = "TDMPROVIDE" or UCase(dTypeOfOrder) = "OVAPROVIDE" Then
		'Retrive alert message in the browser 
		strRetrivedText = objPage.WebElement("webElmConfigureVLANNotification").GetROProperty("innertext")
		If strRetrivedText<> "" Then
			Call ReportLog("ConfigureVLANNotification","ConfigureVLANNotification should be retrived","ConfigureVLANNotification retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("ConfigureVLANNotification ","ConfigureVLANNotification should be retrived","ConfigureVLANNotification is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Clicikng on Next button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to SIPTrunkingDetails page
	Set objMsg = objpage.Webelement("webElmSIPTrunkingDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("OnevoiceConfigureVlan","Should be navigated to SIPTrunkingDetails page on clicking Next Buttton","Not navigated to SIPTrunkingDetailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSIPTrunkingDetails")
		Call ReportLog("OnevoiceConfigureVlan","Should be navigated to SIPTrunkingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
