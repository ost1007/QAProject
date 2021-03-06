'****************************************************************************************************************************
' Function Name	 : fn_eDCA_CustomerContactDetails
' Purpose	 	 : Function to enter values in Customer Contact details Page
' Author	 	 : Linta CK
' Creation Date    : 24/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_CustomerContactDetails(dOrderType,dCFirstName,dCLastName,dCEmail,dCPhone)

	'Variable Declaration Section
	Dim strFirstName, strLastName, strEmail, strPhone
	Dim strRetrievedText,strListBoxItemValue,strContractId,strCurrency,strSiebelId,strServiceCenter,strContractTerm,strMessage,strRetrievedFirstName,strRetrievedLastName,strRetrievedEmail,strRetrievedPhoneNo
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strFirstName = dCFirstName
	strLastName = dCLastName
	strEmail = dCEmail
	strPhone = dCPhone
      
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Updated by Anil Pal, Date, Purpose is if  value is already there in mandatory fields for Modify and Cease Journey then system will not update the fields and for provide journey script will 
	'enter the fields from test data.
	If dOrderType = "ADD" Then
		blnResult = enterText("txtCFirstName",strFirstName)
		If blnResult= False Then
			Call ReportLog("First Name","First Name should be entered","First Name is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	Else
		strRetrievedFirstName = objpage.WebEdit("txtCFirstName").GetROProperty("Value")
		If strRetrievedFirstName = ""  Then
			blnResult = enterText("txtCFirstName",strFirstName)
			If blnResult= False Then
				Call ReportLog("First Name","First Name should be entered","First Name is not entered","FAIL","TRUE")
				Environment.Value("Action_Result")=False 
				Exit Function
			End If
		End If
	End If

'Updated by Anil Pal, Date, Purpose is if  value is already there in mandatory fields for Modify and Cease Journey then system will not update the fields and for provide journey script will 
'enter the fields from test data.
	If dOrderType = "ADD"  Then
		blnResult = enterText("txtCLastName",strLastName)
		If blnResult= False Then
			Call ReportLog("Last Name","Last Name should be entered","Last Name is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	Else
		strRetrievedLastName = objpage.WebEdit("txtCLastName").GetROProperty("Value")
		If strRetrievedLastName = ""  Then
			blnResult = enterText("txtCLastName",strLastName)
			If blnResult= False Then
				Call ReportLog("Last Name","Last Name should be entered","Last Name is not entered","FAIL","TRUE")
				Environment.Value("Action_Result")=False 
				
				Exit Function
			End If
		End If
	End If

'Updated by Anil Pal, Date, Purpose is if  value is already there in mandatory fields for Modify and Cease Journey then system will not update the fields and for provide journey script will 
'enter the fields from test data.
	If dOrderType = "ADD"  Then
			blnResult = enterText("txtCEmail",strEmail)
		If blnResult= False Then
			Call ReportLog("Email","Email should be entered","Email is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	Else
		strRetrievedEmail = objpage.WebEdit("txtCEmail").GetROProperty("Value")
		If strRetrievedEmail = ""  Then
			blnResult = enterText("txtCEmail",strEmail)
			If blnResult= False Then
				Call ReportLog("Email","Email should be entered","Email is not entered","FAIL","TRUE")
				Environment.Value("Action_Result")=False 
				Exit Function
			End If
		End If
	End If


'Updated by Anil Pal, Date, Purpose is if  value is already there in mandatory fields for Modify and Cease Journey then system will not update the fields and for provide journey script will 
'enter the fields from test data.
	If dOrderType = "ADD"  Then
		blnResult = enterText("txtCPhone",strPhone)
		If blnResult= False Then
			Call ReportLog("Phone","Phone should be entered","Phone is not entered","FAIL","TRUE")
			Environment.Value("Action_Result")=False 		
			Exit Function
		End If
	Else
		strRetrievedPhoneNo = objpage.WebEdit("txtCPhone").GetROProperty("Value")
		If strRetrievedPhoneNo = ""  Then
		blnResult = enterText("txtCPhone",strPhone)
			If blnResult= False Then
				Call ReportLog("Phone","Phone should be entered","Phone is not entered","FAIL","TRUE")
				Environment.Value("Action_Result")=False		
				Exit Function
			End If
		End If
	End If
	
	Call ReportLog("Customer Contact details","Customer Contact details page should be completed","Customer Contact details page successfully","PASS","TRUE")
    'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Customer Contact Details Page
	Set objMsg = objpage.Webelement("webElmDistributorContactDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Customer Contact Details","Should be navigated to Distributor contact Details page on clicking Next Buttton","Not navigated to Distributor contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmDistributorContactDetails")
		Call ReportLog("Customer Contact Details","Should be navigated to Distributor contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************