'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SIPTrunkingDetails
' Purpose	 	 :  Adding a new trunk group and details for it
' Author	 	 : Vamshi Krishna G
' Creation Date    : 10/06/2013
' Last Modified : 22/11/2013
' Modified		: Nagaraj V || 07/01/2014 ||Added one Extra Parameter to add the MPLS VPN Name
' Return values :	Nil
'****************************************************************************************************************************	
Public function fn_eDCA_SIPTrunkingDetails(dTypeOfOrder, deDCAOrderId, dCodec, dSBCTransportProtocol, dUniqueTrunkGroupFriendlyName, dTrunkGroupCACLimit, dTrunkGroupTrunkCallDistribution, dUniqueTrunkFriendlyName, dTrunkCACLimit, dPBXIPaddress, dMainSwitchBoardNumber, dPresentationFlag, dNetworkCLIFlag, dScreenValue, dSiteResiliency, dAddMoreTrunkGroup, dAddMoreTrunkDetail, dMPLSVPNID, dUniqueTrunkGroupFriendlyName1, dTrunkGroupCACLimit1, dUniqueTrunkFriendlyName1, dTrunkCACLimit1, dPBXIPaddress1, dMainSwitchBoardNumber1, dIsRTPIPSameAsPBX)

	'Decalration of variables
	Dim streDCAOrderID,strTypeOfOrder
	Dim blnResult,strRetrivedText
	Dim strCodec, strSBCTransportProtocol, strTrunkGroupToBeLinked, strUniqueTrunkGroupFriendlyName, strTrunkGroupCACLimit, strTrunkGroupTrunkCallDistribution, strUniqueTrunkFriendlyName, strPBXIPaddress, strPresentationFlag, strNetworkCLIFlag, strScreenValue, strMainSwitchBoardNumber, strSiteResiliency, strAddMoreTrunkGroup, strAddMoreTrunkDetail

	'Assignment of variables
	streDCAOrderID = deDCAOrderId
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
	strMPLSVPNValue = dMPLSVPNID
	strUniqueTrunkGroupFriendlyName1 = dUniqueTrunkGroupFriendlyName1
	strTrunkGroupCACLimit1 = dTrunkGroupCACLimit1
	strUniqueTrunkFriendlyName1 = dUniqueTrunkFriendlyName1
	strPBXIPaddress1 = dPBXIPaddress1
	strMainSwitchBoardNumber1 = dMainSwitchBoardNumber1
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACLimit1 = dTrunkCACLimit1

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Capturing the only notification message fpopulated or GVPN Bundled 
	If UCase(strTypeOfOrder) = "GVPNBUNDLEDPROVIDE" OR UCase(strTypeOfOrder) = "GVPNBUNDLEDPROVIDE" OR UCase(strTypeOfOrder) = "TDMPROVIDE" Then

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
	Select Case UCase(strTypeOfOrder)
		Case "GSIPPROVIDE", "ETHERNETPROVIDE", "OVAPROVIDE", "OUTBOUNDPROVIDE", "P2PETHERNETPROVIDE", "MPLSPLUSIA" 'GVPNUNBUNDLEDPROVIDE Removed in R41
			blnResult = objPage.WebList("lstCodec").Exist
			If blnResult Then
				'Selecting Codec from drop drown list
				blnResult = selectValueFromPageList("lstCodec",strCodec)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
			
			blnResult = objPage.WebList("lstSBCTransportProtocol").Exist
			If blnResult Then
				'Selecting SBC Transport protocol from drop downlist
				blnResult = selectValueFromPageList("lstSBCTransportProtocol",strSBCTransportProtocol)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					blnResult = Objpage.WebEdit("txtMplsVpnName").Exist
					If blnResult Then
						'Selecting SBC Transport protocol from drop downlist
						If strMPLSVPNValue = "" Then strMPLSVPNValue = deDCAOrderId & "VPN"
						blnResult =enterText("txtMplsVpnName",strMPLSVPNValue)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End if
					Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
	
			'**********************************************************************************************************************************************
			'Adding a new trunk group
			'**********************************************************************************************************************************************	
	
			Call fn_eDCA_AddTrunkGroup(streDCAOrderID,strCodec,strSBCTransportProtocol,strUniqueTrunkGroupFriendlyName,strTrunkGroupCACLimit,strTrunkGroupTrunkCallDistribution,strUniqueTrunkGroupFriendlyName1,strTrunkGroupCACLimit1,strSiteResiliency,strAddMoreTrunkGroup)
				If Not Environment("Action_Result") Then Exit Function
	        
			'****************************************************************************************************************************************************
			'Adding a newTrunk detail 
			'***************************************************************************************************************************************************
			Call fn_eDCA_AddTrunkDetail(streDCAOrderID, strUniqueTrunkFriendlyName, strTrunkCACLimit, strPBXIPaddress, strMainSwitchBoardNumber, strUniqueTrunkFriendlyName1, strTrunkCACLimit1, strPBXIPaddress1, strMainSwitchBoardNumber1, strSiteResiliency, strAddMoreTrunkDetail)
				If Not Environment("Action_Result") Then Exit Function
		
				
			'**********************************************************************************************************************************************
			'Trunk Screen List
			'***********************************************************************************************************************************************
	
			'If  Instr(UCase(strTypeOfOrder), "PROVIDE") > 0 OR UCase(strTypeOfOrder) = "MPLSPLUSIA" Then
			'	'= "ETHERNETPROVIDE" or UCase(strTypeOfOrder) = "OVAPROVIDE" or UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or strTypeOfOrder = "P2PEtherNetProvide"
			'	
			'	'Click on Add New Screen List Button
			'	blnResult = clickButton("btnAddNewScreenList")
			'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
			'	'Select Trunk Name from drop down list
			'	strTrunkName = objPage.WebList("lstTrunkName").GetROProperty("all items")
			'	arrTrunkName = Split(strTrunkName,";")
			'	objPage.WebList("lstTrunkName").Select arrTrunkName(0)
	
			'	'Selecting Presentation flag from drop down
			'	blnResult = selectValueFromPageList("lstPresentationFlag",strPresentationFlag)
			'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'	'Selecting NetworkCLI flag from drop down
			'	blnResult = selectValueFromPageList("lstNetworkCLIFlag",strNetworkCLIFlag)
			'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'	'Entering Screen Value into the text box
			'	blnResult = enterText("txtScreenValue",strScreenValue)
			'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
			'	'Click on Save Button
			'	blnResult = clickButton("btnScreenListSave")
			'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
			'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			'End If
			'*******************************************************************************************************************************************
	End Select
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to additional features details page 
	Set objMsg = objpage.Webelement("webElmAdditionalFeaturesDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Not navigated to AdditionalFeaturesDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmAdditionalFeaturesDetails")
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
