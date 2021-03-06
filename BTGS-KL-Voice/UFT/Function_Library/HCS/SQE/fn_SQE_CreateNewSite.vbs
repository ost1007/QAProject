Public Function fn_SQE_CreateNewSite(BuildingName, BuildingNumber, Room, Floor, Street, City, County, Country, PostCode)
	Const REGION_NOT_CONFIGURED = "Region is not configured for the selected customer and country in BFG"
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwCustomerQuoteManagement","pgCustomerQuoteManagement","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickWebElement("elmCreateSites")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	strSiteName = Ucase("ZAutom" & Replace(Replace(Replace(CStr(Day(Date) & Time), "/", ""),":","")," ",""))
	Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dSiteName",strSiteName)
	Call ReportLog("Create New Site","Generate Site Name","Generated Site Name is <B>" & strSiteName & "</B>","INFORMATION", False)
	
	blnResult = enterText("txtSiteName", strSiteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCompanyName", strSiteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtBuildingName", BuildingName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtBuildingNumber", BuildingNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtRoom", Room)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtFloor", Floor)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtStreet", Street)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'blnResult = enterText("txtLocality", Locality)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCity", City)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	If Strcomp(Country, "united states", vbTextCompare) = 0 Then
		blnResult = enterText("txtStateCountyProvince", County)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	End If
	
	blnResult = selectValueFromPageList("lstCountry", Country)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCity", City)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtPostCode", PostCode)
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
	
	'Set elmPostCode = objPage.WebElement("html tag:=SPAN", "innertext:=" & PostCode, "index:=0")
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
	For intCounter = 1 To 10
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
	
	blnResult = clickButton("btnCreateBranchSite")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	If objPage.WebElement("elmRegionNotConfigured").Exist(120) Then
		blnResult = clickButton("btnOkay")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Create Branch Site", REGION_NOT_CONFIGURED + " message should appear", "Message did not appear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 To 10
		If objPage.WebElement("elmBranchCreationMsg").Exist(20) Then
			Call ReportLog("Branch Creation", "Branch Site creation message should appear", "Branch site creation message has appeared", "PASS", True)
			blnResult = clickButton("btnOkay")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Exit For
		ElseIf objPage.WebElement("elmRequestFailedForSiteCreation").Exist(20) Then
			Call ReportLog("Branch Creation", "Branch Site creation message should appear", "Request Failed while creation of Site", "FAIL", True)
			blnResult = clickButton("btnOkay")
			Environment("Action_Result") = False : Exit Function
		End If
	Next
	
	If Not blnResult Then
		Call ReportLog("Branch Creation", "Branch Site creation message should appear", "Branch site creation message did not appear", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
End Function


Function fn_SQE_GetCustomerDetails(ByVal Text, ByRef SalesChannel, ByRef Customer)
	fn_SQE_GetCustomerDetails = False
	Set regEx = New RegExp
	regEx.Pattern = "Sales Channel:\s+(.*),\s+Customer:\s+(.*),\s+Contract:\s+(.*)"
	regEx.Global = True
	regEx.IgnoreCase = True
	Set Matches = regEx.Execute(Text)
	If Matches.Count = 1 Then
		Set subMatches = Matches.Item(0).SubMatches
		SalesChannel = Trim(subMatches.Item(0))
		Customer = Trim(subMatches.Item(1))
		fn_SQE_GetCustomerDetails = True
	End If
End Function

