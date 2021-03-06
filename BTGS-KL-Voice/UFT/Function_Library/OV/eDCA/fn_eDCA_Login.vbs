'****************************************************************************************************************************
' Function Name	 : fn_eDCA_Login
' Purpose	 	 : Function to login to eDCA Portal Application.
' Author	 	 : Linta CK
' Creation Date  : 13/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_Login(deDCAURL,deDCAUserID)

	'Variable Declaration Section
	Dim streDCAURL,streDCAUserID,streDCAPassword
	Dim streDCALogin,strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	streDCAURL = deDCAURL
	streDCAUserID = deDCAUserID
	SystemUtil.CloseProcessByName "iexplore.exe"

	'Invoke the eDCA Portal application	
	SystemUtil.Run "iexplore.exe",streDCAURL

	For intCounter = 1 To 5
		If Browser("brweDCAPortal").Page("pgeDCAPortal").Exist(60) Then Exit For
	Next '#intCounter

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter the UserName
	blnResult = selectValueFromPageList("lstUserID",streDCAUserID)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Enter the Password 
	streDCAPassword = objpage.WebEdit("txtPassword").GetROProperty("value")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

    	'Click on Login link
	blnResult = clickLink("lnkLogin")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if the login was successful
	Set objMsg = objpage.Webelement("webElmWelcomeToeDCA")
    	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("eDCA Login","User should be able to login to eDCA Portal Application","Login to the eDCA Portal Application was not successful","FAIL","TRUE")
		Environment("Action_Result")=False : Exit Function
	Else
		streDCALogin = GetWebElementText("webElmWelcomeToeDCA")
		Call ReportLog("eDCA Login","Welcome message should be displayed upon login","Welcome Message '"&streDCALogin&"' is displayed","PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
