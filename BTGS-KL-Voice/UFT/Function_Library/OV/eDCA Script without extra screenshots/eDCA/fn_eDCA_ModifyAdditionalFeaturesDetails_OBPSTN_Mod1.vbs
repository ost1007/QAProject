'=============================================================================================================
'Description: Function to Modify Outbound to Full PSTN Product on Additional Feature Details Page
'History	  : Name				Date			Changes Implemented
'Created By	 :  Neelam		23/02/2016 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_OBPSTN_Mod1("New Number","Yes","Orange")
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_OBPSTN_Mod1(ByVal NumberType, ByVal BTSupplied, ByVal dThirdPartyCLI,ByVal Supplier)
	'Variable Declaration
	Dim intCounter
	Dim iRow
	Dim objTblNumberBlockDetails
	Dim strTGLinked

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

	Set objTblNumberBlockDetails = objPage.WebTable("tblNumberBlockDetails")

	strTGLinked = ""
  
	With objTblNumberBlockDetails
			iRow = .RowCount
			
			If iRow <= 1 Then
					Call ReportLog("Number Block", "<B>" & NumberBlock & "</B> should be present in Number Block Details page", "<B>" & NumberBlock & "</B> is in Number Block Details page", "Information", False)
					Environment.Value("Action_Result")=False : Exit Function
			Else	
					arrColumnNames = Split(.GetROProperty("column names"), ";")
					For iItemCounter = 2 To UBound(arrColumnNames)
						If Trim(arrColumnNames(iItemCounter)) = "Parent Name" Then
							intParentNameIndex = iItemCounter + 1
							Exit For
						ElseIf Trim(arrColumnNames(iItemCounter)) = "Block Start Number" Then
							intBlockStartNumber = iItemCounter + 1
						ElseIf Trim(arrColumnNames(iItemCounter)) = "Block Size" Then
							intBlockSize = iItemCounter + 1
						End If
					Next '#iItemCounter
					strTGLinked = .GetCellData(iRow, intParentNameIndex)
					strBlockStartNumber = .GetCellData(iRow,intBlockStartNumber)
					strBlockSize = .GetCellData(iRow,intBlockSize)
			End If
	End With

	'--------------------------------------------------- Add Number Block '--------------------------------------------------- 
	With objTblNumberBlockDetails
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
			blnResult = objPage.WebList("lstNumberType").Exist(10)
			If blnResult Then
					blnResult  = selectValueFromPageList("lstNumberType", NumberType)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			Else
					Call ReportLog("lstNumberType", "WebList Should Exist", "WebList doesnt exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
			End If

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			blnResult  = selectValueFromPageList("lstBTSupplied", BTSupplied)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			If BTSupplied = "No" Then
				'Enter Supplier Name is BT Supplied is Yes
				blnResult  = enterText("txtSupplier", Supplier)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
					
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				
				If objPage.WebList("lstThirdPartyCLI").Exist(10) Then
					blnResult = selectValueFromPageList("lstThirdPartyCLI",dThirdPartyCLI)
						If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
				End If
			End If

			'Enter Block Start Number which has been Removed
			blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			'Enter the Block Size
			blnResult  = enterText("txtNumberBlockSize", strBlockSize)
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

			'Select the Trunk Group
			If strTGLinked <> "" Then
				blnResult  = selectValueFromPageList("lstTrunkGroupToBeLinked", strTGLinked)
					If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
			Else
				Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
			End If
				

			blnResult = clickButton("btnSave")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
				Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
				Wait 10
			End If
	End With

	'--------------------------------------------------- End of Add Number Block '--------------------------------------------------- 

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigfated to BillingDetails page
	Set objMsg = objpage.WebElement("webElmBillingDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If
		
End Function
