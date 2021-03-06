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
Public function fn_TAHITI_PerformAccessAlarmCheckchange(dPerformAccessAlarmCheck)
	'Variable Declaration
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
		
	'Variable Assignment
	strcurrentdate =  Date
	strmonth = Split(strcurrentdate,"/")
	strcurrentmonth = strmonth(1)
	If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
		strmonth =  MonthName(strcurrentmonth, False)
	ElseIf strcurrentmonth = "09" Then
		strmonth =  Left(MonthName(strcurrentmonth, False), 4)
	Else
		strmonth =  MonthName(strcurrentmonth, True)
	End If
	strdate = Day(Now)
	stryear = Year(Now)

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

	If objFrame.WebList("lstAccAlarmTest").Exist(10) Then

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessAlarmTestExecuted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next


		'Access AlarmTest  Executed
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstAccAlarmTest").Click
		Wait 1
		blnResult = selectValueFromList("lstAccAlarmTest",strData)		'strAccessAlarmTestExecuted)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Exit Function
		End If
	End If
    
	If objFrame.WebList("lstAccessDeliveryType").Exist(10) Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessAlarmTestResult" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		'Access Alarm Test Result
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstAccessDeliveryType").Click
		Wait(1)
		blnResult = selectValueFromList("lstAccessDeliveryType",strData)		'strAccessAlarmTestResult)
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
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
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

