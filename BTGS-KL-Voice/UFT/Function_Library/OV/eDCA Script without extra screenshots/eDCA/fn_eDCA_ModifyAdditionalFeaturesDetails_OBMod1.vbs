'=============================================================================================================
'Description: Function to Modify Outbound to Outbound Product on Additional Feature Details Page Limited to Add only Number Blocks
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			15/10/2015 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_OBMod1
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_OBMod1(CallFeatureDetailsRequired, IncomingAnonymousCallRejection, IncomingCLIWithheld, CallDivertBusy, CallDivertBusyDestination,_
	CallDivertUnreachable, CallDivertUnreachableDestination, DirectoryListingRequired, NumberType, BTSupplied, Supplier, ThirdPartyCLI, NumberBlock, NumberBlockSize)
	
	'Variable Declaration
	Dim intCounter
	Dim iRow
	Dim strTGLinked
	Dim arrBlockStartNumber, arrNumberBlockSize
	
	arrBlockStartNumber = Split(NumberBlock, "|")
	arrNumberBlockSize = Split(NumberBlockSize, "|")

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function
		
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

	'Select Call Feature Details Required
	blnResult = objPage.WebList("lstCallFeatureDetailsRequired").Exist(5)
	If blnResult Then
		blnResult = selectValueFromPageList("lstCallFeatureDetailsRequired", CallFeatureDetailsRequired)
			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
	 If CallFeatureDetailsRequired = "Yes" Then
			'Incoming Anonymous Call Rejection
			blnResult = objPage.WebList("lstIncomingAnonymousCallRejection").Exist(5)
			If blnResult Then
				blnResult = selectValueFromPageList("lstIncomingAnonymousCallRejection", IncomingAnonymousCallRejection)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			End If
	
			'Incoming CLI With held
			blnResult = objPage.WebList("lstIncomingCLIWithheld").Exist(5)
			If blnResult Then
				blnResult  =selectValueFromPageList("lstIncomingCLIWithheld", IncomingCLIWithheld)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			End If
	End If
	
	'CallDivert Busy
	blnResult = objPage.WebList("lstCallDivertBusy").Exist(5)
	If blnResult Then
		blnResult  = selectValueFromPageList("lstCallDivertBusy", CallDivertBusy)
			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If CallDivertBusy = "Yes" Then
		'CallDivert Busy Destination
		blnResult = objPage.WebEdit("txtCallDivertBusyDestination").Exist(5)
		If blnResult Then
			blnResult = enterText("txtCallDivertBusyDestination", CallDivertBusyDestination)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End If
	
	'CallDivert Unreachable
	blnResult = objPage.WebList("lstCallDivertUnreachable").Exist
	If blnResult  Then
		blnResult  = selectValueFromPageList("lstCallDivertUnreachable", CallDivertUnreachable)
			If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End if 

	If CallDivertUnreachable = "Yes" Then
		'CallDivert Unreachable Destination
		If objPage.WebEdit("txtCallDivertUnreachableDestination").Exist(5) Then
			blnResult  = enterText("txtCallDivertUnreachableDestination", CallDivertUnreachableDestination)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If

		'Directory Listing required
		If objPage.WebList("lstDirectoryListingRequired").Exist(5) Then
			blnResult  = selectValueFromPageList("lstDirectoryListingRequired", DirectoryListingRequired)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If
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
			Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Select Number type from drop down list
		blnResult = objPage.WebList("lstNumberType").Exist
		If blnResult Then
				blnResult  = selectValueFromPageList("lstNumberType", NumberType)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If strNumberType = "New Number" Then
				blnResult = objPage.WebList("lstBTSupplied").Exist
				If blnResult Then
					'Entering if it is BT supplied
					blnResult  = selectValueFromPageList("lstBTSupplied", BTsupplied)
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
		
		'Entering Third Party CLI
		If objPage.WebList("lstThirdPartyCLI").Exist Then
			blnResult  = selectValueFromPageList("lstThirdPartyCLI", ThirdPartyCLI)		
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
					Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is not populated","FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			End If
		Else
			blnResult  = enterText("txtSupplier", Supplier)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		End If	

		blnResult = objPage.WebEdit("txtBlockStartNumber").Exist
		If blnResult = "True" Then
			blnResult  = enterText("txtBlockStartNumber",strBlockStartNum)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	
		blnResult = objPage.WebEdit("txtNumberBlockSize").Exist
		If blnResult Then
			blnResult  = enterText("txtNumberBlockSize",strBlockSize)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If

		If Cint(objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("items count")) = 2 Then
			objPage.WebList("lstTrunkGroupToBeLinked").Select "#0"
		ElseIf Cint(objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("items count")) - 1 >= intCounter Then
			objPage.WebList("lstTrunkGroupToBeLinked").Select "#" & intCounter
       	End If

       	blnResult = clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
			Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
			Wait 5
		End If

	Next 'intCounter # arrBlockStartNumber

	'--------------------------------------------------- End of Add Number Block '--------------------------------------------------- 
	
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
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If
		
End Function
