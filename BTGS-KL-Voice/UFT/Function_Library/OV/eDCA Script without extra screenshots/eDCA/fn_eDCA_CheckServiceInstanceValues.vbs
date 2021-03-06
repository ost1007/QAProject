Public Function fn_eDCA_CheckServiceInstanceValues(ByVal TypeOfOrder)

	'Variable Declaration
	Dim strRetrievedText

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on View corresponding to product type "one voice" 
	blnResult =  clickButton("btnView")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	If Browser("brweDCAPortal").Window("wndDialog").Exist(10) Then
		Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Check for Disabled Property and its corresponding Values in Page
	If objPage.WebList("lstServiceType").Exist(0) Then
		If objPage.WebList("lstServiceType").GetROProperty("disabled") = 1 Then
			strRetrievedText = objPage.WebList("lstServiceType").GetROProperty("selection")
			Call ReportLog("Check Property", "Service Type should be disabled", "Service Type is disabled and value is found to be:= " & strRetrievedText, "Information", False)
		Else
			Call ReportLog("Check Property", "Service Type should be disabled", "Service Type is enabled", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Sub Service Type
	If objPage.WebList("lstSubServiceType").Exist(0) Then
		If objPage.WebList("lstSubServiceType").GetROProperty("disabled") = 1 Then
			strRetrievedText = objPage.WebList("lstSubServiceType").GetROProperty("selection")
			Call ReportLog("Check Property", "Sub Service Type should be disabled", "Sub Service Type is disabled and value is found to be:= " & strRetrievedText, "Information", True)
		Else
			Call ReportLog("Check Property", "Sub Service Type should be disabled", "Sub Service Type is enabled", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check whether the Page has been navigated to Submission Page or not
	If objPage.WebElement("innertext:=Submit", "html id:=LblHeader", "index:=0").Exist(60*5) Then
		Call ReportLog("Check Navigation", "Page should be navigated to Submit Page", "Navigated to Submission Page", "Information", False)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Check Navigation", "Page should be navigated to Submit Page", "Not Navigated to Submission Page", "FAIL", True)
		Environment("Action_Result") = False
	End If
End Function
