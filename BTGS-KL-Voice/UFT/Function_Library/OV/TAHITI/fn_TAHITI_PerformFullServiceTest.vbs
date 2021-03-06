'=============================================================================================================
'Description: Function to Perform Full Service Test
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			31/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PerformFullServiceTest PerformFullServiceTest
'=============================================================================================================
Public function fn_TAHITI_PerformFullServiceTest(ByVal PerformFullServiceTest)
		'Variable Declaration
		Dim oDictPerformFullServiceTest
		Dim arrPerformFullServiceTest
		Dim strPerformFullServiceTest
		Dim arrPerformFullServiceTestVal
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
	
		Set oDictPerformFullServiceTest = CreateObject("Scripting.Dictionary")
	
		arrPerformFullServiceTest = Split(PerformFullServiceTest, ",")
		For Each strPerformFullServiceTest In arrPerformFullServiceTest
				arrPerformFullServiceTestVal = Split(Trim(strPerformFullServiceTest), ":")
				oDictPerformFullServiceTest(Trim(arrPerformFullServiceTestVal(0))) = Trim(arrPerformFullServiceTestVal(1))
		Next

		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

		'Update all the Access Alarm Check Attributes
		Set objTblAccessAlarmTest = objFrame.WebTable("xpath:=//TABLE[@id='grpFull Service/CPE Test']")
		With objTblAccessAlarmTest
	
				strCellValue = "Full service/CPE test Executed: (*)"
				strSelectValue = oDictPerformFullServiceTest("ServiceTestExecuted")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If

				If UCase(oDictPerformFullServiceTest("ServiceTestExecuted")) = "YES" Then
						strCellValue = "Full service/CPE test Result:"
						strSelectValue = oDictPerformFullServiceTest("ServiceTestResult")
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
						blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
							If Not blnResult Then 
								Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							Else
								Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
							End If

						Wait 5

						strCellValue = "Execution Full service/CPE test Date:"
						iRow = .GetRowWithCellText(strCellValue)
						.ChildItem(iRow, 2, "Image", 0).Click
						Wait 2
		
						Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
						Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
						Wait 2
				End If
		End With

		Environment("Action_Result") = True

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
