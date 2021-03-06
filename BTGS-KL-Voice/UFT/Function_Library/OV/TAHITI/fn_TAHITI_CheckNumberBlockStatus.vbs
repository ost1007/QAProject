'=============================================================================================================
'Description: Function TO get the attachment saved to location and read the contents
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			23/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_CheckNumberBlockStatus(ExpectedSubject)
'=============================================================================================================
Public Function fn_TAHITI_CheckNumberBlockStatus(ByVal ServiceID, ByVal ExpectedSubject)
	On Error Resume Next
		'Variable Declaration
		Dim objOutlook, objNameSpace, objFolder
		Dim intMailCount, intCheckMailCount
		Dim strSubject, strMailContent
		Dim oAttachment

		Set objOutlook = EVal("GetObject(,""Outlook.Application"")")
		If Err.Number = 429 Then
			Err.Clear
			Set objOutlook = CreateObject("Outlook.Application")
		End If

		Set objNameSpace = objOutlook.GetNameSpace("MAPI")
		Set objFolder = objNameSpace.GetDefaultFolder(6)
		blnMessageFound = False

		For intCounter = 1 To 10
			intMailCount  = objFolder.Items.Count
			Set mailItems = objFolder.Items
			Set mailItem = mailItems.GetLast
			
			For index = intMailCount to 1 step -1
				strSubject = mailItem.Subject
				If Instr(strSubject, ExpectedSubject) > 0 Then
					If mailItem.ReceivedTime >= Date Then
						Set oAttachment = mailItem.Attachments(1) 
						strStorageLocation = Left(Environment("TestDataPath"), InStrRev(Environment("TestDataPath"), "\")) & oAttachment.FileName
						
						'Check whether file exists or not, if exists delete the file
						If CreateObject("Scripting.FileSystemObject").FileExists(strStorageLocation) Then
							CreateObject("Scripting.FileSystemObject").DeleteFile strStorageLocation
						End If
						'Save the attachment for verfication
						oAttachment.SaveAsFile strStorageLocation 
						Call ReportLog("Save File", "Mail Attachment should be saved", "Mail attachment saved to location " & strStorageLocation, "INFORMATION", False)
						strContent = UCase(CreateObject("Scripting.FileSystemObject").OpenTextFile(strStorageLocation).ReadAll)
						If Instr(strContent, ServiceID) > 0 Then
							If Instr(strContent, "FAIL") > 0 Then
								Call ReportLog("Save File", "CSV File should not contain FAIL Status", "CSV File Contains Fail Status</BR>" & Replace(strContent, vbCrLf, "</BR>"), "FAIL", False)
								Environment("Action_Result") = False
								Exit Function
							Else
								blnMessageFound = True
								Call ReportLog("Save File", "CSV File should not contain FAIL Status", "Upload was successful</BR>" & Replace(strContent, vbCrLf, "</BR>"), "PASS", False)
								Environment("Action_Result") = True
								Exit For
							End If
							Exit For
						End If
					End If
				End If
				Set mailItem = mailItems.GetPrevious
			Next
			If Not blnMessageFound Then
				Wait 60
			Else
				Exit For
			End If
		Next

		If Not blnMessageFound Then
			Call ReportLog("CSV Verification", "Mail should arrive with attachment", "Mail has not arrived within 10 mins", "FAIL", False)
			Environment("Action_Result") = False
		End If
		
		Set objOutlook = Nothing
		Set objNameSpace = Nothing
		Set objFolder = Nothing
		Set mailItems = Nothing
	
End Function
