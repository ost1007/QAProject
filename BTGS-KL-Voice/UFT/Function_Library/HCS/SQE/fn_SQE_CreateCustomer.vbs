Public Function fn_SQE_CreateCustomer(ByVal SalesChannel, ByVal CustomerName)
	CUSTOMER_EXISTS = "^Customer with name: .* already exists\.$"
	CUSTOMER_CREATE = "Do you want to create customer with name: " & CustomerName & "\?$"
	CUSTOMER_CREATE_SUCCESS = "^Customer " & CustomerName & " is successfully created with customer ID:\d+\.$"
	
	Dim strMessageText, strMatchValue
	Dim intCounter
	strMatchValue = ""
	
	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").Link("lnkCreateCustomer").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickLink("lnkCreateCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	For intCounter = 1 To 5
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebList("lstCreateSalesChannel").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = selectValueFromPageList("lstCreateSalesChannel", SalesChannel)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCreateCustomerName", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = objPage.WebButton("btnCreateCustomer").Exist(60)
	If Not blnResult Then
		Call ReportLog("Create Customer", "Create Customer Button should exist", "Create Customer button does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebButton("btnCreateCustomer").WaitProperty("disabled", 0, 1000*60*1)
	If Not blnResult Then
		Call ReportLog("Create Customer", "Create Customer Button should be enabled", "Create Customer button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = clickButton("btnCreateCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	For intCounter = 1 To 30
		Print intCounter
		If objPage.WebElement("elmPleaseWait").Exist(10) Then
			Print ("Please wait EXIST")
			Wait 5
			Print ("after wait")
		Else
			Print ("Please wait NOT EXIST")
			Exit For
		End If
	Next
	
	Print ("exit loop")
	
	For intCounter = 1 To 5
		blnResult = objPage.WebElement("elmCustomerCreationMsg").Exist(60)
		If blnResult Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("Customer Creation", "Customer Creation message should be displayed", "Customer Creation message does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebElement("elmCustomerCreationMsg").WebElement("elmInnerMessage").Exist(60)
	If Not blnResult Then
		Call ReportLog("Customer Creation", "Customer Creation sub-message should be displayed", "Customer Creation sub-message does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strMessageText = objPage.WebElement("elmCustomerCreationMsg").WebElement("elmInnerMessage").GetROProperty("innerText")
	If getCountOfRegExpPattern(CUSTOMER_EXISTS, strMessageText, True, strMatchValue) >= 1 Then
		Call ReportLog("Customer Creation", "Customer should not be existing", strMatchValue, "FAIL", True)
		clickButton("btnOkay")
		'objBrowser.Close
		Environment("Action_Result") = False : Exit Function
	ElseIf getCountOfRegExpPattern(CUSTOMER_CREATE, strMessageText, True, strMatchValue) >= 1 Then
		Call ReportLog("Customer Creation", "<B>" & CUSTOMER_CREATE & "</B> - message should exist", strMatchValue, "PASS", True)
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 To 30
		Print intCounter
		If objPage.WebElement("elmPleaseWait").Exist(10) Then
			Wait 10
		Else
			Exit For
		End If
	Next
	
	objPage.WebElement("elmCustomerCreationMsg").RefreshObject
	objPage.WebElement("elmCustomerCreationMsg").WebElement("elmInnerMessage").RefreshObject
	blnResult = objPage.WebElement("elmCustomerCreationMsg").WebElement("elmInnerMessage").Exist(60)
	If Not blnResult Then
		Call ReportLog("Customer Creation", "Customer Creation sub-message should be displayed", "Customer Creation sub-message does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strMessageText = objPage.WebElement("elmCustomerCreationMsg").WebElement("elmInnerMessage").GetROProperty("innerText")
	If getCountOfRegExpPattern(CUSTOMER_CREATE_SUCCESS, strMessageText, True, strMatchValue) >= 1 Then
		Call ReportLog("Customer Creation", "<B>" &CUSTOMER_CREATE_SUCCESS & "</B> - message should exist", strMatchValue, "PASS", True)
		Wait 20
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Customer Creation", "<B>" &CUSTOMER_CREATE_SUCCESS & "</B> - message should exist", strMatchValue, "FAIL", True)
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	Call fn_SQE_PleaseWait(objPage)
	
	For intCounter = 1 To 10
		blnResult = objPage.WebElement("elmSelectDifferentCustomer").Exist(30)
		If blnResult Then
			Call ReportLog("Manage Customer", "Should be navigated to Customer Manage page", "Navigated to customer manage page", "Information", True)			
			Exit For
		End If
	Next
End Function
