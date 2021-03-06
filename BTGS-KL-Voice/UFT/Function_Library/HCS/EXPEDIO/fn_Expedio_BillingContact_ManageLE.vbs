'*******************************************************************************************************************************************************************************
' Description	 : Function to Create Legal Entity
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	29/06/2015	NA
' Parameters	 : 	LegalcompanyName, Street, City, ZIPCode
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_BillingContact_ManageLE(ByVal LegalcompanyName, ByVal Street, ByVal City, ByVal ZIPCode)

	'Build Reference
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Click BillingAccount
	blnResult = clickLink("lnkBillingAccount")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	
	Wait 5
	objBrowser.fSync
	
	'Click on Manage LE
	blnResult = clickLink("lnkManageLE")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	
	
	objBrowser.fSync

	'Enter LegalName
	blnResult = enterText("txtLegalcompanyName", LegalcompanyName)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Check the Box SameAsCustomerSite
	blnResult = setCheckBox("chkSameAsCustomerSite", "ON")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	

	'Enter Street
	If objPage.WebEdit("txtLEStreet").GetROProperty("value") = "" Then
		blnResult = enterText("txtLEStreet", Street)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter City
	If objPage.WebEdit("txtLECity").GetROProperty("value") = "" Then
		blnResult = enterText("txtLECity", City)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

	'Enter ZIPCode
	If objPage.WebEdit("txtLEZIPCode").GetROProperty("value") = "" Then
		blnResult = enterText("txtLEZIPCode", ZIPCode)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If

'	'Click on Search Address
'	objPage.Link("lnkSearchAddress").SetTOProperty "index", 4
'	blnResult = clickLink("lnkSearchAddress")
'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
'	objPage.Link("lnkSearchAddress").SetTOProperty "index", 0
'
'	Wait 20
'
'	For intCounter = 1 to 10
'		Set objTable = objPage.WebTable("tblManageLEAddressValidation")
'		blnExist = objTable.Exist(10)
'		If blnExist Then
'			Exit For
'		End If
'	Next
'
'	If Not blnExist Then
'		Call ReportLog("Site Details", "Site Details should be populated in Address", "Site Details is not populated", "FAIL", True)
'		Environment("Action_Result") = False
'		Exit Function
'	End If
'
'	intRow = objTable.GetRowWithCellText(ZipCode)
'
'	Set objElm = objTable.ChildItem(intRow, 12, "WebElement", 0)
'
'	If objElm.Exist(5) Then
'		objElm.HighLight
'		objElm.Click
'		Wait 5
'	End If
'
'	'Handle pop up and click on no link
'	If Browser("brwManagePlaceResult").Exist Then
'		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
'			"Pop Up appeared", "PASS", False)
'		Browser("brwManagePlaceResult").Page("pgManagePlaceResult").Link("lnkNo").Object.click
'	Else
'		Call ReportLog("Site Creation Pop Up", "Pop Up should appear: </BR>" & "Do you wish to update the address details with the address data returned by our database?",_
'			"Pop Up did not appear", "FAIL", True)
'		Environment("Action_Result")  =False
'		Exit Function
'	End If
'	
'	Wait 5

	'Click on Create LE
	blnResult = clickLink("lnkCreateLE")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Check for LE Creation
	If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmLECreation").WaitProperty("height", micGreaterThan(0), 1000*60*5) Then
		Call ReportLog("Create LE", "LE should be created successfully", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmLECreation").GetROProperty("innertext"), "INFORMATION", False)
		objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		Environment("Action_Result") = True
	Else
		If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmLECreation").Exist(0) Then
			Call ReportLog("Create LE", "LE should be created successfully", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmLECreation").GetROProperty("innertext"), "INFORMATION", False)
			objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
			Environment("Action_Result") = True
		ElseIf objPage.Frame("frmBMCRemedyUserError").Exist(0) Then
			Call ReportLog("Create LE", "LE should be created successfully", "LE Creation Message did not appear", "Warnings", True)
			objPage.Frame("frmBMCRemedyUserError").Link("lnkOK").Click
			Environment("Action_Result") = False
		End If
	End If
	
End Function
