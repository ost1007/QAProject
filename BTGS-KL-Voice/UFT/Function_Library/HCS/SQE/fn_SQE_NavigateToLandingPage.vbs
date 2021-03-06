'****************************************************************************************************************************
' Function Name 		:		fn_SQE_NavigateToLandingPage
' Purpose				: 		Function to Navigate To SQE Landing Page
' Author				:		Linta C.K.
' Creation Date  		: 		04/7/2014	     
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_NavigateToLandingPage(ByVal SQEURL)

	'Declaration of variables
	Dim strSQELogin, strMessage
	Dim objMsg
	Dim blnResult
	Dim intCounter
	
	'Killing any open browser before start of execution		
	SystemUtil.CloseProcessByName("iexplore.exe")

	'Open internet explorer browser
	Systemutil.Run "iexplore.exe", SQEURL, , , 3

	For intCounter = 1 to 5
		blnResult = Browser("brwIPSDKProductBundling").Page("pgIPSDKProductBundling").Exist(60)
		If blnResult Then
			'Function to set the browser and page objects by passing the respective logical names
			blnResult = BuildWebReference("brwIPSDKProductBundling","pgIPSDKProductBundling","")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Exit For
		End IF
	Next
	
	Set objMsg = objPage.WebButton("btnAddProduct2Quote")
	blnResult = objMsg.WaitProperty("height", micGreaterThan(0), 1000*60*2)
    	If Not blnResult Then
		Call ReportLog("SQE Login","User should be able to navigate to Quote Landing page on opening the URL","user Unable to navigate to Quote Landing Page ", "FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	Else
		strSQELogin = GetWebElementText("elmProductSelectionPage")
		Call ReportLog("SQE Login","User should be able to navigate to Quote Landing page on opening the URL","User is Navigated to the page - " & strSQELogin, "PASS", False)
	End If

	Environment.Value("Action_Result") = True 	

End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
