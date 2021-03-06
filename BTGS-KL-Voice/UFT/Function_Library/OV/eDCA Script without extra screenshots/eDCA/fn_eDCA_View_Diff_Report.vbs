'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_Submit
' Purpose	 	 :  Submiting the order and checking the status 
' Author	 	 : Anil Kumar Pal
' Creation Date    : 21/08/2014
' Return values :	Nil
'**************************************************************************************************************************************	
Public Function fn_eDCA_View_Diff_Report(dPhysicalPortInterfaceType,dClassicSiteId,deDCAOrderId)

	Dim streDCAOrderId,strFullLegalCompanyName
	strPhysicalPortInterfaceType = dPhysicalPortInterfaceType
    strClassicSiteId = dClassicSiteId
    streDCAOrderId = deDCAOrderId

	'Function to set the browser and page objects by passing the respective logical names
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

	blnResult = clickButton("btnViewDiffSummaryReport")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brwDiffSummaryReport").Page("pgDiffSummaryReport").Sync

	blnResult = BuildWebReference("brwDiffSummaryReport","pgDiffSummaryReport","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	strRetrievedText = objpage.WebElement("webElmClassicSiteId").GetROProperty("innertext")
	If trim(strRetrievedText) =  Trim(strClassicSiteId) Then
		Call ReportLog("Diff Summary Report Page","Classic Site Id should be populated","Classic Site Id is populated with the value - "&strRetrievedText,"PASS","")
	End If

	strRetrievedText = objpage.WebElement("webElmeDCAorderId").GetROProperty("innertext")
	If trim(strRetrievedText) =  Trim(streDCAOrderId) Then
		Call ReportLog("Diff Summary Report Page","eDCA Order Id should be populated","eDCA Order Id is populated with the value - "&strRetrievedText,"PASS","")
	End If
	Browser("brwDiffSummaryReport").Close

	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	blnResult = clickButton("btnApproveDiffReport")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
End Function
