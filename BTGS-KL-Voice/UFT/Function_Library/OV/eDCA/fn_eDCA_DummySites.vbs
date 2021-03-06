Public function fn_eDCA_DummySites()

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = clickButton("btnEdit")
		If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if Navigated to Site page
	Set objMsg = objpage.WebElement("webElmSite")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Sites","Should be navigated to Site page on clicking Edit Buttton","Not navigated to Site page on clicking Edit Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmSite")
		Call ReportLog("Sites","Should be navigated to Site page on clicking Edit Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
