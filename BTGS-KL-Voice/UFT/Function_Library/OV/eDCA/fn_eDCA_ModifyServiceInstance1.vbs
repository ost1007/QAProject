'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ModifyServiceInstance1(TypeOfOrder, NoOfChannels,AccessResiliency,DirectAccessTariff,SLACategory,SharedAccess,GISVoiceChannels)
' Purpose	 	 : Function to editnew voice service 
' Author	 	 : Vamshi Krishna G
' Creation Date    : 07/08/2013
' Parameters	 : 	 NoOfChannels,
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_ModifyServiceInstance1(TypeOfOrder, ServiceType, SubServiceType, NoOfChannels,AccessResiliency,DirectAccessTariff,SLACategory,SharedAccess,GISVoiceChannels)

	'Declaration of variables
	Dim strNoOfChannels,strAccessResiliency,strDirectAccessTariff,strSLACategory,strSharedAccess,strGISVoiceChannels
	Dim strServiceType
	Dim strFullPSTNMsgText, strVisibleText

	'Assignment of values to variables
	strNoOfChannels = NoOfChannels
	strAccessResiliency = AccessResiliency
	strDirectAccessTariff = DirectAccessTariff
	strSLACategory = SLACategory
	strSharedAccess = SharedAccess
	strGISVoiceChannels = GISVoiceChannels
	strFullPSTNMsgText = "Are you sure you want to migrate 'One Voice Outbound' Service to 'Full PSTN' Service"

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Edit corresponding to product type "one voice" 
	blnResult =  clickButton("btnSIEdit")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Handle Dialog if Pop Appears stating Selected PoP is flagged as full
	If Browser("brweDCAPortal").Window("wndDialog").Exist(10) Then
		strHTML = Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").Object.DocumentElement.outerHtml
		Call ReportLog("WebDialog", "WebDialog message", strHTML, "Warnings", True)
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If '#Dialog

	If TypeOfOrder = "GSIPMODIFY" OR TypeOfOrder = "GVPNBUNDLEDMODIFY" OR TypeOfOrder = "GVPNUNBUNDLEDMODIFY" Then

		'Updating the values of NoOfChannels
		If strNoOfChannels <>"" Then
			If objPage.WebEdit("txtNoOfChannels").Exist(5) Then
				blnResult = enterText("txtNoOfChannels",strNoOfChannels)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			End If
		End If

		'Voice VPN required
		If strVoiceVPNRequired <>""  Then
			blnResult = selectValueFromPageList("lstVoiceVPNRequired",strVoiceVPNRequired)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'PSTN Required
		If strPSTNRequired <>"" Then
			blnResult = selectValueFromPageList("lstPSTNRequired",strPSTNRequired)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'Selecting DirectAccessTarrif from drop down list
		If strDirectAccessTariff <>"" Then
			blnResult = selectValueFromPageList("lstDirectAccessTariff",strDirectAccessTariff)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'Selecting SLA category from drop down list
		If strSLACategory <>"" Then
			blnResult = selectValueFromPageList("lstSLACategory",strSLACategory)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

	End If
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	If UCase(TypeOfOrder) = "TDMMODIFY" or  UCase(TypeOfOrder) = "GVPNBUNDLEDMODIFY" Then

		'Shared Access requirement from drop down
		If strSharedAccess <>"" Then
			blnResult = selectValueFromPageList("lstSharedAccess",strSharedAccess)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If strSharedAccess = "Yes" Then
			strRetrivedText = objPage.WebList("lstGISOrderType").GetROProperty("innertext")
				If strRetrivedText <>" " Then
					Call ReportLog("SIPTrunkingDetails","GISOrderType should be retrived","GISOrder Type obtained-"&strRetrivedText,"PASS","")
				Else
					Call ReportLog("SIPTrunkingDetails","GISOrderType should be retrived","GISOrderType not retrived","FAIL","TRUE")
				End If

				'Entering no of  GIS Voice Channels
				blnResult = enterText("txtGISVoiceChannels",strGISVoiceChannels)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

				'Selecting DirectAccessTarrif from drop down list
				If strDirectAccessTariff <>"" Then
					blnResult = selectValueFromPageList("lstDirectAccessTariff",strDirectAccessTariff)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
		End If
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	End If

	'Modify from OutBound to Full PSTN
	If TypeOfOrder = "OB_FULLPSTN_MODIFY" Then
			If objPage.WebList("lstServiceType").Exist Then
				strServiceType = objPage.WebList("lstServiceType").GetROProperty("selection")
				If Trim(ServiceType) = Trim(strServiceType) Then
					Call ReportLog("Service Type", "Service Type should be selected with " & ServiceType, "Service Type is selected as <B>" & strServiceType & "</B", "INFORMATION", False)
				Else
					Call ReportLog("Service Type", "Service Type should be selected with " & ServiceType, "Service Type is selected as <B>" & strServiceType & "</B", "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
			End If
	
			'Seelct Sub Service Type
			blnResult = selectValueFromPageList("lstSubServiceType", SubServiceType)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'Click on Dialog Box
			If objBrowser.Dialog("dlgMsgWebPage").Exist(90) Then
					strVisibleText = objBrowser.Dialog("dlgMsgWebPage").Static("staticMsg").GetROProperty("text")
					If Instr(strVisibleText, strFullPSTNMsgText) > 0 Then
						Call ReportLog("Migration Verification", "<B>" & strFullPSTNMsgText & "</B should be displayed", "<B>" & strVisibleText  & "</B is displayed", "PASS", True)
						Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
					Else
						Call ReportLog("Migration Verification", "<B>" & strFullPSTNMsgText & "</B should be displayed", "<B>" & strVisibleText  & "</B is displayed", "FAIL", True)
						Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
						Environment("Action_Result") = False : Exit Function
					End If
			Else
					Call ReportLog("Migration Verification", "<B>" & strFullPSTNMsgText & "</B should be displayed in dialog box", "Dialog Box is not visible", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
			End If
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	End If

	
	If UCase(TypeOfOrder) = "OMAMODIFY" Then
		'Selecting SLA category from drop down list
			If strSLACategory <>"" Then
				blnResult = selectValueFromPageList("lstSLACategory",strSLACategory)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to Network Connection details page
	Set objMsg = objpage.WebElement("webElmNetworkConnectionDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Not navigated to NetworkConnectionDetails page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False
		Else
			strMessage = GetWebElementText("webElmNetworkConnectionDetails")
			Call ReportLog("ServiceInstance","Should be navigated to NetworkConnectionDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
			Environment("Action_Result") = True
		End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
