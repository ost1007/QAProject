'****************************************************************************************************************************
' Function Name : fn_AIB_Login
' Purpose			: 		Function to log in AIB
' Author			:		Vamshi Krishna G
' Modified by		: 		Suresh HS
' Modified by		: Nagaraj V || 03/02/2015
' Creation Date   : 			28/1/2014
'Modified Date   :				 11/04/2014
' Parameters	  :			dAIBURL,dAIBUserID,dAIBPPwd                 					     
' Return Values	 : 			Not Applicable
'****************************************************************************************************************************
Public function fn_AIB_Login(dAIBURL, dUserID, dPassword)	
	
	On Error Resume Next
	'Declaration of variables
	Dim strAIBURL,strAIBUserName,strAIBPassword
	Dim strAIBLogin,strMessage
	Dim objMsg
	Dim blnResult
	Dim intCounter

	'Assigningof values to variables
	strAIBURL = dAIBURL

	If Browser("brwAIB").Exist(0) Then
		Browser("brwAIB").Close
		Wait 2
	End If

	'Open internet explorer browser
	Systemutil.Run "iexplore.exe",strAIBURL,,,3

	If Not Browser("brwAIB").Page("pgAIB").WebElement("ElmOrderSearch").Exist(30) Then
		For intCounter = 1 to 5
			'Check if the page is opened
			blnResult = Browser("brwAIB").Page("pgAIB").WebEdit("txtAIBUserName").Exist(60)
			If blnResult Then Exit For
		Next '#intCounter
	
		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwAIB").Page("pgAIB").Sync
	
		'Enter the UserName
		blnResult = enterText("txtAIBUserName", dUserID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Enter the Password 
		blnResult = enterSecureText("txtAIBPassword", dPassword)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Click on Sign On button
		blnResult = clickButton("btnSignOn")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Wait 5
		
		'Wait for the Yes Button to Appear on Screen	
		For intCounter = 1 To 10
			If Browser("name:=21C Authentication: Warning Screen", "creationtime:=0").Page("title:=21C Authentication: Warning Screen").WebButton("value:= Yes ").Exist(30) Then Exit For
		Next

		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Click on Yes button
		blnResult = clickButton("btnYes")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 to 5
		blnResult = Browser("brwAIB").Page("pgAIB").Exist(60)
		If blnResult Then
			'Function to set the browser and page objects by passing the respective logical names
			blnResult = BuildWebReference("brwAIB","pgAIB","")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End IF

		Set objMsg =objpage.WebElement("ElmOrderSearch")
		If objMsg.Exist And  CInt(objMsg.GetROProperty("height")) > 0Then
			Exit For
		Else
			Wait 10
		End If
	Next

    If Not objMsg.Exist(60) Then
        Call ReportLog("AIB Login","User should be able to navigate to Order Search page on clicking warning Yes Buttton","user Unable to navigate to Order Search page on clicking warning Yes Buttton","FAIL","TRUE")
		Environment.Value("Action_Result") = False  '
		Call EndReport()
		Exit Function
	Else
		strAIBLogin = GetWebElementText("ElmOrderSearch")
		Call ReportLog("AIB Login","User should be able to navigate to Order Search page on clicking warning Yes Buttton","User is Navigated to the page - "&strAIBLogin,"PASS", True)
	End If

	Environment.Value("Action_Result") = True 	

End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
