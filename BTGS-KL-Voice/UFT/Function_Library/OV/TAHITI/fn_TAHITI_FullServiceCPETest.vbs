'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_FullServiceCPETest
'
' Purpose	 	 : Function to enter particulars for Full Service CPE Test
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_FullServiceCPETest(dFULL_SERVICE_CPE_TEST)

	'Assigning values to an array
	Dim arrFULL_SERVICE_CPE_TEST,arrValues
	arrFULL_SERVICE_CPE_TEST = Split(dFULL_SERVICE_CPE_TEST,",")
	intUBound = UBound(arrFULL_SERVICE_CPE_TEST)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrFULL_SERVICE_CPE_TEST(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrFULL_SERVICE_CPE_TEST(intCounter),":")(1)
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		
		Exit Function
	End If
	
	'Full Service CPE Test  Executed
	If objFrame.WebList("lstFullServiceCPETestExecuted").Exist(10) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstFullServiceCPETestExecuted").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstFullServiceCPETestExecuted").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
		

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "FullServiceCPETestExecuted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = selectValueFromList("lstFullServiceCPETestExecuted",strData)			'strFullServiceCPETestExecuted)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

	End If
	
	If objFrame.WebList("lstFullServiceCPETestResult").Exist(10) Then
		'Full Service CPE Test Result
		wait 3

		For i = 1 to 5
			objFrame.WebList("lstFullServiceCPETestResult").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstFullServiceCPETestResult").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "FullServiceCPETestResult" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = selectValueFromList("lstFullServiceCPETestResult",strData)			'strFullServiceCPETestResult)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

		'Execution Full Service CPETest Date
		blnResult =  clickFrameImage("imgCalendarFullServiceCPETest")
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	
		'Clicking on todays date
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
	
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	End If
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
