'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_Login
'
' Purpose	 	 : Function to login to Tahiti Portal Application.
'
' Author	 	 : Vamshi Krishna G
'Modified By	 : Linta C.K.
'
' Creation Date  : 16/12/2013
'Modification Date: 25/04/2014
'
' Parameters	 : TahitiURL		: Contains URL to login to Tahiti Portal application
' 				   TahitiUserID	: Contains the User Name to be provided to login to Tahiti Portal application
'				   TahitiPassword	: Contains the Password to be provided to login to Tahiti Portal application
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_TAHITI_Login(dTahitiURL,dTahitiUserID,dTahitiPassword)

	'Variable Declaration Section
	Dim strTahitiURL,strTahitiUserID,strTahitiPassword
	Dim strTahitiLogin,strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strTahitiURL = dTahitiURL
	strTahitiUserID = dTahitiUserID
	strTahitiPassword = dTahitiPassword

	'Invoke the eDCA Portal application	

	For intCounter = 1 To 5
		SystemUtil.Run "iexplore.exe", strTahitiURL, , , 3
		Wait 5
		If Browser("name:=Web Server Temporarily Unavailable").Exist(10) Then
			Browser("name:=Web Server Temporarily Unavailable").CloseAllTabs
		Else
			Exit For
		End If
	Next

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	Wait(10)

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 'Environment("Action_Result") = False
		
		Exit Function
	End If

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	Wait(10)

	'Enter the UserName
	blnResult = enterText("txtUserID",strTahitiUserID)
    If blnResult= False Then
		Environment.Value("Action_Result")=False 'Environment("Action_Result") = False
		
		Exit Function
	End If

	'Enter the Password 
	blnResult = enterText("txtPassword",strTahitiPassword)
    If blnResult= False Then
		Environment.Value("Action_Result")=False 'Environment("Action_Result") = False
		
		Exit Function
	End If

    'Click on Login link
	blnResult = clickButton("btnLogin")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 'Environment("Action_Result") = False
		
		Exit Function
	End If

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Clicking on Yes for BT Legal warning
	blnResult = clickButton("btnLegalWarningYes")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 'Environment("Action_Result") = False
		
		Exit Function
	End If

	'Check if the login was successful
	Set objMsg = objpage.Frame("frmThahitiFrame").WebEdit("txtCurrentTime")
    objMsg.WaitProperty "visible","True",100000
	If objMsg.Exist = False Then
		Call ReportLog("Tahiti Login","User should be able to login to Tahiti Portal Application","Login to the Tahiti Portal Application was not successful","FAIL","TRUE")
	Else
		strTahitiLogin = objPage.Frame("frmThahitiFrame").WebEdit("txtCurrentTime").GetROProperty("value")
		Call ReportLog("Tahiti Login","User should be able to login to Tahiti Portal Application","User logged in at '"&strTahitiLogin&"'GMT is displayed","PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

