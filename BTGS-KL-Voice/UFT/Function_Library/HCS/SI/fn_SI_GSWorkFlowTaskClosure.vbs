'=============================================================================================================
'Description: To close the Task
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			09/10/2014 	v1.0
'Modified By  : Nagaraj		    08/12/2014  v1.1 || Functionality addition in R35
'Example: fn_SI_GSWorkFlowTaskClosure(dSearchID, dEIN)
'=============================================================================================================
'Public Function fn_SI_GSWorkFlowTaskClosure(ByVal dSearchID, ByVal dEIN)

Public intTaskIDCol, intTaskNameCol, intTaskOwnerCol, intTaskStatus

Public Function fn_SI_GSWorkFlowTaskClosure(ByVal dSearchID, ByVal dEIN, ByVal dGrpCACLimit, ByVal dTGrpCACLimit, ByVal dTCACLimit, ByVal dTCACBandwidthLimit)
	Dim intCounter, intColCounter
	Dim blnTaskReady
	Dim arrColumnNames
'	On Error Resume Next
	'Check whether WorkFlow Link is loaded is Loaded or Not
	For intCounter = 1 to 5
		blnExist = Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Exist
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = BuildWebReference("brwSIMain", "pgSIMain", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	'Click on WorkFlow Link
	blnResult = clickLink("lnkWorkflow")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	intCounter = 0

	'Flag to turn on if next task is open and to avoid to call the fn_SI_WorkFlowSearchOrder simply 
	blnTaskReady = False
 	Do
        Set WshShell = CreateObject("WScript.Shell")
		WshShell.run "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8"
		'To clear browsing cookies
		WshShell.run "RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2"
		Wait 5

		intCounter = intCounter + 1
		'Avoiding unnecessary call to fn_SI_WorkFlowSearchOrder and fn_SI_WorkFlow_SearchChildTask simply
		If Not blnTaskReady Then
			'Calling Function to Search Order
			Call fn_SI_WorkFlowSearchOrder(dSearchID)
				If Not Environment("Action_Result") Then Exit Function
		
			'Calling Function to Search Child Task
			blnContinue = fn_SI_WorkFlow_SearchChildTask(dSearchID, dTaskID)
				If Not Environment("Action_Result") Then Exit Function
		
			'Terminate the Function
			If Not blnContinue Then
				Call fn_SI_CheckOrderClosure()
				Exit Function
			End If
		End If
	
		'Override the Task ID
		If Instr(UCase(objPage.WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
			Call fn_SI_WorkFlowOverride(dTaskID, dEIN)
				If Not Environment("Action_Result") Then Exit Function
		End If

		'Logic for Closing Task will be Put here
		Call fn_SI_WorkFlowTaskClose(dSearchID, dTaskID, dGrpCACLimit, dTGrpCACLimit, dTCACLimit, dTCACBandwidthLimit)
			If Not Environment("Action_Result") Then Exit Function

		'To Check if Task is Complete or Not
		If fn_SI_WorkFlowChildTaskCloseCheck(dSearchID, dTaskID) Then
			Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is closed successfully", "PASS", True)
			Environment("Action_Result") = True
		Else
			Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is not closed after 5 mins", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		iNewTaskRow = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("grdTaskGrid").fGetRowWithCellText("Open", intTaskStatus)
		If iNewTaskRow > 0 Then
			dTaskID = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblTaskDetail").GetCellData(iNewTaskRow, intTaskIDCol)
			blnTaskReady = True
		Else
			blnTaskReady = False
		End If

	Loop Until (Not blnContinue OR intCounter >= 15)

End Function

'============================================================================================================================
'							Search for Child Task and pass the Task ID back to Calling Function
'============================================================================================================================
Public Function fn_SI_WorkFlow_SearchChildTask(ByVal dSearchID, ByRef dTaskID)

	'Variable Declaration
	Dim arrColumnNames
	Dim blnTableColumnsFound
	
	blnTableColumnsFound = False
	Reporter.ReportNote "Function Execution - [[fn_SI_WorkFlow_SearchChildTask]]"
	On Error Resume Next
	Call fn_SI_ToggleTaskDetail()
	If Not Environment("Action_Result") Then Exit Function
	
	intMaxLoopCounter = 15

	For intCounter = 1 to intMaxLoopCounter
		'To Expand the Table
		Call fn_SI_ExpandTable()

		'To Check If Table Exists and No Record Found Element is not there
		For intLoopCounter = 1 to 5
			'If objPage.WebTable("tblTaskDetail").Exist Then
			If objPage.WbfGrid("grdTaskGrid").Exist(60) Then
				If Not blnTableColumnsFound Then
					'Get the column names
					arrColumnNames = Split(Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblTaskDetail").GetROProperty("column names"), ";")
					For intColCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
						strColumnName = UCase(arrColumnNames(intColCounter))
						If strColumnName = "TASK ID" Then
								intTaskIDCol = intColCounter + 1
						ElseIf strColumnName = "TASK NAME" Then
								intTaskNameCol = intColCounter + 1
						ElseIf strColumnName = "TASK OWNER" Then
								intTaskOwnerCol = intColCounter + 1
						ElseIf strColumnName = "TASK STATUS" Then
								intTaskStatus = intColCounter + 1
						End If
					Next '#intColCounter
				End If
				
				'Avoiding to Check Column Names everytime
				If intTaskIDCol > 0 AND intTaskNameCol > 0 AND intTaskOwnerCol > 0 AND intTaskStatus > 0 Then blnTableColumnsFound = True

				If objPage.WbfGrid("grdTaskGrid").RowCount > 1 Then
					If Instr(UCase(objPage.WbfGrid("grdTaskGrid").GetROProperty("text")), "NO RECORD FOUND") > 0  Then
						blnTableExist = False
						'objPage.HighLight
						'CreateObject("WScript.Shell").SendKeys("{F5}")
						'objPage.Sync
						objBrowser.fRefresh
						'Wait 10
						With Browser("creationtime:=1").Dialog("regexpwndtitle:=Windows Internet Explorer")
							If .WinButton("text:=&Retry").Exist(10) Then
								.WinButton("text:=&Retry").Click
								objBrowser.Sync
							End If	
						End With

						Call fn_SI_ToggleTaskDetail()
						If Not Environment("Action_Result") Then Exit Function
					Else
						blnTableExist = True
						Exit For
					End If
				End If
			Else
				Wait 30
				'With objPage.WebElement("class:=ui-pg-div","outertext:=Refresh", "index:=0")
				'	If .Exist(10) Then .Click
				'	Wait 10
				'End With
				blnTableExist = False
				objBrowser.fRefresh
				Wait 10
				With Browser("creationtime:=1").Dialog("regexpwndtitle:=Windows Internet Explorer")
					If .WinButton("text:=&Retry").Exist(10) Then
						.WinButton("text:=&Retry").Click
						objBrowser.Sync
					End If
				End With
				objPage.Sync
				Call fn_SI_ToggleTaskDetail()
				If Not Environment("Action_Result") Then Exit Function
			End If
		Next '#intLoopCounter

		If Not blnTableExist Then
			Call ReportLog("Order Task Detail Table", "Table should be loaded with Tasks", "Task Detail Table is not populated with Tasks to act", "Warnings", False)
			Environment("Action_Result") = False
			fn_SI_WorkFlow_SearchChildTask = False
		End If

		intRow = objPage.WbfGrid("grdTaskGrid").fGetRowWithCellText("Open", intTaskStatus)
		If intRow <= 0 Then
			'To Terminate if Order is Closed/Complete
			Call fn_SI_CheckOrderClosure()
				If Environment("Action_Result") Then fn_SI_WorkFlow_SearchChildTask = False : Exit Function
			
			Wait 60
			
			With objPage.WebElement("class:=ui-pg-div","outertext:=Refresh", "index:=0")
				If .Exist(10) Then .Click
				Wait 10
			End With
			
			intRow = objPage.WbfGrid("grdTaskGrid").fGetRowWithCellText("Open", intTaskStatus)
			If intRow <= 0 Then
				objBrowser.fRefresh
				With Browser("creationtime:=1").Dialog("regexpwndtitle:=Windows Internet Explorer")
					If .WinButton("text:=&Retry").Exist(10) Then
						.WinButton("text:=&Retry").Click
						objBrowser.Sync
					End If
				End With
				objPage.Sync
				Call fn_SI_ToggleTaskDetail()
					If Not Environment("Action_Result") Then Exit Function
			End If
		Else
			Exit For '#intCounter
		End If

		'If intRow <= 0 Then
		'	Wait 60
		'	objBrowser.fRefresh
		'	'Call Search Order
		'	'Call fn_SI_WorkFlowSearchOrder(dSearchID)
		'	'If Not Environment("Action_Result") Then 'Search Success
		'	'	Call ReportLog("Search Task ID", "Task ID should be Searched", "Task ID couldn't be searched", "FAIL", True)
		'	'	Exit Function
		'	'Else
		'		'Calling to Open the Toggle and continue with Search
		'	Call fn_SI_ToggleTaskDetail()
		'		If Not Environment("Action_Result") Then Exit Function
		'	'End If
		'	With objPage.WebElement("class:=ui-pg-div","outertext:=Refresh", "index:=0")
		'		If .Exist(10) Then .Click
		'		Wait 10
		'	End With
		'	
		'Else
		'	Exit For
		'End If
	Next

	If intCounter > intMaxLoopCounter Then
		fn_SI_WorkFlow_SearchChildTask = False
		Exit Function
	End If

	With objPage.WbfGrid("grdTaskGrid")
		intRow = .fGetRowWithCellText("Open", intTaskStatus)
		If intRow < 1 Then
			Call ReportLog("Task Detail Table", "Atleast 1 Record should be in Open Mode", "All Records are either Complete or Closed", "Warnings", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		strTaskID = .GetCellData(intRow, intTaskIDCol)
		strTaskName = .GetCellData(intRow, intTaskNameCol)
		Call ReportLinerMessage("Assigning Task - <B>" & strTaskID & " - " & strTaskName & "</B> is generated")
		'Call ReportLog("Assigning Task", "Task ID and Task Name should be generated", "<B>" & strTaskID & " - " & strTaskName & " is generated </B>", "INFORMATION", False)
	End With
	dTaskID = strTaskID
	Environment("Action_Result") = True
	fn_SI_WorkFlow_SearchChildTask = True

End Function

'***************************************************************************************************************************************************************
'										Toggle the Task Tab to view the tasks that are generated
'***************************************************************************************************************************************************************
Public Function fn_SI_ToggleTaskDetail()
	On Error Resume Next
	Call writeLogFile( "===== Function Call :::: fn_SI_ToggleTaskDetail =====")
 	Browser("brwSIWorkflow").fSync
	Browser("brwSIWorkflow").Page("pgSIWorkflow").Sync

	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
 	
 	blnResult = objPage.Image("imgToggleTaskDetails").Exist(300)
 	
	If UCase(objPage.Image("imgToggleTaskDetails").GetROProperty("file name")) = UCase("collapse.png") Then
		blnResult = clickImage("imgToggleTaskDetails")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	Environment("Action_Result") = True
End Function

'============================================================================================================================
'																	Override the Task that is to be closed
'============================================================================================================================

Public Function fn_SI_WorkFlowOverride(ByVal dTaskID, ByVal dEIN)
	Reporter.ReportNote "Function Execution - [[fn_SI_WorkFlowOverride]]"
	Call writeLogFile( "===== Function Call :::: fn_SI_WorkFlowOverride =====")
	On Error Resume Next
	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	If objPage.WebElement("elmMenu").Exist(10) Then
		objPage.WebElement("elmMenu").Click
	End If

	blnResult = clickLink("lnkOverride")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	objPage.Sync

	For intCounter = 1 to 10
		blnExist = objPage.WebList("lstSystem").Exist
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = selectValueFromPageList("lstSystem", "GLOBAL SERVICES")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

    Wait 5

	blnResult = enterText("txtTaskID", dTaskID)
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = selectValueFromPageList("lstReason", "Re-accept work")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = clickButton("btnSearch")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

'	Wait 10

	For intCounter = 1 to 10
		blnExist = objPage.WebTable("tblOverrideTaskTable").Exist
		If blnExist Then
			Exit For
		End If
	Next

	'If Override Table does not Exist
	If Not blnExist Then
		Call ReportLog("Override", "Override Table Task should be loaded", "Override table is not loaded", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

    intRow = objPage.WebTable("tblOverrideTaskTable").GetRowWithCellText(dTaskID)

	'If the element does not exist
    If intRow < 0 Then
		Call ReportLog("Override", "Should be able to Search Task ID and assign it", "No record found to Override", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	Set objChkBox = objPage.WebTable("tblOverrideTaskTable").ChildItem(intRow, 1, "WebCheckBox", 0)
	objChkBox.HighLight
	objChkBox.Click

	'If User Role is WorkFlow Controller
    If objPage.WebEdit("txtAssignTo").Exist(10) Then
		blnResult = enterText("txtAssignTo", dEIN)
		If Not blnResult Then
			Environment("Action_Result") = False
			Exit Function
		End If

		blnResult = clickImage("imgAgentSearch")
		If Not blnResult Then
			Environment("Action_Result") = False
			Exit Function
		End If

		Wait 3

		If objPage.WebList("lstAssignTo").Exist Then
			strName = objPage.WebList("lstAssignTo").GetROProperty("selection") 
			If strName <> "" Then
				Call ReportLog("Task Assignment", "Assigning Task to EIN", "Assigned task to " & strName, "INFORMATION", False)
			End If
		End If
	Else
		Call ReportLog("Task Assignment", "User is not logged in as Workflow Controller", "User is not logged in as Workflow Controller", "INFORMATION", False)
	End If

	Wait 3

    blnResult = clickButton("btnAssign")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 10
		blnExist = objPage.WebElement("elmTaskAssignedSuccess").Exist 
		If blnExist Then
			Exit For
		End If
	Next

	If Not blnExist Then
		Call ReportLog("Task Assign Status", "Task should be assigned Successfully", "Task is not assigned", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		Call ReportLog("Task Assign Status", "Task should be assigned Successfully", dTaskID & " is assigned successfully", "PASS", True)
	End If
	Environment("Action_Result") = True
	
End Function

'==================================================================================================================================
'												Close the task which was overridden
'==================================================================================================================================

Public Function fn_SI_WorkFlowTaskClose(ByVal dOrderID, ByVal dTaskID, ByVal dGrpCACLimit, ByVal dTGrpCACLimit, ByVal dTCACLimit, ByVal dTCACBandwidthLimit)
   On Error Resume Next
	Dim iTableIndex :  iTableIndex = 0

	'Skip the Search Order Again if the User is Workflow Controller
	If Instr(UCase(objPage.WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
		Call writeLogFile( "===== Function Call :::: fn_SI_WorkFlowTaskClose =====")
		Call fn_SI_WorkFlowSearchOrder(dOrderID)
		If Not Environment("Action_Result")  Then
			Exit Function
		End If
	
		Call fn_SI_ToggleTaskDetail()
		If Not Environment("Action_Result") Then
			Exit Function
		End If
	End If

	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	'To Expand the Table
	If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
		strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
		If Trim(strRecords(1)) > 10 Then
			objPage.WebList("lstRecordPerPage").Select CStr("100")
			For intCounter = 1 to 5
				objPage.WebTable("tblTaskDetail").RefreshObject
				If objPage.WebTable("tblTaskDetail").RowCount > 12 Then
					Exit For
				Else
					Wait 10
					objPage.WebTable("tblTaskDetail").RefreshObject
				End If
			Next
		End If
	End If

	'Skip this step if Workflow Controller is closing the task
	If Instr(UCase(objPage.WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
		For intCounter = 1 to 20
			intRow = objPage.WebTable("tblTaskDetail").GetRowWithCellText(dTaskID)
			strTaskOwnerName =  Trim(objPage.WebTable("tblTaskDetail").GetCellData(intRow, intTaskOwnerCol))
			If strTaskOwnerName <> "" Then
				Exit For
			Else
				Wait 5
				objPage.HighLight
				CreateObject("Wscript.Shell").SendKeys "{F5}"
				Wait 5
				objPage.Sync
			End If
		Next
		
		If strTaskOwnerName = "" Then
			Call ReportLog("Task Assignment", "Task should be assigned to owner", "Task is not assigned to owner", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
	End If

	intRow = objPage.WebTable("tblTaskDetail").GetRowWithCellText(dTaskID)
	strTaskName =  Trim(objPage.WebTable("tblTaskDetail").GetCellData(intRow, intTaskNameCol))
	Set objLink = objPage.WebTable("tblTaskDetail").ChildItem(intRow, intTaskIDCol, "Link", 0)

	If objLink.Exist Then
		objLink.HighLight
		objLink.Click
'		Wait 60
	End If

	For intCounter = 1 to 5
		blnExist = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebButton("btnEnableEscalation").Exist
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = BuildWebReference("brwTaskDetails", "pgTaskDetailsPage", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 5
		blnExist = Browser("brwTaskDetails").Page("pgTaskDetailsPage").Image("imgToggleOrderItemList").Exist
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = clickImage("imgToggleOrderItemList")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	Wait 3

	intRow = objPage.WebTable("tblOrderItemList").RowCount
    	
	Select Case strTaskName

		Case "Assign Order Owner (SOP) (OCC Site)", "Assign Order Owner (SOP) (OCC Site Soft)", "Assign Order Owner (SOP) (OCC Site Std)",_
				"Review and Verify Order (OCC Site)", "Review Order and Take Ownership (OCC Site Std)",_
				"Gather and Confirm Service Configuration Data (OCC Site Std)",_ 
				"Order Quality Check (OCC Site Soft)", "Order Quality Check (OCC Site Std)", "Order Quality Check (OCC Contract)",_
                "Reserve Numbers on SYRAN (OCC Contract)", "Handover to Maintenance (OCC Contract)",_
                "Confirm Order Closure (OCC Contract)", "Configure Customer Site CRF (OCC Contract)", "Calculate CCD (OCC Contract)", "Calculate CCD (OCC Site)",_
				"Review Order and Take Ownership (OCC Contract)"
				'"Gather and Confirm Service Configuration Data (OCC Site)"

				For intCounter = 2 to intRow
                    strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
					strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
					Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
					strIndicator = imgIndicator.GetROProperty("file name")
					If strIndicator <> "GreenTick2.png" Then
						Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If
				Next

		Case "Notify Customer Service is Ready (OCC Site Soft)", "Notify Customer Service is Ready (OCC Site Std)","Notify Customer Service is Ready (OCC Site)",_
					"Review and Verify Order (OCC Site Soft)", "Review and Verify Order (OCC Site Std)",_
					"OCC Site Build-Modify (OCC Site Soft)", "OCC Site Build-Modify (OCC Site Std)",_
					"Change Number Status to In-Use (OCC Site Soft)", "Change Number Status to In-Use (OCC Site Std)",_
					"Confirm Order Closure (OCC Site Soft)", "Confirm Order Closure (OCC Site Std)", "Notify Customer Service is Ready (OCC Contract)"

				For intCounter = 2 to intRow
						strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
						strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
						Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
						strIndicator = imgIndicator.GetROProperty("file name")
	
						'Check ReadOnly Attribute
						If Instr(strChildTaskName, "Move and Change-Site") > 0  And strIndicator = "GreenTick2.png" Then
									imgIndicator.HighLight
									imgIndicator.Click
									Wait 2
									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If

						ElseIf (strChildTaskName = "Site Number Range-Line Service" OR strChildTaskName = "Line Service-OCC" OR strChildTaskName = "Lync Integration RCC"_
									OR strChildTaskName = "Google Apps Integration" OR strChildTaskName = "Unified Messaging" OR strChildTaskName = "User Self Serve") And strIndicator = "GreenTick2.png" Then

									imgIndicator.HighLight
									imgIndicator.Click
									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If

						ElseIf strIndicator <> "GreenTick2.png"  And (strChildTaskName = "Soft Change-Site" OR strChildTaskName = "Standard Change-Site" Or strChildTaskName = "One Cloud Cisco Site" OR strChildTaskName = "One Cloud Cisco - Site")Then
									imgIndicator.HighLight
									imgIndicator.Click
									dtNotifyDate = DateAdd("d", 7, Date)
									Wait 2
									strDate = MonthName(Month(dtNotifyDate ), True) & "-" & Right("0" & DatePart("d",dtNotifyDate), 2) & "-" & Year(dtNotifyDate )
									blnResult = enterText("txtNotifyServiceReadyDate", strDate)
									If Not blnResult Then
										Environment("Action_Result") = False
										Exit Function
									End If
		
									blnResult = clickButton("btnUpdate")
									If Not blnResult Then
										Environment("Action_Result") = False
										Exit Function
									End If
		
									Wait 60
	
									For intInnerCounter = 1 to 20
										If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Exist Then
											If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").GetROProperty("file name") = "expand.png" Then
												Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Click
												Wait 3
											End If

                                            If Browser("brwSITaskDetails").Page("pgSITaskDetails").WebElement("elmUpdateSuccessFul").Exist Then
												Call ReportLog("Update-Notify Service Ready date", "Should Update Notify Service Ready Date", "Update was successful", "INFORMATION", True)
												Wait 5
												Exit For
											End If
										End If
									Next

						ElseIf strIndicator <> "GreenTick2.png" Then
									Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
									Environment("Action_Result") = False
									Exit Function
						End If
				Next

		Case "Perform Number Management (OCC Site)", "Initiate Service (OCC Site)", "Change Number Status to In-Use (OCC Site)", "Order Quality Check (OCC Site)",_
				"Gather and Confirm Service Configuration Data (OCC Site)"
				iTblLineServiceOCCIndex = 0 : iTblSiteNumberRngServiceIndex = 0
				For intCounter = 2 to intRow
						strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
						strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
						Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
						strIndicator = imgIndicator.GetROProperty("file name")
						'Check ReadOnly Attribute
						If ( strChildTaskName = "Site Number Range-Line Service" Or strChildTaskName = "Line Service-OCC" )And strIndicator = "GreenTick2.png" Then
									imgIndicator.HighLight
									imgIndicator.Click
									If strChildTaskName = "Line Service-OCC" Then
										Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", iTblLineServiceOCCIndex
										iTblLineServiceOCCIndex = iTblLineServiceOCCIndex + 1

									ElseIf  strChildTaskName = "Site Number Range-Line Service" Then
										Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyPNM").SetTOProperty "index", iTblSiteNumberRngServiceIndex
										iTblSiteNumberRngServiceIndex = iTblSiteNumberRngServiceIndex + 1
									End If

									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If
						End If

						If strIndicator <> "GreenTick2.png" Then
							Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
				Next
				Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", 0
				Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyPNM").SetTOProperty "index", 0

		Case "Confirm Order Closure (OCC Site)"
				For intCounter = 2 to intRow
						strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
						strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
						Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
						strIndicator = imgIndicator.GetROProperty("file name")
						'Check ReadOnly Attribute
						If strChildTaskName = "Line Service-OCC" And strIndicator = "GreenTick2.png" Then
									imgIndicator.HighLight
									imgIndicator.Click
									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If
						End If

						If strIndicator <> "GreenTick2.png" Then
							Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
				Next
		Case "OCC Site Build (OCC Site)", "Schedule Test and Turn-up (OCC Site)", "Full Service Test and Turn-up (OCC Site)", "Handover to Maintenance (OCC Site)",_
	            "Update VLP (OCC Site)", "Build VLP (OCC Site)"

				iTblLineServiceOCCIndex = 0 : iTblSiteNumberRngServiceIndex = 0
				For intCounter = 2 to intRow
						strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
						strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
						Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
						strIndicator = imgIndicator.GetROProperty("file name")
						'Check ReadOnly Attribute
						If ( strChildTaskName = "Line Service-OCC" OR strChildTaskName = "Site Number Range-Line Service" ) And strIndicator = "GreenTick2.png" Then
									imgIndicator.HighLight
									imgIndicator.Click
									If strChildTaskName = "Line Service-OCC" Then
										Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", iTblLineServiceOCCIndex
										iTblLineServiceOCCIndex = iTblLineServiceOCCIndex + 1

									ElseIf  strChildTaskName = "Site Number Range-Line Service" Then
										Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyPNM").SetTOProperty "index", iTblSiteNumberRngServiceIndex
										iTblSiteNumberRngServiceIndex = iTblSiteNumberRngServiceIndex + 1
									End If

									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If
						End If

						If (strChildTaskName = "One Cloud Cisco - Site" OR strChildTaskName = "One Cloud Cisco Site") And strIndicator = "GreenTick2.png" Then
									imgIndicator.HighLight
									imgIndicator.Click
									Call fn_SI_CheckReadOnlyValues(strChildTaskName)
									If Environment("Action_Result") = False Then
										Exit Function
									End If
						End If

						If strIndicator <> "GreenTick2.png" Then
							Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
				Next
				Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", 0
				Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyPNM").SetTOProperty "index", 0


		Case "Assign Order Owner (SOP) (OCC Contract)", "Review and Verify Order (OCC Contract)", "Configure VQM and T2R Tools (OCC Contract)", "Configure HCS (OCC Contract)",_
				"Configure GMA (OCC Contract)", "IP Design (OCC Contract)", "Confirm CCD with Customer (OCC Contract)","Deconfigure GMA (OCC Contract)","Deconfigure HCS (OCC Contract)",_
				"Remove Numbers from SYRAN (OCC Contract)","Deconfigure VQM and T2R Tools (OCC Contract)","Remove Services from Monitoring (OCC Contract)"
				
				For intCounter = 2 to intRow
					strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
					strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
					Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
					strIndicator = imgIndicator.GetROProperty("file name")
					'Check ReadOnly Attribute
					If strChildTaskName = "One Cloud Cisco" And strIndicator = "GreenTick2.png" Then
								imgIndicator.HighLight
								imgIndicator.Click
								Call fn_SI_CheckReadOnlyValues(strChildTaskName)
								If Environment("Action_Result") = False Then
									Exit Function
								End If
					End If

					If strChildTaskName = "Trunk Group - OCC" And strIndicator = "GreenTick2.png" Then
								imgIndicator.HighLight
								imgIndicator.Click
					End If

					If (strIndicator <> "GreenTick2.png") Then
						If strTaskName = "Configure HCS (OCC Contract)" And strIndicator = "GreenTick2Disabled.png"  Then
							imgIndicator.HighLight
							imgIndicator.Click
							Call fn_SI_CheckReadOnlyValues(strChildTaskName)
							If Environment("Action_Result") = False Then
								Exit Function
							End If
						Elseif strTaskName = "Deconfigure HCS (OCC Contract)" And strIndicator = "GreenTick2Disabled.png"  Then
							imgIndicator.HighLight
							imgIndicator.Click
							Call fn_SI_CheckReadOnlyValues(strChildTaskName)
							If Environment("Action_Result") = False Then
								Exit Function
							End if
						Else
							Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
					End If
				Next
		Case "Confirm CCD with Customer (OCC Site)", "Deconfigure OCC Site Build-TOS (OCC Site)"
				
				For intCounter = 2 to intRow
					strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
					strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
					Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
					strIndicator = imgIndicator.GetROProperty("file name")
					'Check ReadOnly Attribute
					If (strChildTaskName = "Lync Integration RCC" OR strChildTaskName = "Google Apps Integration") And strIndicator = "GreenTick2.png" Then
								Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", iTableIndex
								imgIndicator.HighLight
								imgIndicator.Click
								Call fn_SI_CheckReadOnlyValues(strChildTaskName)
								If Environment("Action_Result") = False Then
									Exit Function
								End If
								'incrementing index for every sub task that encounters quantity table
								iTableIndex = iTableIndex + 1
					End If

					If strChildTaskName = "One Cloud Cisco - Site" And strIndicator = "GreenTick2.png" Then
								imgIndicator.HighLight
								imgIndicator.Click
								Call fn_SI_CheckReadOnlyValues(strChildTaskName)
								If Environment("Action_Result") = False Then
									Exit Function
								End If
					End If

					If strIndicator <> "GreenTick2.png" Then
						Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If
				Next

		Case "Deconfigure Users from Portal (OCC Site)", "Configure Users on Portal (OCC Site)"
				iTableIndex :  iTableIndex = 0
				For intCounter = 2 to intRow
					strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
					strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
					Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
					strIndicator = imgIndicator.GetROProperty("file name")
					'Check ReadOnly Attribute
					If (strChildTaskName = "User Self Serve" OR strChildTaskName = "One Cloud Cisco - Site") And strIndicator = "GreenTick2.png" Then
								Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC").SetTOProperty "index", iTableIndex
								imgIndicator.HighLight
								imgIndicator.Click
								Call fn_SI_CheckReadOnlyValues(strChildTaskName)
								If Environment("Action_Result") = False Then
									Exit Function
								End If
								'incrementing index for every sub task that encounters quantity table
								iTableIndex = iTableIndex + 1
					End If

					If strChildTaskName = "One Cloud Cisco - Site" And strIndicator = "GreenTick2.png" Then
								imgIndicator.HighLight
								imgIndicator.Click
								Call fn_SI_CheckReadOnlyValues(strChildTaskName)
								If Environment("Action_Result") = False Then
									Exit Function
								End If
					End If

					If strIndicator <> "GreenTick2.png" Then
						Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If
				Next

		'Came as New Requirement in Release 35 || by Sagar Kumar || 8/12/2014
		Case "Build Network Capacity (OCC Contract)"
				iTrunkOCC_Counter = 0
				For intCounter = 2 to intRow
					strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
					strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
					Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
					strIndicator = imgIndicator.GetROProperty("file name")
					'Check ReadOnly Attribute
					If ( strChildTaskName = "Trunk Group - OCC" OR strChildTaskName = "Trunk - OCC" ) And strIndicator <> "GreenTick2.png" Then
							imgIndicator.HighLight
							imgIndicator.Click

							If strChildTaskName = "Trunk - OCC" Then
								objPage.WebTable("tblOrderItemData").WebTable("tblTrunkOCC").RefreshObject
								objPage.WebTable("tblOrderItemData").WebTable("tblTrunkOCC").SetTOProperty "index", iTrunkOCC_Counter
								objPage.WebTable("tblOrderItemData").WebTable("tblTrunkOCC").RefreshObject
								iTrunkOCC_Counter = iTrunkOCC_Counter + 1
							End If

							Call fn_SI_SetTaskValues_R35(strChildTaskName, dGrpCACLimit, dTGrpCACLimit, dTCACLimit, dTCACBandwidthLimit)
							If Environment("Action_Result") = False Then
								Exit Function	
							End If

							blnResult = clickButton("btnUpdate")
							If Not blnResult Then
								Environment("Action_Result") = False
								Exit Function
							End If

							Wait 60

							If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Exist(5) Then
								If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").GetROProperty("file name") = "expand.png" Then
									Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Click
									Wait 3
								End If
							End If

					ElseIf strIndicator <> "GreenTick2.png" Then
						Call ReportLog ("Check Mandatory Data Indicator", "Mandatory Data Indicator should be green", "Mandatory Data Indicator is not green & found to be " & strIndicator, "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If
				Next

				objPage.WebTable("tblOrderItemData").WebTable("tblTrunkGroupOCC").SetTOProperty "index", 0

		Case Else
					Call ReportLog ("New Task", "New Task has been encountered", strTaskName & " new task has been encountered", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
	
	End Select

	'Click on Close Task
	blnResult = clickButton("btnCloseTask")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 5
		blnExist = objPage.WebElement("elmCloseTask").Exist(10)
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = clickButton("btnOK")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If
    
	For intCounter = 1 to 20
		blnExist = objPage.WebElement("elmTaskClosedSuccessfully").Exist
		If blnExist Then
			Call ReportLog("Task Closure", "<B>" & strTaskName & " </B> should be closed successfully", "Task is closed Successfully", "PASS", True)
			Environment("Action_Result") = True
			Exit Function
		End If
	Next

	Call ReportLog("Task Closure", "<B>" & strTaskName & " </B> should be closed successfully", "Task is not closed", "FAIL", True)
	Environment("Action_Result") = False

End Function
'******************************************************************************************************************************************************************************
'													Function to check readonly attributes of SubTask
'******************************************************************************************************************************************************************************
Public Function fn_SI_CheckReadOnlyValues(ByVal dItemName)
   On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_CheckReadOnlyValues =====")
	On Error Resume Next
	Dim oDesc
	Dim intRow, iRow, iCol, intCol
	Dim strData, strCorrespondingData
	Dim blnFound

	Call ReportLog("Read Only Attribute Check", "Check Read Only attribute for <B>" & dItemName & "</B>", "Checking Read Only attribute for <B>" & dItemName & "</B>", "INFORMATION", False)

 	Select Case Trim(dItemName)
			Case "Move and Change-Site Soft Change", "Move and Change-Site Standard Change"
					Wait 3
					Set oDesc = Description.Create
					oDesc("micclass").Value = "WebTable"
					oDesc("column names").Value = "ACTIVITY LEVEL.*"
					Set objPage1 = Browser("brwTaskDetails").Page("pgTaskDetailsPage")
					If objPage1.WebElement("elmReadOnlyAttribute").Exist(5) OR objPage1.WebElement("elmReadOnlyAttributeStandardChanges").Exist(5) _
						Or Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblNotifyReadOnlyAttribute").Exist(5) Then
						If objPage1.WebElement("elmReadOnlyAttribute").Exist(5) Then
							Set obj = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebElement("elmReadOnlyAttribute").ChildObjects(oDesc)					
							Set objTable = obj(0)
						ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebElement("elmReadOnlyAttributeStandardChanges").Exist(5) Then
							Set obj = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebElement("elmReadOnlyAttributeStandardChanges").ChildObjects(oDesc)
							Set objTable = obj(0)
						ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblNotifyReadOnlyAttribute").Exist(5) Then
							Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblNotifyReadOnlyAttribute")
						End If

						
						intRow = objTable.RowCount
						For iRow = 1 to intRow
								intCol = objTable.ColumnCount(iRow)
								For iCol = 1 to intCol
										strData = UCase(objTable.GetCellData(iRow, iCol))
				
										If Instr(strData, "ACTIVITY LEVEL") > 0 Then
													strCorrespondingData = objTable.GetCellData(iRow, iCol + 2)
													Call fn_SI_VerifyReadOnlyAttribute(strData, strCorrespondingData, blnFound)
													Exit For
				
										ElseIf Instr(strData, "GROUPING LEVEL") > 0 Then
													strCorrespondingData = objTable.GetCellData(iRow, iCol + 2)
													Call fn_SI_VerifyReadOnlyAttribute(strData, strCorrespondingData, blnFound)
													Exit For
				
										ElseIf Instr(strData, "SERVICE TYPE") > 0 Then
													strCorrespondingData = objTable.GetCellData(iRow, iCol + 2)
													Call fn_SI_VerifyReadOnlyAttribute(strData, strCorrespondingData, blnFound)
													Exit For
				
										End If
								Next
								If Not blnFound Then Exit For
						Next
					ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblActivityLabelCNSI").Exist(10) Then
							strData = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblActivityLabelCNSI").GetROProperty("text")
							intMatchCount = getCountOfRegExpPattern("ACTIVITY LEVEL:.*", strData, False, strMatchVal)
							If intMatchCount >=1 Then
								Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist", strData, "PASS", False)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist", "Missing Read Only Attribute", "FAIL", True)
								Environment("Action_Result") = False
								blnFound = False
								Exit Function
							End If	
					End If
	
			Case "Site Number Range-Line Service"
					'arrTelNumber = Array("END TELEPHONE NUMBER", "START TELEPHONE NUMBER")
					Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyPNM")
					intRow = objTable.RowCount
					objTable.HighLight
					For i = 1 to intRow
						strVal = Trim(objTable.GetCellData(i, 3))
						If strVal = "" Then
							Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
							blnFound = True
						Else
							Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", False)
							blnFound = True
						End If
					Next

			Case "Line Service-OCC", "Lync Integration RCC", "Google Apps Integration", "User Self Serve", "Unified Messaging"
					Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyLineSeviceOCC")
					If objTable.Exist(5) Then
						strData = objTable.GetROProperty("text")
                        intMatchCount = getCountOfRegExpPattern("QUANTITY:\d+", strData, False, strMatchVal)
						If intMatchCount >=1 Then
							Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist", strData, "PASS", False)
							blnFound = True
						Else
							blnFound = False
						End If
					Else
						Call ReportLog("Read Only Attribute Check", "<B>Line Service-OCC</B>: Read OnlyAttribute should exist", "No values are found, please verify the task", "WARNINGS", True)
						blnFound = True
					End If


			Case "One Cloud Cisco - Site", "One Cloud Cisco Site"
'					arrReadOnly = Array("AF4 BANDWIDTH", "AF3 BANDWIDTH", "EF BANDWIDTH", "MAXIMUM CONCURRENT VIDEO CALLS", "MAXIMUM CONCURRENT VOICE CALLS")
					Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyBandwidth")
					If Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("innertext:=.*No Attributes to display.*", "index:=0").Exist(5) Then
						Call ReportLog("Read Only Attribute Check", "Read Only Attribute Check", "No Attributes to display", "PASS", True)
						Environment("Action_Result") = True
						blnFound = True
					ElseIf objTable.Exist(5) Then
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next
					ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblCPEOrderRef").Exist(5) Then
						Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblCPEOrderRef")
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next

					ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblHandovertoMaintenance").Exist(5) Then
						Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblHandovertoMaintenance")
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next
					ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblUpdateVLP").Exist(5) Then
						Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblUpdateVLP")
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next
					ElseIf Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblWANOrderRef").Exist(5) Then
						Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblWANOrderRef")
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next

					End If


			Case "One Cloud Cisco"
					
					If Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyOCCContract").Exist(2) Then
						Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblReadOnlyOCCContract")
					End If

					If objTable.Exist(2) Then
						intRow = objTable.RowCount
						objTable.HighLight
						For i = 1 to intRow
							strVal = Trim(objTable.GetCellData(i, 3))
							If strVal = "" Then
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists with no value", "Warnings", True)
								blnFound = True
							Else
								Call ReportLog("Read Only Attribute Check", "Read Only " & objTable.GetCellData(i, 1) & " Attribute should exist", "Attribute Exists & Value is <B>[" & objTable.GetCellData(i, 3) & "]</B>", "PASS", True)
								blnFound = True
							End If
						Next
					End If

			Case Else 
					Call ReportLog("New Sub Task Encountered", "New Sub Task encountered", "Encountered Task - <B>" & dItemName & "<\B>", "FAIL", False)
					Environment("Action_Result") = False
					Exit Function
	End Select
	If blnFound Then
		Environment("Action_Result") = True
	Else
		Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist", strData & strCorrespondingData & " No Value Found", "FAIL", False)
		Environment("Action_Result") = False
	End If
End Function

'###########################################################################################################################################
Public Function fn_SI_SetTaskValues_R35(ByVal dItemName, ByVal dGrpCACLimit, ByVal dTGrpCACLimit, ByVal dTCACLimit, ByVal dTCACBandwidthLimit)
   'New Functionality in R35
	On Error Resume Next
		Call writeLogFile("===== Function Call ::: fn_SI_CheckReadOnlyValues_R35 =====")
		On Error Resume Next
		Dim oDesc
		Dim intRow, iRow, iCol, intCol
		Dim strData, strCorrespondingData
		Dim blnFound
	
		Call ReportLog("Read Only Attribute Check", "Check Read Only attribute for <B>" & dItemName & "</B>", "Checking Read Only attribute for <B>" & dItemName & "</B>", "INFORMATION", False)
	
		Select Case Trim(dItemName)
		
			Case "Trunk Group - OCC"

					blnResult = fn_SI_GetTrunkTable(".*TRUNK GROUP FRIENDLY NAME.*", objInnerTable)
					If Not blnResult Then
						Call ReportLog("WebTable TG-OCC", "Table should be present", "Table is not present" , "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If

					'Check if Table exists or not
					If Not objInnerTable.Exist(2) Then
						Call ReportLog("WebTable - Order Item Data", "Table should be visible", "Table is not visible" , "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If

					intRow = objInnerTable.GetRowWithCellText("GROUP CAC LIMIT")
					Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
					Call ReportLog("Set Value", "Setting value to task <B>GROUP CAC LIMIT</B>", "Setting value to task <B>GROUP CAC LIMIT</B>" , "INFORMATION", False)
					blnSet = fn_SI_SetMandateAttr(objWebEdit, dGrpCACLimit)
					If Not blnSet Then
						Exit Function
					End If

					'Setting up TRUNKGROUP CAC LIMIT
					intRow = objInnerTable.GetRowWithCellText("TRUNKGROUP CAC LIMIT")
					Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
					Call ReportLog("Set Value", "Setting value to task <B>TRUNKGROUP CAC LIMIT</B>", "Setting value to task <B>TRUNKGROUP CAC LIMIT</B>" , "INFORMATION", False)
					blnSet = fn_SI_SetMandateAttr(objWebEdit, dTGrpCACLimit)
					If Not blnSet Then
						Exit Function
					End If

			Case "Trunk - OCC"
					blnResult = fn_SI_GetTrunkTable(".*TRUNK FRIENDLY NAME.*", objInnerTable)
					If Not blnResult Then
						Call ReportLog("WebTable T-OCC", "Table should be present", "Table is not present" , "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If

					'Check if Table exists or not
					If Not objInnerTable.Exist(2) Then
						Call ReportLog("WebTable - T-OCC", "Table should be visible", "Table is not visible" , "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If

					'Setting up TRUNK CAC LIMIT
					intRow = objInnerTable.GetRowWithCellText("TRUNK CAC LIMIT")
					Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
					Call ReportLog("Set Value", "Setting value to task <B>TRUNK CAC LIMIT</B>", "Setting value to task <B>TRUNK CAC LIMIT</B>" , "INFORMATION", False)
					blnSet = fn_SI_SetMandateAttr(objWebEdit, dTCACLimit)
					If Not blnSet Then
						Exit Function
					End If

					'Setting up TRUNK CAC BANDWITH LIMIT
					intRow = objInnerTable.GetRowWithCellText("TRUNK CAC BANDWIDTH LIMIT")
					Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
					Call ReportLog("Set Value", "Setting value to task <B>TRUNK CAC BANDWIDTH LIMIT</B>", "Setting value to task <B>TRUNK CAC BANDWITH LIMIT</B>" , "INFORMATION", False)
					blnSet = fn_SI_SetMandateAttr(objWebEdit, dTCACBandwidthLimit)
					If Not blnSet Then
						Exit Function
					End If
				
					'Setting up HCS_FRIENDLY_TRUNK_ID
					intRow = objInnerTable.GetRowWithCellText("HCS_FRIENDLY_TRUNK_ID")
					Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
					Call ReportLog("Set Value", "Setting value to task <B>HCS_FRIENDLY_TRUNK_ID</B>", "Setting value to task <B>HCS_FRIENDLY_TRUNK_ID</B>" , "INFORMATION", False)
					blnSet = fn_SI_SetMandateAttr(objWebEdit, "TRKAUT" & Replace(Replace(Replace(Now, "/", ""),":","")," ",""))
					If Not blnSet Then
						Exit Function
					End If
						
		End Select
End Function

'###########################################################################################################################################
'													Function to Set mandate value to Sub Task
'###########################################################################################################################################

Public Function fn_SI_SetMandateAttr(ByVal oWebEdit, ByVal strValue)
	On Error Resume Next
		If oWebEdit.Exist(2) Then
			oWebEdit.Set CStr(strValue)
			For intCounter = 1 to 5
				If oWebEdit.WaitProperty("value", strValue, 5000)  Then
					Call ReportLog("Set Value", "Value should be set successfully", "<B>[" & strValue & "] value was set successfully", "PASS", False)
					fn_SI_SetMandateAttr = True
					Environment("Action_Result") = True
					blnSet = True
					Exit For
				End If
			Next
	
			If Not blnSet Then
				Call ReportLog("Set Value", "Value should be set successfully", "<B>[" & strValue & "]</B> value was not set successfully", "FAIL", True)
				Environment("Action_Result") = False
				fn_SI_SetMandateAttr = False
			End If
		Else
			Call ReportLog("Edit Box", "EditBox should exist", "Edit Box doesn't exist", "FAIL", True)
			Environment("Action_Result") = False
			fn_SI_SetMandateAttr = False
		End If
End Function

'###########################################################################################################################################
'								Function to Just verify the correspoding data is blank or not, if then make a log
'###########################################################################################################################################

Public Function fn_SI_VerifyReadOnlyAttribute(strData, strCorrespondingData, blnFound)
   On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_VerifyReadOnlyAttribute =====")
	If  strCorrespondingData = "" Then
		blnFound = False
	Else
		Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist <B>", strData & " : " & strCorrespondingData & "</B>", "PASS", False)
		blnFound = True
	End If
End Function

'###########################################################################################################################################
'												Function to Check whether the task was closed successfully or not
'###########################################################################################################################################

Public Function fn_SI_WorkFlowChildTaskCloseCheck(ByVal dTaskID, ByVal dChildTaskID)
   On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_WorkFlowChildTaskCloseCheck =====")
	Dim blnComplete
	blnComplete = False

	Browser("brwSIMain").Page("pgSIMain").Link("lnkWorkflow").Click
	Browser("brwSIMain").Page("pgSIMain").Sync

	Call fn_SI_WorkFlowSearchOrder(dTaskID)
	If Not Environment("Action_Result") Then
		Exit Function
	End If

	Call fn_SI_ToggleTaskDetail()
	If Not Environment("Action_Result") Then
		Exit Function
	End If

	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 5
		'To Expand the Table
		If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
			strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
			If Trim(strRecords(1)) > 10 Then
				objPage.WebList("lstRecordPerPage").Select CStr("100")
				For intInnerCounter = 1 to 5
					objPage.WebTable("tblTaskDetail").RefreshObject
					If objPage.WebTable("tblTaskDetail").RowCount > 12 Then
						Exit For
					Else
						Wait 10
						objPage.WebTable("tblTaskDetail").RefreshObject
					End If
				Next
			End If
		End If
	
		intRow = objPage.WebTable("tblTaskDetail").GetRowWithCellText(dChildTaskID)
		strTaskStatus =  UCase(Trim(objPage.WebTable("tblTaskDetail").GetCellData(intRow, intTaskStatus)))
		If strTaskStatus = "COMPLETE" Then
			blnComplete = True
			Exit For
		Else'If The Task is nor in Complete Status then refresh and check again
			Wait 60
			objPage.Highlight
			CreateObject("Wscript.Shell").SendKeys "{F5}"
			Wait 5
			objPage.Sync
	
			Call fn_SI_ToggleTaskDetail()
			If Not Environment("Action_Result") Then
				Exit Function
			End If
		End If
	Next

	fn_SI_WorkFlowChildTaskCloseCheck = blnComplete

End Function

'**********************************************************************************************************************************************************
'															Expand Table If Record Cound > 10
'**********************************************************************************************************************************************************
'Public Function fn_SI_ExpandTable()
'   On Error Resume Next
'	Call writeLogFile("===== Function Call ::: fn_SI_ExpandTable =====")
'	If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
'		strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
'		If Trim(strRecords(1)) > 1 Then
'			objPage.WebList("lstRecordPerPage").Select CStr("80")
'			For intCounter = 1 to 5
'				objPage.WbfGrid("grdTaskGrid").RefreshObject
'				If objPage.WbfGrid("grdTaskGrid").RowCount > 11 Then
'					Exit For
'				Else
'					Wait 10
'					objPage.WbfGrid("grdTaskGrid").RefreshObject
'				End If
'			Next
'		End If
'	End If
'End Function

'**********************************************************************************************************************************************************
'**********************************************************************************************************************************************************
Public Function fn_SI_GetTrunkTable(ByVal Text, ByRef oTable)
	Dim oDescTable
	Set oDescTable = Description.Create
	oDescTable("micclass").Value = "WebTable"
	oDescTable("text").Value = Text
	
	Set oTables = Browser("brwTaskDetails").Page("pgTaskDetailsPage").ChildObjects(oDescTable)
	
	For iTabCounter = 0 to oTables.Count - 1
		If oTables(iTabCounter).GetROProperty("height") > 0 Then
			If Instr(oTables(iTabCounter).GetROProperty("text"), "Updatable Attributes") <= 0 Then
				Set oTable = oTables(iTabCounter)
				fn_SI_GetTrunkTable = True
				Exit Function
			End If
		End If
	Next
End Function
'**********************************************************************************************************************************************************



''###########################################################################################################################################
'Public Function fn_SI_SetTaskValues_R35(ByVal dItemName, ByVal dGrpCACLimit, ByVal dTGrpCACLimit, ByVal dTCACLimit, ByVal dTCACBandwidthLimit)
'   'New Functionality in R35
'	On Error Resume Next
'		Call writeLogFile("===== Function Call ::: fn_SI_CheckReadOnlyValues_R35 =====")
'		On Error Resume Next
'		Dim oDesc
'		Dim intRow, iRow, iCol, intCol
'		Dim strData, strCorrespondingData
'		Dim blnFound
'	
'		Call ReportLog("Read Only Attribute Check", "Check Read Only attribute for <B>" & dItemName & "</B>", "Checking Read Only attribute for <B>" & dItemName & "</B>", "INFORMATION", False)
'	
'		Select Case Trim(dItemName)
'		
'			Case "Trunk Group - OCC"
'					Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblOrderItemData")
'					If objTable.Exist(2) Then
'						intHeight = objTable.GetROProperty("height")
'						If intHeight <= 0 Then
'							objTable.SetTOProperty "index", 1
'							blnSetIndexto1 = True
'						End If
'					End If
'
'					'Check if Table exists or not
'					If Not objTable.Exist(2) Then
'						Call ReportLog("WebTable - Order Item Data", "Table should be visible", "Table is not visible" , "FAIL", True)
'						objTable.SetTOProperty "index", 0
'						Environment("Action_Result") = False
'						Exit Function
'					End If
'
'						Set objInnerTable = objTable.WebTable("tblOrderItemData").WebTable("tblTrunkGroupOCC")
'						'Setting up GROUP CAC LIMIT
'						intRow = objInnerTable.GetRowWithCellText("GROUP CAC LIMIT")
'						Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
'						Call ReportLog("Set Value", "Setting value to task <B>GROUP CAC LIMIT</B>", "Setting value to task <B>GROUP CAC LIMIT</B>" , "INFORMATION", False)
'						blnSet = fn_SI_SetMandateAttr(objWebEdit, dGrpCACLimit)
'						If Not blnSet Then
'							If blnSetIndexto1 Then
'								objTable.SetTOProperty "index", 0
'							End If
'							Exit Function
'						End If
'
'						'Setting up TRUNKGROUP CAC LIMIT
'						intRow = objInnerTable.GetRowWithCellText("TRUNKGROUP CAC LIMIT")
'						Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
'						Call ReportLog("Set Value", "Setting value to task <B>TRUNKGROUP CAC LIMIT</B>", "Setting value to task <B>TRUNKGROUP CAC LIMIT</B>" , "INFORMATION", False)
'						blnSet = fn_SI_SetMandateAttr(objWebEdit, dTGrpCACLimit)
'						If Not blnSet Then
'							If blnSetIndexto1 Then
'								objTable.SetTOProperty "index", 0
'							End If
'							Exit Function
'						End If
'
'			Case "Trunk - OCC"
'					Set objTable = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebTable("tblOrderItemData")
'					If objTable.Exist(2) Then
'						intHeight = objTable.GetROProperty("height")
'						If intHeight <= 0 Then
'							objTable.SetTOProperty "index", 1
'							blnSetIndexto1 = True
'						End If
'					End If
'
'					'Check if Table exists or not
'					If Not objTable.Exist(2) Then
'						Call ReportLog("WebTable - Order Item Data", "Table should be visible", "Table is not visible" , "FAIL", True)
'						Environment("Action_Result") = False
'						objTable.SetTOProperty "index", 0
'						Exit Function
'					End If
'
'						Set objInnerTable = objTable.WebTable("tblOrderItemData").WebTable("tblTrunkOCC")
'						'Setting up TRUNK CAC LIMIT
'						intRow = objInnerTable.GetRowWithCellText("TRUNK CAC LIMIT")
'						Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
'						Call ReportLog("Set Value", "Setting value to task <B>TRUNK CAC LIMIT</B>", "Setting value to task <B>TRUNK CAC LIMIT</B>" , "INFORMATION", False)
'						blnSet = fn_SI_SetMandateAttr(objWebEdit, dTCACLimit)
'						If Not blnSet Then
'							If blnSetIndexto1 Then
'								objTable.SetTOProperty "index", 0
'							End If
'							Exit Function
'						End If
'
'						'Setting up TRUNK CAC BANDWITH LIMIT
'						intRow = objInnerTable.GetRowWithCellText("TRUNK CAC BANDWIDTH LIMIT")
'						Set objWebEdit = objInnerTable.ChildItem(intRow, 3, "WebEdit", 0)
'						Call ReportLog("Set Value", "Setting value to task <B>TRUNK CAC BANDWIDTH LIMIT</B>", "Setting value to task <B>TRUNK CAC BANDWITH LIMIT</B>" , "INFORMATION", False)
'						blnSet = fn_SI_SetMandateAttr(objWebEdit, dTCACBandwidthLimit)
'						If Not blnSet Then
'							If blnSetIndexto1 Then
'								objTable.SetTOProperty "index", 0
'							End If
'							Exit Function
'						End If
'						
'		
'		End Select
'End Function

