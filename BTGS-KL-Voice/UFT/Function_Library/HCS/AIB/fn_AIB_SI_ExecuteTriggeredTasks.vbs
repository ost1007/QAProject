'===================================================================================================================================================================
' Description	: Function to check for completion of auto tasks and Trigger the execution tasks in SI
' History	  	  :		Name				Date			Changes Implemented
' Created By	:  Nagaraj			03/07/2015 			NA
' Example		: fn_AIB_SI_ExecuteTriggeredTasks(dictTasks, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, ByRef dCompletedTasks)
'===================================================================================================================================================================
Public Function fn_AIB_SI_ExecuteTriggeredTasks(dictTasks, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, ByRef dCompletedTasks, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)

		'Variable Declaration
		Dim arrTasks
		Dim strServer, strTaskName
		Dim intRow
		
		arrTasks = dictTasks.Keys
		
		'To Load the Function Libs associated with SI
		Call fLoadFunctionLib("SI")

		For Each TaskID In arrTasks
				'intRow = Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber").GetRowWithCellText(TaskID, 1)
				intRow = fn_AIB_GetRow(Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber"), TaskID)
				strTaskName = Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber").GetCellData(intRow, 2)
				strServer = UCase(Browser("brwAIB").Page("pgAIB").WebTable("tblFulfilmentOrderNumber").GetCellData(intRow, 3))
			
				If Instr(strServer, "SI-MANAGEWORKITEM") > 0 Then
						'Search the Task and assign to the user who is logged in
						Call fn_SI_SearchTaskAndAssign(TaskID)
							If Not Environment("Action_Result") Then Exit Function
						'Search in My tasks and close the task
						Call fn_SI_SearchMyTask_Close(TaskID, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)
							If Not Environment("Action_Result") Then Exit Function
						'Check whether the task is completed in AIB or not after the task is closed in SI
						blnAchieved = fn_AIB_CheckCompletionStatusByID(TaskID, "Complete")
							If Not blnAchieved Then Exit Function
							
				ElseIf Instr(strServer, "SI-MWI-FALSE") > 0 Then
						Call fn_SI_SearchTaskAndAssign(TaskID)
						If Environment("Action_Result") Then
							'Search in My tasks and close the task
							Call fn_SI_SearchMyTask_Close(TaskID, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)
								If Not Environment("Action_Result") Then Exit Function
						End If
						'Check whether the task is completed in AIB or not after the task is closed in SI
						blnAchieved = fn_AIB_CheckCompletionStatusByID(TaskID, "Complete")
							If Not blnAchieved Then Exit Function
				Else
						'Check only for Completion as the tasks are auto Completed
						blnAchieved = fn_AIB_CheckCompletionStatusByID(TaskID, "Complete")
						If Instr(strServer, "PACS") > 0 And Not blnAchieved Then 'Trigger the mail if the rPACS task is not closed in PACSapplication
							Call ReportLog("Manual Intervention", "Manual Intervention Required for Task", "Manual Intervention Required for Task ID <B>" & TaskID & "</B>", "FAIL", False)
							Call fCreateAndSendMail(Environment("ToList"), Environment("CcList"), Environment("BCcList"), "Manual Intervention Required for " & TaskID & " - " & strTaskName,_
								 "Please close the task <B>" & strTaskName &  " </B>manually in rPACS and re-run the script", "")
						End If
						If Not blnAchieved Then 
							Exit Function
						End If
				End If

				Rem If Task has achieved the Completed Status then add the tasks to Completed Tasks and make an 
				Rem entry in the Excel Sheet for reference so that tasks are not checked again for its completion
				If blnAchieved Then
					dCompletedTasks = dCompletedTasks & "|" & TaskID
					Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dCompletedTasks", dCompletedTasks)
					Environment("Action_Result") = True
				End If
		Next
End Function

'========================================================================================================================================================
' Description: Search the Table and get the Row of the Task ID
'========================================================================================================================================================
Private Function fn_AIB_GetRow(ByVal objTable, ByVal TaskID)
	Dim intRows, iRow
	intRows = objTable.RowCount
	For iRow = 1 to intRows
		If Trim(objTable.GetCellData(iRow, 1)) = Trim(TaskID) Then
			fn_AIB_GetRow = iRow
			Exit For
		End If
	Next
End Function
