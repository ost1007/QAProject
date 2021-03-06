'=============================================================================================================
'Description: Function to handle PortInOutAndTestServiceWithCustomer
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			01/08/2015 				NA
'Return Values : Boolean
'Example: fn_TAHITI_PlanAssignSecondaryGlobalNetwork
'=============================================================================================================
Public Function fn_TAHITI_PlanAssignSecondaryGlobalNetwork(ByVal AIBURL, ByVal AIBUserName, ByVal AIBPassword)
		'Variable Declaration
		Dim strStatus, strResponseStatus, strRetrievedText
		Dim blnInteractionCompleted
		Dim intCounter
		
		'Assignment
		fn_TAHITI_PlanAssignSecondaryGlobalNetwork = True
		
		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Click on Update rPACS Button
		blnResult = clickFrameButton("btnUpdaterPACS")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Check Whether the page has been Navigated to Interaction Details Page or Not
		For intCounter = 1 To 10 Step 1
			If objFrame.WebButton("btnSubmit").Exist Then
				Exit For
			End If
		Next
		
		If Not objFrame.WebButton("btnSubmit").Exist(0) Then
			Call ReportLog("Navigation", "Page should be navigated to Interaction Details page", 	"Unable to navigate to Interaction Details Page", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
		
		If Not objFrame.WebButton("btnSubmit").Object.disabled Then
			'Click on Submit Button
			blnResult = clickFrameButton("btnSubmit")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			
			'Wait for Loading Element to disappear
			If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
				objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
			End If
		End If
		
		intRows = objFrame.WebTable("tblInteractionDetails").RowCount()		
		For iRow = 2 To intRows Step 1
			strStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 3)
			strResponseStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 4)
			If strResponseStatus = "InProgress"  Or strResponseStatus = "Waiting" Or strResponseStatus = "Success" Then
				strInteractionID = "CL01" & Trim(objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 1))
				Exit For '#iRow
			End If
		Next
		
		'Write Logic For Opening AIB and Waiting for the Interaction to be Completed
		Call fn_AIB_Login(AIBURL, AIBUserName, AIBPassword)
			If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
		Call fn_AIB_OrderSearch(strInteractionID)
			If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
		blnCompleted = fn_AIB_CheckInteractionCompletion()
		
		'If Interaction is Completed in AIB then Check for Status in Tahiti
		If blnCompleted Then
			blnInteractionCompleted = False
			For intCounter = 1 To 10 Step 1
				Wait 60
				objFrame.WebButton("btnRefresh").Click
				If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
					objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
				End If
				
				If Instr(objFrame.WebTable("tblInteractionDetails").Object.InnerText, "Success") > 0 Then
					Call ReportLog("Interaction Status", "All KSUs should get completed", "Interaction Request Success", "PASS", True)
					blnInteractionCompleted = True
					Exit For '#intCounter
				End If
			Next
		Else
			blnInteractionCompleted = False
		End If
		
		'Terminate If Interaction has Failed
		If Not blnInteractionCompleted Then
			Call ReportLog("Interaction Status", "All KSUs should get completed", "Interaction Request Failed", "FAIL", True)
			Environment("Action_Result") = blnInteractionCompleted : Exit Function
		End If
		
		If blnInteractionCompleted Then
			For intCounter = 1 To 10 Step 1
				If Instr(objFrame.WebTable("tblInteractionDetails").object.innertext, "Success") > 0 Then
						objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
						objPage.Sync
						
						objFrame.WebButton("btnUpdaterPACS").WaitProperty "visible", "True", 1000*60*3
						
						'Check whether Port Allocation Service ID is Blank or not
						strRetrievedText = objFrame.WebEdit("txtPortAllocationServiceID").GetROProperty("value")
						If  strRetrievedText <> ""  Then
							Call ReportLog("Port Allocation Service ID", "Should be blank", "Value is populated:= "  & strRetrievedText, "PASS", False)
						Else
							objFrame.WebEdit("txtPortAllocationServiceID").HighLight
							Call ReportLog("Port Allocation Service ID", "Should be blank", "Value is found to be blank", "FAIL", True)
							fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
						End If
				
						'Check whether A end SNEID is Blank or not
						strRetrievedText = objFrame.WebEdit("txtAendSNEID").GetROProperty("value")
						If  strRetrievedText <> ""  Then
							Call ReportLog("A end SNEID", "Should be blank", "Value is already populated:= "  & strRetrievedText, "PASS", False)
						Else
							objFrame.WebEdit("txtAendSNEID").HighLight
							Call ReportLog("A end SNEID", "Should be blank", "Value is found to be blank", "FAIL", True)
							fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
						End If
						
						fn_TAHITI_PlanAssignSecondaryGlobalNetwork = blnInteractionCompleted
						Exit Function
				End If '#Success
			Next '#intCounter
		End If '#blnCompleted
