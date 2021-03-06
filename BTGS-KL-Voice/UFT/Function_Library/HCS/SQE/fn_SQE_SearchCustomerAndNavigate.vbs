'=================================================================================================================================
' Description	: Search Customer and navigate to specified screen
' History		:		Name		Date		Version
' Created By	: 	Nagaraj V	29/04/2015		v1.0
' Example	: fn_SQE_SearchCustomerAndNavigate "BTGS UK", "R43AUTOUK03", "ManageQuote"
'=================================================================================================================================
Public Function fn_SQE_SearchCustomerAndNavigate(ByVal SalesChannel, ByVal CustomerName, ByVal Operation)
	
	Dim blnCustomerFound
	blnCustomerFound = False

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwCustomerQuoteManagement","pgCustomerQuoteManagement","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Existing Customer
	blnResult = clickLink("lnkExistingCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 1 Step 1
		clickWebElement "elmSalesChannelDownArrow"
		Wait 2
		enterText "txtSalesChannel", SalesChannel
		Wait 2
		objPage.WebElement("elmSalesChannel").SetTOProperty "innerText", SalesChannel & Space(1)
		blnResult = clickWebElement("elmSalesChannel")
		If Not blnResult Then 
			Environment("Action_Result") = False
			Exit Function
		Else
			Exit For
		End If
	Next
	
	Setting.WebPackage("ReplayType") = 2 'Mouse Events
	For intCounter = 1 To 5
		objPage.WebEdit("txtCustomer").Set ""
		objPage.WebElement("elmCustomerName").SetTOProperty "innertext", CustomerName
		objPage.WebEdit("txtCustomer").Click
		CreateObject("Mercury.DeviceReplay").SendString CustomerName
		blnResult = objPage.WebElement("elmCustomerName").Exist(60)
		If blnResult Then
			objPage.WebElement("elmCustomerName").Click
			blnCustomerFound = True
			Setting.WebPackage("ReplayType") = 1 'Web Events
			Exit For '#intCounter
		Else
			Wait 30
		End If
	Next '#intCounter
	Setting.WebPackage("ReplayType") = 1 'Web Events
	
	If Not blnCustomerFound Then
		Call ReportLog("Select Customer", "On typing Customer Name Dropdown should be listed", "On typing Customer Name <B>" & CustomerName & "</B> is not populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebList("lstContractID/ContractReference").WaitProperty("value", micNotEqual("#0"), 1000*60*2)
	If Not blnResult Then
		Call ReportLog("Select Contract", "Contract ID should be auto populated", "Contract ID is not auto populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebButton("btn" & Operation).WaitProperty("disabled", 0, 1000*60*2)
	If Not blnResult Then
		Call ReportLog(Operation, Operation & " Button should be enabled", Operation & " Button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Wait 5
	End If
	
	'Click on Operation
	blnResult = clickButton("btn" & Operation)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	If Operation = "ManageQuote" Then
		blnResult = objPage.WebElement("elmManageQuotes").Exist(180)
		If Not blnResult Then
			Call ReportLog(Operation, "Should be navigated to [Manage Quotes] screen", "Unable to navigate to [Manage Quotes] screen", "FAIL", True)
			Environment("Action_Result") = False
		Else
			Call ReportLog(Operation, "Should be navigated to [Manage Quotes] screen", "Navigated to [Manage Quotes] screen", "PASS", True)
			Environment("Action_Result") = True
		End If
	ElseIf Operation = "TrackOrder" Then
		blnResult = objPage.WebElement("elmOrders").Exist(180)
		If Not blnResult Then
			Call ReportLog(Operation, "Should be navigated to [Orders] screen", "Unable to navigate to [Orders] screen", "FAIL", True)
			Environment("Action_Result") = False
		Else
			Call ReportLog(Operation, "Should be navigated to [Orders] screen", "Navigated to [Orders] screen", "PASS", True)
			Environment("Action_Result") = True
		End If
	ElseIf Operation = "ManageSite" Then
		blnResult = objPage.WebElement("elmManageSites").Exist(180)
		If Not blnResult Then
			Call ReportLog(Operation, "Should be navigated to [Manage Sites] screen", "Unable to navigate to [Manage Sites] screen", "FAIL", True)
			Environment("Action_Result") = False
		Else
			Call ReportLog(Operation, "Should be navigated to [Manage Sites] screen", "Navigated to [Manage Sites] screen", "PASS", True)
			Environment("Action_Result") = True
		End If
	End If
	
End Function
