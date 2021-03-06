Public Function fn_SQE_BillingContact(ByVal BACFirstName, ByVal BACLastName, ByVal BACJobTitle, ByVal BuildingName, ByVal BuildingNumber, ByVal Street, ByVal City, ByVal State_County_Province, ByVal Country, ByVal ZIPPostalCode, ByVal BACPhoneNumber,_
	ByVal AccountName, ByVal CustomerBillingRef, ByVal BillPeriod, ByVal USScenario, Byval InvoiceLanguage, ByVal BillingCurrency, ByVal PaymentDays, ByVal InfoCurrency, ByVal PaymentMethod)
	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebElement("elmBillingDetails").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickWebElement("elmBillingAccount")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	Call fn_SQE_PleaseWait(objPage)
	
	blnResult = objPage.WebEdit("txtLECompanyName").Exist(60)
	If Not blnResult Then
		Call ReportLog("LE Company Name", "LE Company Name should be displayed", "LE Company is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If objPage.WebEdit("txtLECompanyName").GetROProperty("value") = "" Then
		Call ReportLog("LE Company Name", "LE Comapny Name should be displayed", "Legal Entity is not yet created", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = enterText("txtFirstName", BACFirstName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtLastName", BACLastName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtJobTitle", BACJobTitle)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtBuildingName", BuildingName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtBuildingNumber", BuildingNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtStreet", Street)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtCity", City)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	If Strcomp(Country, "United States", vbTextCompare) = 0 Then
		blnResult = enterText("txtStateCountyProvince", State_County_Province)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
		
	blnResult = enterText("txtPostCode", ZIPPostalCode)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = enterText("txtBACPhoneNumber", BACPhoneNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = selectValueFromPageList("lstCountry", Country)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	For intCounter = 1 To 5
		blnResult = objPage.WebButton("btnSearchAddress").Exist(30)
	Next
	
	blnResult = clickButton("btnSearchAddress")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 10
		If objPage.WebElement("elmSearchAddressMsg").Exist(30) Then
			Call ReportLog("Address Search", "Address Search should be successful", "Address search was unsuccessful. Retry by providing valid details", "FAIL", True)
			blnResult = clickButton("btnOkay")
			objBrowser.Close
			Environment("Action_Result") = False : Exit Function
		ElseIf objPage.WebElement("elmSearchResults").Exist(30) Then
			Exit For
		End If
	Next

	Set elmRow = objPage.WebElement("class:=ng-scope ngRow even", "index:=0")
	If Not elmRow.Exist(30) Then
		Call ReportLog("Postal Code", "Postal Code Search with " & PostCode & " should be successful", "Postal Code Search with " & PostCode & " was unsuccessful", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	elmRow.HighLight
	elmRow.Click
	
	If objPage.WebElement("elmUpdateLatitudeLongitude").Exist(60) Then
		blnResult = clickButton("btnYes")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Update Address Details", "Message should appear for updating Latitude and Logitude", "Message did not appear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	objBrowser.fSync
	
	blnLatLongPopulated = False
	For intCounter = 1 To 2
		strLatitude = Trim(objPage.WebEdit("txtLatitude").GetROProperty("value"))
		strLogitude = Trim(objPage.WebEdit("txtLongitude").GetROProperty("value"))
		If strLatitude = "" OR strLogitude = "" Then
			Wait 30
		Else
			blnLatLongPopulated = True
			Exit For
		End If
	Next
	
	If Not blnLatLongPopulated Then
		objPage.WebEdit("txtLatitude").Click	
		Call ReportLog("Latitude & Logitude", "Latitude and Longitude should be populated", "Latitude/Longitude is not populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Capture Latitide", "Latitude should be populated", "Latitude is found to be <B>" & strLatitude & "</B>", "Information", False)
		Call ReportLog("Capture Longitude", "Longitude should be populated", "Longitude is found to be <B>" & strLogitude & "</B>", "Information", False)
	End If
	
	Wait 10
	
	'### Enter Billing Details
	blnResult = enterText("txtAccountName", AccountName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = enterText("txtCustomerBillingReference", CustomerBillingRef)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = selectValueFromPageList("lstBillPeriod", BillPeriod)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = objPage.WebElement("elmNonStandardMessage").Exist(30)
	If blnResult Then
		if objPage.WebElement("elmNonStandardMessage").GetROProperty("height") > 0 Then
			objPage.WebButton("btnOkay").Click
			Wait 3
		End If
	End If
		
	blnResult = selectValueFromPageList("lstUSScenario", USScenario)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = selectValueFromPageList("lstInfoCurrency", InfoCurrency)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = selectValueFromPageList("lstPaymentDays", PaymentDays)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = objPage.WebElement("elmNonStandardMessage").Exist(30)
	If blnResult Then
		if objPage.WebElement("elmNonStandardMessage").GetROProperty("height") > 0 Then
			objPage.WebButton("btnOkay").Click
			Wait 3
		End If
	End If
	
	blnResult = selectValueFromPageList("lstInvoiceLanguage", InvoiceLanguage)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = selectValueFromPageList("lstBillingCurrency", BillingCurrency)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = selectValueFromPageList("lstPaymentMethod", PaymentMethod)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Rem Activation date selection
	strDate = (Date + 1)
	strMonth = MonthName(Month(strDate), False)
	If Not objPage.WebEdit("txtActivationDate").Exist(60) Then
		Call ReportLog("Activation Date", "Activation Date should be visible", "Activation Date is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		objPage.WebEdit("txtActivationDate").Click
	End If
	
	Set lblMonth = objPage.WebElement("class:=ui-datepicker-month")
	If Not lblMonth.Exist(60) Then
		Call ReportLog("Calendar", "Month Name should be displayed in calendar", "Month Name is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strDisplayedMonth = lblMonth.GetROProperty("innerText")
	If StrComp(strMonth, strDisplayedMonth, vbtextCompare) <> 0 Then
		Set lblNext = objPage.WebElement("html tag:=SPAN","innertext:=Next", "index:=0")
		If Not lblNext.Exist(60) Then
			Call ReportLog("Next Month", "Next button should be displayed to select Next month", "Next button is not displayed", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		lblNext.Click
		Wait 2
	End If
	
	Set oDate = objPage.Link("name:=" & Day(strDate), "index:=0")
	If Not oDate.Exist(60) Then
		Call ReportLog("Date Selection", Day(strDate) & " - should be selected", Day(strDate) & " - link is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		oDate.Click
		Wait 2
	End If
	
	objPage.WebEdit("txtActivationDate").RefreshObject
	strDateSelected = objPage.WebEdit("txtActivationDate").GetROProperty("value")
	If DateDiff("d", strDateSelected, strDate) = 0 Then
		Call ReportLog("Activation Date", strDate & " - is to be selected", strDateSelected & " - is selected", "Information", False)
	Else
		Call ReportLog("Activation Date", strDate & " - is to be selected", strDateSelected & " - is selected", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'strDate = fRegExpReplaceText(Cstr(Date + 1), "(\d{2})/(\d{2})/(\d{4})", "$2/$1/$3")
	'blnResult = enterText("txtActivationDate", strDate)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	If Not objPage.WebButton("btnCreateNewAccount").Exist(60) Then
		Call ReportLog("btnCreateNewAccount", "Button should exist", "Button doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebButton("btnCreateNewAccount").WaitProperty("disabled", False, 1000*60*2)
	If Not blnResult Then
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
		Call ReportLog("Create New Account", "Create New Account button should be enabled", "Create New Account button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = clickButton("btnCreateNewAccount")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Call fn_SQE_PleaseWait(objPage)
	
	For intCounter = 1 To 7
		blnResult = objPage.WebElement("elmBillingAccountMsg").Exist(30)
		If blnResult Then
			strMessage = objPage.WebElement("elmBillingAccountMsg").GetROProperty("innerText")
			Exit For
		End If
	Next '#intCounter
	
	If Not blnResult Then
		Call ReportLog("Billing Account", "Billing Account should be created", "Billing Account is not created", "FAIL", True)
		If objPage.WebButton("btnOkay").Exist(0) Then objPage.WebButton("btnOkay").Click
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Billing Account", "Billing Account should be created", strMessage, "PASS", True)
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Environment("Action_Result") = True
	End If
	
End Function
