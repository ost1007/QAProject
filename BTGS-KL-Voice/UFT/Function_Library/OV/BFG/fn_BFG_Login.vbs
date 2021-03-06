'****************************************************************************************************************************
' Function Name	 : fn_BFG_Login
' Purpose	 	 : Function to Login to BFG IMS
' Modified By	: Nagaraj V			17/02/2015
' Parameters	 : 	UserID, Password, URL
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_BFG_Login(ByVal URL, ByVal UserID, ByVal Password)

	'Variable Declaration Section
	Dim objButton
	Dim blnResult
	Dim intCounter

	'Killing any open browser before start of execution		
	SystemUtil.CloseProcessByName("iexplore.exe")   
	WebUtil.DeleteCookies
	'Invoke the SI application
	'change to chrome
	SystemUtil.Run "iexplore.exe",URL,,,3

	For intCounter = 1 to 40
		'Check if the page is opened
        blnResult = Browser("brw21CAuthentication").Page("pgLogin").WebEdit("txtUserName").Exist
        If blnResult Then
			Exit For
		Else
			Wait 2
		End If
	Next

	Browser("brw21CAuthentication").Page("pgLogin").Sync

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brw21CAuthentication","pgLogin","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter the UserName
	blnResult = enterText("txtUserName",UserID)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter the Password 
	blnResult = enterSecureText("txtPassword", Password)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

    'Click on Sign On button
    blnResult = clickButton("btnSignOn")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Wait for the Yes Button to Appear on Screen	
	For intCounter = 1 To 10
		If Browser("name:=21C Authentication: Warning Screen", "creationtime:=0").Page("title:=21C Authentication: Warning Screen").WebButton("value:= Yes ").Exist(30) Then Exit For
	Next
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brw21CAuthentication","pgRedirect","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Yes button
    blnResult = clickButton("btnYes")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	With Browser("brwBFG-IMS").Page("pgBFG-IMS")
		For intCounter = 1 to 40
			'Check if the login was successful
			Set objButton = .WebButton("btnContinue")
			If objButton.Exist Then
				Exit For
			Else
				Wait 2
			End If
		Next
	End With
	
	If Not objButton.Exist(5) Then
		Call ReportLog("BFG IMS Login","User should be able to login to BFG IMS Application","Login to the BFG IMS Application was not successful", "FAIL","TRUE")
		Environment.Value("Action_Result") = False  
		Exit Function
	Else
		Call ReportLog("BFG IMS Login","User should be able to login to BFG IMS Application","Login Successful and Navigated to the page","PASS","TRUE")
		Environment.Value("Action_Result") = True
	End If
	
End Function
