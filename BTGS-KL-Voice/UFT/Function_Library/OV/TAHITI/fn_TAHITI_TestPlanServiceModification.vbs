'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_PerformAccessAlarmCheck
'
' Purpose	 	 : Function to hand over the task to maintenance
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_TestPlanServiceModification(dPlanServiceModification)

	'Assigning values to an array
	Dim arrPerformAccessAlarmCheck,arrValues
	arrPerformAccessAlarmCheck = Split(dPerformAccessAlarmCheck,",")
	intUBound = UBound(arrPerformAccessAlarmCheck)
	ReDim arrValues(intUBound,1)

	arrPerformAccessAlarmCheck = Split(dPerformAccessAlarmCheck,",")
	intUBound = UBound(arrPerformAccessAlarmCheck)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrPerformAccessAlarmCheck(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrPerformAccessAlarmCheck(intCounter),":")(1)
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		
		Exit Function
	End If

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	If objFrame.WebList("lstAccessAlarmTestExecuted").Exist(10) Then

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessAlarmTestExecuted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		'Access AlarmTest  Executed
		blnResult = selectValueFromList("lstAccessAlarmTestExecuted",strData)		'strAccessAlarmTestExecuted)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	End If
    
	If objFrame.WebList("lstAccessAlarmTestResult").Exist(10) Then

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessAlarmTestResult" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		'Access Alarm Test Result
		blnResult = selectValueFromList("lstAccessAlarmTestResult",strData)		'strAccessAlarmTestResult)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

		'Execution Access Alarm Test Date
		blnResult =  clickFrameImage("imgCalendarAccessAlarmTest")
			If blnResult= False Then
				Environment.Value("Action_Result")=False 
				
				Exit Function
			End If
		
		'Clicking on todays date
		Browser("brwCalendar").Page("pgCalendar").Link("lnkTodaysDate").Click
	
		'Checking whether the calendar got closed or not
		If Browser("brwCalendar").Page("pgCalendar").Exist = "False"Then
			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

