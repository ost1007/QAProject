Public function fn_TAHITI_CustomerActivationSupport()

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Fill Attrinutes of Service Test
	Set objTblCustActivationSupport = objFrame.WebTable("html id:=grpCustomer Activation Support", "index:=0")
	If objTblCustActivationSupport.Exist(10) Then
		With objTblCustActivationSupport
				strCellValue = "Customer Activation Support Executed: (*)"
				iRow = .GetRowWithCellText(strCellValue)
				If iRow >= 1 Then '#1
					strSelectValue = "YES"
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
				End If '#1
				
				strCellValue = "Customer Activation Support Result:"
				iRow = .GetRowWithCellText(strCellValue)
				If iRow >= 1 Then '#1
					strSelectValue = "Passed"
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
				End If '#1
				
				strCellValue = "Customer Activation Support Execution Date:"
				iRow = .GetRowWithCellText(strCellValue)
				If iRow >= 1 Then '#1
					.ChildItem(iRow, 2, "Image", 0).Click
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
				End If '#1
		End With
	End If
End Function
