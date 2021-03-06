'****************************************************************************************************************************
' Function Name	 : fn_eDCA_NetworkConnectionDetails
' Purpose	 	 : Function to enter Network Connection Details
' Author	 	 : Vamshi Krishna G
' Creation Date    : 07/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_NetworkConnectionDetails(dTypeOfOrder, dOneVoicePoPRegion, dCascadedIntegratedRouter, dOnNetRoutingType, dDefaultPublicNumber, dSignalingtype, dPhoenixPop, dNoOfVoiceChannels, dVoiceVPNRequired)

	'Declaration of variables
	Dim strOneVoicePoPRegion,strCascadedIntegratedRouter,strDefaultPublicNumber,strOnNetRoutingType,strSignalingtype,strPhoenixPop,strNoOfVoiceChannels,strTypeOfOrder
	Dim blnResult,objMsg

	'Assignment of variables
	strOneVoicePoPRegion = dOneVoicePoPRegion
	strCascadedIntegratedRouter = dCascadedIntegratedRouter
	strDefaultPublicNumber = dDefaultPublicNumber
	strOnNetRoutingType = dOnNetRoutingType
	strSignalingtype = dSignalingtype
	strPhoenixPop = dPhoenixPop
	strNoOfVoiceChannels = dNoOfVoiceChannels
	strTypeOfOrder = dTypeOfOrder

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Entering the values for TDM Provide order
	If UCase(strTypeOfOrder) = "TDMPROVIDE"  then
		'Entring value for PhoenixPoP
		blnResult = enterText("txtPhoenixPOP",strPhoenixPop)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Selecting OneVoicePOPRegion from drop down list
		blnResult = selectValueFromPageList("lstSignalingtype",strSignalingtype)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	'Selecting OneVoicePoPRegion from drop down for GSIP TDM and GVPN Bundled products
	'Added GSIPMODIFY for Internet Access '#R41 19-Nov-2015
	
	Select Case UCase(strTypeOfOrder)
		Case "GSIPPROVIDE", "GVPNBUNDLEDPROVIDE", "OVAPROVIDE", "OUTBOUNDPROVIDE", "GSIPMODIFY", "MPLSPLUSIA", "GVPNUNBUNDLEDPROVIDE"
			If objPage.WebList("lstOneVoicePoPRegion").Exist(10) Then
				If Not objPage.WebList("lstOneVoicePoPRegion").Object.disabled Then
					blnResult = selectValueFromPageList("lstOneVoicePoPRegion",strOneVoicePoPRegion)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function	
				End If
			End If
	End Select

	'Validation for no of channels for all  poroducts
	'Select Case UCase(strTypeOfOrder)
	'	Case "OVAPROVIDE", "GVPNBUNDLEDPROVIDE", "GVPNUNBUNDLEDMODIFY", "GSIPPROVIDE" 'or  UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or  Then - Nagaraj || R40 Requirement Changes
	If objPage.WebEdit("txtGISVoiceChannelsNetwork").Exist(0) Then
		blnResult = enterText("txtGISVoiceChannelsNetwork", strNoOfVoiceChannels)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		strRetrievedText = objPage.WebEdit("txtGISVoiceChannelsNetwork").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("NoOfVoiceChannels","NoOfVoiceChannels should be populated"," NoOfVoiceChannels is populated with the value - " & strRetrievedText,"PASS","")
		Else
			Call ReportLog("NoOfVoiceChannels","NoOfVoiceChannels should be populated","NoOfVoiceChannels is not populated","FAIL","TRUE")
			Environment("Action_Result")=False : Exit Function
		End If
	End If
	'End Select
	
	If objPage.WebList("lstOnNetRoutingType").Exist(0) Then
		If dVoiceVPNRequired = "Yes" Then
			blnResult = selectValueFromPageList("lstOnNetRoutingType", strOnNetRoutingType)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If	
	End If
	
	'Selecting  particulars for GVPNBundled product only
	Select Case Ucase(strTypeOfOrder)
		Case "GVPNBUNDLEDPROVIDE", "GVPNUNBUNDLEDPROVIDE", "GSIPMODIFY", "GVPNBUNDLEDMODIFY", "GVPNUNBUNDLEDMODIFY"
			'Selecting Cascaded/Integrated router from drop down
			blnResult = selectValueFromPageList("lstCascaded/IntegratedRouter",strCascadedIntegratedRouter)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	End Select

	'Retriving the Announcement Language
	strRetrievedText = objPage.WebList("lstAnnouncementLanguage").GetROProperty("value")
	If strRetrievedText <> "" Then
		Call ReportLog("AnnouncementLanguage","AnnouncementLanguage should be populated"," AnnouncementLanguage is populated with the value - "&strRetrievedText,"PASS","")
	Else
		Call ReportLog("AnnouncementLanguage","AnnouncementLanguage should be populated","AnnouncementLanguage is not populated","FAIL","TRUE")
		Environment("Action_Result")=False : Exit Function
	End If

	'Moved to Additional Feature Details Page
	'Entering default public number
	If objPage.WebEdit("txtDefaultPublicNumber").Exist(10) Then
		If objPage.WebEdit("txtDefaultPublicNumber").object.disabled Then
			blnResult = enterText("txtDefaultPublicNumber", strDefaultPublicNumber)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			strRetrievedText = objPage.WebEdit("txtDefaultPublicNumber").GetROProperty("value")
			If strRetrievedText <> "" Then
				Call ReportLog("Default Public No.", "Default Public Number Check", "Default Public Number is populated with:= " & 	strRetrievedText, "Informaton", False)
			End If
		End If
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Clicking on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to PBX details page
	Set objMsg = objpage.Webelement("webElmPBXDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("NetworkConnectionDetails","Should be navigated to PBXDetails page on clicking Next Buttton","Not navigated to PBXDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Exit Function
	Else
		strMessage = GetWebElementText("webElmPBXDetails")
		Call ReportLog("NetworkConnectionDetails","Should be navigated to PBXDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
