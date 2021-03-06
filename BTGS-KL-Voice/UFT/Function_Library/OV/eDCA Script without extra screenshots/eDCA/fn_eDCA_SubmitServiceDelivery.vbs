'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SubmitServiceDelivery
' Purpose	 	 :  Submitting the order when logged in with Serivce Delivery
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 14/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_SubmitServiceDelivery(dTypeOfOrder,dPPRValidationCompleted,dSearch,deDCAOrderId,dOETOwner)

	'Variable declaration section
	Dim strPPRValidationCompleted,strSearch,strSearchOrderIdValue

	'Assignment of variables
	strPPRValidationCompleted = dPPRValidationCompleted
	strSearch = dSearch
	streDCAOrderId = deDCAOrderId
	strEmailMessage = "Test"

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Submit link on left side
   	Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
	For intCounter = 1 To 5
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	
	Next

	'Click on PPR Validation Completed - Set the Check Box "ON"
	For intCounter = 1 To 5
		If objPage.WebCheckBox("chkPPRValidationCompleted").Exist(60) Then
			blnResult = setCheckBox("chkPPRValidationCompleted", strPPRValidationCompleted)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function	
			
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync		
			
			blnSetPPR = objPage.WebCheckBox("chkPPRValidationCompleted").WaitProperty("checked", 1, 1000*60*2)
			If blnSetPPR Then
				Exit For
			End If
		End If
	Next
	
	If Not blnSetPPR Then
		Call ReportLog("PPR Validation", "PPR validation should be done", "Unable to select PPR Validation after try", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	
	Wait 5
	
	'add for R48 --------
	'Select Overwrite Order Entry Submission Queue
	blnResult = setCheckBox("chkSubmitOETQueue", "ON")
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 10
	
	'Select OET
	blnResult = selectValueFromPageList("lstSubmitOET", "BT Customer Order Entry Wipro")
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 5
	
	'Select OET
	blnResult = selectValueFromPageList("lstSubmitOETOwner", dOETOwner)
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 10
	'--------------------

	'Click on Submit To OET with Auto Email button
	If Instr(dTypeOfOrder, "CEASE") > 0 Then
		If ObjPage.Webbutton("btnSubmitToOETwithManulEmail").Exist Then
			blnResult = clickButton("btnSubmitToOETwithManulEmail")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End if

		If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist(10) then 
			Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		Wait(30)
	
		If ObjPage.WebEdit("txtemailmessage").Exist(10) then 
			blnResult = enterText("txtemailmessage", strEmailMessage)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End if

		If ObjPage.WebButton("btnSubmitOrder").Exist(10) then
			blnResult = ClickButton("btnSubmitOrder")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End if
		Wait 5
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		blnResult = clickButton("btnSubmitToOETwithAutoEmail")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End if

	If dTypeOfOrder = "MODIFY" Then
		blnResult = clickButton("btnUploadPass1DataToClassic")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Capturing the order submission message
	strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessage").GetROProperty("innertext")
	If strRetrievedText <> "" Then
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Search with order ID
	blnResult = selectValueFromPageList("lstSearch",strSearch)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Enter the order id into search
	blnResult = enterText("txtSearch",streDCAOrderId)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on Search button
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on Submit to Oet link
	'	blnResult = clickLink("lnkSubmitToOet")
	'		If blnResult = False Then
	'			Environment("Action_Result") = False
	'			Call EndReport()
	'			Exit Function
	'		End If
	'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Signing out from eDCA
	blnResult = clickLink("lnkSignout")
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Closing the browser
	Browser("brweDCAPortal").Close

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
