'===================================================================================================================================================================
' Description	: Function to check the Tasks which are Free To Execute in AIB and add it to dictionary to be used by calling function
' History	  	  :		Name				Date			Changes Implemented
' Created By	:  Nagaraj			03/07/2015 			NA
' Example		: fn_AIB_GetExecutablesTasks(dictTasks)
'===================================================================================================================================================================
Public Function fn_AIB_GetExecutablesTasks(ByRef dictTasks, ByVal dCompletedTasks)

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
	
		blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
		Set dictTasks = CreateObject("Scripting.Dictionary")
		Set objTasksTable = Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber")
	
		With objTasksTable
				.RefreshObject
				intRows = .RowCount
				For iRow = 1 To intRows
						strDependency = UCase(.GetCellData(iRow, DEPENDENCY))
						If strDependency = "FREE TO EXECUTE" Then
								strStatus = UCase(.GetCellData(iRow, STATUS))
								strSubStatus = UCase(Replace(.GetCellData(iRow, SUBSTATUS), " ", ""))
								strTaskName = UCase(.GetCellData(iRow, TASKNAME))
								If ( strTaskName = "REQUEST MIS ACCESS" OR strTaskName = "REMOVE MIS ACCESS" )And strStatus = "COMPLETE" Then
										strTaskID = .GetCellData(iRow, TASKID)
										If Instr(dCompletedTasks, Trim(strTaskID) & "|") <= 0 Then
											dictTasks.Add strTaskID, strTaskID
										End If
								ElseIf strStatus = "OPEN" And strSubStatus = "INPROGRESS" Then
										strTaskID = .GetCellData(iRow, TASKID)
										dictTasks.Add strTaskID, strTaskID
								End If
						End If
				Next
		End With
	
		If dictTasks.Count = 0 Then
			fn_AIB_GetExecutablesTasks = False
		Else
			fn_AIB_GetExecutablesTasks = True
		End If
End Function
