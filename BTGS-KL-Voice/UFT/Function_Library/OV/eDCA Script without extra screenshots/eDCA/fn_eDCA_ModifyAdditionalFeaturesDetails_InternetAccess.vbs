'=============================================================================================================
'Description: Function to Modify GSIP Product on Additional Feature Details Page
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			20-Nov-2015 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_InternetAccess
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_InternetAccess()

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

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
