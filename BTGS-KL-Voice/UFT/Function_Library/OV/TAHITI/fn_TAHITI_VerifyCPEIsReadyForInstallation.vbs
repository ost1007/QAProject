'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_VerifyCPEIsReadyForInstallation
' Purpose	 	 : Function to Fill the Required Dates
' History		:			Name			Date			Changes Implemented
' Author	 	 : 		Nagaraj V 		24/08/2015			NA
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_VerifyCPEIsReadyForInstallation()

	'Variable Declaration
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear, strRetrievedText
	Dim objPlannedInstallationDate, objDeliverytoSiteDate
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	strcurrentdate =  ( Date + 1 )
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

	Set objPlannedInstallationDate = objFrame.WebEdit("xpath:=//TR[normalize-space()='Planned Installation Date: (*)']/TD[2]/INPUT[1]", "index:=0")
	Set objDeliverytoSiteDate = objFrame.WebEdit("xpath:=//TR[normalize-space()='Delivered to Site Date: (*)']/TD[2]/INPUT[1]", "index:=0")

	'Enter Planned Installation Date
	If objPlannedInstallationDate.Exist(5) Then
		strRetrievedText = Trim(objPlannedInstallationDate.GetROProperty("value"))
		If strRetrievedText <> "" Then
			Call ReportLog("Planned Installation Date", "Planned Installation Date should be populated", "Planned Installation Date is populated with:= " & strRetrievedText, "Information", False)
		Else
			objFrame.Image("xpath:=//TR[normalize-space()='Planned Installation Date: (*)']/TD[2]//IMG[1]").Click : Wait 2
			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
			strRetrievedText = Trim(objPlannedInstallationDate.GetROProperty("value"))
			Call ReportLog("Planned Installation Date", "Planned Installation Date should be populated", "Planned Installation Date is populated with:= " & strRetrievedText, "Information", False)
		End If
	End If

	'Enter Delivered to Site Date
	If objDeliverytoSiteDate.Exist(5) Then
		objFrame.Image("xpath:=//TR[normalize-space()='Delivered to Site Date: (*)']/TD[2]//IMG[1]").Click : Wait 2
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
		strRetrievedText = Trim(objDeliverytoSiteDate.GetROProperty("value"))
		Call ReportLog("Delivered to Site Date", "Delivered to Site Date should be populated", "Delivered to Site Date is populated with:= " & strRetrievedText, "Information", False)
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************