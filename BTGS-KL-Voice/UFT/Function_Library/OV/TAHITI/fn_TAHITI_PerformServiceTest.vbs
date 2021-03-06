'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_PerformServiceTest
'
' Purpose	 	 : Function to enter particulars for ServiceTest
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_PerformServiceTest(dPERFORM_SERVICE_TEST)

	'Assigning values to an array
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear, strPerformServiceTest
	Dim arrPerformServiceTestVal, arrPerformServiceTest
	Dim oDictAttributeValues
    
	Set oDictAttributeValues = CreateObject("Scripting.Dictionary")
	arrPerformServiceTest = Split(dPERFORM_SERVICE_TEST, ",")
	For Each strPerformServiceTest In arrPerformServiceTest
			arrPerformServiceTestVal = Split(Trim(strPerformServiceTest ), ":")
			oDictAttributeValues(Trim(arrPerformServiceTestVal (0))) = Trim(arrPerformServiceTestVal (1))
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If

	'Enter H323 Trunk ID
	If Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebEdit("txtH323TrunkID").Exist(10) Then
		If oDictAttributeValues.Exists("H323TrunkID") Then
			blnResult = enterFrameText("txtH323TrunkID", oDictAttributeValues("H323TrunkID"))			'strH323TrunkID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Test Data", "H323 Trunk ID Atrribute is to be filled but test data is not present in DataSheet", "Please add Test Data in DataSheet", "Warnings", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'Select Encryption Applied
	If Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstEncryptionApplied").Exist(10) Then
		If oDictAttributeValues.Exists("EncryptionApplied") Then
			objFrame.WebList("lstEncryptionApplied").Click
			Wait 5
			blnResult = selectValueFromList("lstEncryptionApplied",oDictAttributeValues.Item("EncryptionApplied"))
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Test Data", "EncryptionApplied Atrribute is to be filled but test data is not present in DataSheet", "Please add Test Data in DataSheet", "Warnings", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Fill Attrinutes of Service Test
	Set objTblServiceTest = objFrame.WebTable("html id:=grpService Test", "index:=0")
	If objTblServiceTest.Exist(10) Then
		With objTblServiceTest
				strCellValue = "Service test Executed: (*)"
				iRow = .GetRowWithCellText(strCellValue)
				If iRow >= 1 Then '#1
						If oDictAttributeValues.Exists("ServiceTestExecuted") Then '#2
							strSelectValue = oDictAttributeValues("ServiceTestExecuted")
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
								If Not blnResult Then 
									Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
								End If
						Else
								Call ReportLog(strCellValue, strCellValue & " value exists in application", "Test Data is not found for [ServiceTestExecuted]", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
						End If '#2
				End If '#1

				strCellValue = "Service test Result: (*)"
				iRow = .GetRowWithCellText(strCellValue)
				If iRow <= 0 Then
					iRow = .GetRowWithCellText("Service test Result:")
				End If
				If iRow >= 1 Then '#1
						If oDictAttributeValues.Exists("ServiceTestResult") Then '#2
							strSelectValue = oDictAttributeValues("ServiceTestResult")
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
								If Not blnResult Then 
									Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
								End If
						Else
								Call ReportLog(strCellValue, strCellValue & " value exists in application", "Test Data is not found for [ServiceTestResult]", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
						End If '#2
				End If '#1

				'Execution Full Service CPETest Date
				blnResult =  clickFrameImage("imgCalendarFullServiceCPETest")
					If Not blnResult Then  Environment.Value("Action_Result")=False : Exit Function
			
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
		End With
	End If

	 Environment.Value("Action_Result") = True
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************



    'Removed by Nagaraj as Objects are not recognized
	'	If objFrame.WebList("lstServiceTestResult").Exist(10) Then
	'		wait 3
	'		For i = 1 to 5
	'			objFrame.WebList("lstServiceTestResult").Click
	'			objPage.Sync
	'			strListValues = objFrame.WebList("lstServiceTestResult").GetROProperty("all items")
	'			arrListValues = Split(strListValues,";")
	'			If UBound(arrListValues) >= 1 Then
	'				Wait 5
	'				Exit For
	'			Else 
	'				Wait 3
	'			End If
	'		Next		
	'
	'		For intLoop = 0 to intUBound
	'			If arrValues(intLoop,0) = "ServiceTestResult" Then
	'				strData = arrValues(intLoop,1)
	'				Exit For
	'			End If
	'		Next
	'
	'		blnResult = selectValueFromList("lstServiceTestResult",strData)			'strServiceTestResult)
	'		If blnResult= False Then
	'			Environment.Value("Action_Result")=False 
	'			Exit Function
	'		End If
	'
	'		'Execution Full Service CPETest Date
	'		blnResult =  clickFrameImage("imgCalendarFullServiceCPETest")
	'		If blnResult= False Then
	'			Environment.Value("Action_Result")=False 
	'			Exit Function
	'		End If
	'	
	'		'Clicking on todays date
	'		strcurrentdate =  Date
	'		strmonth = Split(strcurrentdate,"/")
	'		strcurrentmonth = strmonth(1)
	'		If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
	'			strmonth =  MonthName(strcurrentmonth, False)
	'		Else
	'			strmonth =  MonthName(strcurrentmonth, True)
	'		End If
	'		strdate = Day(Now)
	'		stryear = Year(Now)
	'
	'		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
	'		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	'		
	'		'Checking whether the calendar got closed or not
	'		If Browser("brwCalendar").Page("pgCalendar").Exist(5) = "False"Then
	'			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
	'		Else
	'			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
	'		End If	
	'	End If	
