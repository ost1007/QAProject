'=============================================================================================================
'Description: Function to Click on Next
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			20-Nov-2015 			NA
'Example: fn_eDCA_ModifyAdditionalFeaturesDetails_NoModify
'=============================================================================================================
Public Function fn_eDCA_ModifyAdditionalFeaturesDetails_NoModify()

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	
	
	'Check if navigfated to BillingDetails page
	Set objMsg = Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("webElmBillingDetails")
	For intCounter = 1 To 5
		blnResult = objMsg.Exist(60)
			If blnResutl Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If
		
End Function
