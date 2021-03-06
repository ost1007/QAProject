'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_NotifyCustomerServiceReady 
'
' Purpose	 	 : Function to wite customer service ready date
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 31/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_NotifyCustomerServiceReady(dDate, dHour, dMinute, dSecond)
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Execution Access Alarm Test Date
	blnResult =  clickFrameImage("imgCalendarAccessAlarmTest")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	strcurrentdate =  FormatDateTime(dDate, vbGeneralDate)
	strmonth = Split(strcurrentdate,"/")
	strcurrentmonth = strmonth(1)
	If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
		strmonth =  MonthName(strcurrentmonth, False)
	ElseIf strcurrentmonth = "09" Then
		strmonth =  Left(MonthName(strcurrentmonth, False), 4)
	Else
		strmonth =  MonthName(strcurrentmonth, True)
	End If
	strdate = Day(strcurrentdate)
	stryear = Year(strcurrentdate)

	Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
	Browser("brwDateTimePicker").Page("pgDateTimePicker").WebEdit("name:=hour", "index:=0").Set dHour
	Browser("brwDateTimePicker").Page("pgDateTimePicker").WebEdit("name:=minute", "index:=0").Set dMinute
	Browser("brwDateTimePicker").Page("pgDateTimePicker").WebEdit("name:=second", "index:=0").Set dSecond
	Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

	'Checking whether the calendar got closed or not
	If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
		Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
	Else
		Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
	End If	
	

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
