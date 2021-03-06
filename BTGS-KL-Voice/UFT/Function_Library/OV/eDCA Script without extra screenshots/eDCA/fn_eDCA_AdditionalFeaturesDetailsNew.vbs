'************************************************************************************************************************************
' Function Name	 : fn_eDCA_AdditionalFeaturesDetailsNew
' Return values :	Nil
'**************************************************************************************************************************************	
Function fn_eDCA_AdditionalFeaturesDetailsNew(TypeOfOrder, SubServiceType, eDCAOrderID, CallBarringDetailsRequired, DirectoryListingRequired,_
									OCBCategoryLabel, CallFeatureDetailsRequired, IncomingAnonymousCallRejection, IncomingCLIWithheld,_
									CallDivertBusy, CallDivertBusyDestination, CallDivertUnreachable, CallDivertUnreachableDestination,_
									NumberType, BTSupplied, Supplier, PrivateNumberMapping, BlockStartNumber, NumberBlockSize)

	'Varaible Declaration
	Dim arrOCBCategoryLabel, arrNumberType, arrBlockStartNumber, arrNumberBlockSize
	Dim strNumberType, strBlockStartNumber, strNumberBlockSize
	
	'Variable Assignment
	arrOCBCategoryLabel = Split(OCBCategoryLabel, "|")
	arrNumberType = Split(NumberType, "|")
	arrBlockStartNumber = Split(BlockStartNumber, "|")
	arrNumberBlockSize = Split(NumberBlockSize, "|")
	
	'CheckPoint for Automation
	If Not ( ( UBound(arrNumberType) = UBound(arrBlockStartNumber) ) AND ( UBound(arrNumberType) = UBound(arrNumberBlockSize) ) )Then
		Call ReportLog("Mismatch Data", "NumberType, BlockStartNumber, NumberBlockSize array size should be same", "Check Data sheet", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'CallBarringDetailsRequired
	If objPage.WebList("lstCallBarringDetailsRequired").Exist(0) Then
		blnResult = selectValueFromPageList("lstCallBarringDetailsRequired", CallBarringDetailsRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Selecting OCB category from drop down list
	If CallBarringDetailsRequired = "Yes" Then '#2
		For intCounter = LBound(arrOCBCategoryLabel) to UBound(arrOCBCategoryLabel)
			blnResult = objPage.WebList("lstOCBCategoryLabel" & (intCounter + 1)).Exist
			If blnResult Then '#3
				blnResult = selectValueFromPageList("lstOCBCategoryLabel" & (intCounter + 1), arrOCBCategoryLabel(intCounter))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If '#3
		Next '#intCounter
	End If '#2

	'============ Call feature details  ==============
	If objPage.WebList("lstCallFeatureDetailsRequired").Exist(0) Then
		blnResult = selectValueFromPageList("lstCallFeatureDetailsRequired", CallFeatureDetailsRequired)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End IF

	If CallFeatureDetailsRequired = "Yes" Then
		If SubServiceType <> "One Voice Outbound" Then
			'Incoming Anonymous Call Rejection
			blnResult = selectValueFromPageList("lstIncomingAnonymousCallRejection", IncomingAnonymousCallRejection)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			'Incoming CLI With held
			blnResult  =selectValueFromPageList("lstIncomingCLIWithheld",IncomingCLIWithheld)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End if

		'CallDivert Busy
		If objPage.WebList("lstCallDivertBusy").Exist Then
			blnResult  = selectValueFromPageList("lstCallDivertBusy", CallDivertBusy)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If CallDivertBusy = "Yes" Then
			'CallDivert Busy Destination
			blnResult = enterText("txtCallDivertBusyDestination", CallDivertBusyDestination)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If

		'CallDivert Unreachable
		If objPage.WebList("lstCallDivertUnreachable").Exist Then
			blnResult  = selectValueFromPageList("lstCallDivertUnreachable", CallDivertUnreachable)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if 

		If CallDivertUnreachable = "Yes" Then
			'CallDivert Unreachable Destination
			blnResult  = enterText("txtCallDivertUnreachableDestination", CallDivertUnreachableDestination)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function

			'Directory Listing required
			If dSubServiceType <> "One Voice Outbound" Then
				blnResult = selectValueFromPageList("lstDirectoryListingRequired", DirectoryListingRequired)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End if
		End If
	End if 'CallFeatureDetailsRequired
	
	'===================================== Add Number Block ================================ 
	For index = LBound(arrNumberType) TO UBound(arrNumberType)
			strNumberType = Trim(arrNumberType(index))
			strBlockStartNumber = Trim(arrBlockStartNumber(index))
			strBlockSize = Trim(arrNumberBlockSize(index))
	
			'Clicking on Add block details button
			If SubServiceType <> "One Voice Outbound" Then
				objPage.WebButton("btnAddBlockDetails").WaitProperty "height", micGreaterThan(0), 1000*60*2
				blnResult = clickButton("btnAddBlockDetails")
					If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					
				'Click on dialog that appears
				If Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Exist(5) Then
					Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
			End if '#SubServiceType
			
			'Select Number type from drop down list
			blnResult  = selectValueFromPageList("lstNumberType", NumberType)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
			'Entering if it is BT supplied
			blnResult  = selectValueFromPageList("lstBTSupplied", BTSupplied)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Retriving the supplier name
			If BTsupplied = "Yes" Then
				strRetrievedText = objPage.WebEdit("txtSupplier").GetROProperty("value")
				If strRetrievedText <> "" Then
					Call ReportLog("Supplier","Supplier should be populated","Supplier is populated with the value - "&strRetrievedText,"PASS","")
				Else
					Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
					Environment("Action_Result") = False : Exit Function
				End If
			Else
				blnResult = enterText("txtSupplier", Supplier)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
					
			Select Case NumberType
					Case "New Number"
								
								'Retriving 'Action' field value
								strRetrievedText = objPage.WebList("lstAction").GetROProperty("value")
								If strRetrievedText <> "" Then
									Call ReportLog("Action","Action should be populated","Action is populated with the value - " & strRetrievedText,"PASS","")
								Else
									Call ReportLog("Action","Action should be populated","Action is not populated","FAIL","TRUE")
									Environment("Action_Result") = False : Exit Function
								End If
						
					Case Else
						
							blnResult = objPage.WebList("lstThirdPartyCLI").Exist
							If blnResult Then
								blnResult = selectValueFromPageList("lstThirdPartyCLI",strSelectThirdPartyCLI)
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
							End if
			End Select '#NumberType
			
			'Enter Block Start Number
			blnResult  = enterText("txtBlockStartNumber", BlockStartNumber)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			'Enter Block Size 			
			blnResult  = enterText("txtNumberBlockSize", NumberBlockSize)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Selecting TrunkGroup to be linked	
			Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
			
			Select Case UCase(TypeOfOrder) 
				'Need to check for case PrivateNumber appearing
				Case "ETHERNETPROVIDE", "MPLSPLUSIA"
						'Selecting Private Number Mapping from drop down list
						blnResult = objPage.WebList("lstPrivateNumberMapping").Exist(0)
						If blnResult Then
							blnResult  = selectValueFromPageList("lstPrivateNumberMapping", PrivateNumberMapping)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						End If
			End Select
			
			If objPage.WebButton("btnSave").Exist(60) Then
				'Clicking on Save button
				blnResult = clickButton("btnSave")
					If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
			
			If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
				Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
				Wait 5
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
	Next '#index
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigfated to BillingDetails page
	Set objMsg = objpage.WebElement("webElmBillingDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
