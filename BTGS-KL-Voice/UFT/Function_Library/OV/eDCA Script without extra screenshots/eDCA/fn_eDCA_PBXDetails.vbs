'****************************************************************************************************************************
' Function Name	 : fn_eDCA_PBXDetails(PBXType,PBXManufacturer,PBXModel,CLIPresentation,PhysicalPortSpeed)
' Purpose	 	 : Function to add  PBX details
' Author	 	 : Vamshi Krishna G
' Creation Date    : 07/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_eDCA_PBXDetails(deDCAOrderId, dTypeOfOrder, dPBXType, dPBXManufacturer, dPBXModel, dCLIPresentation, dPhysicalPortSpeed,_
								dConnectedLinePresentation, dPBXSignallingType, dCRC4, dSynchronisationMode, dIPPBXIPAddress,_
								dPhysicalPortInterfaceType, dDirectAccessType)

	'Declaration of variables
	Dim strPBXType,strPBXManufacturer,strPBXModel,strCLIPresentation,strPhysicalPortSpeed
	Dim strIPPBXIPAddress,strPhysicalPortInterfaceType
	Dim strConnectedLinePresentation,strPBXSignallingType,strCRC4,strSynchronisationMode 'Variables added for GVPN Bundled product

	'Assignment of variables
	strPBXType = dPBXType
	strPBXManufacturer = dPBXManufacturer
	strPBXModel = dPBXModel
	strCLIPresentation = dCLIPresentation
	strPhysicalPortSpeed = dPhysicalPortSpeed 
	strIPPBXIPAddress = dIPPBXIPAddress
	strPhysicalPortInterfaceType = dPhysicalPortInterfaceType
	strConnectedLinePresentation = dConnectedLinePresentation
	strPBXSignallingType = dPBXSignallingType
	strCRC4 = dCRC4
	strSynchronisationMode = dSynchronisationMode
	strTypeOfOrder = dTypeOfOrder
	streDCAOrderId = deDCAOrderId

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebList("lstPBXType").Exist(0) Then
		If objPage.WebList("lstPBXType").GetROProperty("disabled")  = 0 Then
			'Selecting PBXType from drop down list
			blnResult = selectValueFromPageList("lstPBXType",strPBXType)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Else
			strRetrivedText = objPage.WebList("lstPBXType").GetROProperty("Value")	
			Call ReportLog("PBX Details","PBX Type should be populated","PBX Type is populated with the value - " & strRetrivedText,"PASS", "")
		End If
	End If

	strPBXManufacturer = streDCAOrderId & "PBX"
	If objPage.WebEdit("txtPBXManufacturer").Exist(0) Then
		'Entering PBX Manufacturer
		strRetrivedText = objPage.WebEdit("txtPBXManufacturer").GetROProperty("Value")	
		If strRetrivedText <> "" Then
			Call ReportLog("PBX Details","PBX Manufacturer should be populated","PBX Manufacturer is populated with the value - "&strRetrivedText,"PASS","")
		Else
			blnResult = enterText("txtPBXManufacturer",strPBXManufacturer)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End if

	strPBXModel = streDCAOrderId & "PBXM"
	If objPage.WebEdit("txtPBXModel").Exist(0) Then
		'Entering PBX model
		strRetrivedText = objPage.WebEdit("txtPBXModel").GetROProperty("Value")	
		If strRetrivedText <> "" Then
			Call ReportLog("PBX Details","PBX Model should be populated","PBX Model is populated with the value - "&strRetrivedText,"PASS","")
		Else
			blnResult = enterText("txtPBXModel",strPBXModel)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End if

	If objPage.WebList("lstCLIPresentation").Exist(0) Then
		'Selecting CLI Presentation from drop down list
		strRetrivedText = objPage.WebList("lstCLIPresentation").GetROProperty("Value")	
		If strRetrivedText = "Please Select" Then
			blnResult = selectValueFromPageList("lstCLIPresentation",strCLIPresentation)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
        Else
			Call ReportLog("PBX Details","CLI Presentation should be populated","CLIPresentation is populated with the value - "&strRetrivedText,"PASS","")
		End If
	End if

	If objPage.WebList("lstPhysicalPortSpeed").Exist(0) Then
		'Selecting PhysicalPortSpeed from drop down list
		strRetrivedText = objPage.WebList("lstPhysicalPortSpeed").GetROProperty("Value")	
		If strRetrivedText = "Please Select" Then
			blnResult = selectValueFromPageList("lstPhysicalPortSpeed",strPhysicalPortSpeed)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Else
			Call ReportLog("PBX Details","Physical Port Speed should be populated","Physical Port Speed is populated with the value - "&strRetrivedText,"PASS","")
		End If
	End if
	'Entering particulars for GVPN Bundled product
	
	If UCase(strTypeOfOrder) = "GVPNBUNDLEDPROVIDE" or UCase(strTypeOfOrder) = "TDMPROVIDE" or UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or UCase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" or UCase(strTypeOfOrder) = "OB_FULLPSTN_MODIFY" or strTypeOfOrder = "P2PEtherNetProvide"Then

		'Seleting Connected Line Presentation from drop down
		If objPage.WebList("lstConnectedLinePresentation").Exist(0) Then
			strRetrivedText = objPage.WebList("lstConnectedLinePresentation").GetROProperty("Value")	
			If strRetrivedText = "Please Select" Then
				blnResult = selectValueFromPageList("lstConnectedLinePresentation",strConnectedLinePresentation)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
				Call ReportLog("PBX Details","Connected Line Presentation should be populated","Connected Line Presentation is populated with the value - "&strRetrivedText,"PASS","")
			End if
		End if

		'Selecting PBX Signalling Type from drop down
		If objPage.WebList("lstPBXSignallingType").Exist(0) Then
			strRetrivedText = objPage.WebList("lstPBXSignallingType").GetROProperty("Value")	
			If strRetrivedText = "Please Select" Then
				blnResult = selectValueFromPageList("lstPBXSignallingType",strPBXSignallingType)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
				Call ReportLog("PBX Details","PBX Signalling Type should be populated","PBX Signalling Type is populated with the value - "&strRetrivedText,"PASS","")
			End if 
		End if

		'Selectong CRC4 from drop down
		If objPage.WebList("lstCRC4").Exist(0) Then
		strRetrivedText = objPage.WebList("lstCRC4").GetROProperty("Value")	
			If strRetrivedText = "Please Select" Then
				blnResult = selectValueFromPageList("lstCRC4",strCRC4)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
				Call ReportLog("PBX Details","CRC4 should be populated","CRC4 is populated with the value - "&strRetrivedText,"PASS","")		
			End if 
		End if

		If objPage.WebList("lstSynchronisationMode").Exist(0) Then
			strRetrivedText = objPage.WebList("lstSynchronisationMode").GetROProperty("Value")	
			If strRetrivedText = "Please Select" Then
				blnResult = selectValueFromPageList("lstSynchronisationMode",strSynchronisationMode)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
				Call ReportLog("PBX Details","Synchronisation Mode should be populated","Synchronisation Mode is populated with the value - "&strRetrivedText,"PASS","")				
			End if 
		End if
	End If

	'Entering particulars for Ethernet Product and  GVPN bundled
	If UCase(strTypeOfOrder) = "ETHERNETPROVIDE" or UCase(strTypeOfOrder) ="GVPNBUNDLEDPROVIDE" Then
		'Entering the IP PBX IP Address value
		blnResult = enterText("txtIPPBXIPAddress",strIPPBXIPAddress)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function		
		
		'Selecting Physical Port Interface Type from drop down
		blnResult = selectValueFromPageList("lstPhysicalPortInterfaceType", strPhysicalPortInterfaceType)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'##### R41 Requirement Added for Direct AccessType for Internet #### 18-Nov-2015 ######
	'strDirectAccessType = Trim(GetAttributeValue("dDirectAccessType"))
	If UCase(strTypeOfOrder) ="TDMPROVIDE" or UCase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" Or dDirectAccessType = "Internet" Then
		'Selecting Physical Port Interface Type from drop down
		blnResult = selectValueFromPageList("lstPhysicalPortInterfaceType",strPhysicalPortInterfaceType)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if  navigated to OneVoiceConfigureAccessPage
	Set objMsg = objpage.Webelement("webElmOnevoiceConfigureAccess")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("PBX Details","Should be navigated to OnevoiceConfigureAccess page on clicking Next Buttton","Not navigated to OneVoiceConfigureAccess page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmOnevoiceConfigureAccess")
		Call ReportLog("PBXDetails","Should be navigated to OnevoiceConfigureAccess page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
