'=============================================================================================================
'Description: Function to Modify GSIP Product on Additional Feature Details Page
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			29/07/2015 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_GSIP("27245632300", "Porting", "Orange")
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_GSIP01(ByVal NumberType, ByVal NumberBlock, ByVal BlockSize, ByVal Supplier, ByVal DonatingProductName, ByVal DonatingProductServiceID)
	'Variable Declaration
	Dim intCounter
	Dim iRow
	Dim objTblNumberBlockDetails
	Dim strTGLinked
	Dim arrNumberType, arrNumberBlock, arrBlockSize

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

	Set objTblNumberBlockDetails = objPage.WebTable("tblNumberBlockDetails")
	If Not objTblNumberBlockDetails.Exist(10) Then
		Call ReportLog("NumberBlockDetails", "NumberBlockDetails table should exist", "NumberBlockDetails table does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	arrNumberType = Split(NumberType, "|")
	arrNumberBlock = Split(NumberBlock, "|")
	arrBlockSize = Split(BlockSize, "|")
	

	'--------------------------------------------------- Add Number Block '--------------------------------------------------- 
	For index = LBound(arrNumberType) To UBound(arrNumberType)
			strNumberType = Trim(arrNumberType(index))
			strNumberBlock = Trim(arrNumberBlock(index))
			strBlockSize = Trim(arrBlockSize(index))
			
			'Clicking on Add block details button
			blnResult = clickButton("btnAddBlockDetails")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		
			'Click on dialog that appears
			If Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Exist(5) Then
				Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
			End If
			
			'Select Number type from drop down list
			blnResult = objPage.WebList("lstNumberType").Exist(120)
			blnResult  = selectValueFromPageList("lstNumberType", strNumberType)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
			Select Case strNumberType
				Case "Porting"
					'Enter Supplier
					blnResult  = enterText("txtSupplier", Supplier)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
				
				Case "Cutover"
					'Enter Provide the donating BT Product name from where the number block needs to be cut over
					blnResult  = enterText("txtDonatingBTProductname", DonatingProductName)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
					
					'Enter Donating BT product Service ID
					blnResult  = enterText("txtDonatingProductServiceId", DonatingProductServiceID)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			End Select
			
			'Enter Block Start Number which has been Removed
			blnResult  = enterText("txtBlockStartNumber", strNumberBlock)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
				
			'Enter the Block Size
			blnResult  = enterText("txtNumberBlockSize", strBlockSize)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			
			If objPage.WebList("lstTrunkGroupToBeLinked").Exist(60) Then
				arrAllItems = Split(objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items"), ";")
				If UBound(arrAllItems) < 1 Then
					Call ReportLog("Trunk Group Linking", "List Should contain Trunk Group to be listed", "List contains </BR>" & Join(arrAllItems, "</BR>"), "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
				
				For Each ListItem In arrAllItems
					If ListItem <> "Please Select" Then
						strTGLinked = ListItem
						Exit For '#ListItem
					End If
				Next
			End If
			
			'Select the Trunk Group
			blnResult  = selectValueFromPageList("lstTrunkGroupToBeLinked", strTGLinked)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		
			blnResult = clickButton("btnSave")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
			If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(10) Then
				Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
				Wait 10
			End If
			
	Next '#index
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
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If
		
End Function
