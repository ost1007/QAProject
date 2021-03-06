Public Function fn_SQE_CreateCustomerSite(ByVal CustomerValidationStatus, ByVal BuildingName, ByVal BuildingNumber, ByVal Street, ByVal City, ByVal State_County_Province, ByVal Country, ByVal ZIPCode)

	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebElement("elmCustomerSite").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = clickWebElement("elmCustomerSite")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	If Not objPage.WebEdit("txtCompanyName").Exist(60) Then
		Call ReportLog("Company Name", "Company Name WebEdit should exist", "Company Name WebEdit doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebEdit("txtCompanyName").WaitProperty("value", micNotEqual(""), 1000*60*1)
	If Not blnResult Then
		Call ReportLog("Company Name", "Company name should be populated with data", "Company name is not populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		strValue = objPage.WebEdit("txtCompanyName").getROProperty("value")
		Call ReportLog("Company Name", "Company name should be populated with data", "Company name is populated with <B>" & strValue & "</B>", "Information", True)
	End If
	
	blnResult = selectValueFromPageList("lstCustValidStatusName", CustomerValidationStatus)
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
		
	blnResult = enterText("txtPostCode", ZIPCode)
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
	
	blnResult = clickButton("btnCreate")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(10) Then
			Wait 10
		Else
			Exit For
		End If
	Next
	
	For intCounter = 1 To 10
		blnResult = objPage.WebElement("elmCreateCustomerSite").Exist(30)
			If blnResult Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("Customer Site Creation", "Customer Site Creation message should apear", "Customer Site Cration message did not appear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If Not objPage.WebElement("elmCreateCustomerSite").WebElement("elmCentralSiteMessage").Exist(60) Then
		Call ReportLog("Customer Site Creation", "Customer Site Creation sub-message should apear", "Customer Site Creation sub-message did not apear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strMessage = objPage.WebElement("elmCreateCustomerSite").WebElement("elmCentralSiteMessage").GetROProperty("innerText")
	If Instr(strMessage,"Central site successfully created for customer") > 0 Then
		Call ReportLog("Customer Site Creation", "Central site should be successfully created for customer", strMessage, "PASS", True)
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Customer Site Creation", "Central site should be successfully created for customer", strMessage, "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

End Function
