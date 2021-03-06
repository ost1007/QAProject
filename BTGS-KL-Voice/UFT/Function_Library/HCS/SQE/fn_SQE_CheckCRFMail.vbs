'****************************************************************************************************************************
' Description			  :		To validate an auto generated mail whether CRF Sheet upload was successful or not
' History				   : Name				Date			Changes Implemented
'			Created By   : Nagaraj V		25/06/2015			NA
'			Modified By  :
' Return Values	 	    : 			Not Applicable
' Example				 : fn_SQE_CheckCRFMail "Success", "Failure"
'****************************************************************************************************************************
Public Function fn_SQE_CheckCRFMail(ByVal ExpectedSuccessMessage, ByVal ExpectedFailureMessage)
	On Error Resume Next
		'Variable Declaration
		Dim objOutlook, objNameSpace, objFolder
		Dim intMailCount, intCheckMailCount
		Dim strSubject, strMailContent

		Set objOutlook = Eval("GetObject(,""Outlook.Application"")")
		If Err.Number = 429 Then
			Err.Clear
			Set objOutlook = CreateObject("Outlook.Application")
		End If

		Set objNameSpace = objOutlook.GetNameSpace("MAPI")
		Set objFolder = objNameSpace.GetDefaultFolder(6)

		intCheckMailCount = 0
		For intCounter = 1 To 5
				Set mailItems = objFolder.Items.Restrict("[Subject] = '" & ExpectedSuccessMessage &"' OR [Subject] = '" & ExpectedFailureMessage & "'")
				intMailCount = mailItems.Count
				If intMailCount >= 1 Then
						Set mailItem = mailItems.GetLast
						For index = intMailCount to 1 step -1
							If mailItem.ReceivedTime >= Date Then
								intCheckMailCount = intCheckMailCount + 1
							End If
						Next 'index
		
						'Even though mail items are terminate For condition iff it is received today
						If intCheckMailCount <> 0 Then
							Exit For
						Else
							Wait 60
						End If
				Else
						Wait 60
				End If
		Next 'intCounter

		intMailCount = mailItems.Count
		Set mailItem = mailItems.GetLast
		
		For index = intMailCount to 1 step -1
				If mailItem.ReceivedTime >= Date Then
					strSubject = mailItem.Subject
					strMailContent = mailItem.HTMLBody
						If Instr(strSubject, ExpectedSuccessMessage) > 0 Then '#1
								Call ReportLog("Capture Mail Content", "Mail Subject Should Contain <B>" & ExpectedSuccessMessage & "</B>", "Verification of Mail Subject Passed </BR>" & strMailContent , "PASS", False)
								Environment("Action_Result") = True
						ElseIf Instr(strSubject, ExpectedFailureMessage) > 0 Then
								Call ReportLog("Capture Mail Content", "Mail Content should contain <B>" & ExpectedFailureMessage & "</B>", "Subject Found to be <B>" & strSubject & "<b></br>"& strMailContent , "FAIL", False)
								Environment("Action_Result") = False
						End If '#1
				End If
				Set mailItem = mailItems.GetPrevious
		Next
		
		If intMailCount = 0 Then
			Call ReportLog("Bulk Upload", "Bulk upload success message or failure should be received", "Did not receive mail with below subject</BR>" & ExpectedSuccessMessage & "</BR>" & ExpectedFailureMessage, "FAIL", False)
			Environment("Action_Result") = False
		End If

		Set objOutlook = Nothing
		Set objNameSpace = Nothing
		Set objFolder = Nothing
		Set mailItems = Nothing

End Function
