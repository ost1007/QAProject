'****************************************************************************************************************************
' Function Name	 : fncModifySIPTrunkingDetails
' Purpose	 	 :  Adding a new trunk group and details for it
' Author	 	 : Vamshi Krishna G
' Creation Date    : 16/08/2013
' Parameters	 : 	
' Return values :	Nil
'****************************************************************************************************************************		
Public function fn_eDCA_ModifySIPTrunkingDetails(TypeOfOrder, eDCAOrderID,Codec,SBCTransportProtocol,PBXIPaddress,MainSwitchBoardNumber,PresentationFlag,NetworkCLIFlag,ScreenValue)

   'Declaration of variables
   Dim streDCAOrderID,strCodec,strSBCTransportProtocol,strPBXIPaddress,strMainSwitchBoardNumber,strPresentationFlag,strNetworkCLIFlag,strScreenValue
   Dim arrTrunkName,strTrunkName

   'Assignment of value to variables
   streDCAOrderID = eDCAOrderID
   strCodec = Codec
   strSBCTransportProtocol = SBCTransportProtocol
   strPBXIPaddress = PBXIPaddress
   strMainSwitchBoardNumber = MainSwitchBoardNumber
   strTrunkName = TrunkName
   strPresentationFlag = PresentationFlag
   strNetworkCLIFlag = NetworkCLIFlag
   strScreenValue = ScreenValue

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retriving the notifcation message for GVPN Bundled Modify
	Select Case TypeOfOrder
		Case "GVPNBUNDLEDMODIFY", "GVPNUNBUNDLEDMODIFY"
			'Retriving the notification message obtained
			strRetrivedText = objPage.WebElement("webElmConfigureVLANNotification").GetROProperty("innertext")
			If strRetrivedText <>" " Then
				Call ReportLog("SIPTrunkingDetails","SIPTrunkingDetails notifiaction message should be retrived","Notification message obtained-"&strRetrivedText,"PASS","TRUE")
			Else
				Call ReportLog("SIPTrunkingDetails","SIPTrunkingDetails notifiaction message should be retrived","SIPTrunkingDetails notification message not retrived","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
	End Select

	'Entering details for GSIP modify order
	If UCase(TypeOfOrder) = "GSIPMODIFY" Then
		'Updating Codec
		If strCodec <> "" Then
			blnResult = selectValueFromPageList("lstCodec",strCodec)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'Selecting SBC Transport protocol from drop downlist
		If strSBCTransportProtocol <> "" Then
			blnResult = selectValueFromPageList("lstSBCTransportProtocol",strSBCTransportProtocol)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'Retriving Unique Trunk Group Friendly Name
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtUniqueTrunkGroupFriendlyName").GetROProperty("value")
			Call ReportLog("UniqueTrunkGroupFriendlyName","UniqueTrunkGroupFriendlyName should be retrived","UniqueTrunkGroupFriendlyName retrived as -"&strRetrivedText,"PASS","TRUE")
	
		'Retriving Trunk Group CAC limit
		strRetrivedText = objPage.WebEdit("txtTrunkGroupCACLimit").GetROProperty("value")
			Call ReportLog("TrunkGroupCACLimit", "TrunkGroupCACLimit should be populated","TrunkGroupCACLimit is populated with the value - "&strRetrivedText,"PASS","")
	
		'Retriving Trunk Group Bandwidth CAC limit
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtRevisedTrunkGroupCACLimit").GetROProperty("value")
			Call ReportLog("TrunkGroupRevisedTrunkGroupCACLimit","TrunkGroupRevisedTrunkGroupCACLimit should be retrived","TrunkGroupRevisedTrunkGroupCACLimit retrived as -"&strRetrivedText,"PASS","TRUE")
	
		'Retriving Unique Trunk Friendly Name
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtUniqueTrunkFriendlyName").GetROProperty("value")
			Call ReportLog("UniqueTrunkFriendlyName","UniqueTrunkFriendlyName should be retrived","UniqueTrunkFriendlyName retrived as -"&strRetrivedText,"PASS","TRUE")
	
		'Retriving the Trunk group to be Linked value
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").GetROProperty("value")
			Call ReportLog("TrunkGroupToBeLinked","TrunkGroupToBeLinked should be retrived","TrunkGroupToBeLinked retrived as -"&strRetrivedText,"PASS","TRUE")
	
		'Retriving Trunk priorty
		strRetrivedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtTrunkPriority").GetROProperty("value")
			Call ReportLog("TrunkPriority","TrunkPriority should be retrived","TrunkPriority retrived as -"&strRetrivedText,"PASS","TRUE")
	
		'Updating the PBXIPaddress
		If strPBXIPaddress <> "" Then
			blnResult = enterText("txtPBXIPaddress",strPBXIPaddress)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'Updating the Main switch Board Number
		If strMainSwitchBoardNumber <> "" Then
			blnResult = enterText("txtMainSwitchBoardNumber",strMainSwitchBoardNumber)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'*********************************************************************************************************************************************************
		'Trunk Screen List
		'*********************************************************************************************************************************************************
		For intCounter = 1 To 3 Step 1
			blnExist = objPage.WebButton("btnAddNewScreenList").Exist
			If blnExist Then Exit For
		Next
		blnScreenList = False
		
		If blnScreenList Then
			'Click Add New screen List button
			blnResult = clickButton("btnAddNewScreenList")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
			'Select Trunk Name from drop down list
			strTrunkName = objPage.WebList("lstTrunkName").GetROProperty("innertext")
			arrTrunkName = Split(strTrunkName," ")
			objPage.WebList("lstTrunkName").select arrTrunkName(1)
		
			'Selecting Presentation flag from drop down
			If strPresentationFlag <> "" Then
				blnResult = selectValueFromPageList("lstPresentationFlag",strPresentationFlag)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		
			'Selecting NetworkCLI flag from drop down
			If strNetworkCLIFlag <> "" Then
				blnResult = selectValueFromPageList("lstNetworkCLIFlag",strNetworkCLIFlag)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		
			'Entering Screen Value into the text box
			If strScreenValue <> "" Then
				blnResult = enterText("txtScreenValue",strScreenValue)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		
			'Click on Save Button
				blnResult = clickButton("btnSave")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If '#If blnScreenList Then
		
	End If 'Closing If loop for GSIPmodify

	If UCase(TypeOfOrder) = "OB_FULLPSTN_MODIFY" Then
		If objPage.WebCheckBox("name:=.*ChkDefaultPub").Exist Then
			objPage.WebCheckBox("name:=.*ChkDefaultPub").Set "ON"
		End If
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to additional features details page 
	Set objMsg = objpage.Webelement("webElmAdditionalFeaturesDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Not navigated to AdditionalFeaturesDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False 
	Else
		strMessage = GetWebElementText("webElmAdditionalFeaturesDetails")
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
