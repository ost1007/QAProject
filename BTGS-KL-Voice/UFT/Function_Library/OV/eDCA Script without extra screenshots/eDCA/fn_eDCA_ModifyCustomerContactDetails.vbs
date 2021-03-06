'****************************************************************************************************************************
' Purpose	 	 : Function to enter values in Customer Contact details Page
' Author	 	 : Vamshi Krishna G
' Creation Date    : 13/08/2013
' Parameters	 : CFirstName			 :	   Contains First Name
'			  					 CLastName			 : 	   Contains Last Name
'			  					 CEmail				       :	 Contains Email
'			  					 CPhone				     :	   Contains Phone
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_ModifyCustomerContactDetails(CFirstName,CLastName,CEmail,CPhone)

	'Variable Declaration Section
	Dim strFirstName, strLastName, strEmail, strPhone
	Dim strRetrievedText,strListBoxItemValue,strContractId,strCurrency,strSiebelId,strServiceCenter,strContractTerm,strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strFirstName = CFirstName
	strLastName = CLastName
	strEmail = CEmail
	strPhone = CPhone
      
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment("Action_Result") = False : Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter First Name
	If strFirstName <> "" Then
		blnResult = enterText("txtCFirstName",strFirstName)
		If blnResult= False Then
			Call ReportLog("First Name","First Name should be entered","First Name is not entered","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Enter Last Name
	If strLastName<>"" Then
		blnResult = enterText("txtCLastName",strLastName)
		If blnResult= False Then
			Call ReportLog("Last Name","Last Name should be entered","Last Name is not entered","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Enter Email
	If strEmail<>"" Then
		blnResult = enterText("txtCEmail",strEmail)
		If blnResult= False Then
			Call ReportLog("Email","Email should be entered","Email is not entered","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Enter Phone
	If strPhone<> ""  Then
		blnResult = enterText("txtCPhone",strPhone)
		If blnResult= False Then
			Call ReportLog("Phone","Phone should be entered","Phone is not entered","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

      'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment("Action_Result") = False : Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Customer Contact Details Page
	Set objMsg = objpage.Webelement("webElmDistributorContactDetails")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Customer Contact Details","Should be navigated to Distributor contact Details page on clicking Next Buttton","Not navigated to Distributor contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmDistributorContactDetails")
		Call ReportLog("Customer Contact Details","Should be navigated to Distributor contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
