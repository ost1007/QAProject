Public Function fn_BFG_CheckPackageInstanceStatus(ByVal PackageName, ByVal Status)

	'Variable Declaration
	Dim iRow
	Dim strStatus

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBFG-IMS","pgBFG-IMS","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	iRow = objPage.WebTable("tblPackageInstanceMain").GetRowWithCellText(Trim(PackageName))
	Set objWebRadioGrp = objPage.WebTable("tblPackageInstanceMain").ChildItem(iRow, 1, "WebRadioGroup", 0)
	arrValues = Split(objWebRadioGrp.GetROProperty("all items"), ";")
    objWebRadioGrp.Select arrValues(iRow - 2)
	Wait 10

	'Click on View PI
	blnResult = clickButton("btnViewPI")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	objPage.Sync
	
	For intCounter = 1 To 5
		blnResult = objPage.WebList("lstPISTATUS").Exist
			If blnResult Then Exit For
	Next
	
	If blnResult Then
		strStatus = objPage.WebList("lstPISTATUS").GetROProperty("selection")
		If strStatus = Status Then
			Wait 60
			Call ReportLog("BFG Order Status", "Package Instance Status for <B>" & PackageName & "</B> should be <B>" & Status,_
				"Package Instance Status for <B>" & PackageName & "</B> found to be <B>" & strStatus, "PASS", True)
				Environment("Action_Result") = True
		Else
			Wait 60
			Call ReportLog("BFG Order Status", "Package Instance Status for <B>" & PackageName & "</B> should be <B>" & Status,_
				"Package Instance Status for <B>" & PackageName & "</B> found to be <B>" & strStatus, "FAIL", True)
				Environment("Action_Result") = False
		End If
	Else
		Call ReportLog("PI Page", "Should be navigated to PI information Page", "Not navigated to PI information Page", "FAIL", True)
		Environment("Action_Result") = False
	End If

	Browser("brwBFG-IMS").CloseAllTabs
End Function