End Function


'Public Function fn_TAHITI_PlanAssignSecondaryGlobalNetwork(ByVal AIBURL, ByVal AIBUserName, ByVal AIBPassword)
'		'Variable Declaration
'		Dim strStatus, strResponseStatus, strRetrievedText
'		
'		'Assignment
'		fn_TAHITI_PlanAssignSecondaryGlobalNetwork = True
'		
'		'Building reference
'		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'		'Click on Update rPACS Button
'		blnResult = clickFrameButton("btnUpdaterPACS")
'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'		For intCounter = 1 To 10 Step 1
'			If objFrame.WebButton("btnSubmit").Exist Then
'				Exit For
'			End If
'		Next
'		
'		If Not objFrame.WebButton("btnSubmit").Exist(0) Then
'			Call ReportLog("Navigation", "Page should be navigated to Interaction Details page", 	"Unable to navigate to Interaction Details Page", "FAIL", False)
'			Environment("Action_Result") = False : Exit Function
'		End If
'		
'		If Not objFrame.WebButton("btnSubmit").Object.disabled Then
'				
'				intRowsBefore = objFrame.WebTable("tblInteractionDetails").RowCount()
'				
'				'Click on Submit Button
'				blnResult = clickFrameButton("btnSubmit")
'					If Not blnResult Then Environment("Action_Result") = False : Exit Function
'		
'				If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
'					objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
'				End If
'				
'				Wait 60
'				
'				intRowsAfter = objFrame.WebTable("tblInteractionDetails").RowCount()
'				If intRowsAfter =  intRowsAfter Then
'					blnResult = clickFrameButton("btnRefresh")
'						If Not blnResult Then Environment("Action_Result") = False : Exit Function				
'					
'					If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
'						objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
'					End If
'				End If
'				
'				intRows = objFrame.WebTable("tblInteractionDetails").RowCount()		
'				For iRow = 2 To intRows Step 1
'					strStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 3)
'					strResponseStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 4)
'					If strResponseStatus = "InProgress"  Or strResponseStatus = "Waiting" Then
'						strInteractionID = "CL01" & Trim(objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 1))
'					End If
'				Next
'				
'				'Write Logic For Opening AIB and Waiting for the Interaction to be Completed
'				Call fn_AIB_Login(AIBURL, AIBUserName, AIBPassword)
'					If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False
'				Call fn_AIB_OrderSearch(strInteractionID)
'					If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False
'				blnCompleted = fn_AIB_CheckInteractionCompletion()
'				
'				blnResult = clickFrameButton("btnRefresh")
'					If Not blnResult Then Environment("Action_Result") = False : Exit Function				
'				
'				If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
'					objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
'				End If
'							
'				'Call ReportLog("Interaction Details", "All KSUs should get completed", "Status is found to be <B>" & strStatus & "</B></BR> Response Status is found to be <B>" & strResponseStatus, "information", True)
'				
'				strHTML = objFrame.Object.documentElement.innerHTML
'				strHTML = "Please find below snapshot for your reference. Request you to wait until KSU are closed and then rerun to close the task </BR></BR>" & strHTML
'				fCreateAndSendMail Environment("ToList"), "", "", "Task - Plan Assign & Secondary GlobalNetwork", strHTML, ""
'				fn_TAHITI_PlanAssignSecondaryGlobalNetwork = blnCompleted
'		Else
'				Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
'				Wait 60
'				
'				'If the Interaction Details Table doesn't contain Success And Status is instread InProgress or Waiting then Navigate to AIB and check for completion
'				strInteractionTableText = objFrame.WebTable("tblInteractionDetails").object.innertext
'				If Instr(strInteractionTableText, "Success") <= 0 And ( Instr(strInteractionTableText, "InProgress") > 0 OR Instr(strInteractionTableText, "Waiting") > 0 ) Then '#1
'						intRows = objFrame.WebTable("tblInteractionDetails").RowCount()		
'						For iRow = 2 To intRows Step 1
'							strStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 3)
'							strResponseStatus = objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 4)
'							If strResponseStatus = "InProgress"  Or strResponseStatus = "Waiting" Then
'								strInteractionID = "CL01" & Trim(objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 1))
'								Exit For '#iRow
'							End If
'						Next '#iRow
'				
'						'Write Logic For Opening AIB and Waiting for the Interaction to be Completed
'						Call fn_AIB_Login(AIBURL, AIBUserName, AIBPassword)
'							If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False
'						Call fn_AIB_OrderSearch(strInteractionID)
'							If Not Environment("Action_Result") Then fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False
'						blnCompleted = fn_AIB_CheckInteractionCompletion()
'						
'						blnResult = clickFrameButton("btnRefresh")
'							If Not blnResult Then Environment("Action_Result") = False : Exit Function				
'						
'						If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
'							objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
'						End If
'				ElseIf Instr(strInteractionTableText, "Success") > 0 Then
'					blnCompleted = True
'				End If '#1
'				
'				'If Completed in AIB then wait for it to get reflexted in TAHITI as Success
'				If blnCompleted Then
'					blnCompleted = False
'					For intCounter = 1 To 10 Step 1
'						If Instr(objFrame.WebTable("tblInteractionDetails").object.innertext, "Success") > 0 Then
'								blnCompleted = True
'								Call ReportLog("Interaction Details", "All KSUs should get completed", "Response Status is found to be <B>Success</B>", "Pass", True)
'							
'								objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
'								objPage.Sync
'								
'								objFrame.WebButton("btnUpdaterPACS").WaitProperty "visible", "True", 1000*60*3
'								
'								'Check whether Port Allocation Service ID is Blank or not
'								strRetrievedText = objFrame.WebEdit("txtPortAllocationServiceID").GetROProperty("value")
'								If  strRetrievedText <> ""  Then
'									Call ReportLog("Port Allocation Service ID", "Should be blank", "Value is populated:= "  & strRetrievedText, "PASS", False)
'								Else
'									objFrame.WebEdit("txtPortAllocationServiceID").HighLight
'									Call ReportLog("Port Allocation Service ID", "Should be blank", "Value is found to be blank", "FAIL", True)
'									fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
'								End If
'						
'								'Check whether A end SNEID is Blank or not
'								strRetrievedText = objFrame.WebEdit("txtAendSNEID").GetROProperty("value")
'								If  strRetrievedText <> ""  Then
'									Call ReportLog("A end SNEID", "Should be blank", "Value is already populated:= "  & strRetrievedText, "PASS", False)
'								Else
'									objFrame.WebEdit("txtAendSNEID").HighLight
'									Call ReportLog("A end SNEID", "Should be blank", "Value is found to be blank", "FAIL", True)
'									fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False : Exit Function
'								End If
'								
'								fn_TAHITI_PlanAssignSecondaryGlobalNetwork = blnCompleted
'								Exit Function
'						Else
'								Wait 60
'								blnResult = clickFrameButton("btnRefresh")
'									If Not blnResult Then Environment("Action_Result") = False : Exit Function				
'								
'								If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
'									objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
'								End If
'						End If
'					Next '#intCounter
'				Else
'					fn_TAHITI_PlanAssignSecondaryGlobalNetwork = blnCompleted
'				End If '#blnCompleted
'		End If
'		
'		fn_TAHITI_PlanAssignSecondaryGlobalNetwork = False
'End Function
