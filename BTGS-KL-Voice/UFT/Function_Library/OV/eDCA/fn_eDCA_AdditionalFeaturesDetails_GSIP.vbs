'==========================================================================================================================================================================================
' Function Name	:  fn_eDCA_AdditionalFeaturesDetails_GSIP
' Purpose		:  To fill additional feature details for GSIP Order type
' Author			: Nagaraj Venkobasa
' Creation Date    : 
' Return values 	: Not Applicable
'==========================================================================================================================================================================================
	'Call Features and Call Barring Details are removed as part of Story in R43
	
'Public Function fn_eDCA_AdditionalFeaturesDetails_GSIP(strCallBarringDetailsRequired, strOCBCategoryLabel1, strCallFeatureDetailsRequired, strIncomingAnonymousCallRejection,_
'	strIncomingCLIWithheld,	strCallDivertBusy, strCallDivertBusyDestination, strCallDivertUnreachable, strCallDivertUnreachableDestination, strDirectoryListingRequired, strNumberType, strBTsupplied,_
'	strBlockStartNumber, strNumberBlockSize)

Public Function fn_eDCA_AdditionalFeaturesDetails_GSIP(strDirectoryListingRequired, strNumberType, strBTsupplied, strBlockStartNumber, strNumberBlockSize)

	'Variable Declaration
	Dim arrOCBCategoryLabel1, arrBlockStartNumber, arrNumberBlockSize
	Dim intCounter
	
	'Variable Assignment
	'arrOCBCategoryLabel1 = split(strOCBCategoryLabel1, "|")
	arrBlockStartNumber = Split(strBlockStartNumber, "|")
	arrNumberBlockSize = Split(strNumberBlockSize, "|")

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

	'Call Features and Call Barring Details are removed as part of Story in R43

		'Select Call Barring
		blnResult = objPage.WebList("lstCallBarringDetailsRequired").Exist(5)
		If blnResult  Then
			blnResult = selectValueFromPageList("lstCallBarringDetailsRequired", "No")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	'	If strCallBarringDetailsRequired = "Yes" Then
	'			For intCounter = LBound(arrOCBCategoryLabel1) to UBound(arrOCBCategoryLabel1)
	'					'Selecting OCB category from drop down list
	'					blnResult = objPage.WebList("lstOCBCategoryLabel" & (intCounter + 1)).Exist(30)
	'					If blnResult Then
	'							blnResult = selectValueFromPageList("lstOCBCategoryLabel" & (intCounter + 1),arrOCBCategoryLabel1(intCounter))
	'								If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'					End If
	'			Next 'intCounter
	'	End If
	'
	'	'Select Call Feature Details Required
	'	blnResult = objPage.WebList("lstCallFeatureDetailsRequired").Exist(5)
	'	If blnResult Then
	'		blnResult = selectValueFromPageList("lstCallFeatureDetailsRequired",strCallFeatureDetailsRequired)
	'			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'	End If
	'
	'    If strCallFeatureDetailsRequired = "Yes" Then
	'			'Incoming Anonymous Call Rejection
	'			blnResult = objPage.WebList("lstIncomingAnonymousCallRejection").Exist(5)
	'			If blnResult Then
	'				blnResult = selectValueFromPageList("lstIncomingAnonymousCallRejection",strIncomingAnonymousCallRejection)
	'					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'			End If
	'	
	'			'Incoming CLI With held
	'			blnResult = objPage.WebList("lstIncomingCLIWithheld").Exist(5)
	'			If blnResult Then
	'				blnResult  =selectValueFromPageList("lstIncomingCLIWithheld",strIncomingCLIWithheld)
	'					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'			End If
	'	End If
	'
	'	'CallDivert Busy
	'	blnResult = objPage.WebList("lstCallDivertBusy").Exist(5)
	'	If blnResult Then
	'		blnResult  = selectValueFromPageList("lstCallDivertBusy",strCallDivertBusy)
	'			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'	End If
	'
	'	If strCallDivertBusy = "Yes" Then
	'		'CallDivert Busy Destination
	'		blnResult = objPage.WebEdit("txtCallDivertBusyDestination").Exist(5)
	'		If blnResult Then
	'			blnResult = enterText("txtCallDivertBusyDestination",strCallDivertBusyDestination)
	'				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	'		End If
	'	End If
	'
	'	'CallDivert Unreachable
	'	blnResult = objPage.WebList("lstCallDivertUnreachable").Exist(5)
	'	If blnResult  Then
	'		blnResult  = selectValueFromPageList("lstCallDivertUnreachable",strCallDivertUnreachable)
	'			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'	End if 
	'
	'	If strCallDivertUnreachable = "Yes" Then
	'		'CallDivert Unreachable Destination
	'		blnResult = objPage.WebEdit("txtCallDivertUnreachableDestination").Exist(5)
	'		If blnResult Then
	'			blnResult  = enterText("txtCallDivertUnreachableDestination",strCallDivertUnreachableDestination)
	'				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	'		End If
	'	End If

	'Directory Listing required
	If objPage.WebList("lstDirectoryListingRequired").Exist(10) Then
		blnResult  = selectValueFromPageList("lstDirectoryListingRequired",strDirectoryListingRequired)
			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function	
	End If
	
	'===================== Adding Block Details ================
	For intCounter = LBound(arrBlockStartNumber) To UBound(arrBlockStartNumber)
		strBlockStartNum = arrBlockStartNumber(intCounter)
		strBlockSize = arrNumberBlockSize(intCounter)
		objPage.WebButton("btnAddBlockDetails").WaitProperty "height", micGreaterThan(0), 1000*60*2
		'Clicking on Add block details button
		blnResult = clickButton("btnAddBlockDetails")
			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Click on dialog that appears
		If Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Exist(10) Then
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Select Number type from drop down list
		blnResult = objPage.WebList("lstNumberType").Exist(30)
		If blnResult = "True" Then
				blnResult  = selectValueFromPageList("lstNumberType",strNumberType)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If strNumberType = "New Number" Then
				blnResult = objPage.WebList("lstBTSupplied").Exist(30)
				If blnResult = "True" Then
					'Entering if it is BT supplied
					blnResult  = selectValueFromPageList("lstBTSupplied",strBTsupplied)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
		End If
			
		'Retriving 'Action' field value
		strRetrievedText = objPage.WebList("lstAction").GetROProperty("value")
		If strRetrievedText <> "" Then
			Call ReportLog("Action","Action should be populated","Action is populated with the value - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Action","Action should be populated","Action is not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	
		'Retriving the supplier name
		If strBTsupplied = "Yes" Then
			strRetrievedText = objPage.WebEdit("txtSupplier").GetROProperty("value")
			If strRetrievedText <> "" Then
				Call ReportLog("Supplier","Supplier should be populated","Supplier is populated with the value - "&strRetrievedText,"PASS","")
			Else
				Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
				
			If objPage.WebList("lstPortInOut").Exist(0) Then
				strRetrievedText = objPage.WebList("lstPortInOut").GetROProperty("value")
				If strRetrievedText <> "" Then
					Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is populated with the value - "&strRetrievedText,"PASS","")
				Else
					Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is not populated","FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
			End If
		Else
			blnResult  = enterText("txtSupplier","Orange")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If	

		blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
		If blnResult = "True" Then
			blnResult  = enterText("txtBlockStartNumber",strBlockStartNum)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If
	
		blnResult = objPage.WebEdit("txtNumberBlockSize").Exist(30)
		If blnResult = "True" Then
			blnResult  = enterText("txtNumberBlockSize",strBlockSize)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If

		If Cint(objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("items count")) = 2 Then
			objPage.WebList("lstTrunkGroupToBeLinked").Select "#0"
		ElseIf Cint(objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("items count")) - 1 >= intCounter Then
			objPage.WebList("lstTrunkGroupToBeLinked").Select "#" & intCounter
        End If
		
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
        blnResult = clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Wait 5
		End If
	Next 'intCounter # arrBlockStartNumber

	Wait 5
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigfated to BillingDetails page
	Set objMsg = objpage.WebElement("webElmBillingDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If
End Function
