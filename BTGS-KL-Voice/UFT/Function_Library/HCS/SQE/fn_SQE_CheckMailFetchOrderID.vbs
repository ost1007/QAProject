Public Function fn_SQE_CheckMailFetchOrderID(ByVal ExpectedSuccessMessage)
	On Error Resume Next
	'Variable Declaration
	Dim objOutlook, objNameSpace, objFolder
	Dim intMailCount, intCheckMailCount
	Dim strSubject, strMailContent
	
	Set objOutlook = Eval("GetObject(,""Outlook.Application"")")
	If Err.Number = 429 Then
		Err.Clear
		Set objOutlook = CreateObject("Outlook.Application")
	End If
	
	Set objNameSpace = objOutlook.GetNameSpace("MAPI")
	Set objFolder = objNameSpace.GetDefaultFolder(6)
	
	intCheckMailCount = 0
	For intCounter = 1 To 5
		Set mailItems = objFolder.Items.Restrict("[Subject] = '" & ExpectedSuccessMessage &"'")
		intMailCount = mailItems.Count
		If intMailCount >= 1 Then
			Set mailItem = mailItems.GetLast
			For index = intMailCount to 1 step -1
				If mailItem.ReceivedTime >= Date Then
					intCheckMailCount = intCheckMailCount + 1
				End If
			Next 'index
			
			'Even though mail items are terminate For condition iff it is received today
			If intCheckMailCount <> 0 Then
				Exit For
			Else
				Wait 60
			End If
		Else
			Wait 60
		End If
	Next 'intCounter
	
	intMailCount = mailItems.Count
	Set mailItem = mailItems.GetLast
	
	For index = intMailCount to 1 step -1
		If mailItem.ReceivedTime >= Date Then
			strSubject = mailItem.Subject
			strMailContent = mailItem.HTMLBody
			If Instr(strSubject, ExpectedSuccessMessage) > 0 Then '#1
				Call ReportLog("Capture Mail Content", "Mail Subject Should Contain <B>" & ExpectedSuccessMessage & "</B>", "Verification of Mail Subject Passed </BR>" & strMailContent , "PASS", False)
				Environment("Action_Result") = True
				Exit For
			End If '#1
		End If
		Set mailItem = mailItems.GetPrevious
	Next
	
	Set objOutlook = Nothing
	Set objNameSpace = Nothing
	Set objFolder = Nothing
	Set mailItems = Nothing
	
	Set oDOM = CreateObject("HTMLFILE")
	oDom.write(strMailContent)
	Set oTable = oDOM.getElementsByTagName("table")
	If oTable.length = 0 Then
		Call ReportLinerMessage(strMailContent)
		Call ReportLog("Fetch Order Number", "Order Number should be fetched from Email", "Order table doesn't exist", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Set oTR = oTable.item(0).getElementsByTagName("tr")
	intRows = oTR.Length
	If intRows <= 1 Then
		Call ReportLog("Fetch Order Number", "Order Number should be fetched from Email", "Order table contains rows <= 1", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	For iCellIterator = 0 To oTR.Item(0).Cells.Length - 1
		If UCase(oTR.Item(0).Cells(iCellIterator).innerText) = "EXPEDIO ORDER ID" Then
			For iRow = 1 To intRows - 1
				strOrderID = Trim(oTR.Item(iRow).Cells(iCellIterator).innerText)
				If iRow <> intRows - 1 Then
					ExpedioOrderID = ExpedioOrderID & "EXP" & strOrderID & ","
				Else
					ExpedioOrderID = ExpedioOrderID & "EXP" & strOrderID
				End If
			Next
			Exit For '#iCellIterator
		End If
	Next
	
	If ExpedioOrderID = "" Then
		Call ReportLog("Fetch Order Number", "Order Number should be fetched from Email", "Order ID doesn't exist", "FAIL", False)
		Environment("Action_Result") = False
	Else
		Call ReportLog("Capture Expedio ID", "Expedio ID should be generated", "Expedio ID is found to be " & ExpedioOrderID, "PASS", False)
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dExpedioID", ExpedioOrderID)
		Environment("Action_Result") = True
	End If
	
End Function
