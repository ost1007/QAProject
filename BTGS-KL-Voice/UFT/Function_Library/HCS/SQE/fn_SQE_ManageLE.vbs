Public Function fn_SQE_ManageLE(ByVal LegalCompanyName)

	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebElement("elmBillingDetails").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = clickWebElement("elmBillingDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Call fn_SQE_PleaseWait(objPage)
	
	blnResult = clickWebElement("elmManageLE")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Call fn_SQE_PleaseWait(objPage)
	
	blnResult = setCheckBox("chkSameAsCustomerSite", "ON")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Call fn_SQE_PleaseWait(objPage)
		
	blnResult = enterText("txtLegalCompanyName", LegalCompanyName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = clickButton("btnCreateLE")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Call fn_SQE_PleaseWait(objPage)
	
	For intCounter = 1 To 10
		blnExist = objPage.WebElement("elmCreateLEMsg").Exist(30)
			If blnExist Then Exit For
	Next
	
	If Not blnExist Then
		Call ReportLog("Create LE", "Create LE message should appear", "Create LE message did not appear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = objPage.WebElement("elmCreateLEMsg").GetROproperty("innerText")
		Call ReportLog("Create LE", "Create LE message should appear", strMessage, "PASS", True)
	End If
	
	blnREsult = clickButton("btnOkay")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
End Function

