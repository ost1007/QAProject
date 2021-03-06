Public Function fn_SQE_ManageAdvancedBillingCapability(ByVal LegalCompanyName, ByVal AccountClassification)

	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebElement("elmAdvancedBillingCapability").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickWebElement("elmAdvancedBillingCapability")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	Call fn_SQE_PleaseWait(objPage)
	
	Set elmRowCell = objPage.WebElement("class:=ng-binding", "html tag:=SPAN", "innertext:=" & LegalCompanyName, "index:=0")
	If Not elmRowCell.Exist(60) Then
		Call ReportLog("Billing Record", "Billing Record should be displayed", "Biiling record - <B>" & LegalCompanyName & "</B> should be displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		elmRowCell.Click
	End If
	
	blnResult = objPage.WebList("lstLegalCompanyName").WaitProperty("selection", LegalCompanyName, 1000*60*1)
	If Not blnResult Then
		Call ReportLog("Advance Billing", "Legal Company Name should be populated", "Legal Company Name is not yet populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = selectValueFromPageList("lstAccountClassification", AccountClassification)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickButton("btnUpdateLegalEntity")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	Call fn_SQE_PleaseWait(objPage)

	blnResult = objPage.WebElement("elmUpdateLegalEntityMessage").Exist(120)
	If Not blnResult Then
		Call ReportLog("Account Classification", "Account Classification should be updated successfully", "Account classification update message did not appear", "FAIL", True)
		Environment("Action_Result") = False
	Else
		Call ReportLog("Account Classification", "Account Classification should be updated successfully", "Account classification update message is displayed", "Information", True)
		blnResult = clickButton("btnOkay")
		Environment("Action_Result") = True
	End If
	
	objBrowser.Close
	
End Function
