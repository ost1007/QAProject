'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Login
' Purpose	 	 : Function to login to EXPEDIO Application.
' Author	 	 : Linta CK
' Creation Date  : 11/10/2013
' Parameters	 : 	ExpedioURL		: Contains URL to login to EXPEDIO application
' 					ExpedioUserId	: Contains the User Name to be provided to login to EXPEDIO application
' 					ExpedioPassword	: Contains the password to be provided to login to EXPEDIO application                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_Login(dExpedioURL, dExpedioUserId, dExpedioPassword)
	On Error Resume Next
	'Variable Declaration Section
	Dim strExpedioURL, strExpedioUserId, strExpedioPassword
	Dim blnResult
	Dim intCounter

	'Assignment of Variables
	strExpedioURL = dExpedioURL
	strExpedioUserId = dExpedioUserId
	strExpedioPassword = dExpedioPassword

	SystemUtil.CloseProcessByName("iexplore.exe")

	CreateObject("Mercury.GUI_WebUtil").DeleteCookies
	Wait 10

	'Open IE and Navigate to Expedio Web URL
	SystemUtil.Run "iexplore.exe", "-private " & strExpedioURL, , , 3
	
	'Check if Expedio page is opened
	For intCounter = 1 to 50
		blnResult = Browser("brwBMCRemedyMidTier").Page("pgBMCRemedyMidTier").Exist(20)
		If blnResult Then
			'Function to set the browser and page objects by passing the respective logical names
			blnResult = BuildWebReference("brwBMCRemedyMidTier","pgBMCRemedyMidTier","")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			
			Browser("brwBMCRemedyMidTier").Page("pgBMCRemedyMidTier").Sync

			If objPage.WebEdit("txtUserName").Exist(30) Then
				Browser("brwBMCRemedyMidTier").Page("pgBMCRemedyMidTier").Sync
				Exit For
			End If
		End If
	Next

	'Enter the UserName
	blnResult = enterText("txtUserName",strExpedioUserId)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter Password
	blnResult = enterSecureText("txtPassword",strExpedioPassword)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Login Button
	blnResult = clickButton("btnLogin")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'To Handle Authorization window
	Set oBrowser = Browser("name:=WARNING!! Are You Authorised.*", "creationtime:=0")
	If oBrowser.Exist(30) Then
		Set oPage = oBrowser.Page("title:=WARNING!! Are You Authorised.*")
		Set oLnkYes = oPage.Link("name:=Yes", "index:=0")
		If oLnkYes.Exist(30) Then oLnkYes.Click
	End If '#oBrowser.Exist
	
	'To Handle Password Change window and Decline
	Set oBrowser = Browser("name:=Password Message.*", "creationtime:=0")
	If oBrowser.Exist(20) Then
		Set oPage = oBrowser.Page("title:=Password Message.*")
		Set oLnkDecline = oPage.Link("name:=Decline", "index:=0")
		If oLnkDecline.Exist(30) Then oLnkDecline.Click
	End If '#oBrowser.Exist
	
	'Closing the Browser's Tab if more than one tab opens
	'Call fn_Expedio_CloseBrowser()
	
	If Browser("brwIPSDKTrackOrder").Exist(60) Then
		Browser("brwIPSDKTrackOrder").fSync
		Browser("brwIPSDKTrackOrder").Close
	End If
	
	'comment by FKH 
'	If Browser("name:=Change console.*", "creationtime:=0").Exist(60) Then
'		Browser("name:=Change console.*", "creationtime:=0").fSync
'		Browser("name:=Change console.*", "creationtime:=0").Close
'	End If
	
	'add by FKH - close browser Change console (Search)
	If Browser("brwconsole(Search)").Exist(60) Then
		Browser("brwconsole(Search)").fSync
		Browser("brwconsole(Search)").Close
	End If

	For intCounter = 1 to 40
		'Check if the login was successful
		blnResult = Browser("brwBMCRemedyMidTier").Page("pg"&strTypeOfOrder).Link("lnkLogout").Exist
		If blnResult = "True" Then
			Exit For
		Else
			Wait 2
		End If
	Next

	If Not blnResult Then
		Call ReportLog("EXPEDIO Login","User should be able to login to EXPEDIO Application","Login to EXPEDIO Application was not successful","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	Else
		Call ReportLog("EXPEDIO Login","User should be able to login to EXPEDIO Application","Login Successful and Name text field is displayed on the page","PASS","")
	End If

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
