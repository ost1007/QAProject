'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_SelectandScheduletestsrequired
' Purpose	 	 : Function to  complete Select & Schedule tests required
' Author	 	 : Biswabharati Sahoo
' Creation Date  	 : 19/12/2013
' Parameters	 :                                  					      
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_SelectandScheduletestsrequired(dSELECT_SCHEDULE_TESTS_REQUIRED)
	On Error Resume Next
		'Declaration of variables
		Dim strServicetestrequired, strOnsiteCPETestRequired
		Dim strDelayedFullServiceTestrequired, strAccessAlarmTestRequired, strFullserviceCPEtestRequired, strCustomerActivationSupportRequired
		Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
		Dim strcurrentdate1, strmonth1, strcurrentmonth1, strdate1, stryear1

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
				
		strcurrentdate1 =  Date + 1
		strmonth1 = Split(strcurrentdate1,"/")
		strcurrentmonth1 = strmonth1(1)
		If strcurrentmonth1 = "06" OR strcurrentmonth1 = "07" Then
			strmonth1 =  MonthName(strcurrentmonth1, False)
		ElseIf strcurrentmonth1 = "09" Then
			strmonth1 =  Left(MonthName(strcurrentmonth1, False), 4)
		Else
			strmonth1 =  MonthName(strcurrentmonth1, True)
		End If
		strdate1 = Day(strcurrentdate1)
		stryear1 = Year(strcurrentdate1)
		
		'Assigning values to an array
		Dim arrSELECT_SCHEDULE_TESTS_REQUIRED,arrValues
		arrSELECT_SCHEDULE_TESTS_REQUIRED = Split(dSELECT_SCHEDULE_TESTS_REQUIRED,",")
		intUBound = UBound(arrSELECT_SCHEDULE_TESTS_REQUIRED)
		ReDim arrValues(intUBound,1)

		For intCounter = 0 to intUBound
			arrValues(intCounter,0) = Split(arrSELECT_SCHEDULE_TESTS_REQUIRED(intCounter),":")(0)
			arrValues(intCounter,1) = Split(arrSELECT_SCHEDULE_TESTS_REQUIRED(intCounter),":")(1)
		Next	
		
		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		
		'Select the date 
		' select the value For Alarm Test Required
		If objFrame.WebList("lstAccAlarmTest").Exist(20) Then
			For i = 1 to 5
				objFrame.WebList("lstAccAlarmTest").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstAccAlarmTest").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then Exit For
			Next
		
			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "AccessAlarmTest" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next
				
			blnResult = selectValueFromList("lstAccAlarmTest",strData)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If

		If strData = "YES" Then
			'Enter date and Time if Access AlarmTest is required
			blnResult =  clickFrameImage("imgCalendarAccessAlarmTest")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			'Clicking on todays date
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
			
			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False" Then
				Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
		End If

		'Select The Value For Customer Support
		If objFrame.WebList("lstCustomerActivationSupportRequired").Exist(20) Then	
			For i = 1 to 5
				objFrame.WebList("lstCustomerActivationSupportRequired").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstCustomerActivationSupportRequired").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then Exit For
			Next
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "CustomerActivationSupportRequired" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next
			
			blnSelect = False
			For intCounter = 1 To 5
				blnResult = selectValueFromList("lstCustomerActivationSupportRequired",strData)		'strCustomerActivationSupportRequired)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				
				If objFrame.WebList("lstCustomerActivationSupportRequired").GetROProperty("selection") = strData Then
					blnSelect = True
					Exit For
				Else
					objFrame.WebList("lstCustomerActivationSupportRequired").Click
					Wait 5
				End If	
			Next '#intCounter
			
			If Not blnSelect Then
				Call ReportLog("lstCustomerActivationSupportRequired", strData & " should be Selected", "Unable to Select the Value", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		End if

		If strData = "YES" Then
			'Enter date and Time if Customer Activation Supportis required
			blnResult =  clickFrameImage("imgCalendarCustomerActSupport")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
			'Clicking on todays date
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
		
			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
				Call ReportLog("CustomerActivationSupportRequired","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("CustomerActivationSupportRequired","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
		End If

		' Select  value For Delay Full Service  Cpe Test Required
		If objFrame.WebList("lstDelayedFullServiceTestrequired").Exist(20) Then	
			For i = 1 to 5
				objFrame.WebList("lstDelayedFullServiceTestrequired").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstDelayedFullServiceTestrequired").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then Exit For
			Next
			objPage.Sync
			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "DelayedFullServiceTestrequired" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next

			blnResult = selectValueFromList("lstDelayedFullServiceTestrequired",strData)		'strDelayedFullServiceTestrequired)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If
	''''''''''''''''''''''''''''''''''''''

		' Select  the  Value For Full Service Test  REquired From List
		If objFrame.WebList("lstFullServiceCPEtestRequired").Exist(20) Then	
			For i = 1 to 5
				objFrame.WebList("lstFullServiceCPEtestRequired").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstFullServiceCPEtestRequired").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then Exit For
			Next
			
			objPage.Sync

			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "FullserviceCPEtestRequired" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next

			blnResult = selectValueFromList("lstFullServiceCPEtestRequired",strData)		'strFullserviceCPEtestRequired)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If

		' Enter The Date For the Same.
		If strData = "YES" Then
			'Enter date and Time if Customer Activation Supportis required
			blnResult =  clickFrameImage("imgCalendarFullServiceCPETest")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function		
		
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
				Call ReportLog("FullServiceTestrequired","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("FullServiceTestrequired","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	

			'Enter KPI  installation date
			blnResult =  clickFrameImage("imgCalendarKPIinstallation")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
			'Clicking on todays date
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth1
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("YearSelector").Select CStr(stryear1)
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="& strdate1).Click
		
			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
				Call ReportLog("KPI Installation","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("KPI Installation","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
		End If

		'Select  ONsiteCPETest Required Value From The List
		If objFrame.WebList("lstOnsiteCPETestRequired").Exist(20) Then		
			For i = 1 to 5
				objFrame.WebList("lstOnsiteCPETestRequired").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstOnsiteCPETestRequired").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then Exit For
			Next
			objPage.Sync

			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "OnsiteCPETestRequired" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next

			blnResult = selectValueFromList("lstOnsiteCPETestRequired",strData)		'strOnsiteCPETestRequired)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End If

		If strData = "YES" Then
			'Enter date and Time if Customer Activation Supportis required
			blnResult =  clickFrameImage("imgCalendarOnsiteCPETest")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			'Clicking on todays date		
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
				Call ReportLog("OnsiteCPETestRequired","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("OnsiteCPETestRequired","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
		End If

		'----------------------------------------------------------

		'Select Service Test Required Value From The List
		If objFrame.WebList("lstServiceTestRequired").Exist(20) Then
			For i = 1 to 5
				objFrame.WebList("lstServiceTestRequired").Click
				objPage.Sync
				Wait 2
				strListValues = objFrame.WebList("lstServiceTestRequired").GetROProperty("all items")
				arrListValues = Split(strListValues,";")
				If UBound(arrListValues) >= 1 Then
					Exit For
				End If
			Next
			objPage.Sync

			Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstServiceTestRequired").Click
			Wait 2
			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "Servicetestrequired" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next
			
			blnResult = selectValueFromList("lstServiceTestRequired",strData)		'strServiceTestRequired)
			blnResult = False
			For intCounter = 1 to 10
				If objFrame.WebList("lstServiceTestRequired").GetROProperty("selection") <> strData Then
					objFrame.WebList("lstServiceTestRequired").Select strData
					Wait 5
				Else
					blnResult = True
				End If
			Next

			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
		End if

		If strData = "YES" Then
			'Enter date and Time if Service Test  is required
			blnResult =  clickFrameImage("imgCalendarServiceTest")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
			'Clicking on todays date
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
		
			'Checking whether the calendar got closed or not
			If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
				Call ReportLog("ServiceTestRequired","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("ServiceTestRequired","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
	
		End If
	On Error Goto 0

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
