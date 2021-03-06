'=============================================================================================================
'Description: Function to initiate the Intearction and complete the Process
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			06/08/2015 				NA
'Return Values : Boolean
'Example: fn_TAHITI_HandleInteractionProcess("URL", "Username", "Password")
'=============================================================================================================
Public Function fn_TAHITI_HandleInteractionProcess(ByVal AIBURL, ByVal AIBUserName, ByVal AIBPassword)
	
	'Variable Declaration
	Dim intCounter, intRows, iRow
	Dim strStatus, strResponseStatus, strInteractionID
	Dim blnCompleted, blnInteractionCompleted
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check Whether the page has been Navigated to Interaction Details Page or Not
	For intCounter = 1 To 10 Step 1
		If objFrame.WebButton("btnSubmit").Exist Then
			Exit For
		End If
	Next
	
	If Not objFrame.WebButton("btnSubmit").Exist(0) Then
		Call ReportLog("Navigation", "Page should be navigated to Interaction Details page", 	"Unable to navigate to Interaction Details Page", "FAIL", False)
		fn_TAHITI_HandleInterationProcess = False : Exit Function
	End If
	
	If Not objFrame.WebButton("btnSubmit").Object.disabled Then
		'Click on Submit Button
		blnResult = clickFrameButton("btnSubmit")
			If Not blnResult Then fn_TAHITI_HandleInterationProcess = False : Exit Function	
		
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
		If Not Environment("Action_Result") Then fn_TAHITI_HandleInterationProcess = False : Exit Function
	Call fn_AIB_OrderSearch(strInteractionID)
		If Not Environment("Action_Result") Then fn_TAHITI_HandleInterationProcess = False : Exit Function
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
		fn_TAHITI_HandleInterationProcess = False : Exit Function
	End If
	
	If blnInteractionCompleted Then
		For intCounter = 1 To 10 Step 1
			If Instr(objFrame.WebTable("tblInteractionDetails").object.innertext, "Success") > 0 Then
				objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
				objPage.Sync
				objFrame.WebButton("btnUpdaterPACS").WaitProperty "visible", "True", 1000*60*3
				fn_TAHITI_HandleInterationProcess = blnInteractionCompleted
				Exit Function
			End If '#Success
		Next '#intCounter
	End If '#blnInteractionCompleted

End Function
