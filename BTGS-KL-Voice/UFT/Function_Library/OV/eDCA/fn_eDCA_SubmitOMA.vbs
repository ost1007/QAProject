Public Function fn_eDCA_SubmitOMA(dTypeOfOrder,dSearch,deDCAOrderId, dServiceDelivery, dServiceDeliveryOwner)
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on Submit link of Left hand isde
	blnResult =Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
	If blnResult = True Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebButton("btnOrderValidation").Exist Then
		If objPage.WebButton("btnOrderValidation").GetROProperty("disabled") = 0 Then
			blnResult = clickButton("btnOrderValidation")
				If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
		Else
			Call ReportLog("Click on OrderValidation","OrderValidation should be clicked","OrderValidation is not enabled","FAIL","TRUE")
			Environment("Action_Result") = False
			Exit Function
		End If
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = setCheckBox("chkSubmitSDqueue", "ON")
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Service Delivery
	blnResult = selectValueFromPageList("lstSubmitServiceDelivery", dServiceDelivery)
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Service Delivery Owner
	blnResult = selectValueFromPageList("lstSubmitServiceDeliveryOwner", dServiceDeliveryOwner)
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebButton("btnSubmitToSDWithAutoEmail").Exist Then
		If objPage.WebButton("btnSubmitToSDWithAutoEmail").GetROProperty("disabled") = 0 Then
			blnResult = clickButton("btnSubmitToSDWithAutoEmail")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Else
			Call ReportLog("Click on SubmitToSDWithAutoEmail","SubmitToSDWithAutoEmail should be clicked","SubmitToSDWithAutoEmail is not enabled","FAIL","TRUE")
			Environment("Action_Result") = False
			Exit Function
		End If
	End If

	strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessage").GetROProperty("innertext")
	If strRetrievedText <> "" Then
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is not populated","FAIL","TRUE")
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = selectValueFromPageList("lstSearch", dSearch)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	blnResult = enterText("txtSearch", deDCAOrderId)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = clickButton("btnSearch")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
'	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retrive the order status
	strRetrivedText = objPage.Link("lnkSubmitToSd").GetROProperty("outertext")
	If strRetrivedText<>"" Then
		Call ReportLog("Submit To Sd","Submit To Sd link should be populated","Submit To Sd link is populated with value-"&strRetrievedText,"PASS","")
	Else
		Call ReportLog("Submit To Sd","Submit To Sd link should be populated","Submit To Sd is not populated","FAIL","TRUE")
		blnResult = clickLink("lnkSignout")
		Environment("Action_Result") = False
	End If

	'Signing out from appliaction
	If objPage.Link("lnkSignout").Exist Then
		blnResult = clickLink("lnkSignout")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End if

	'Closing the browser after signing out
	Browser("brweDCAPortal").Close
	
End Function