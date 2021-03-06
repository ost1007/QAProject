'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SiteContactDetails
' Purpose	 	 : Function to enter Site Contact Details
' Author	 	 : Linta CK
' Creation Date  	 : 29/05/2013                                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_SiteContactDetails(dPrimarySiteFirstName,dPrimarySiteLastName,dPrimarySiteEmail,dPrimarySitePhone)

	Dim strPrimarySiteFirstName,strPrimarySiteLastName
	Dim strPrimarySiteEmail,strPrimarySitePhone

	'Assignment of variables
	strPrimarySiteFirstName = dPrimarySiteFirstName
	strPrimarySiteLastName = dPrimarySiteLastName
	strPrimarySiteEmail = dPrimarySiteEmail
	strPrimarySitePhone = dPrimarySitePhone

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Primary Site First name
	strRetrievedText = objpage.WebEdit("txtPrimarySiteFirstName").GetROProperty("Value")
	If Cstr(strRetrievedText) <> "" Then
		Call ReportLog("Site Contact Details page","Field Primary Site First Name is displayed ","Value of Primary Site First Name is  - "&strRetrievedText,"PASS","")
		Else
		blnResult = enterText("txtPrimarySiteFirstName",strPrimarySiteFirstName)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If		
	End If


	'Enter Primary Site Last name
	strRetrievedText = objpage.WebEdit("txtPrimarySiteLastName").GetROProperty("Value")
	If Cstr(strRetrievedText) <> "" Then
		Call ReportLog("Site Contact Details page","Field Primary Site Last Name is displayed ","Value of Primary Site Last Name is  - "&strRetrievedText,"PASS","")
		Else
		blnResult = enterText("txtPrimarySiteLastName",strPrimarySiteLastName)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	 End if

	'Enter Primary Site Email
	strRetrievedText = objpage.WebEdit("txtPrimarySiteEmail").GetROProperty("Value")
	If Cstr(strRetrievedText) <> "" Then
		Call ReportLog("Site Contact Details page","Field Primary Site Email is displayed ","Value of Primary Site Email is  - "&strRetrievedText,"PASS","")
		Else
		blnResult = enterText("txtPrimarySiteEmail",strPrimarySiteEmail)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	 End if

	'Enter Primary Site Phone
	strRetrievedText = objpage.WebEdit("txtPrimarySitePhone").GetROProperty("Value")
	If Cstr(strRetrievedText) <> "" Then
		Call ReportLog("Site Contact Details page","Field Primary Site Phone is displayed ","Value of Primary Site Phone is  - "&strRetrievedText,"PASS","")
	Else
		blnResult = enterText("txtPrimarySitePhone",strPrimarySitePhone)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	 End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Service Instance Page
	Set objMsg = objpage.Webelement("webElmServiceInstance")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Contact Details","Should be navigated to Service Instance page on clicking Next Buttton","Not navigated to Service Instance page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmServiceInstance")
		Call ReportLog("Site Contact Details","Should be navigated to Service Instance page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If


End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
