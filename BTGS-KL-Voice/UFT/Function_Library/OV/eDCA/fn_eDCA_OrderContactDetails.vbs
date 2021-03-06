'****************************************************************************************************************************
' Function Name	 : fn_eDCA_OrderContactDetails
' Purpose	 	 : Function to enter values in Order Contact details Page
' Creation Date    : 28/05/2013             					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_OrderContactDetails(dOrderType,dOrderMgrFirstName,dOrderMgrLastName,dOrderMgrEmail,dOrderMgrPhone,dBTMgrFirstName,dBTMgrLastName,dBTMgrEmail,dBTMgrPhone)

	'Variable Declaration Section
	Dim strOrderMgrFirstName,strOrderMgrLastName,strOrderMgrEmail,strOrderMgrPhone
	Dim strBTMgrFirstName,strBTMgrLastName,strBTMgrEmail,strBTMgrPhone
    Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strOrderMgrFirstName = dOrderMgrFirstName
	strOrderMgrLastName = dOrderMgrLastName
	strOrderMgrEmail = dOrderMgrEmail
	strOrderMgrPhone = dOrderMgrPhone

	strBTMgrFirstName = dBTMgrFirstName
	strBTMgrLastName = dBTMgrLastName
	strBTMgrEmail = dBTMgrEmail
	strBTMgrPhone = dBTMgrPhone
      
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Enter First Name -  Order Contact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
			blnResult = enterText("txtOrderMgrFirstName",strOrderMgrFirstName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtOrderMgrFirstName").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtOrderMgrFirstName",strOrderMgrFirstName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Order Manager First Name","Order Manager First Name should be populated","Order Manager First Name is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If
    
	'Enter Last Name - Order Contact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
			blnResult = enterText("txtOrderMgrLastName",strOrderMgrLastName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtOrderMgrLastName").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtOrderMgrLastName",strOrderMgrLastName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Order Manager Last Name","Order Manager's Last Name should be populated","Order Manager's Last Name is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	'Enter Email - Order Contact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		blnResult = enterText("txtOrderMgrEmail",strOrderMgrEmail)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtOrderMgrEmail").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtOrderMgrEmail",strOrderMgrEmail)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Order Manager Email","Order Manager's Email should be populated","Order Manager's Email is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	'Enter Phone - Order Contact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		blnResult = enterText("txtOrderMgrPhone",strOrderMgrPhone)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtOrderMgrPhone").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtOrderMgrPhone",strOrderMgrPhone)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Order Manager Email","Order Manager's Phone should be populated","Order Manager's Phone is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	'Enter details in Manager Contact Details Page
	'Enter First Name -  ManagerContact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		blnResult = enterText("txtBTMgrFirstName",strBTMgrFirstName)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtBTMgrFirstName").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtBTMgrFirstName",strBTMgrFirstName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("BT Project Manager First Name","BT Project Manager First Name should be populated","BT Project Manager First Name is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	'Enter Last Name - Manager Contact details Page
	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		blnResult = enterText("txtBTMgrLastName",strBTMgrLastName)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtBTMgrLastName").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtBTMgrLastName",strBTMgrLastName)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("BT Project Manager Last Name","BT Project Manager Last Name should be populated","BT Project Manager Last Name is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
			blnResult = enterText("txtBTMgrEmail",strBTMgrEmail)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtBTMgrEmail").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtBTMgrEmail",strBTMgrEmail)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("BT Project Manager Email","BT Project Manager's Email should be populated","BT Project Manager's Email is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		blnResult = enterText("txtBTMgrPhone",strBTMgrPhone)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		strRetrievedText = ObjPage.WebEdit("txtBTMgrPhone").GetROProperty("Value")
		If strRetrievedText ="" Then
			blnResult = enterText("txtBTMgrPhone",strBTMgrPhone)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Else
			Call ReportLog("BT Project Manager Phone","BT Project Manager's Phone should be populated","BT Project Manager's Phone is populated with the value - "&strRetrievedText,"PASS","")
		End if
	End If

    'Click on Next Button
	Call ReportLog("Order Contact Details","Order Contact Details Page should be completed","Order Contact Details Page completed successfully","PASS","TRUE")
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Addtional information  Page
	Set objMsg = objpage.Webelement("webElmAdditionalInformation")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Additional Information page","Should be navigated to Additional Information page on clicking Next Buttton","Not navigated to Additional Information page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmAdditionalInformation")
		Call ReportLog("Additional Information page","Should be navigated to Additional Information  page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment("Action_Result") = True
	End If

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
