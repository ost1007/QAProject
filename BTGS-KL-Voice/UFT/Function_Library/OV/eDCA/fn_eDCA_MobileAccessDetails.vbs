Public Function fn_eDCA_MobileAccessDetails(ByVal OrderType, ByVal CLIFile, ByVal BulkActivationRequired)
	
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check whether the CLI file exits or not
	blnResult = CreateObject("Scripting.FileSystemObject").FileExists(CLIFile)
	If Not blnResult Then
		Call ReportLog("CLI File", "CLI File should be present in mentioned Path [" & CLIFile & "]", "File was not Found", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	objPage.WebFile("webFilBrowser").Set CLIFile

	'Select Whether Bulk Activation is requried or not
	blnResult = selectValueFromPageList("lstBulkActivationRequired", BulkActivationRequired)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Upload Button
	blnResult = clickButton("btnUpload")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	For intCounter = 1 to 5
		strGeneratedFileName = objPage.WebElement("elmGeneratedFileName").GetROProperty("innertext")
		If strGeneratedFileName <> "" Then
			Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dGeneratedFileName",strGeneratedFileName)
			Call ReportLog("CLI File", "File Name Should be generated", "File Name is found to be <b>" & strGeneratedFileName & "</B>", "PASS", True)
			Exit For
		Else
			Wait 60
		End If
	Next

	If strGeneratedFileName = "" Then
		Call ReportLog("CLI File", "File Name Should be generated", "File Name is not generated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigfated to BillingDetails page
	Set objMsg = objpage.WebElement("webElmBillingDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If
	
End Function
