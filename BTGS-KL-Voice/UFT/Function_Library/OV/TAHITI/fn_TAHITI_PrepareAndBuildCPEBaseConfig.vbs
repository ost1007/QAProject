'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_PrepareAndBuildCPEBaseConfig
' Purpose	 	 : Function to Prepare And Build CPE Base Config
' Author	 	 : Linta
' Creation Date  	 : 14/05/2014 					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_TAHITI_PrepareAndBuildCPEBaseConfig(dPREPARE_BUILD_CPE_BASE_CONFIG, AIBURL, AIBUserName, AIBPassword)

	'Declaration of variables
	Dim blnCompleted, blnURLGenerated
	Dim iRow, intRows, intCounter, intUBound, intLoop
	Dim strStatus, strResponseStatus, strInteractionID, strRetrievedText
	Dim arrPREPARE_BUILD_CPE_BASE_CONFIG, arrValues
	
	'Assigning values to an array
	arrPREPARE_BUILD_CPE_BASE_CONFIG = Split(dPREPARE_BUILD_CPE_BASE_CONFIG,",")
	intUBound = UBound(arrPREPARE_BUILD_CPE_BASE_CONFIG)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrPREPARE_BUILD_CPE_BASE_CONFIG(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrPREPARE_BUILD_CPE_BASE_CONFIG(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

		'Enter Managed Device name
		If objFrame.WebEdit("txtManagedDeviceName").Exist(20) Then
			If objFrame.WebEdit("txtManagedDeviceName").GetROProperty("value") = "" Then
				For intLoop = 0 to intUBound
					If arrValues(intLoop,0) = "ManagedDeviceName" Then
						strData = arrValues(intLoop,1)
						Exit For
					End If
				Next
				
				blnResult = enterFrameText("txtManagedDeviceName",strData)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		End If

		'Enter  Management/Loopback IP Address
		If objFrame.WebEdit("txtManagementLoopbackIPAddress").Exist(20) then
			For intLoop = 0 to intUBound
				If arrValues(intLoop,0) = "ManagementLoopbackIPAddress" Then
					strData = arrValues(intLoop,1)
					Exit For
				End If
			Next

			blnResult = enterFrameText("txtManagementLoopbackIPAddress",strData)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
		If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
			'If Update rPACS button exists then perform update rPACS and check whether Base Config URL is generated or not
			If objFrame.Webbutton("btnUpdaterPACS").Exist Then
				If Not objFrame.Webbutton("btnUpdaterPACS").Object.disabled Then
					blnResult = clickFrameButton("btnUpdaterPACS")
						If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
					
					Wait 5
					objPage.Sync
					
					If Not objFrame.WebButton("btnSubmit").WaitProperty("height", micGreaterThan(0), 1000*60*5) Then
						If Not objFrame.WebButton("btnSubmit").Exist(0) Then
							Call ReportLog("Navigation", "Page should be navigated to Interaction Details page", 	"Unable to navigate to Interaction Details Page", "FAIL", False)
							Environment("Action_Result") = False : Exit FUnction
						End If
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
						If strResponseStatus = "InProgress"  Or strResponseStatus = "Waiting" Then
							strInteractionID = "CL01" & Trim(objFrame.WebTable("tblInteractionDetails").GetCellData(iRow, 1))
						End If
					Next
					
					'Write Logic For Opening AIB and Waiting for the Interaction to be Completed
					Call fn_AIB_Login(AIBURL, AIBUserName, AIBPassword)
						If Not Environment("Action_Result") Then fn_TAHITI_PrepareAndBuildCPEBaseConfig = False : Exit Function
					Call fn_AIB_OrderSearch(strInteractionID)
						If Not Environment("Action_Result") Then fn_TAHITI_PrepareAndBuildCPEBaseConfig = False : Exit Function
					blnCompleted = fn_AIB_CheckInteractionCompletion()
					
					If blnCompleted Then
						blnURLGenerated = False
						For intCounter = 1 To 10 Step 1
							Wait 60
							objFrame.WebButton("btnRefresh").Click
							If objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
								objPage.Frame("html id:=content").WebElement("class:=progress_text","html tag:=DIV","innertext:=Loading \.\.\.").WaitProperty "height", 0, 1000*60*10
							End If
							
							If Instr(objFrame.WebTable("tblInteractionDetails").Object.InnerText, "Success") > 0 Then
								Call ReportLog("NTE Base Config", "NTE Base Config URL should be generated", "NTE Base Config URL is generated and response is success", "PASS", True)
								blnURLGenerated = True
								Exit For
							End If
						Next
					Else
						blnURLGenerated = False
					End If
					
					If Not blnURLGenerated Then
						fn_TAHITI_PrepareAndBuildCPEBaseConfig = False
						Exit Function
					End If
					
					objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
					objPage.Sync
					
					objFrame.WebButton("btnUpdaterPACS").WaitProperty "visible", "True", 1000*60*3
					
					strRetrievedText = objFrame.WebEdit("txtBTEBaseConfigURL").GetROProperty("value")
					If strRetrievedText = "" Then
						Call ReportLog("NTE Base URL", "NTE Base Config URL should be generated", "NTE Base Config URL is not generated", "FAIL", True)
						fn_TAHITI_PrepareAndBuildCPEBaseConfig = False : Exit Function
					Else
						Call ReportLog("NTE Base URL", "NTE Base Config URL should be generated", "NTE Base Config URL:= " & strRetrievedText, "PASS", True)
					End If
				End If
			End If
		End If
		
		fn_TAHITI_PrepareAndBuildCPEBaseConfig = True

'====================================Adding for Closure of MPLS Task'====================================
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
