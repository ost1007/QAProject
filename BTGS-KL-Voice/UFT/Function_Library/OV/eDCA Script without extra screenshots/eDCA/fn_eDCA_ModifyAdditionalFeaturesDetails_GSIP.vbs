'=============================================================================================================
'Description: Function to Modify GSIP Product on Additional Feature Details Page
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			29/07/2015 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_GSIP("27245632300", "Porting", "Orange")
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_GSIP(ByVal RemovalNumberBlock, ByVal AddNumberBlock, ByVal BlockSize, ByVal NumberType, ByVal Supplier)
	'Variable Declaration
	Dim intCounter
	Dim iRow
	Dim objTblNumberBlockDetails
	Dim strTGLinked

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

	Set objTblNumberBlockDetails = objPage.WebTable("tblNumberBlockDetails")

	With objTblNumberBlockDetails
			'--------------------------------------------------- Removing Existing Number Block '--------------------------------------------------- 
			iRow = .GetRowWithCellText(RemovalNumberBlock)
			If iRow <= 0 Then
				Call ReportLog("Number Block", "<B>" & RemovalNumberBlock & "</B> should be present in Number Block Details page", "<B>" & RemovalNumberBlock & "</B> is not present in Number Block Details page", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If

			.ChildItem(iRow, 1, "WebButton", 0).Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			'Terminate if Save Button is not enabled
			If Not objPage.WebButton("btnSave").WaitProperty("disabled", "0", 10000*6) Then
					Call ReportLog("Edit Number Block", "On Clicking on Edit the Save Button should be enabled", "Save Button is disabled", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
			End If

			blnResult = selectValueFromPageList("lstAction", "Remove Existing Number Block")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			strTGLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("selection")
			'strNumberBlockSize = objPage.WebEdit("txtNumberBlockSize").GetROProperty("value")

			blnResult = clickButton("btnSave")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
				Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
				Wait 10
			End If
			'--------------------------------------------------- End Removing Existing Number Block '--------------------------------------------------- 
	End With

	'--------------------------------------------------- Add Number Block '--------------------------------------------------- 
	With objTblNumberBlockDetails
			'Clicking on Add block details button
			blnResult = clickButton("btnAddBlockDetails")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	
			'Click on dialog that appears
			If Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Exist(5) Then
				Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
			End If
			
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
			'Select Number type from drop down list
			blnResult = objPage.WebList("lstNumberType").Exist
			If blnResult Then
					blnResult  = selectValueFromPageList("lstNumberType", NumberType)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
					Call ReportLog("lstNumberType", "WebList Should Exist", "WebList doesnt exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
			End If

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			'Enter Block Start Number which has been Removed
			blnResult  = enterText("txtSupplier", Supplier)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			'Enter Block Start Number which has been Removed
			blnResult  = enterText("txtBlockStartNumber", AddNumberBlock)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			'Enter the Block Size
			blnResult  = enterText("txtNumberBlockSize", BlockSize)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			'Select the Trunk Group
			blnResult  = selectValueFromPageList("lstTrunkGroupToBeLinked", strTGLinked)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			blnResult = clickButton("btnSave")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
				Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
				Wait 10
			End If
	End With

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
