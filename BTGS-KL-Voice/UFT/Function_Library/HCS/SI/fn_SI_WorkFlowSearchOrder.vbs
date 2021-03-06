'============================================================================================================================
'Description		: To close the Task
'History	  		: Name				Date			Version
'Created By		: Nagaraj			09/10/2014 		  v1.0
'Example			: fn_SI_WorkFlowSearchOrder(dSearchID)
'============================================================================================================================
Public Function fn_SI_WorkFlowSearchOrder(ByVal dSearchID)
	On Error Resume Next
	Dim blnExist
	Call writeLogFile( "===== Function Call :::: fn_SI_WorkFlowSearchOrder =====")
	Reporter.ReportNote "Function Execution - [[fn_SI_WorkFlowSearchOrder]]"
	For intCounter = 1 to 5
		blnExist = Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Exist(60)
		If blnExist Then
			Browser("brwSIMain").Page("pgSIMain").Sync
			Exit For
		End If
	Next

	For intCounter = 1 to 10
		blnExist = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebButton("btnGo").Exist(30)
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 to 3
		objPage.WebEdit("txtSearchID").Click
		If intCounter = 1 Then
				blnResult = enterText("txtSearchID", dSearchID)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
				blnResult = clickButton("btnGo")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
				If Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Exist(0) Then Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Click
				Wait 5
				
				If objPage.WebEdit("txtSearchID").Exist(0) Then
					objPage.WebEdit("txtSearchID").Set dSearchID
				Else
					Call ReportLog("Order Search", "Search Order ID textbox should exist", "Search Order ID text box doesn't exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
				
				If objPage.WebButton("btnGo").Exist(0) Then
					objPage.WebButton("btnGo").Click
				Else
					Call ReportLog("Order Search", "Go button should exist", "Go Button doesn't exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
		End If '#intCounter

		Wait 5

		objPage.Sync
			
		For intInnerCounter = 1 to 3
			If objPage.WebElement("elmOrderExistMsg").Exist(2) Then
				If objPage.WebButton("btnClose").Exist(5) Then
					objPage.WebButton("btnClose").Click
					blnFound = False
				End If
			ElseIf objPage.WebElement("elmInvalidTTID").Exist(2) Then
				blnFound = False
			Else
				Browser("brwSIWorkflow").RefreshObject
				Browser("brwSIWorkflow").Page("pgSIWorkflow").RefreshObject
				If Browser("brwSIWorkflow").Page("pgSIWorkflow").WebButton("btnAction").Exist(5) Then
					blnFound = True
					Exit For
				End If
			End If
		Next

		If blnFound Then	Exit For
	Next

	If blnFound Then
		Call ReportLog("Order Search on SI+", "Order Search should be Successfull", "Order Search was successfull", "PASS", False)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Order Search on SI+", "Order Search should be Successfull", "Order Search was unsuccessfull", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 25
		blnExist = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebButton("btnAction").Exist(30)
		If blnExist Then
			Exit For
		End If
	Next

	Environment("Action_Result") = True
End Function
