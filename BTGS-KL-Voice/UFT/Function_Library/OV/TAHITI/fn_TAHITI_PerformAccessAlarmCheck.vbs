'=============================================================================================================
'Description: Function to Perform Access Alarm Check
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			31/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PerformAccessAlarmCheck dPerformAccessAlarmCheck
'=============================================================================================================
Public function fn_TAHITI_PerformAccessAlarmCheck(ByVal PerformAccessAlarmCheck)
		'Variable Declaration
		Dim oDictPerformAccessAlarmCheck
		Dim arrPerformAccessAlarmCheck
		Dim strPerformAccessAlarmCheck
		Dim arrPerformAccessAlarmChk
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
	
		Set oDictPerformAccessAlarmCheck = CreateObject("Scripting.Dictionary")
	
		arrPerformAccessAlarmCheck = Split(PerformAccessAlarmCheck, ",")
		For Each strPerformAccessAlarmCheck In arrPerformAccessAlarmCheck
				arrPerformAccessAlarmChk = Split(Trim(strPerformAccessAlarmCheck), ":")
				oDictPerformAccessAlarmCheck(Trim(arrPerformAccessAlarmChk(0))) = Trim(arrPerformAccessAlarmChk(1))
		Next

		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

		'Update all the Access Alarm Check Attributes
		Set objTblAccessAlarmTest = objFrame.WebTable("xpath:=//TABLE[@id='grpAccess Alarm Test']")
		With objTblAccessAlarmTest
	
				strCellValue = "Access Alarm Test Executed: (*)"
				strSelectValue = oDictPerformAccessAlarmCheck("AccessAlarmTestExecuted")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If

				If UCase(oDictPerformAccessAlarmCheck("AccessAlarmTestExecuted")) = "YES" Then
					strCellValue = "Access Alarm Test Result:"
					strSelectValue = oDictPerformAccessAlarmCheck("AccessAlarmTestResult")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If

					strCellValue = "Execution Access Alarm Test Date:"
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "Image", 0)
					objChildItem.Click
					Wait 2
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
				End If
		End With                 

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
