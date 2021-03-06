'=================================================================================================================================
' Description	: Function to Fill Details and Create Quote
' History		:		Name		Date		Version
' Created By	: 	Nagaraj V	29/04/2015		v1.0
' Example	: fn_SQE_CreateQuote "OCC_CONTRACT", "Provide", "12", "GBP", "QT_BCM"
'=================================================================================================================================
Public Function fn_SQE_CreateQuote(ByVal QuoteName, ByVal OrderType, ByVal ContractTerm, ByVal Currncy, ByVal OpportunityRefNumber)	
	
	Dim iWaitCntr, intInitWait
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwCustomerQuoteManagement","pgCustomerQuoteManagement","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'	If Not objPage.WebElement("elmCreateQuote").Exist(30) Then
	'		blnResult = clickWebElement("elmManageQuotes")
	'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'							
	'		For iWaitCntr = 1 To 50
	'			If objPage.WebElement("elmPleaseWait").Exist(5) Then
	'				Wait 5
	'			Else
	'				Exit For '#iWaitCntr
	'			End If	
	'		Next '#iWaitCntr
	'		
	'		objBrowser.fSync
	'		objBrowser.RefreshObject
	'		If objPage.Link("lnkExistingCustomer").Exist(30) Then
	'			Call fn_SQE_SearchCustomerAndNavigate(SalesChannel, CustomerName, "ManageQuote")
	'			If Not Environment("Action_Result") Then Exit Function
	'		End If
	'	End If
	
	blnResult = clickWebElement("elmCreateQuote")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	intInitWait = 30
	For iWaitCntr = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(intInitWait) Then
			intInitWait = 10
			Wait 10
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	'Enter the Quote Name
	blnResult = enterText("txtQuoteName", QuoteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Order Type
	blnResult = selectValueFromPageList("lstOrderType", OrderType)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Contract Term
	blnResult = selectValueFromPageList("lstContractTerm", ContractTerm)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Currency
	blnResult = selectValueFromPageList("lstCurrency", Currncy)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter the Quote Name
	blnResult = enterText("txtOpportunityRefNumber", OpportunityRefNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select Quote Indicative Flag
	blnResult = selectValueFromPageList("lstQuoteIndicativeFlag", "Firm")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = objPage.WebButton("btnCreateQuote").WaitProperty("disabled", 0, 1000*60*1)
	If Not blnResult Then
		Call ReportLog("Create Button", "Create Button should be enabled", "Create Button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function	
	End If
	
	'Click on Create Button
	blnResult = clickButton("btnCreateQuote")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	intInitWait = 30
	For iWaitCntr = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(intInitWait) Then
			intInitWait = 10
			Wait 10
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	If objPage.WebElement("elmMsgQuoteCreation").Exist(300) Then
		Call ReportLog("Create Quote", "Quote Creation message should appear", "Quote Creation message is displayed", "PASS", True)
		objPage.WebButton("btnOkay").Click
		Environment("Action_Result") = True
	Else
		Call ReportLog("Create Quote", "Quote Creation message should appear", "Quote Creation message is not displayed even after 5mins", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
End Function
