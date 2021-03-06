'*******************************************************************************************************************************************************************************
' Description	 : Function to Fill Billing Account Details and Create Account
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	30/06/2015	NA
' Parameters	 : 	AccountName, CustomerBillingRef, BillPeriod, USScenario, InvoiceLanguage, BillingCurrency, PaymentDays, InfoCurrency, PaymentMethod, AccountClassification
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_CreateAccount_BillingAccountDetails(ByVal SalesChannel, ByVal AccountName, ByVal CustomerBillingRef, ByVal BillPeriod, ByVal USScenario, ByVal InvoiceLanguage,_
											ByVal BillingCurrency, ByVal PaymentDays, ByVal InfoCurrency, ByVal PaymentMethod, ByVal AccountClassification, ByVal ProjectCode)

	Dim oDesc
	
	SetDelimeterSymbol 96
	
	blnResult = setDPBrowserObject("IPSDK WEB GUI", "name:=IPSDK WEB GUI.*` creationtime:=0")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	blnResult = setDPPageObject("IPSDK WEB GUI", "title:=IPSDK WEB GUI.*")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Account Name
	blnResult = enterPgTextValue("Account Name", "xpath:=//DIV[contains(@class, 'AccountName_BillingAccount')]/TEXTAREA[1]` index:=0", AccountName)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter CustomerBillingRef
	blnResult = enterPgTextValue("Customer Billing Ref", "xpath:=//DIV[contains(@class, 'CustomerBillingReference_BillingAccount')]/TEXTAREA[1]` index:=0", CustomerBillingRef)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter BillPeriod
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Bill Period", BillPeriod, 0)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter USScenario
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for US Scenario", USScenario, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter InvoiceLanguage
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Invoice Language", InvoiceLanguage, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter BillingCurrency
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Billing Currency", BillingCurrency, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter PaymentDays
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Payment Days", PaymentDays, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Info Currency
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Info Currency", InfoCurrency, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter PaymentMethod
	blnResult = fn_Expedio_SelectValueFromDropDownAltImage("Menu for Payment Method", PaymentMethod, 1)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Info ActivationDate
	blnResult = enterPgTextValue("ActivationDate", "xpath:=//DIV[contains(@class, 'ActivationDate_BillingAccount')]//INPUT[1]` index:=0", CStr(Now + 1))
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	

	'Click on Advanced Billing
	blnResult = clickPgLink("Advanced Billing", "name:=Advanced Billing` index:=0")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'If Account Classification is Internal
	If AccountClassification = "Internal" Then
		blnResult = setDPBrowserObject("AdvancedBillingWindow", "name:=EXP: IPSDK: AdvancedBillingWindow.*` creationtime:=0")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		blnResult = setDPPageObject("AdvancedBillingWindow", "title:=EXP: IPSDK: AdvancedBillingWindow.*")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter Account Classification
		objPage.WebEdit(BuildObjectDescription("xpath:=//DIV[contains(@class, 'AccountClassification')]//INPUT[1]` index:=0")).Click
		objPage.WebElement("innertext:=Internal", "index:=0").HighLight
		x = objPage.WebElement("innertext:=Internal", "index:=0").GetROProperty("abs_x")
		y = objPage.WebElement("innertext:=Internal", "index:=0").GetROProperty("abs_y")
		CreateObject("Mercury.DeviceReplay").MouseMove x, y
		CreateObject("Mercury.DeviceReplay").MouseClick x, y,LEFT_MOUSE_BUTTON

		objPage.Frame("title:=BMC Remedy User - Warning").Link("name:=OK").Click

		'Click on Save Link
		blnResult = clickPgLink("Save", "name:=Save` index:=1")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
		blnResult = setDPBrowserObject("IPSDK WEB GUI", "name:=IPSDK WEB GUI.*` creationtime:=0")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		blnResult = setDPPageObject("IPSDK WEB GUI", "title:=IPSDK WEB GUI.*")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
	'Project Code will be added only if Sales Channel is BTGS UK
	If SalesChannel = "BTGS UK" AND Instr(objBrowser.GetROProperty("url"), ".t1.") = 0 Then
		'Enter Project Code
		blnResult = enterPgTextValue("Project Code", "xpath:=//DIV[contains(@class, 'ProjectCode_BillingAccount')]/TEXTAREA[1]` index:=0", ProjectCode)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
		'Click on Search Code
		blnResult = clickPgLink("Search Code", "name:=Search Code` index:=0")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			
		Wait 10
		
		With objPage.WebTable("class:=BaseTable","column names:=Project Code;Project Name;Description;Project Start Date;Project End Date", "index:=0")
			blnResult = .Exist(300)
			If blnResult Then
				intRow = .GetRowWithCellText(ProjectCode)
				If intRow <= 0 Then
					Call ReportLog("Add Project Code", "Project Code should be added", "Project Code could not searched/Added", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
				
				.ChildItem(intRow, 1, "WebElement", 0).Click
				Wait 5
			Else
				With Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserError").WebElement("elmInvalidProjectCode")
					If .Exist(60) Then
						Call ReportLog("Search Project Code", "Search Project Code should be successful", .GetROProperty("innertext"), "FAIL", True)
					Else
						Call ReportLog("Add Project Code", "Project Code should be added", "Project Code Info Detail Table is not populated", "FAIL", True)
					End If
					Environment("Action_Result") = False : Exit Function
				End With
			End If
		End With
	End If
	
	'Click on Create Account
	blnResult = clickPgLink("Create Account", "name:=Create Account` index:=0")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Wait 60

	'Check for LE Creation
	If Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").Exist(60*5) Then
		Set objPage = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI")
		Call ReportLog("Create Account", "Account should be created successfully", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmAccountCreation").GetROProperty("innertext"), "INFORMATION", False)
		Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		Environment("Action_Result") = True
	Else
		If Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").WebElement("elmAccountCreation").Exist(0) Then
			Set objPage = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI")
			Call ReportLog("Create Account", "Account should be created successfully", objPage.Frame("frmBMCRemedyUserNote").WebElement("elmAccountCreation").GetROProperty("innertext"), "INFORMATION", False)
			Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
			Environment("Action_Result") = True
		Else
			Call ReportLog("Create Account", "Account should be created successfully", "Account Creation Message did not appear", "FAIL", True)
			'Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
			Environment("Action_Result") = False	
		End If
	End If

	Call fn_Expedio_Logout
	
End Function

Public Function fn_Expedio_SelectValueFromDropDownAltImage(ByVal ImageProp, ByVal DataSelection, ByVal MenuTableIndex)
	Dim oDesc

	Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Image("alt:=" & ImageProp).Object.click

	blnSelect = False

	Set oDesc = Description.Create
	oDesc("micclass").Value = "WebElement"
	oDesc("class").Value = "MenuEntryName.*"
	oDesc("html tag").Value = "TD"
	Set objElms = objPage.WebTable("class:=MenuTable", "index:=" & MenuTableIndex).ChildObjects(oDesc)
	For intCounter = 0 to objElms.Count - 1
		If Cstr(Trim(objElms(intCounter).GetROProperty("innertext"))) = Cstr(DataSelection) Then
			objElms(intCounter).FireEvent "onmouseover"
			objElms(intCounter).Click
			blnSelect = True
			Exit For
		End If
	Next	

	If Browser("name:=Note.*", "creationtime:=0").Page("title:=Note.*").Link("name:=OK", "index:=0").Exist(5) Then
		Call ReportLog("User Note", "User Note is displayed", Browser("name:=Note.*", "creationtime:=0").Page("title:=Note.*").Object.documentElement.innerText, "Information", False)
		Browser("name:=Note.*", "creationtime:=0").Page("title:=Note.*").Link("name:=OK", "index:=0").Click
	End If

	fn_Expedio_SelectValueFromDropDownAltImage = blnSelect
End Function
