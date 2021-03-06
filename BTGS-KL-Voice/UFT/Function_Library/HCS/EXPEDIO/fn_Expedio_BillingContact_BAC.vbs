'*******************************************************************************************************************************************************************************
' Description	 : Function to Create Billing Account
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	29/06/2015	NA
' Parameters	 : 	FirstName, LastName, JobTitle, BuildingName, BuildingNumber, Street, City, Country, ZIPCode, PhoneNumber
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_BillingContact_BAC(ByVal FirstName, ByVal LastName, ByVal JobTitle, ByVal BuildingName, ByVal BuildingNumber, ByVal Street, ByVal City,_
													ByVal Country, ByVal ZIPCode, ByVal PhoneNumber)

	Dim intCounter, intRow
	Dim strLatitude, strLongitude
	Dim objTable, objElm
	
	'Build Reference
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Click Billing Account
	blnResult = clickLink("lnkBAC")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	

'	'Enter First Name
'	blnResult = enterText("txtBACFirstName", FirstName)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'
'	'Enter Last Name
'	blnResult = enterText("txtBACLastName", LastName)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'
'	'Enter Job Title
'	blnResult = enterText("txtBACJobTitle", JobTitle)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'
'	'Enter Building Name
'	blnResult = enterText("txtBACBuildingName", BuildingName)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'
'	'Enter Building Number
'	blnResult = enterText("txtBACBuildingNumber", BuildingNumber)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'
'	'Enter Street
'	blnResult = enterText("txtBACStreet", Street)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	'Enter City
	blnResult = enterText("txtBACCity", City)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Country
	objPage.WebEdit("txtBACCountry").Click : Wait 1
	'objPage.Image("alt:=Menu for Country", "index:=1").Object.Click
	'blnResult = enterText("txtBACCountry", Country)
	blnResult = fn_Expedio_SelectValueFromDropDownAlt(objPage, Country, objPage.WebEdit("txtBACCountry"))
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	objPage.WebEdit("txtBACCountry").Object.Click
	CreateObject("WScript.Shell").SendKeys "{ENTER}"
	Wait 2

	'Enter ZIP Code
	blnResult = enterText("txtBACZIPCode", ZIPCode)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

'	'Enter Phone Number
'	blnResult = enterText("txtBACPhoneNumber", PhoneNumber)
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Click on Search Address Button
	blnResult = clickPgLink("lnkSearchAddress", "name:=Search Address, index:=3")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Wait 10
	
	For intCounter = 1 to 10
		Set objTable = objPage.WebTable("tblBACAddressValidation")
		blnExist = objTable.Exist(20)
		If blnExist Then
			Exit For
		Else
			'Click on Search Address Button
			blnResult = clickPgLink("lnkSearchAddress", "name:=Search Address, index:=3")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	Next

	If Not blnExist Then
		Call ReportLog("Site Details", "Site Details should be populated in Address", "Site Details is not populated", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	intRow = objTable.GetRowWithCellText(ZIPCode)

	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)

	If objElm.Exist(5) Then
		objElm.HighLight
		objElm.Click
		Wait 5
	End If

	'Handle pop up and click on no link
	If Browser("brwManagePlaceResult").Exist(60) Then
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
	objPage.Link("lnkGetGeoCode").SetTOProperty "index", 3
	objPage.Link("lnkGetGeoCode").Object.click
	objPage.Link("lnkGetGeoCode").SetTOProperty "index", 1

	Wait 2

	'Handle the Pop Up - Click Ok/Yes
	objTable.RefreshObject
	intRow = objTable.GetRowWithCellText(ZIPCode)

	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)
	If objElm.Exist(5) Then
		objElm.HighLight
		objElm.Click
		Wait 5
	End If

	'Handle pop up and click on Yes link
	If Browser("brwManagePlaceResult").Exist Then
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
		strLatitude = objPage.WebEdit("xpath:=//DIV[contains(@class, 'Latitude_billing')]/TEXTAREA[1]", "index:=0").GetROProperty("innertext")
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

	strLongitude = objPage.WebEdit("xpath:=//DIV[contains(@class, 'Longitude_billing')]/TEXTAREA[1]", "index:=0").GetROProperty("innertext")
	If strLongitude = "" Then
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is not populated","FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is populated: " & strLongitude,"INFORMATION", False)
		Environment("Action_Result") = True
	End If

	'Reenter the Mandate Value if it is blank
	If objPage.WebEdit("txtBACCity").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACCity", City)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
	'Enter First Name
	If objPage.WebEdit("txtBACFirstName").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACFirstName", FirstName)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Last Name
	If objPage.WebEdit("txtBACLastName").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACLastName", LastName)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Job Title
	If objPage.WebEdit("txtBACJobTitle").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACJobTitle", JobTitle)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Building Name
	If objPage.WebEdit("txtBACBuildingName").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACBuildingName", BuildingName)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Building Number
	If objPage.WebEdit("txtBACBuildingNumber").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACBuildingNumber", BuildingNumber)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter Street
	If objPage.WebEdit("txtBACStreet").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACStreet", Street)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
		
	'Enter Phone Number
	If objPage.WebEdit("txtBACPhoneNumber").GetROProperty("value") = "" Then
		blnResult = enterText("txtBACPhoneNumber", PhoneNumber)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
End Function
