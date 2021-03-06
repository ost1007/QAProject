Public Function fn_eDCA_SubmitNew(dTypeOfOrder,dSearch,deDCAOrderId, dServiceDelivery, dServiceDeliveryOwner)

	blnPrevNext = False
	For intCounter = 1 to 5
			If blnPrevNext Then
				objPage.Sync
				objPage.WbfTreeView("html id:=TreeView1").Link("innertext:=Distributor Contact Details.*", "index:=0").Click
				Wait 2
				objPage.Sync
			End If
		
			'Function to set the browser and page objects by passing the respective logical names
			blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
			'Click on Submit link of Left hand isde
			Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
			Call ReportLog("Submit","Should be navigated to Submit Page","Navigated to Submit Page successfully","PASS","TRUE")
			If Instr(UCase(dTypeOfOrder), "PROVIDE") > 0 OR UCase(dTypeOfOrder) = "MPLSPLUSIA" Then
				'Click on btnValidateTrunkGroupAndTrunkFriendlyName button
				If objPage.WebButton("btnValidateTrunkGroupAndTrunkFriendlyName").Exist Then
						If objPage.WebButton("btnValidateTrunkGroupAndTrunkFriendlyName").GetROProperty("disabled") = 0 Then
							blnResult = clickButton("btnValidateTrunkGroupAndTrunkFriendlyName")
								If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						Else
							Call ReportLog("Click on ValidateTrunkGroupAndTrunkFriendlyName","ValidateTrunkGroupAndTrunkFriendlyName should be clicked","ValidateTrunkGroupAndTrunkFriendlyName is not enabled","FAIL","TRUE")
							Environment("Action_Result") = False : Exit Function
						End If
						Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If
			End If

			If Not objPage.WebButton("btnOrderValidation").WaitProperty("disabled", 0, 30000) Then
				blnPrevNext = True
			Else
				Exit For
			End If
	Next

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
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
	Wait 5
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WbfGrid("html id:=UsrTahitiSubmit_dgErrorList","index:=0").Exist(60) Then
		Call ReportLog("Click on OrderValidation","Error List Found",objPage.WbfGrid("html id:=UsrTahitiSubmit_dgErrorList","index:=0").GetROProperty("innerHTML"),"FAIL", TRUE)
		Environment("Action_Result") = False : Exit Function
	End If

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	blnResult = setCheckBox("chkSubmitSDqueue", "ON")
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait(10)
	
	'If objPage.WebElement("html id:=Header1_lblProfile", "html tag:=SPAN", "index:=0").Exist(5) Then
	'	strProfile = objPage.WebElement("html id:=Header1_lblProfile", "html tag:=SPAN", "index:=0").GetROProperty("innertext")
	'	arrProfileText = Split(strProfile, " - ")
	'	strCountryText = Split(arrProfileText(1), "Sales")
	'	strCountry = Trim(strCountryText(1))
	'	If Instr(dServiceDelivery, strCountry) <= 0 Then
	'		dServiceDelivery = "Service Delivery " & strCountry
	'	End If
	'End If
	
	blnResult = objPage.WebList("lstSubmitServiceDelivery").Exist(120)	
	'Select Service Delivery
	blnResult = selectValueFromPageList("lstSubmitServiceDelivery", dServiceDelivery)
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select Service Delivery Owner
	Wait(10)
	blnResult = selectValueFromPageList("lstSubmitServiceDeliveryOwner", dServiceDeliveryOwner)
		If blnResult = False Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If objPage.WebButton("btnSubmitToSDWithAutoEmail").Exist Then
		If objPage.WebButton("btnSubmitToSDWithAutoEmail").GetROProperty("disabled") = 0 Then
			blnResult = clickButton("btnSubmitToSDWithAutoEmail")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Else
			Call ReportLog("Click on SubmitToSDWithAutoEmail","SubmitToSDWithAutoEmail should be clicked","SubmitToSDWithAutoEmail is not enabled","FAIL","TRUE")
			Environment("Action_Result") = False
			Exit Function
		End If
	End If

	If Instr(dTypeOfOrder, "CEASE") > 0 Then
		If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist then 
			Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
		End If
		Wait 5
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessage").GetROProperty("innertext")
	If strRetrievedText <> "" Then
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is not populated","FAIL","TRUE")
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = selectValueFromPageList("lstSearch", dSearch)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = enterText("txtSearch", deDCAOrderId)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

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
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	End if

	'Closing the browser after signing out
	Browser("brweDCAPortal").Close
	
End Function
