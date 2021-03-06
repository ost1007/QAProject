Public Function fn_TAHITI_CoordinateCutoverActivities()

	Dim objTableKPI, objScheduledInstallationDate
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear

    'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Set objTableKPI = objFrame.WebTable("xpath:=//TABLE[@id='grpKPI']")
	If objTableKPI.Exist Then
		iRow = objTableKPI.GetRowWithCellText("Scheduled Installation Date: ")
		If iRow >= 1 Then
			Set objScheduledInstallationDate = objTableKPI.ChildItem(iRow, 2, "WebEdit", 0)
			If objScheduledInstallationDate.GetROProperty("value") = "" Then
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
	
					objTableKPI.ChildItem(iRow, 2, "Image", 0).Click
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
			Else
					Call ReportLog("Scheduled Installation Date", "Scheduled Installation Date should be populated", "Scheduled Installation Date is populated with " & objScheduledInstallationDate.GetROProperty("value"), "INFORMATION", True)
			End If
		End If
	End If

	Environment("Action_Result") = True
    	
End Function
