'=================================================================================================================================
' Description	: Login to SQE CQM Application
' History		:		Name		Date		Version
' Created By	: 	Nagaraj V	29/04/2015		v1.0
' Example	: fn_SQE_Login "URL", "username", "password"
'=================================================================================================================================
Public Function fn_SQE_Login(ByVal URL, ByVal Username, ByVal Password)
	
	'Variable Declaration Section
	Dim intCounter

	'Killing any open browser before start of execution		
	SystemUtil.CloseProcessByName("iexplore.exe")   
	WebUtil.DeleteCookies
	'Invoke the SI application
	SystemUtil.Run "iexplore.exe", "-private " & URL , , , 3

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
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter the UserName
	blnResult = enterText("txtUserName",Username)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter the Password 
	blnResult = enterSecureText("txtPassword", Password)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Sign On button
	blnResult = clickButton("btnSignOn")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Wait for the Yes Button to Appear on Screen	
	For intCounter = 1 To 10
		If Browser("name:=21C Authentication: Warning Screen", "creationtime:=0").Page("title:=21C Authentication: Warning Screen").WebButton("value:= Yes ").Exist(30) Then Exit For
	Next

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brw21CAuthentication","pgRedirect","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Yes button
	blnResult = clickButton("btnYes")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 To 30
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").Link("lnkExistingCustomer").Exist(10)
			If blnResult Then Exit For '#intCounter
	Next	
	
	If Not blnResult Then
		Call ReportLog("CQM Login","User should be able to login to CQM Application","Login to the CQM Application was not successful", "FAIL", True)
		Environment("Action_Result") = False  
		Exit Function
	Else
		Call ReportLog("CQM Login","User should be able to login to CQM Application","Login Successful and Navigated to the page","PASS", True)
		Environment("Action_Result") = True
	End If

End Function
