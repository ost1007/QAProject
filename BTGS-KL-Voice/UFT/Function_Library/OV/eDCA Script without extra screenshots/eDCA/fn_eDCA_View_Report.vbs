Public Function fn_eDCA_View_Report(deDCAOrderId,dPhysicalPortInterfaceType,dFullLegalCompanyName)

	Dim streDCAOrderId,strFullLegalCompanyName
	streDCAOrderId = deDCAOrderId
    strFullLegalCompanyName = dFullLegalCompanyName
	strServiceCentre = dServiceCentre
	strPhysicalPortInterfaceType = dPhysicalPortInterfaceType

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If


	'Clicking on Submit link on left side
    blnResult =Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
	If blnResult = True Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Wait (3)

	
	blnResult =clickButton("btnViewDiffReport")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait (10)

	blnResult = BuildWebReference("brwOnevoiceDiffReport","pgOnevoiceDiffReport","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brwOnevoiceDiffReport").Page("pgOnevoiceDiffReport").Sync

'		strRetrievedText = objpage.WebElement("webElmeDCAorderID").GetROProperty("innertext")
'		If trim(strRetrievedText) =  Trim(streDCAOrderId) Then
'			Call ReportLog("One Voice Difference Page","eDCA order ID should be populated","eDCA order ID is populated with the value - "&strRetrievedText,"PASS","")
'		End If

		strRetrievedText = objpage.WebElement("webelmCustomerName").GetROProperty("innertext")
		If trim(strRetrievedText) =  Trim(strFullLegalCompanyName) Then
			Call ReportLog("One Voice Difference Page","Full Legal Company Name should be populated","FullLegalCompanyName is populated with the value - "&strRetrievedText,"PASS","")
		End If

		strRetrievedText = objpage.WebElement("webElmCustomerOldValue").GetROProperty("innertext")
        Call ReportLog("One Voice Difference Page","Customer Old Name should be populated","Customer Old Name is populated with the value - "&strRetrievedText,"PASS","")
		
		strRetrievedText = objpage.WebElement("webElmCustomerNewValue").GetROProperty("innertext")
		If trim(strRetrievedText) =  Trim(strServiceCentre) Then
			Call ReportLog("One Voice Difference Page","Customer New Name should be populated","Customer New Name is populated with the value - "&strRetrievedText,"PASS","")
		End If

		Browser("brwOnevoiceDiffReport").Close

		blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
		End If

		blnResult = selectValueFromPageList("lstPhysicalPortInterfaceType",strPhysicalPortInterfaceType)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
	Wait 5

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		blnResult = clickButton("btnApproveDiffReport")
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
	Wait 3
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = clickButton("btnUploadPass1DataToClassic")
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
	Wait 5
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
'
If Browser("brweDCAPortal").Dialog("MessageFromWebpage").Exist Then
Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").HighLight
Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
End if

If Browser("brweDCAPortal").Page("pgeDCAPortal").Link("lnkOrderList").Exist then
	Browser("brweDCAPortal").Page("pgeDCAPortal").Link("lnkOrderList").highlight
	Browser("brweDCAPortal").Page("pgeDCAPortal").Link("lnkOrderList").Click
End If

  
wait 10
	blnResult = selectValueFromPageList("lstSearch",strSearch)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

wait 1
	'Enter the order id into search
	blnResult = enterText("txtSearch",streDCAOrderId)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
wait 1
If Browser("brweDCAPortal").Page("pgeDCAPortal").WebCheckBox("chkSearchAllRecords").Exist Then 
Browser("brweDCAPortal").Page("pgeDCAPortal").WebCheckBox("chkSearchAllRecords").Set "ON"
End if
	'Click on Search button
	blnResult = clickButton("btnSearch")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

wait 5

'		Capturing the order submission message
'	strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessage").GetROProperty("innertext")
'	If strRetrievedText <> "" Then
'		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is populated with the value - "&strRetrievedText,"PASS","")
'	Else
'		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is not populated","FAIL","TRUE")
'	End If



		blnResult = clickLink("lnkSignout")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Closing the browser
	Browser("brweDCAPortal").Close

        		
End Function
