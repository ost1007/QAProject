'****************************************************************************************************************************
' Function Name	 : fn_eDCA_DSCPCoS()
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 06/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_DSCPCoS()

	'Declaration of variables
	Dim objMsg

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Clicking on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Pricing Page
    Set objMsg = objpage.WebElement("webElmPricing")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("DSCPCoS","Should be navigated to Pricing page on clicking Next Buttton","Not navigated to Pricing page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result")=False : Exit Function
	Else
		strMessage = GetWebElementText("webElmPricing")
		Call ReportLog("Sites","Should be navigated to Pricing page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************