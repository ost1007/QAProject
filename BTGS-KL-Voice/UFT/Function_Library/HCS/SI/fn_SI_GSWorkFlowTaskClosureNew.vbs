'=============================================================================================================
'Description: To close the Tasks for Service Internet Contract
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			09/10/2014 	v1.0
'Modified By  : Murali T		    09/04/2015  v1.2 || Functionality addition in R37
'Example: fn_SI_GSWorkFlowTaskClosureNew(dSearchID, dEIN)
'=============================================================================================================
Public Function fn_SI_GSWorkFlowTaskClosureNew(ByVal dSearchID, ByVal dEIN, ByVal dMPDMSheet,ByVal dSheetName)
		Dim intCounter
		Dim blnTaskReady

		On Error Resume Next
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
				If Not Environment("Action_Result") Then
					Exit Function
				End If
				'Calling Function to Search Child Task
				blnContinue = fn_SI_WorkFlow_SearchChildTask(dSearchID, dTaskID)
				If Not Environment("Action_Result") Then
					Exit Function
				End If
				
				'Terminate the Function
				If Not blnContinue Then
					Call fn_SI_CheckOrderClosure()
					Exit Function
				End If
			End If

			If Instr(UCase(objPage.WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
				'Override the Task ID
				Call fn_SI_WorkFlowOverride(dTaskID, dEIN)
				If Not Environment("Action_Result") Then
					Exit Function
				End If
			End If
			
			'Logic for Closing Task will be Put here 'changes made to the function
			Call fn_SI_WorkFlowTaskCloseNew(dSearchID, dTaskID, dMPDMSheet,dSheetName)
			If Not Environment("Action_Result") Then
				Exit Function
			End If

			'To Check if Task is Complete or Not
			If fn_SI_WorkFlowChildTaskCloseCheck(dSearchID, dTaskID) Then
				Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is closed successfully", "PASS", True)
				Environment("Action_Result") = True
			Else
				Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is not closed after 5 mins", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If

			iNewTaskRow = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblTaskDetail").GetRowWithCellText("Open")
			If iNewTaskRow > 0 Then
				dTaskID = Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblTaskDetail").GetCellData(iNewTaskRow, intTaskIDCol)
				blnTaskReady = True
			Else
				blnTaskReady = False
			End If
		Loop Until (Not blnContinue OR intCounter >= 15)
End Function

'==================================================================================================================================
'												Close the task which was overridden
'==================================================================================================================================

Public Function fn_SI_WorkFlowTaskCloseNew(ByVal dOrderID, ByVal dTaskID, ByVal dMPDMSheet,ByVal dSheetName)
	On Error Resume Next
    Dim strActualTaskName,arrSheetData,strRecords,strExpTaskName

	'Skip the Search Order Again if the User is Workflow Controller
	If Instr(UCase(objPage.WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
		Call writeLogFile( "===== Function Call :::: fn_SI_WorkFlowTaskCloseNew =====")
		Call fn_SI_WorkFlowSearchOrder(dOrderID)
		If Not Environment("Action_Result")  Then
			Exit Function
		End If
	
		Call fn_SI_ToggleTaskDetail()
		If Not Environment("Action_Result") Then
			Exit Function
		End If
	End if
	
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

	blnResult = clickImage("imgToggleOrderItemList")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	Wait 3

	intRow = objPage.WebTable("tblOrderItemList").RowCount
	If Instr(strTaskName,"Notify Customer Service is Ready")>0 Then
		strActualTaskName=Split(strTaskName,"(")
		strExpTaskName=strActualTaskName(0)
	End If
	
	For intCounter = 2 to intRow
		strChildTaskID = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 1)
		strChildTaskName = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 2)
		strAction = objPage.WebTable("tblOrderItemList").GetCellData(intCounter, 3)
		Set imgIndicator = objPage.WebTable("tblOrderItemList").ChildItem(intCounter, 6, "Image", 0)
		strIndicator = imgIndicator.GetROProperty("file name")
		'Check ReadOnly Attribute
		If  (strIndicator = "GreenTick2.png" OR strIndicator = "GreenTick2Disabled.png") AND strAction <> "None" Then
			imgIndicator.HighLight
			imgIndicator.Click
			Wait 2
			arrSheetData = ""
			Call ReportLog("Read-Only Attributes", "<B>" & strChildTaskName & "</B> is being checked", "<B>" & strChildTaskName & "</B> is being checked", "INFORMATION", False)
			arrSheetData = fn_SI_FetchTaskLineItemDetails(strTaskName, strChildTaskName,dMPDMSheet,dSheetName)
				If Not Environment("Action_Result") Then Exit Function
			If arrSheetData = "" Then
					Set oTblNoAttribute = objPage.WebTable("column names:=Order Item Data " & strChildTaskName & " \(" & strChildTaskID & "\)No Attributes to display", "index:=0")
					If oTblNoAttribute.Exist(0) Then
						Call ReportLog(strChildTaskName, "No Attributes to display", oTblNoAttribute.GetROProperty("text"), "INFORMATION", True)
					Else
						Call ReportLog(strChildTaskName, "mPDM Sheet contains no ReadOnly attribute", "Application is displaying ReadOnly Attributes", "FAIL", True)
					End If
			Else
					Call fn_SI_CheckReadOnlyValuesApp(arrSheetData, strExpTaskName)
					If Environment("Action_Result") = False Then Exit Function
			End If

		ElseIf (strIndicator = "GreenTick2.png" OR strIndicator = "GreenTick2Disabled.png") AND strAction = "None" Then 
			imgIndicator.Click
			
		ElseIf strIndicator <> "GreenTick2.png" And Trim(strActualTaskName) = "Notify Customer Service is Ready" Then
			dtNotifyDate = DateAdd("d", 7, Date)
			Wait 2
			strDate = MonthName(Month(dtNotifyDate ), True) & "-" & Right("0" & DatePart("d",dtNotifyDate), 2) & "-" & Year(dtNotifyDate )
			objPage.WebEdit("txtNotifyServiceReadyDate").Object.Value = strDate

			blnResult = clickButton("btnUpdate")
			If Not blnResult Then
				Environment("Action_Result") = False
				Exit Function
			End If
			
			Wait 30
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
			imgIndicator.Click
			arrSheetData= fn_SI_FetchTaskLineItemDetails(strTaskName,dMPDMSheet,dSheetName)
			Call fn_SI_CheckReadOnlyValuesApp(arrSheetData,strExpTaskName)
		
		ElseIf strIndicator <> "GreenTick2.png" Then
			
			Select Case Trim(strTaskName)
				
					Case "Build Network Capacity (OCC Contract)"
								'Get Attributes
								dGrpCACLimit = GetAttributeValue("dGrpCACLimit")
								dTGrpCACLimit = GetAttributeValue("dTGrpCACLimit")
								dTCACLimit = GetAttributeValue("dTCACLimit")
								dTCACBandwidthLimit = GetAttributeValue("dTCACBandwidthLimit")
								
								imgIndicator.HighLight
								imgIndicator.Click
								Wait 2
								Call ReportLog("Read-Only Attributes", "<B>" & strChildTaskName & "</B> is being checked", "<B>" & strChildTaskName & "</B> is being checked", "INFORMATION", False)	
								If ( strChildTaskName = "Trunk Group - OCC" OR strChildTaskName = "Trunk - OCC" ) And strIndicator <> "GreenTick2.png" Then '#1
									Call fn_SI_SetTaskValues(strChildTaskName, dGrpCACLimit, dTGrpCACLimit, dTCACLimit, dTCACBandwidthLimit)
									If Not Environment("Action_Result")  Then Exit Function
								End If '#1
								
								blnResult = clickButton("btnUpdate")
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
								Wait 60
		
								If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Exist(5) Then
									If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").GetROProperty("file name") = "expand.png" Then
										Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Click : Wait 3
									End If
								End If
						
					Case Else
								Call ReportLog("Unhadled Task", "Task has not been handled", "Please contact automation team", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
					
			End Select
			
			
		
		End If
	Next

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
Public Function fn_SI_CheckReadOnlyValuesApp(strSheetData, strExpTaskName)
	On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_CheckReadOnlyValuesApp =====")
	On Error Resume Next
	Dim oDesc, oDescReadOnly
	Dim intRow, iRow, iCol, intCol,intChkData
	Dim strData, strCorrespondingData,strReadData
	Dim arrFinalData,arrAppData
	Dim strwarnData,NotifyDate,strlen,strDay,strRequiredAttributes
	Dim iAttrCounter 
	Dim strRequiredData:strRequiredData=""

	Wait 3
	Set oDesc = Description.Create()
	oDesc("micclass").Value = "WebTable"
	oDesc("column names").Value = "Order Item.*"
	Set objPage = Browser("brwTaskDetails").Page("pgTaskDetailsPage")
	
	Set oDescReadOnly = Description.Create
	oDescReadOnly("micclass").Value = "WebElement"
	oDescReadOnly("innertext").Value = "Read Only Attributes"
	
	Set oElmReadOnlyAttrs = objPage.ChildObjects(oDescReadOnly)
	For iCount = 0 To oElmReadOnlyAttrs.Count - 1 Step 1
		If oElmReadOnlyAttrs.GetROProperty("height") > 0 Then
			blnReadOnlyAttr = True : Exit For '#iCount
		End If
	Next '#iCount

	If blnReadOnlyAttr Then
		Set objTables = objPage.ChildObjects(oDesc)
		For iCounter = 0 To objTables.Count - 1
			If objTables(iCounter).GetROProperty("height") > 0 Then
				Set objTable = objTables(iCounter)
				Set objReadOnlyTab = objTable.WebTable("cols:=4", "index:=0")
				Exit For
			End If
		Next

		blnWarnings = False
		strFinalData = ""
		arrSheetData = Split(strSheetData, ";")
		For iAttrCounter = LBound(arrSheetData) To UBound(arrSheetData)
			strAttributeName = Trim(arrSheetData(iAttrCounter))
			iRow = objReadOnlyTab.GetRowWithCellText(strAttributeName)
			If iRow <= 0 Then
				Call ReportLog("ReadOnly Attribute", "<B>" & strAttributeName & "</B> should be displayed in application", "Attribute is not displayed in application", "Warnings", True)
				blnWarnings = True
			Else
				strAttibuteValue = objReadOnlyTab.GetCellData(iRow, 3)
				Call ReportLog("ReadOnly Attribute", "<B>" & strAttributeName & "</B> should be displayed in application", "Attribute is displayed and found to be</BR>" & strAttributeName & " : " & strAttibuteValue, "Information", False)
				If strFinalData = "" Then
					strFinalData = strAttributeName
				Else
					strFinalData = strFinalData & ";" & strAttributeName
				End If
				
			End If
		Next

		arrFinalData = Split(strFinalData, ";")

		'To highlight mPDM sheet missmatch with Application displayed attrinutes 
		If Ubound(arrSheetData) <> Ubound(arrFinalData)Then
			Call ReportLog("Read Only Attribute Check", "mPDM Sheet has extracted below attributes</BR>" & strSheetData, "SI is not displaying all attributes </BR>" &_
										"Application is Displaying only <B>" & Ubound(arrAppData) + 1 &"</B> against <B>" & Ubound(arrFinalData) + 1 & "</B> of mPDM Sheet" &_
										"Matched Values - ", Join(arrFinalData, ";"),"Warnings", True)		
		End If
		'To Display Mismatch attribute count of Application and mPDM Sheet
		If UBound(arrSheetData) + 1 <> objReadOnlyTab.GetROProperty("rows") Then
			Call ReportLog("Read Only Attribute Check", "mPDM and application attribute count should match", "mPDM Sheet has <B>" & UBound(arrSheetData) + 1 & " </B>Attributes</BR>"&_
					"Application is displaying <B>" & objReadOnlyTab.GetROProperty("rows") & "</B> attributes", "Warnings", True)
		End If
	Else
		Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist", strData & strCorrespondingData & " No Value Found", "FAIL", False)
		Environment("Action_Result") = False
	End If
End Function

'###########################################################################################################################################
'								Function to Just verify the correspoding data is blank or not, if then make a log
'###########################################################################################################################################

Public Function fn_SI_VerifyReadOnlyAttributeNew(strData,strCorrespondingData)
   On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_VerifyReadOnlyAttributeNew =====")
	If  strCorrespondingData = "" Then
		Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist <B>", strData & " : " & "<B>" & strCorrespondingData & "</B>", "WARNING", False)
		blnFound = False
	Else
		Call ReportLog("Read Only Attribute Check", "Read OnlyAttribute should exist <B>", strData & " : " & "<B>" &  strCorrespondingData & "</B>", "PASS", True)
		blnFound = True
	End If
End Function

'###########################################################################################################################################
'												Function to Check whether the task was closed successfully or not
'###########################################################################################################################################

Public Function fn_SI_WorkFlowChildTaskCloseCheck(ByVal dTaskID, ByVal dChildTaskID)
	On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_WorkFlowChildTaskCloseCheck =====")
	Dim blnComplete : blnComplete = False
	Dim oDescRefresh
	
	Set oDescRefresh = Description.Create
	oDescRefresh("micclass").Value = "WebElement"
	oDescRefresh("class").Value = "ui-pg-div"
	oDescRefresh("innertext").Value = "Refresh"	
	
	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
	If Not blnResult Then
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 5
		'To Expand the Table
		If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
			strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
			If Trim(strRecords(1)) > 1 Then
				'objPage.WebList("lstRecordPerPage").Select CStr("80")
				objPage.WebList("lstRecordPerPage").Click
				CreateObject("WScript.Shell").SendKeys CStr("80")
				For intInnerCounter = 1 to 5
					objPage.WbfGrid("grdTaskGrid").RefreshObject
					If objPage.WbfGrid("grdTaskGrid").RowCount > 11 Then
						Exit For
					Else
						Wait 10
						objPage.WbfGrid("grdTaskGrid").RefreshObject
					End If
				Next
			End If
		End If
		
		intRow = objPage.WbfGrid("grdTaskGrid").fGetRowWithCellText(dChildTaskID, intTaskIDCol)
		strTaskStatus =  UCase(Trim(objPage.WbfGrid("grdTaskGrid").GetCellData(intRow, intTaskStatus)))
		If strTaskStatus = "COMPLETE" Then
			blnComplete = True
			Exit For
		Else
			Wait 30
			objPage.RefreshObject
			Set oRefreshElms = objPage.ChildObjects(oDescRefresh)
			For intRefreshCounter = 0 To oRefreshElms.Count - 1
				If CInt(oRefreshElms(intRefreshCounter).GetROProperty("height")) > 0 Then
					oRefreshElms(intRefreshCounter).Click
					Wait 10
					Exit For '#intRefreshCounter
				End If
			Next '#intRefreshCounter
			
			'With objPage.WebElement("class:=ui-pg-div","outertext:=Refresh", "index:=0")
			'	If .Exist(10) Then .Click
			'	Wait 10
			'End With
			
			If objPage.WebElement("html id:=load_TaskGrid","html tag:=DIV","innertext:=Loading\.\.\.", "index:=0").Exist(5) Then
				objPage.WebElement("html id:=load_TaskGrid","html tag:=DIV","innertext:=Loading\.\.\.", "index=0").WaitProperty "visible", False, 1000*60*3
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
'   	If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
'		strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
'		If Trim(strRecords(1)) > 10 Then
'			objPage.WebList("lstRecordPerPage").Select CStr("100")
'			For intCounter = 1 to 5
'				objPage.WebTable("tblTaskDetail").RefreshObject
'				If objPage.WebTable("tblTaskDetail").RowCount > 12 Then
'					Exit For
'				Else
'					Wait 10
'					objPage.WebTable("tblTaskDetail").RefreshObject
'				End If
'			Next
'		End If
'	End If
'End Function


Public Function fn_SI_ExpandTable()
   On Error Resume Next
	Call writeLogFile("===== Function Call ::: fn_SI_ExpandTable =====")
	If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
		strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
		If Trim(strRecords(1)) > 1 Then
			objPage.WebList("lstRecordPerPage").Click
			CreateObject("WScript.Shell").SendKeys CStr("80")
			'objPage.WebList("lstRecordPerPage").Select CStr("80")
			For intCounter = 1 to 5
				objPage.WbfGrid("grdTaskGrid").RefreshObject
				If objPage.WbfGrid("grdTaskGrid").RowCount > 11 Then
					Exit For
				Else
					Wait 10
					objPage.WbfGrid("grdTaskGrid").RefreshObject
				End If
			Next
		End If
	End If
End Function

'**********************************************************************************************************************************************************
'**********************************************************************************************************************************************************
Public Function  fn_SI_FetchTaskLineItemDetails(ByVal strTaskName, ByVal strLineItemName, ByVal dMPDMSheet,ByVal dSheetName)

	blnResult=False
	Dim dSheetPath
	Dim RowLineItem,ExcelCurrentRow,ExcelCurrentCol,NoOfExcelRows,NoOfExcelCols
	Dim ExcelCurrentCol1,strExcelData

	'Check for the existence of mPDM WorkBook
	If Not CreateObject("Scripting.FileSystemObject").FileExists(dMPDMSheet) Then
		Call ReportLog("mPDM WorkBook", "<B>" & dMPDMSheet & "</B> should exist", "<B>" & dMPDMSheet & "</B> doesn't exist", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	Set ExcelApp = CreateObject("Excel.Application")
	dSheetPath = dMPDMSheet
	'Make sure that you have created an excel file before exeuting the script. 
	'Use the path of excel file in the below code
	'Also make sure that your excel file is in Closed state
	ExcelApp.Workbooks.Open dSheetPath
	ExcelApp.Application.Visible = False
	ExcelApp.Application.DisplayAlerts = False
	'this is the name of  Sheet  in Excel file "qtp.xls"   where data needs to be entered 
	set MPDMsheet = ExcelApp.ActiveWorkbook.Worksheets (dSheetName)
		
	'Get the max row occupied in the excel file 
	NoOfExcelRows=MPDMsheet.UsedRange.Rows.Count
	
	'Get the max column occupied in the excel file 
	NoOfExcelCols=MPDMsheet.UsedRange.columns.count
	 
	'To read the data from the entire Excel file
    	blnResult=False
	Set oSearchTask = MPDMsheet.Cells.Find(Trim(strTaskName),,-4163, 1)
	If Not oSearchTask Is Nothing Then
		ExcelCurrentCol = oSearchTask.Column
		blnResult = True
	Else
		Call ReportLog("Find Task", "<B>" & strTaskName & "</B> task should exist in mPDM Sheet", "<B>" & strTaskName & "</B> task doesn't exist in mPDM Sheet", "FAIL", False)
		ExcelApp.ActiveWorkbook.Close(False)
		ExcelApp.Application.DisplayAlerts = True 
		ExcelApp.Quit
		Environment("Action_Result") = False : Exit Function
	End If

	'Search for Line Item Attribute Name and get the corresponding column number
	blnResult=False
	Set oSearchItem = MPDMsheet.Cells.Find("Line Item Attribute Name")
	If Not oSearchItem Is Nothing Then
		FetchLineItemCol = oSearchItem.Column
		ExcelCurrentRow = oSearchItem.Row + 1
		blnResult = True
	Else
		Call ReportLog("Find Line Item Attribute Name", "<B>Line Item Attribute Name</B> should exist in mPDM Sheet", "<B>Line Item Attribute Name</B> doesn't exist in mPDM Sheet", "FAIL", False)
		ExcelApp.ActiveWorkbook.Close(False)
		ExcelApp.Application.DisplayAlerts = True 
		ExcelApp.Quit
		Environment("Action_Result") = False : Exit Function
	End If

	blnResult=False
	Set oSearchItem = MPDMsheet.Cells.Find("Line Item")
	If Not oSearchItem Is Nothing Then
		intLineItemCol = oSearchItem.Column
		blnResult = True
	Else
		Call ReportLog("Find Line Item Attribute Name", "<B>Line Item Attribute Name</B> should exist in mPDM Sheet", "<B>Line Item Attribute Name</B> doesn't exist in mPDM Sheet", "FAIL", False)
		ExcelApp.ActiveWorkbook.Close(False)
		ExcelApp.Application.DisplayAlerts = True 
		ExcelApp.Quit
		Environment("Action_Result") = False : Exit Function
	End If
	
	strData = "" : strExcelData = ""
	If  blnResult = True Then	
		For  RowLineItem = ExcelCurrentRow to NoOfExcelRows	 
			strAttributeType = Trim(ExcelApp.WorkSheetFunction.Clean(MPDMsheet.cells(RowLineItem,ExcelCurrentCol).value))
			strActualLineItem = Trim(ExcelApp.WorkSheetFunction.Clean(MPDMsheet.cells(RowLineItem,intLineItemCol).Value))
			If Trim(strLineItemName) = strActualLineItem Then
				If strAttributeType = "ReadOnly" Then
					strLineItemAttributeName = Trim(ExcelApp.WorkSheetFunction.Clean(MPDMsheet.cells(RowLineItem, FetchLineItemCol).value))
					strData= strData & strLineItemAttributeName & ";"
				End If
			End If
			'If Trim(MPDMsheet.cells(RowLineItem,ExcelCurrentCol).value) = "ReadOnly" And strLineItemName = Trim(MPDMsheet.cells(RowLineItem,intLineItemCol).value) Then
			'	strData=strData&MPDMsheet.cells(RowLineItem,FetchLineItemCol).value &";"
			'End if
		Next
		If strData <> "" Then strExcelData = Mid(strData,1,Len(strData)-1)	
	End If
	
	'Close the Workbook
	ExcelApp.ActiveWorkbook.Close(False)
	ExcelApp.Application.DisplayAlerts = True 
	'Close Excel
	ExcelApp.Application.Quit
	Set MPDMsheet =nothing
	Set ExcelApp = nothing
	fn_SI_FetchTaskLineItemDetails=strExcelData
End Function
'===========================================================================================================================================================
' Description: Check Order is Completed or Not
'===========================================================================================================================================================
'Private Function fn_SI_CheckOrderClosure()
'	With Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblOrderDetail")
'		If .Exist Then
'			intStatRow = .RowCount
'			For iRow = 1 to intStatRow
'				intCol = .ColumnCount(iRow)
'				For iCol = 1 to intCol
'					strData = Trim(.GetCellData(iRow, iCol))
'					If strData = "Order Status :" Then
'						strStatus = UCase(Trim(.GetCellData(iRow, iCol + 1)))
'						If strStatus = "COMPLETE" Then
'							Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblOrderDetail").HighLight
'							Call ReportLog("Order Closure on SI+", "Order should be closed on SI+", "Order is closed on SI+", "PASS", True)
'							Environment("Action_Result") = True
'							Exit Function
'						Else
'							Call ReportLog("Task Completion", "All tasks should be completed or closed", "New Task is not arrived", "FAIL", True)
'							Environment("Action_Result") = False
'							Exit Function
'						End If
'					End If
'				Next '#iCol
'			Next '#iRow
'		End If
'	End With
'End Function

'================================================================================================================================================================

Public Function fn_SI_SetTaskValues(ByVal dItemName, ByVal dGrpCACLimit, ByVal dTGrpCACLimit, ByVal dTCACLimit, ByVal dTCACBandwidthLimit)
	On Error Resume Next
		Call writeLogFile("===== Function Call ::: fn_SI_CheckReadOnlyValues =====")
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
						Environment("Action_Result") = False : Exit Function
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

'==================================================================================================================================================================

'==================================================================================================================================================================
Private Function fn_SI_GetTrunkTable(ByVal Text, ByRef oTable)
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

'==================================================================================================================================================================

'==================================================================================================================================================================
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


'Line 355
		
'		intRow = objTable.RowCount
'		For iRow = 1 to intRow
'			intCol = objTable.ColumnCount(iRow)
'			For iCol = 1 to intCol
'				strData = UCase(objTable.GetCellData(iRow, iCol))
'				strReadData=Mid(strData,1,20)
'				arrFinalData=Split(strSheetData,";")
'		
'				If Instr(strData,"READ ONLY ATTRIBUTES") > 0  Then
'					strCorrespondingData = objTable.GetCellData(iRow, iCol)
'					If Trim(strExpTaskName)=Ucase("Notify Customer Service is Ready") then
'						strwarnData=Split(strData,"NOTIFY CUSTOMER SERVICE READY DATE")
'						NotifyDate=Mid(strwarnData(1),2,11)
'						strlen=Len(day(Date))
'						If strlen<2 Then
'							strDay="0"&day(Date)
'						End If
'		
'						If NotifyDate >Trim( Ucase(left(Monthname(month(Date)),3))&"-"&strDay &"-"&year(Date)) then
'							Call ReportLog("Read Only Attribute Check", "Check Read Only attribute for <B>" & "NOTIFY CUSTOMER SERVICE READY DATE" & "</B>", "Checking Read Only attribute for <B>" & "NOTIFY CUSTOMER SERVICE READY DATE : "&NotifyDate& "</B>", "INFORMATION", False)
'						End IF
'					End IF
'					strValuesFound = ""
'					For intChkData=Lbound(arrFinalData) to Ubound(arrFinalData)
'						If Instr(strCorrespondingData, arrFinalData(intChkData)) > 0 Then											
'							strRequiredData = strRequiredData & arrFinalData(intChkData) & ";"
'							strValuesFound = arrFinalData(intChkData) & ";"
'						End If
'						strRequiredAttributes = Mid(strRequiredData,1,len(strRequiredData)-1)
'						arrAppData = Split(strRequiredAttributes,";")
'					Next
'
'					For intChkData= Lbound(arrFinalData) to Ubound(arrFinalData)
'						strDigitData=Split(strCorrespondingData,arrFinalData(intChkData))
'						strDigit=Split(strDigitData(1),"N")
'						If Instr(strCorrespondingData,arrFinalData(intChkData))>0Then
'							Call fn_SI_VerifyReadOnlyAttributeNew(strReadData,arrFinalData(intChkData) & strDigit(0))
'						Else
'							Call fn_SI_VerifyReadOnlyAttributeNew(strReadData,arrFinalData(intChkData) & strDigit(0))
'						End If
'					Next
'
'					
'
'				End If
'			Next
'		Next
