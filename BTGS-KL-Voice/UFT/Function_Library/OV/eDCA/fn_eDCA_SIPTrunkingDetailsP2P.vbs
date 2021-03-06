'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SIPTrunkingDetails
' Purpose	 	 :  Adding a new trunk group and details for it
' Author	 	 : Vamshi Krishna G
' Creation Date    : 10/06/2013
' Last Modified : 22/11/2013
' Return values :	Nil
'****************************************************************************************************************************	
Public function fn_eDCA_SIPTrunkingDetailsP2P(dTypeOfOrder,deDCAOrderID,dCodec,dSBCTransportProtocol,dUniqueTrunkGroupFriendlyName,dTrunkGroupCACLimit,dTrunkGroupTrunkCallDistribution, dUniqueTrunkFriendlyName, dTrunkCACLimit, dPBXIPaddress,dMainSwitchBoardNumber,dPresentationFlag,dNetworkCLIFlag,dScreenValue,dSiteResiliency,dAddMoreTrunkGroup,dAddMoreTrunkDetail)

	'Decalration of variables
	Dim streDCAOrderID,strTypeOfOrder
	Dim blnResult,strRetrivedText
	Dim strCodec,strSBCTransportProtocol,strTrunkGroupToBeLinked,strUniqueTrunkGroupFriendlyName,strTrunkGroupCACLimit,strTrunkGroupTrunkCallDistribution,strUniqueTrunkFriendlyName,strPBXIPaddress
	Dim strPresentationFlag,strNetworkCLIFlag,strScreenValue,strMainSwitchBoardNumber,strSiteResiliency,strAddMoreTrunkGroup,strAddMoreTrunkDetail

	'Assignment of variables
	streDCAOrderID = deDCAOrderID
	strCodec = dCodec
	strSBCTransportProtocol = dSBCTransportProtocol
	strUniqueTrunkGroupFriendlyName = dUniqueTrunkGroupFriendlyName
	strTrunkGroupCACLimit = dTrunkGroupCACLimit
	strTrunkGroupTrunkCallDistribution = dTrunkGroupTrunkCallDistribution
	strUniqueTrunkFriendlyName = dUniqueTrunkFriendlyName
	strPBXIPaddress = dPBXIPaddress
	strMainSwitchBoardNumber = dMainSwitchBoardNumber
	strPresentationFlag = dPresentationFlag
	strNetworkCLIFlag = dNetworkCLIFlag
	strScreenValue = dScreenValue
	strTypeOfOrder = dTypeOfOrder
	strSiteResiliency = dSiteResiliency
	strAddMoreTrunkGroup = dAddMoreTrunkGroup
	strAddMoreTrunkDetail = dAddMoreTrunkDetail
	strTrunkCACLimit = dTrunkCACLimit
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Capturing the only notification message fpopulated or GVPN Bundled 
	If UCase(strTypeOfOrder) = "GVPNBUNDLEDPROVIDE" or UCase(strTypeOfOrder) = "TDMPROVIDE" Then

		'Retriving the notification message obtained
		strRetrivedText = objPage.WebElement("webElmConfigureVLANNotification").GetROProperty("innertext")
		If strRetrivedText <>" " Then
			Call ReportLog("SIPTrunkingDetails","SIPTrunkingDetails notifiaction message should be retrived","Notification message obtained-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("SIPTrunkingDetails","SIPTrunkingDetails notifiaction message should be retrived","SIPTrunkingDetails notification message not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If

	End If

	'Entering the particualrs if the product type is of GSIP or Ethernet

	If UCase(strTypeOfOrder) = "GSIPPROVIDE" or UCase(strTypeOfOrder) ="ETHERNETPROVIDE"  or UCase(strTypeOfOrder) = "OVAPROVIDE" or UCase(strTypeOfOrder) ="OUTBOUNDPROVIDE" or UCase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" or strTypeOfOrder = "P2PEtherNetProvide" Then

		blnResult = objPage.WebList("lstCodec").Exist
		If blnResult = "True" Then
			'Selecting Codec from drop drown list
			blnResult = selectValueFromPageList("lstCodec",strCodec)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
	
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		blnResult = objPage.WebList("lstSBCTransportProtocol").Exist
		If blnResult = "True" Then
			'Selecting SBC Transport protocol from drop downlist
			blnResult = selectValueFromPageList("lstSBCTransportProtocol",strSBCTransportProtocol)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
	
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'**********************************************************************************************************************************************
		'Adding a new trunk group
		'**********************************************************************************************************************************************	

		Call fn_eDCA_AddTrunkGroupP2P(streDCAOrderID,strCodec,strSBCTransportProtocol,strUniqueTrunkGroupFriendlyName,strTrunkGroupCACLimit,strTrunkGroupTrunkCallDistribution,strUniqueTrunkGroupFriendlyName1,strTrunkGroupCACLimit1,strSiteResiliency,strAddMoreTrunkGroup)
        
		'****************************************************************************************************************************************************
		'Adding a newTrunk detail 
		'***************************************************************************************************************************************************
	
		Call fn_eDCA_AddTrunkDetailP2P(streDCAOrderID,strUniqueTrunkFriendlyName, strTrunkCACLimit, strPBXIPaddress,strMainSwitchBoardNumber,strUniqueTrunkFriendlyName1,strPBXIPaddress1,strMainSwitchBoardNumber1,strSiteResiliency,strAddMoreTrunkDetail)

		'**********************************************************************************************************************************************
		'Trunk Screen List
		'***********************************************************************************************************************************************

		'If  UCase(strTypeOfOrder) = "ETHERNETPROVIDE" or UCase(strTypeOfOrder) = "OVAPROVIDE" or UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or strTypeOfOrder = "P2PEtherNetProvide"Then

		'	'Click on Add New Screen List Button
		'	blnResult = clickButton("btnAddNewScreenList")
		'	If blnResult = False Then
		'		Environment.Value("Action_Result")=False
		'		Call EndReport()
		'		Exit Function
		'	End If

		'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			'Select Trunk Name from drop down list
		'	strTrunkName = objPage.WebList("lstTrunkName").GetROProperty("all items")
		'	arrTrunkName = Split(strTrunkName,";")
		'	objPage.WebList("lstTrunkName").Select arrTrunkName(0)

		'	'Selecting Presentation flag from drop down
		'	blnResult = selectValueFromPageList("lstPresentationFlag",strPresentationFlag)
		'	If blnResult = False Then
		'		Environment.Value("Action_Result")=False
		'		Call EndReport()
		'		Exit Function
		'	End If


		'	'Selecting NetworkCLI flag from drop down
		'	blnResult = selectValueFromPageList("lstNetworkCLIFlag",strNetworkCLIFlag)
		'	If blnResult = False Then
		'		Environment.Value("Action_Result")=False
		'		Call EndReport()
		'		Exit Function
		'	End If

			'Entering Screen Value into the text box
		'	blnResult = enterText("txtScreenValue",strScreenValue)
		'	If blnResult = False Then
		'		Environment.Value("Action_Result")=False
		'		Call EndReport()
		'		Exit Function
		'	End If
		'End If

		'*******************************************************************************************************************************************

		'Click on Save Button
		blnResult = clickButton("btnSave")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to additional features details page 
	Set objMsg = objpage.Webelement("webElmAdditionalFeaturesDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Not navigated to AdditionalFeaturesDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else	
		strMessage = GetWebElementText("webElmAdditionalFeaturesDetails")
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
