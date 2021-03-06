'*******************************************************************************************************************************************************************************
' Description	 : Function to Create Central Site by Filling Address Details
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	29/06/2015	NA
' Parameters	 : 	BuildingName, BuildingNumber, Street, City, State/County/Province, Country, ZIPPostalCode
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_FillCustomerDetails(ByVal BuildingName, ByVal BuildingNumber, ByVal Street, ByVal City, ByVal State_County_Province, ByVal Country, ByVal ZIPPostalCode)

	'Variable Declaration
	Dim intCounter
	Dim objTable, objElm
	
	'Build Reference
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Click on Customer Detail Tab
	blnResult = clickLink("lnkCustomerDetails")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
	objPage.WebEdit("txtCentralBuildingName").WaitProperty "height", micGreaterThan(0), 10000*6*2

	'Enter Buidling Name
	'blnResult = enterText("txtCentralBuildingName", BuildingName)
		'If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Buidling Number
	'blnResult = enterText("txtCentralBuidingNumber", BuildingNumber)
		'If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Street
	'blnResult = enterText("txtCentralStreet", Street)
		'If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter City
	blnResult = enterText("txtCentralCity", City)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	If Country = "UNITED STATES" Then
		blnResult = enterText("txtCentralStateCountyProvince", State_County_Province)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Country Name
	objPage.WebEdit("txtCentralCountry").Click : Wait 1
	objPage.Image("alt:=Menu for Country", "index:=0").Object.Click

	blnResult = fn_Expedio_SelectValueFromDropDown(objPage, Country, objPage.WebEdit("txtCentralCountry"))
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter ZipCode
	blnResult = enterText("txtCentralZipCode", ZIPPostalCode)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Click on Search Address Button
	blnResult = clickLink("lnkSearchAddress")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Wait 20
	
	For intCounter = 1 to 10
		objPage.WebTable("tblAddressValidation").RefreshObject
		Set objTable = objPage.WebTable("tblAddressValidation")
		blnExist = objTable.Exist(10)
		If blnExist Then
			Exit For
		End If
	Next

	If Not blnExist Then
		Call ReportLog("Site Details", "Site Details should be populated in Address", "Site Details is not populated", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	intRow = objTable.GetRowWithCellText(ZIPPostalCode)
	If intRow <= 0 Then
		Call ReportLog("Search Address", "Address search should result adresses which contain ZIP Code - " & ZIPPostalCode, ZIPPostalCode & " - was not populated on Search Address", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)
	If objElm.Exist(5) Then
		objElm.HighLight
		objElm.Click
		Wait 5
	End If

	'Handle pop up and click on no link
	If Browser("brwManagePlaceResult").Exist Then
		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
			"Pop Up appeared", "PASS", False)
		Browser("brwManagePlaceResult").Page("pgManagePlaceResult").Link("lnkNo").Object.click
	Else
		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
			"Pop Up did not appear", "FAIL", True)
		Environment("Action_Result")  =False
		Exit Function
	End If
	
	Wait 5

	'Click on Get Geo Code
	objPage.Link("lnkGetGeoCode").SetTOProperty "index", 0
	objPage.Link("lnkGetGeoCode").Object.click
	objPage.Link("lnkGetGeoCode").SetTOProperty "index", 1

	Wait 2

	'Handle the Pop Up - Click Ok/Yes
	objTable.RefreshObject
	intRow = objTable.GetRowWithCellText(ZIPPostalCode)
	If intRow <= 0 Then
		Call ReportLog("Search Address", "Search Address should return Valid result", "Searched for " & ZIPPostalCode & " and found invalid result against this search", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)
	If objElm.Exist(5) Then
		objElm.HighLight
		objElm.Click
		Wait 5
	End If

	'Handle pop up and click on Yes link
	If Browser("brwManagePlaceResult").Exist(120) Then
		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
			"Pop Up appeared", "PASS", False)
		Browser("brwManagePlaceResult").Page("pgManagePlaceResult").Link("lnkYes").Object.click
	Else
		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
			"Pop Up did not appear", "FAIL", True)
		Environment("Action_Result")  =False
		Exit Function
	End If

	Wait 5

	'Check whether the Latitude and longitude has been populated or not
	For intCounter = 1 to 20
		strLatitude = objPage.WebEdit("txtCentralLatitude").GetROProperty("innertext")
		If strLatitude <> "" Then
			Exit For
		Else
			Wait 5
		End If
	Next

	If strLatitude = "" Then
		Call ReportLog("Check Latitude Field","Latitude Field should be populated","Latitude field is not populated","FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Check Latitude Field","Latitude Field should be populated","Latitude field is populated: " & strLatitude,"INFORMATION", False)
	End If

	strLongitude = objPage.WebEdit("txtCentralLongitude").GetROProperty("innertext")
	If strLongitude = "" Then
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is not populated","FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is populated: " & strLongitude,"INFORMATION", False)
	End If

	'##
	
	'##

	'Check Whether RFO Fields are updated or not
	If objPage.WebEdit("txtCentralBuildingName").GetROProperty("value") = "" Then
		blnResult = enterText("txtCentralBuildingName", BuildingName)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	If objPage.WebEdit("txtCentralBuidingNumber").GetROProperty("value") = "" Then
		blnResult = enterText("txtCentralBuidingNumber", BuildingNumber)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	If objPage.WebEdit("txtCentralStreet").GetROProperty("value") = "" Then
		blnResult = enterText("txtCentralStreet", Street)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	If objPage.WebEdit("txtCentralCity").GetROProperty("value") = "" Then
		blnResult = enterText("txtCentralCity", City)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	If objPage.WebEdit("txtCentralZipCode").GetROProperty("value") = "" Then
		blnResult = enterText("txtCentralZipCode", ZIPPostalCode)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Click on Create Customer Site Button
	blnResult = clickLink("lnkCreateCustomerSite")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteCreationMsg").Exist(300) Then
		objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteCreationMsg").WaitProperty "height", micGreaterThan(0), 1000*60*5 
		Call ReportLog("Central Site Creation", "Site Creation Message should be displayed", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteCreationMsg").GetROProperty("innertext"), "PASS", True)
		objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		Environment("Action_Result") = True
	Else
		If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteCreationMsg").Exist(10) Then
			Call ReportLog("Central Site Creation", "Site Creation Message should be displayed", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteCreationMsg").GetROProperty("innertext"), "PASS", True)
			objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
			Environment("Action_Result") = True
		Else
			Call ReportLog("Central Site Creation", "Site Creation Message should be displayed", "Site Creation was unsuccessfull", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

End Function
