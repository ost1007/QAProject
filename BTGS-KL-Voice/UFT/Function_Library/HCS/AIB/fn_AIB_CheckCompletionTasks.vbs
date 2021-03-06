'===================================================================================================================================================================
' Description	: Function to chech the atsks that are completed in AIB except the task ID mentioned in CompletedTasks
' History	  	  :		Name				Date			Changes Implemented
' Created By	:  Nagaraj			03/07/2015 			NA
' Example		: fn_AIB_CheckCompletionTasks(ByRef CompletedTasks)
'===================================================================================================================================================================
Public Function fn_AIB_CheckCompletionTasks(ByRef CompletedTasks)
		'Constant Column Names
		Const TASKID = 1
		Const TASKNAME = 2
		Const SERVER = 3
		Const STATUS = 4
		Const SUBSTATUS = 5
		Const DEPENDENCY = 6
	
		Dim objTasksTable
		Dim intRows
		Dim strDependency, strStatus, strSubStatus, strTaskName
		Dim blnChange
		Dim arrTasks
	
		blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
		Set dictTasks = CreateObject("Scripting.Dictionary")
		Set objTasksTable = Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber")

		blnChange = False
		With objTasksTable
				.RefreshObject
				intRows = .RowCount
				For iRow = 1 To intRows
						strStatus = UCase(.GetCellData(iRow, STATUS))
						strSubStatus = UCase(Replace(.GetCellData(iRow, SUBSTATUS), " ", ""))
						strTaskName = UCase(.GetCellData(iRow, TASKNAME))
						If strStatus = "COMPLETE" And strSubStatus = "ALLLINEITEMSCOMPLETE" And ( strTaskName = "REQUEST MIS ACCESS" OR strTaskName = "REMOVE MIS ACCESS" )Then
								strTaskID = Trim(.GetCellData(iRow, TASKID))
								If getCountOfRegExpPattern(strTaskID & "\|", CompletedTasks, False, strMatchVal) <=0 Then
									If getCountOfRegExpPattern("\|" & strTaskID, CompletedTasks, False, strMatchVal) <=0 Then
										blnChange = True	
									End If
								End If
						ElseIf strStatus = "COMPLETE" And strSubStatus = "ALLLINEITEMSCOMPLETE" Then
								strTaskID = Trim(.GetCellData(iRow, TASKID))
								If getCountOfRegExpPattern(strTaskID & "\|", CompletedTasks, False, strMatchVal) <= 0 Then
										strTaskName = .GetCellData(iRow, TASKNAME)
										'.ChildItem(iRow, 1, "WebElement", 0).HighLight : Wait 2
										Call ReportLog("Task Completion", "Task Completion Check", "<B>" & strTaskID & "-" & strTaskName & "</B> task is in <B>" & strStatus & "</B> state", "PASS", False)
										CompletedTasks = CompletedTasks & "|" & strTaskID
										blnChange = True
								End If
						End If
				Next 'iRow
		End With

		If blnChange Then
			Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dCompletedTasks", CompletedTasks)
		End If

		fn_AIB_CheckCompletionTasks = blnChange
End Function
