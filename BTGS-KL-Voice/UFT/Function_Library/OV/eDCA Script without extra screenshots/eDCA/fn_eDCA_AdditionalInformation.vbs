'****************************************************************************************************************************
' Function Name	 : fn_eDCA_AdditionalInformation
' Purpose	 	 : Function to validate for Additional Information page
' Author	 	 : Linta CK
' Creation Date  	 : 29/05/2013            					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_AdditionalInformation(dOrderType)

	'Variable Declaration Section
	Dim strRetrievedText,strMessage
	Dim objMsg
	Dim blnResult

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retrieve BFGCustomer ID and Check Digit field Values
	strRetrievedText = objPage.WebEdit("txtBFGCustomerID").GetROProperty("value")
	If strRetrievedText <> "" Then
		Call ReportLog("BFG Customer ID","BFG Customer ID should be populated","BFG Customer ID is populated with the value - "&strRetrievedText,"PASS","")
	Else
		Call ReportLog("BFG Customer ID","BFG Customer ID should be populated","BFG Customer ID is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	strRetrievedText = objPage.WebEdit("txtCheckDigit").GetROProperty("value")
	If strRetrievedText <> "" Then
		Call ReportLog("Check Digit","Check Digit should be populated","Check Digit is populated with the value - "&strRetrievedText,"PASS","")
	Else
		Call ReportLog("Check Digit","Check Digit should be populated","Check Digit is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Check if Navigated to Product Selection Page
	If dOrderType = "ADD"  OR dOrderType = "PROVIDE" Then
		Set objMsg = objpage.WebElement("webElmProductSelection")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Additional Information","Should be navigated to Product Selection page on clicking Next Buttton","Not navigated to Product Selection page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmProductSelection")
			Call ReportLog("Additional Information","Should be navigated to Product Selection page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
	Elseif dOrderType = "CEASE"  Then
		Set objMsg = objpage.WebElement("webElmSites")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Sites","Should be navigated to Sites page on clicking Next Buttton","Not navigated to Sites page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmSites")
			Call ReportLog("Sites","Should be navigated to Sites page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
	End if
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************