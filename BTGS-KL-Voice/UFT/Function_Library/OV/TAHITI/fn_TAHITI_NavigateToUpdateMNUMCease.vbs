'=============================================================================================================
'Description: Function to Select Update MNUM(Cease) Task and provide next function to Navigate and download the file
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			08/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_NavigateToUpdateMNUMCease
'=============================================================================================================
Public Function fn_TAHITI_NavigateToUpdateMNUMCease()

	'Variable Declaration
	Dim strTaskName, strRetrivedText, strTaskID
	Dim arrResultMessage
	Dim NoOfTasksUpdated
	Dim iNext, intNext, intRowsInPage, iRow
	Dim blnTaskFound 
	Dim strSelectTaskName : strSelectTaskName = "Update MNUM(Cease)"
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
	Wait 2 : objPage.Sync

    objFrame.WebElement("webElmNoOfTasks").RefreshObject
	strRetrivedText = objFrame.WebElement("webElmNoOfTasks").GetROProperty("innerhtml")
	arrResultMessage = SPlit(strRetrivedText," ")
	NoOfTasksUpdated = arrResultMessage(0)	

	Call fn_TAHITI_SortRecords

	'To get number of Next buttons to be clicked on page
	intNext = Ceil(NoOfTasksUpdated/10)

	blnTaskFound = False
	For iNext = 1 To intNext
			'To see if already generated tasks are there which are not closed
			intRowsInPage = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
			blnFlag = False
			For iRow = 4 to intRowsInPage
					strTaskName = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 3)
					If strTaskName = strSelectTaskName Then
							strTaskID = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 2)
							objFrame.WebRadioGroup("IdNumber").Select strTaskID
							blnTaskFound = True
							Exit For '#iRow
					End If
			Next

			If Not blnTaskFound Then
					If intNext > iNext Then
							blnResult = clickFrameImage("imgNext")
								If Not BlnResult Then Environment("Action_Result") = False : Exit Function
							Wait 10
					End If
			Else
					Exit For '#iNext
			End If
	Next '#iNext

    'If Update MNUM(Cease) Task could not be located then terminate
	If Not blnTaskFound Then
		Call ReportLog(strSelectTaskName, strSelectTaskName & " task should be located", "Task could not be located", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

End Function
