'****************************************************************************************************************************
' Function Name	 : fnc_SI_Override
' Purpose	 	 : Function to perform Override functionality in SI
' Author	 	 : Linta CK Creation Date  : 18/06/2013
' Modified By	: Nagaraj V			01/04/2014
' Parameters	 : 	SystemName,AIId,Reason
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fnc_SI_Override(vSystemName,vAIId,vReason)

	'Variable Declaration Section
	Dim strMessage,strAIId,strSystemName
	Dim objMsg
	Dim blnResult
	Dim intCounter

	'Assignment of Variables
	strAIId = vAIId
	strSystemName = vSystemName
	strReason = vReason

	For intCounter = 1 to 10
		blnResult = Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Exist
		If blnResult Then
			Exit For
		else
			Wait 2
		End If
	Next

	If Not blnResult Then
		Call ReportLog("SI Home Page","Should navigate to SIHome Page","Not navigated to SI Home Page","Fail","True")
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function		
	End If

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSIMain","pgSIMain","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	objPage.Sync

	'Click on Workflow link
	blnResult = clickLink("lnkWorkflow")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	For intCounter = 1 to 10
		blnResult = Browser("brwSIWorkflow").Page("pgSIWorkflow").Link("lnkOverride").Exist
		If blnResult Then
			Exit For
		else
			Wait 2
		End If
	Next

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSIWorkflow","pgSIWorkflow","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	If Not blnResult Then
		Call ReportLog("Click on Workflow link","Should be able to see Override link","Override link not visible","Fail","True")
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function		
	End If

	'Click on Override link
	blnResult = clickLink("lnkOverride")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Enter Search Criterias
	For intCounter = 1 to 10
		blnResult = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebList("lstSystem").Exist
		If blnResult Then
			Exit For
		Else
			Wait 2
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Click on Override link","Should be able to see SI Override page","SI Override page not visible","Fail","True")
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function		
	End If

	'Enter value for System field
	blnResult = selectValueFromPageList("lstSystem",strSystemName)
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	Wait 3

	'Enter WorkItemId
	blnResult = enterText("txtServiceIdorActionItemId",strAIId)
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	Wait 3

	'Enter value for Reason field
	blnResult = selectValueFromPageList("lstReason",strReason)
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Click on Search button
	blnResult = clickButton("btnSearch")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	If objPage.WebElement("elmNoResultFound").Exist Then
		Call ReportLog("Search for WI","WI Details should be retrieved on search","WI Details not retrieved on search","FAIL",True)
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	blnSearch = False

	For intCounter = 1 to 5
		blnResult = objPage.WebEdit("txtSearchResults_WorkItemId").Exist(10)
		If blnResult Then
			blnSearch = True
			Exit For
		Else
			Wait 2
		End If
	Next

	isNEOActionItemID = False
	'Check for another 21CN orders
	For intCounter = 1 to 5
		isNEOActionItemID = objPage.WebTable("webTblActionID").Exist(10)
		If isNEOActionItemID Then
			blnSearch = True
			Exit For
		Else
			Wait 2
		End If
	Next
	
	If Not blnSearch Then
		Call ReportLog("Search for WI","WI Details should be retrieved on search","WI Details not retrieved on search","Fail","")
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	If Not isNEOActionItemID Then
		'Fetch the values retrieved on search
		strRetrievedText = objPage.WebEdit("txtSearchResults_WorkItemId").GetROProperty("value")
		If Trim(strAIId) = Trim(strRetrievedText) Then
			Call ReportLog("Action item Id","Action Item id searched should be retrieved for override.","Searched Action Item Id - "&strAIId&" is retrieved.","PASS","")
		Else
			Call ReportLog("Action item Id","Action Item id searched should be retrieved for override.","Searched Action Item Id - "&strAIId&" is not retrieved.","Fail","")
			Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
		
		strRetrievedText = objPage.WebEdit("txtSearchResults_JobId").GetROProperty("value")
		Call ReportLog("Job Id","Job Id should be retrieved on search","Job Id retrieved - "&strRetrievedText,"PASS","")
		strRetrievedText = objPage.WebEdit("txtSearchResults_Queue").GetROProperty("value")
		Call ReportLog("Queue name","Queue name should be retrieved on search","Queue name retrieved - "&strRetrievedText,"PASS","")
		strRetrievedText = objPage.WebEdit("txtSearchResults_Created").GetROProperty("value")
		Call ReportLog("Created","Created should be retrieved on search","Created retrieved - "&strRetrievedText,"PASS","")
		strRetrievedText = objPage.WebEdit("txtSearchResults_AssignedTo").GetROProperty("value")
		Call ReportLog("AssignedTo","AssignedTo should be retrieved on search","AssignedTo retrieved - "&strRetrievedText,"PASS","")
	Else
		blnExistActionItem = False
		intRow = objPage.WebTable("webTblActionID").RowCount
		intCol = objPage.WebTable("webTblActionID").ColumnCount(1)
		For iRow = 2 to intRow - 1
			For iCol = 1 to intCol
				strData = objPage.WebTable("webTblActionID").GetCellData(iRow, iCol)
				If Trim(AIId) = Trim(strData) Then
					Set chkBox = objPage.WebTable("webTblActionID").ChildItem(iRow, iCol - 1, "WebCheckBox", 0)
					blnExistActionItem = True
					chkBox.Set "ON"
					If chkBox.WaitProperty("checked","1", 30000)  Then
						Call ReportLog("Override Task","Should be able to check the Box beside Action Item ID","Able to check the Box beside Action Item ID","PASS","")
					Else
						Call ReportLog("Override Task","Should be able to check the Box beside Action Item ID","Not Able to check the Box beside Action Item ID","FAIL",True)
						Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
						Call EndReport()
						Exit Function
					End If
					Exit For
				End If
			Next
		Next 
	End If

	'Click on Assign button
	blnResult = clickButton("btnAssign")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	For intCounter = 1 to 40
		'Check if navigation was successful
		Set objMsg = objpage.WebElement("webElmMyWork")
		If objMsg.Exist = "True" Then
			Exit For
		Else
			Wait 2
		End If
	Next

    If Not objMsg.Exist Then
		Call ReportLog("Override","Should navigate to 'My Work' after Override","Not succesfully navigated to 'My Work'","FAIL","TRUE")
		Environment.Value("Action_Result") = False  'Environment.Value("Action_Result") = False  'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	Else
		strMessage = GetWebElementText("webElmMyWork")
		Call ReportLog("Override","Should navigate to 'My Work' after Override","Login Successful and Navigated to the page - '"&strMessage&"'.","PASS","")
	End If
	
	Environment.Value("Action_Result") = True 
End Function


'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
