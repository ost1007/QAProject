'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_TaskClosure
' Purpose					: 			Function to check closure status of tasks in AIB
' Author					:		  	Nagaraj V|| 27/11/2014
' Parameters	 		 :			AIBUrl,SearchData,TaskName, ExpectedStatus  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_AIB_FetchTaskID(ByVal AIBUrl, ByVal UserName, ByVal Password, ByVal SearchData, ByVal TaskName, ByVal ExpectedStatus)
	On Error Resume Next
		'Variable Declaration
		Dim StrColumnName, strColumnValue, strTaskName, strAIBURL, strAIBSearchData
		strTaskName = TaskName
		strAIBURL = AIBUrl
		strAIBSearchData = SearchData

		'If Application is already loaded with Search Data then no need to Login
		blnResult = Browser("brwAIB").Exist(5)
        If Not blnResult Then
			Call fn_AIB_Login(strAIBURL, UserName, Password)
			Call fn_AIB_OrderSearch(strAIBSearchData)
		End If

		'Build  web reference
		If Browser("brwAIB").Page("pgAIB").Exist Then
			blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then
				Environment.Value("Action_Result") = False  
				Exit Function
			End If	
		End If

		Wait 3
		'Click on Fulfilment orders tab
		If objPage.Link("lnkFulfilmentOrders").Exist Then
			blnResult = clickLink("lnkFulfilmentOrders")
			If Not blnResult Then
				Environment.Value("Action_Result") = False  
				Exit Function
			End If
			objPage.Sync
		End If

		Wait 5

		'To Capture Task ID
		If objPage.WebTable("tblFulfilmentOrderNumber").Exist Then
			'Set main Order table under Fulfilment Tab
			Set objTable = objPage.WebTable("tblFulfilmentOrderNumber")
			'Set main Order table under Fulfilment Tab
			intRowCount = objTable.GetROProperty("rows")
			For intRow = 2 to intRowCount
				strRetrievedText = objTable.GetCellData(intRow,2)
				If Trim(UCase(strRetrievedText)) = Trim(UCase(strTaskName)) Then
					strTaskID = objTable.GetCellData(intRow, 1)
					If strTaskID = "" Then
						Call ReportLog("Fetch Task ID", "Task ID should be captured", "Task ID for <B>" & strTaskName & " </B> is found to be blank", "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					Else
                        Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dTaskID", strTaskID)
						Call ReportLog("Fetch Task ID", "Task ID should be captured", "Task ID for <B>" & strTaskName & " </B> is found to be <B>" & strTaskID & "<B>", "PASS", False)
						objTable.ChildItem(intRow, 1, "WebElement", 0).HighLight
						blnStatus = fn_AIB_CheckCompletionStatus(intRow, objTable, ExpectedStatus, strOrderNumber)
						If Not blnStatus Then
							Environment("Action_Result") = False
							Exit Function
						Else
							Environment("Action_Result") = True
						End If
						Exit For
					End If
				End If
			Next
		End If

		If Browser("brwAIB").Exist(2)Then
			Browser("brwAIB").Close
		End If
End Function
