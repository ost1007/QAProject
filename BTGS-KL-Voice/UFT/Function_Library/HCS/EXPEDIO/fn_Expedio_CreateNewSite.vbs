'=============================================================================================================
'Description: To Create a New Site
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			24/09/2014 	v1.0
'Modified By	:   Nagaraj			12/02/2016    v1.0
'Example: fn_Expedio_CreateNewSite(dSiteName, dLocalCompanyName, dBuildingName, dBuildingNumber, dRoom, dFloor, dSubLocationName, dCity, dStreet, dCountry, dZipCode)
'=============================================================================================================
Public Function fn_Expedio_CreateNewSite(dSiteName, dBuildingName, dBuildingNumber, dRoom, dFloor, dSubLocationName, dCity, dStreet, dState_County_Province, dCountry, dZipCode)

	Dim blnExist
	Dim wscript
	Dim strSiteName

	'Generate Unique SiteName & Update back to Data Sheet
	strSiteName = Ucase("ZAutom" & Replace(Replace(Replace(CStr(Day(Date) & Time), "/", ""),":","")," ",""))
	Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dSiteName",strSiteName)
	Call ReportLog("Create New Site","Generate Site Name","Generated Site Name is <B>" & strSiteName & "</B>","INFORMATION", False)

	Set wscript = CreateObject("Wscript.Shell")

	Set objPage = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI")
	For intCounter = 1 to 15
		blnExist = objPage.Exist(10)
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = BuildWebReference("brwIPSDKWEBGUI", "pgIPSDKWEBGUI", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Set objSites = objPage.Link("name:=Sites")
	If objSites.Exist Then
		objSites.Object.click
	End If
	
	Set objNewSite = objPage.Link("name:=New Site")
	If objNewSite.Exist Then
		objNewSite.Click
	End If

	'Enter SiteName
	blnResult = enterText("txtSiteName", strSiteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter LocalCompanyName
	blnResult = enterText("txtLocalCompanyName", strSiteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter BuildingName
	blnResult = enterText("txtBuildingName", dBuildingName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter BuidingNumber
	blnResult = enterText("txtBuidingNumber", dBuildingNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Room
	blnResult = enterText("txtRoom", dRoom)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Floor
	blnResult = enterText("txtFloor", dFloor)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Enter Sublocation Name
	blnResult = enterText("txtSubLocationName", dSubLocationName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Street
	blnResult = enterText("txtStreetNewSite", dStreet)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter City
	blnResult = enterText("txtCity", dCity)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Enter State C
	If UCase(dCountry) = "UNITED STATES" Then
		blnResult = enterText("txtStateCountyProvince", dState_County_Province)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	objPage.Image("alt:=Menu for Country", "index:=1").Object.Click
	Wait 2
	
	Set oDesc = Description.Create
	oDesc("micclass").Value = "WebElement"
	oDesc("class").Value = "MenuEntryName.*"
	oDesc("html tag").Value = "TD"
	Set objElms = objPage.WebTable("class:=MenuTable", "index:=0").ChildObjects(oDesc)
	For intCounter = 0 to objElms.Count - 1
		If Cstr(Trim(objElms(intCounter).GetROProperty("innertext"))) = Cstr(dCountry) Then
			objElms(intCounter).HighLight
			objElms(intCounter).FireEvent "onmouseover"
			objElms(intCounter).Click
			Exit For
		End If
	Next
	Wait 2

	objPage.WebEdit("txtZipCode").Object.Click
	'Enter ZipCode
	blnResult = enterText("txtZipCode", dZipCode)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click Search Address
	objPage.Link("name:=Search Address", "index:=1").Object.Click

	For intCounter = 1 to 10
		Set objTable = objPage.WebTable("innertext:=Building Name.*")
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

	intRow = objTable.GetRowWithCellText(dZipCode)
	If intRow <= 0 Then
		Call ReportLog("Search Address", "Address search should result adresses which contain ZIP Code - " & dZipCode, dZipCode & " - was not populated on Search Address", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
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
	objPage.Link("lnkGetGeoCode").Object.click
	
	Wait 2

	'Handle the Pop Up - Click Ok/Yes
	objTable.RefreshObject
	intRow = objTable.GetRowWithCellText(dZipCode)
	If intRow <= 0 Then
		Call ReportLog("Search Address", "Address search should result adresses which contain ZIP Code - " & dZipCode, dZipCode & " - was not populated on Search Address", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)
	If objElm.Exist(5) Then
		objElm.HighLight
		objElm.Click
		Wait 5
	End If

	'Handle pop up and click on Yes link
	If Browser("brwManagePlaceResult").Exist(60) Then
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
		strLatitude = objPage.WebEdit("txtLatitude").GetROProperty("innertext")
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

	strLongitude = objPage.WebEdit("txtLongitude").GetROProperty("innertext")
	If strLongitude = "" Then
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is not populated","FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Check Longitude Field","Longitude Field should be populated","Longitude field is populated: " & strLongitude,"INFORMATION", False)
	End If
	
	If Trim(objPage.WebEdit("txtBuildingName").GetROProperty("innertext")) = "" Then
		'Enter SiteName
		blnResult = enterText("txtBuildingName", dBuildingName)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	If Trim(objPage.WebEdit("txtBuidingNumber").GetROProperty("innertext")) = "" Then
		'Enter BuidingNumber
		blnResult = enterText("txtBuidingNumber", dBuildingNumber)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	If Trim(objPage.WebEdit("txtStreetNewSite").GetROProperty("innertext")) = "" Then
		'Enter Street
		blnResult = enterText("txtStreetNewSite", dStreet)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	objPage.Link("lnkAddSite2Customer").Object.click
'	blnResult = clickLink("lnkAddSite2Customer")
'	If Not blnResult Then
'		Environment("Action_Result") = False
'		Exit Function
'	End If

	Wait 2

	blnExist = False
	For intCounter = 1 to 10
		blnExist = objPage.Frame("frmBMCRemedyUserNote").Exist(10)
		If blnExist Then
			strText = Split(objPage.Frame("frmBMCRemedyUserNote").WebElement("elmSiteNote").GetROProperty("innertext"), " : ")
			strBFGIDs = Split(strText(1), " . ")
			strBFGID = strBFGIDs(0)
			objPage.WebButton("btnCloseRight").Click
			Exit For
		End If
	Next

	If Not blnExist Then
		Call ReportLog("Capture BFG ID", "BFG IDshould be generated", "BFG ID is not generated", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Capture BFG ID", "BFG IDshould be generated", "BFG ID generated <B>" & strBFGID &"</B>", "PASS", False)
		Environment("Action_Result") = True
	End If

End Function
