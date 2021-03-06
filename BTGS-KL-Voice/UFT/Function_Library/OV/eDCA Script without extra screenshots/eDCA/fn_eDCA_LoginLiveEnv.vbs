'====================================================================================================================
' Function Name	 : fn_eDCA_LoginLiveEnv
' Purpose	 	 : Function to Login to eDCA
'====================================================================================================================
Public Function fn_eDCA_LoginLiveEnv(ByVal URL, ByVal Username, ByVal Password)
	'Variable Declaration Section
	Dim intCounter
	Dim objMsg
	Dim streDCALogin

	'Killing any open browser before start of execution		
	SystemUtil.CloseProcessByName("iexplore.exe")   
	WebUtil.DeleteCookies
	'Invoke the SI application
	SystemUtil.Run "iexplore.exe",URL,,,3

	For intCounter = 1 to 5
		'Check if the page is opened
		blnResult = Browser("brwAuthentication").Page("pgAuthentication").WebEdit("txtUserName").Exist(60)
		If blnResult Then Exit For
	Next '#intCounter

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwAuthentication","pgAuthentication", "")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brwAuthentication").Page("pgAuthentication").Sync

	'Enter the UserName
	blnResult = enterText("txtUserName",Username)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter the Password 
	blnResult = enterText("txtPassword", Password)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Sign On button
	blnResult = clickButton("btnSignOn")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Wait 3
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwAuthentication","pgAuthentication", "")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Yes button
	blnResult = clickButton("btnYes")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Check if the login was successful
	Set objMsg = Browser("brweDCAPortal").Page("pgeDCAPortal").Webelement("webElmWelcomeToeDCA")
	If Not objMsg.Exist(60*3) Then
		Call ReportLog("eDCA Login","User should be able to login to eDCA Portal Application","Login to the eDCA Portal Application was not successful","FAIL", True)
		Environment("Action_Result")=False : Exit Function
	Else
		streDCALogin = objMsg.GetROProperty("innerText")
		Call ReportLog("eDCA Login","Welcome message should be displayed upon login","Welcome Message '" & streDCALogin & "' is displayed","PASS", False)
	End If
	
End Function

