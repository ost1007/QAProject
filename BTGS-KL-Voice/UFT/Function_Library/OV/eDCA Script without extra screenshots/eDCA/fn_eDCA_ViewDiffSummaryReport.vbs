Public Function fn_eDCA_ViewDiffSummaryReport(ByVal eDCAOrderId, ByVal ClassicSiteId, ByVal PhysicalOrLogical)

	Dim streDCAOrderId, strClassicSiteId
    strClassicSiteId = ClassicSiteId
    streDCAOrderId = eDCAOrderId

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False

	blnResult = Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
	If blnResult = True Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	For intCounter = 1 To 10
		If objPage.WebButton("btnViewDiffReport").Exist Then Exit For
	Next
	
	blnResult = clickButton("btnViewDiffReport")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	For intCounter = 1 To 10
		blnExist = Browser("brwOnevoiceDiffReport").Exist
		If blnExist Then
			blnResult = BuildWebReference("brwOnevoiceDiffReport","pgOnevoiceDiffReport","")
				If Not blnResult Then Environment.Value("Action_Result") = False
			Call ReportLog("View Diff Report", "Report Should be displayed", "Report is displayed", "PASS", True)
			Browser("brwOnevoiceDiffReport").Close
			Wait 5
			Exit For
		End If
	Next

	'Terminate if Report is not downlaoded
	If Not blnExist Then
		Call ReportLog("View Diff Report", "Report Should be displayed", "Report is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = clickButton("btnViewDiffSummaryReport")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	Browser("brwDiffSummaryReport").Page("pgDiffSummaryReport").Sync

	blnResult = BuildWebReference("brwDiffSummaryReport","pgDiffSummaryReport","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	strRetrievedText = objpage.WebElement("webElmClassicSiteId").GetROProperty("innertext")
	If trim(strRetrievedText) =  Trim(strClassicSiteId) Then
		Call ReportLog("Diff Summary Report Page","Classic Site Id should be populated","Classic Site Id is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("Diff Summary Report Page","Classic Site Id should be populated","Classic Site Id is populated with the value - "&strRetrievedText,"FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	strRetrievedText = objpage.WebElement("webElmeDCAorderId").GetROProperty("innertext")
	If trim(strRetrievedText) =  Trim(streDCAOrderId) Then
		Call ReportLog("Diff Summary Report Page","eDCA Order Id should be populated","eDCA Order Id is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("Diff Summary Report Page","eDCA Order Id should be populated","eDCA Order Id is populated with the value - "&strRetrievedText,"FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
  
	Browser("brwDiffSummaryReport").Close

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = selectValueFromPageList("lstLogicalOrPhysical", PhysicalOrLogical)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = clickButton("btnApproveDiffReport")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	Environment("Action_Result") = True
    		
End Function
