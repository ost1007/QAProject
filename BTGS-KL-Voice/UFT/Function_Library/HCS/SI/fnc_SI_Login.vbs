'****************************************************************************************************************************
' Function Name	 : fnc_SI_Login
' Purpose	 	 : Function to Login to SI
' Modified By	: Nagaraj V			01/04/2014
' Parameters	 : 	SIUserID, SIPassword, SIURL
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fnc_SI_Login(ByVal SIURL, ByVal SIUserID, ByVal SIPassword)

	'Variable Declaration Section
	Dim strSIURL,strSIUserID,strSIPassword
	Dim strSILogin,strMessage
	Dim objLink
	Dim blnResult
	Dim intCounter

	'Assignment of Variables
	strSIURL = SIURL
	strSIUserID = SIUserID
	strSIPassword = SIPassword

	'Killing any open browser before start of execution		
	SystemUtil.CloseProcessByName("iexplore.exe")   
	WebUtil.DeleteCookies
	'Invoke the SI application
	SystemUtil.Run "iexplore.exe",strSIURL,,,3
	
	Set brwSI = Browser("name:=SI", "creationtime:=0")
	Set elmContentBlocked = brwSI.Page("title:=SI").WebElement("html id:=ContentBlocked")
	Set brwNavigation = Browser("name:=Certificate Error: Navigation Blocked", "creationtime:=0")
	Set lnkOverride = brwNavigation.Page("title:=.*").Link("html id:=overridelink")

	For intCounter = 1 to 100
		'Check if the page is opened
        blnResult = Browser("brwSIAuthentication").Page("pgSIAuthentication").WebEdit("txtUserName").Exist(2)
        If blnResult Then
			Exit For
		ElseIf elmContentBlocked.Exist(2) Then
			brwSI.Refresh
		ElseIf lnkOverride.Exist(2) Then
			lnkOverride.Click
			Wait 2
			If brwNavigation.Dialog("regexpwndtitle:=Security Warning").Exist(60) Then brwNavigation.Dialog("regexpwndtitle:=Security Warning").WinButton("text:=Yes").Click
		Else
			Wait 2
		End If
	Next

	Browser("brwSIAuthentication").Page("pgSIAuthentication").Sync

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSIAuthentication","pgSIAuthentication","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	Browser("brwSIAuthentication").Page("pgSIAuthentication").Sync

	'Enter the UserName
	blnResult = enterText("txtUserName",strSIUserID)
	If blnResult= "False" Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	'Enter the Password 
	blnResult = enterSecureText("txtPassword", strSIPassword)
	If Not blnResult Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

    'Click on Sign On button
    blnResult = clickButton("btnSignOn")
	If Not blnResult Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If
	
	'Wait for the Yes Button to Appear on Screen	
	For intCounter = 1 To 10
		If Browser("name:=21C Authentication: Warning Screen", "creationtime:=0").Page("title:=21C Authentication: Warning Screen").WebButton("value:= Yes ").Exist(30) Then Exit For
	Next
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSIAuthentication","pgSIAuthentication","")
	If blnResult= "False" Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	'Click on Yes button
    blnResult = clickButton("btnYes")
	If Not blnResult Then
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	With Browser("brwSIMain").Page("pgSIMain")
		For intCounter = 1 to 40
			'Check if the login was successful
			Set objLink = .Link("lnkWorkflow")
			If objLink.Exist(5) Then
				Exit For
			ElseIf Browser("brwSIMain").Page("pgSIMain").Frame("title:=Object reference not set to an instance of an object.*").Exist(5) Then
				Call ReportLog("SI Login", "User should be able to login", "Encountered Message : <B>Object reference not set to an instance of an object</B>", "FAIL", True)
				Browser("brwSIMain").Close : Environment("Action_Result") = False
				Exit Function
			ElseIf Browser("brwSIMain").Page("pgSIMain").Frame("title:=Timeout expired.*").Exist(5) Then
				Call ReportLog("SI Login", "User should be able to login", "Encountered Message : <B>Timeout expired</B>", "FAIL", True)
				Browser("brwSIMain").Close : Environment("Action_Result") = False
				Exit Function
			Else
				Wait 2
			End If
		Next
	End With
	
	If Not objLink.Exist(5) Then
		Call ReportLog("SI Login","User should be able to login to SI Application","Login to the SI Application was not successful","FAIL","TRUE")
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	Else
		Call ReportLog("SI Login","Login should be successful","Login Successful and Navigated to the page","PASS","")
	End If
	Environment.Value("Action_Result") = True
End Function
