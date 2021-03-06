'****************************************************************************************************************************
' Function Name	 :  fn_TAHITI_TaskNavigation
'
' Purpose	 	 :  To  search the task and yank the task
'
' Author	 	 : Biswabharati Sahoo
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : CurrentTask
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_TaskNavigation(CurrentTaskName)
	On Error Resume Next
		'Variable Declaration Section
		Dim objMsg
		Dim blnResult
	
		'Assign variables
		strCurrentTaskName  = CurrentTaskName
	
		'Building Reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If blnResult = False Then Environment.Value("Action_Result") = False : Exit Function
	
		strDisabled = objFrame.WebButton("btnYankTask").GetROProperty("disabled")
		If strDisabled = 0 Then
			'Click on Yank Task button
			blnResult = clickFrameButton("btnYankTask")
				If blnResult = False Then Environment.Value("Action_Result") = False : Exit Function
		Else
			'Click on Task Details button
			blnResult = clickFrameButton("btnTaskDetail")
				If blnResult = False Then Environment.Value("Action_Result") = False : Exit Function
		End If
		
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		If objPage.Frame("frmContent").WebElement("elmTaskDetails").WaitProperty("visible", True, 30000) Then
			strRetrivedText = objPage.Frame("frmContent").WebElement("elmTaskDetails").Object.innerText
			Call ReportLog("TaskDetails","Should be navigated to the task details page after clicking on Yank Task button","Navigated to the page - " & strRetrivedText,"PASS","")
			Environment("Action_Result") = True
		Else
			Call ReportLog("TaskDetails","Should be navigated to the task details page after clicking on Yank Task button","Not navigated to task details page after clicking on Yank Task button","FAIL", TRUE)
		End If
	On Error Goto 0	
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
