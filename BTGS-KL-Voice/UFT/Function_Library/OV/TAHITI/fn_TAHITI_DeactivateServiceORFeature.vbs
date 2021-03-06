'=============================================================================================================
'Description: Function to Deactivate Service or Feature
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			12/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_DeactivateServiceORFeature
'=============================================================================================================
Public Function fn_TAHITI_DeactivateServiceORFeature()

		'Variable Declaration
		Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
	
		'Variable Assignment
		strcurrentdate =  Date
		strmonth = Split(strcurrentdate,"/")
		strcurrentmonth = strmonth(1)
		If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
			strmonth =  MonthName(strcurrentmonth, False)
		Else
			strmonth =  MonthName(strcurrentmonth, True)
		End If
		strdate = Day(Now)
		stryear = Year(Now)

		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
			blnResult = clickFrameButton("btnUpdaterPACS")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
			Wait 20
	
			strInnerText = objPage.Frame("frmContent").Object.documentElement.innertext
			If Instr(strInnerText, "Request has been send successfully to rPACS") > 0 Then
				Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has been send successfully to rPACS", "PASS", True)
			Else
				Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has not been send successfully to rPACS", "FAIL", True)
				Environment("Action_Result") = False : Exit FUnction
			End If
	
			Message = "Successful Response Received from rPACS for Deactivate Service / Feature"
			blnVerification = False
			For intCounter = 1 To 10
				strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
				strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
				If Instr(strText, Message) > 0 Then
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
					blnVerification = True
					Exit For
				Else
					Wait 30
					objPage.Link("name:=All", "index:=0").Click
					Wait 5
				End If
			Next
		
			If Not blnVerification Then
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message doesnt exist</BR>" & strInnerHTML, "FAIL", True)
					Environment("Action_Result") = False : Exit Function
			Else
					If objFrame.WebTable("xpath:=//TABLE[@id='grpOrder Management']", "index:=0").Exist Then
							objFrame.Image("xpath:=//TABLE[@id='grpOrder Management']//Image[1]").Click
							Wait 2
							Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
							Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
							Wait 2
					Else
							Call ReportLog("Hard Cease Date", "Hard Cease Date Parent Table should exist", "Hard Cease Date Parent Table doesn't exist", "FAIL", True)
							Environment("Action_Result")  = False : Exit Function
					End If
			End If
		End If
End Function
