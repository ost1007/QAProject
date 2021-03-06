'****************************************************************************************************************************
' Function Name 		:		fn_SQE_CreateOffer
' Purpose				: 		Function to Create Offer
' Author				:		Linta C.K.
' Creation Date  		: 		08/7/2014	        					     
' Return Values	 		:		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_CreateOffer(ByVal OfferName, ByVal CustomerOrderReference)
	On Error Resume Next
	Dim intConfiguredCol
		
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Check for Product Line Items Populated
	blnResult = objPage.WebTable("tblProductLineItems").WaitProperty("rows", micGreaterThan(1), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Product Line Item", "Product Line Item Table should be populated", "Product Line Item Table is not populated with Line Items", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		intRows = objPage.WebTable("tblProductLineItems").RowCount
	End If
	
	arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	For intCounter = 0 To UBound(arrColumns) Step 1
		If Trim(arrColumns(intCounter)) = "Configured" Then
			intConfiguredCol = intCounter + 1
			Exit For
		End If
	Next '#intCounter
	
	For intCounter = 1 To 30
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intRows,intConfiguredCol)
		If strConfigured = "" Then
			Wait 10
		Else
			Exit For '#intCounter
		End If
	Next '#intCounter
	
	'Check for Configured Status
	strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intRows,intConfiguredCol)
	If strConfigured = "VALID" Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
	Else
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as '" & strConfigured & "' after bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Select Checkbox
	blnResult = setCheckBox("chkListOfQuoteOptionItems", "ON")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Create Offer
	blnResult = clickLink("lnkCreateOffer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Offer Name
	objPage.WebEdit("txtOfferName").WaitProperty "height", micGreaterThan(0), 1000*60*1
	blnResult = enterText("txtOfferName",OfferName)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	Wait 5
	
	'Enter Customer Order Reference
	blnResult = enterText("txtCustomerOrderReference",CustomerOrderReference)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Save
	blnResult = clickButton("btnSave")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Check if navigated to Offers Link
	blnResult = objPage.Link("lnkOffers").Exist(120)
	If blnResult Then
		blnResult = objPage.Link("lnkOffers").WaitProperty("height", micGreaterThan(0), 1000*60*2)
		If blnresult Then
			objPage.Link("lnkOffers").Object.Click
			Call ReportLog("Save Offer Details","User should be able to save offer details and navigate to Offers link","User is able to save offer details and navigate to Offers link","PASS","False")
		End If
	End If
	
	If Not blnResult Then
		Call ReportLog("Save Offer Details","User should be able to save offer details and navigate to Offers link","User is able to save offer details and unable navigate to Offers link","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	'Check Offer Status
	blnResult = objPage.WebTable("tblOffers").Exist(120)
	If blnResult Then
		strStatus = Trim(objPage.WebTable("tblOffers").GetCellData(2,4))
		If strStatus = "Active" Then
			blnResult = objPage.Image("imgCustomerApprove").Exist
			If blnResult Then
				blnResult = clickImage("imgCustomerApprove")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Else
				Call ReportLog("Customer Approve","CustomerApprove image should exist","CustomerApprove image does not exist","FAIL","True")
				Environment("Action_Result") = False : Exit Function
			End If
		ElseIf strStatus = "Approved" Then
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is Approved","PASS","False")
			Exit Function
		Else
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is not Approved, instead - " & strStatus, "FAIL", "True")
			Environment("Action_Result") = False : Exit Function
		End If
	Else
		Call ReportLog("Offer Details","Offers Table should be visible for Cusomter Approval","Offers Table is not visible for Cusomter Approval","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Check for Approved status after clicking on Customer Approve Image
	For intCounter = 1 to 10
		strStatus = Trim(objPage.WebTable("tblOffers").GetCellData(2,4))
		If strStatus = "Approved" Then
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is <B>" & strStatus & "</B>", "PASS", True)
			Exit For
		Else
			Wait 5
		End If
	Next

	If strStatus <> "Approved" Then
		Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is displayed as - <B>" & strStatus & "</B>","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Set innertext for Offer Name
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = OfferName

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count >= 1 Then
			objElm(0).Click
            Exit For
		End IF
	Next

	If objElm.Count = 0 Then
		Call ReportLog("Offer Name","User should be able to click on Offer Name","Offer Name does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	blnResult = objBrowser.Page("pgOfferDetails").Link("lnkOfferDetails").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If blnResult Then
		Call ReportLog("Offer Details Tab","User should be able to navigate to Offer Details on clicking offer name","User is able to navigate to Offer Details on clicking offer name","PASS","False")
		Environment.Value("Action_Result") = True
	Else
		Call ReportLog("Offer Details Tab","User should be able to navigate to Offer Details on clicking offer name","User is not able to navigate to Offer Details on clicking offer name","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
