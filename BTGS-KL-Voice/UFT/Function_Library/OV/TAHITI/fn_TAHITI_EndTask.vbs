'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_EndTask
'
' Purpose	 	 : Function to close a task
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_EndTask()

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on End task
	blnResult = clickFrameButton("btnEndTask")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	
	strTaskName = objPage.Frame("frmContent").WebElement("elmTaskDetails").GetROProperty("innertext")
	If Instr(strTaskName, "Plan & Assign in-country Network Resource (Provide)") > 0  OR Instr(strTaskName, "Confirm Access Delivery Date & reference number (Provide)") > 0 OR _
		Instr(strTaskName, "Confirm Access installation (Provide)") > 0 Then
		If objFrame.WebElement("webElmThereIsNoNTEConfiguration").Exist(60) Then
			objFrame.Link("lnkYes").Click
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If
	ElseIf  Instr(strTaskName, "Prepare & build CPE base config (Provide)") > 0  Then
		If objFrame.WebElement("webElmPleaseNoteThatAuto-update").Exist(60) Then
			objFrame.Link("lnkYes").Click
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If		
	End If
	
	'Click on Task In service link
	blnResult = Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmThahitiFrame").Link("lnkTasksInService").Click

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Check if navigated to Task List page
	Set objMsg = objpage.Frame("frmMyTasks").WebElement("webElmAllTasksForService")
	objMsg.WaitProperty "visible","True",100000
	If objMsg.Exist = False Then
		Call ReportLog("AllTasksForService","Should be navigated to Tasks for Service page list on clicking TasksInService link","Not navigated to Tasks for Service page list on clicking Tasks in service link","FAIL","TRUE")
	Else
		strMessage = objpage.Frame("frmMyTasks").WebElement("webElmAllTasksForService").GetRoProperty("innertext")
		Call ReportLog("AllTasksForService","Should be navigated to Tasks for Service page list on clicking TasksInService link","Navigated to the page - "&strMessage,"PASS","")
	End If
	
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

