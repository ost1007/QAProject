'=============================================================================================================
'Description: To close the Task
'History	  : Name							Date			Version
'Created By	 :  BT Test Automation Tema			09/10/2014 	v1.0
'Example: fn_SI_GSWorkFlowTaskClosureTreeView(OrderID, EIN, mPDMSheet,SheetName)
'=============================================================================================================
Function fn_SI_GSWorkFlowTaskClosureTreeView(ByVal OrderID, ByVal EIN, ByVal mPDMSheet,ByVal SheetName)
		
		'Variable Declaration
		Dim intCounter, iNewTaskRow
		Dim blnTaskReady, blnContinue

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

				'Calling Function to Search Child Task
				blnContinue = fn_SI_WorkFlow_SearchChildTask(OrderID, dTaskID)
					If Not Environment("Action_Result") Then Exit Function
				
				'Terminate the Function
				If Not blnContinue Then
					Call fn_SI_CheckOrderClosure()
					Exit Function
				End If
			End If

			If Instr(UCase(Browser("creationtime:=0").Page("title:=.*").WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext")), "WORKFLOW CONTROLLER") = 0 Then
				'Override the Task ID
				Call fn_SI_WorkFlowOverride(dTaskID, EIN)
					If Not Environment("Action_Result") Then Exit Function
			End If
			
			'Logic for Closing Task will be Put here 'changes made to the function
			Call fn_SI_WorkFlowTaskCloseTreeView(OrderID, dTaskID, mPDMSheet, SheetName)
				If Not Environment("Action_Result") Then Exit Function

			'To Check if Task is Complete or Not
			If fn_SI_WorkFlowChildTaskCloseCheck(OrderID, dTaskID) Then
				Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is closed successfully", "PASS", True)
				Environment("Action_Result") = True
			Else
				Call ReportLog("Task Closure", dTaskID & " should be closed", dTaskID & " is not closed after 5 mins", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If

			iNewTaskRow = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("grdTaskGrid").fGetRowWithCellText("Open", intTaskStatus)
			If iNewTaskRow > 0 Then
				dTaskID = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("grdTaskGrid").GetCellData(iNewTaskRow, intTaskIDCol)
				strTaskName = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("grdTaskGrid").GetCellData(iNewTaskRow, intTaskNameCol)
				Call ReportLinerMessage("<B>" & dTaskID & " - " & strTaskName & "</B> is generated")
				blnTaskReady = True
			Else
				blnTaskReady = False
			End If
		Loop Until (Not blnContinue OR intCounter >= 25)
End Function

'###########################################################################################################################################
'								Function to close the task
'###########################################################################################################################################
Function fn_SI_WorkFlowTaskCloseTreeView(ByVal OrderID, ByVal TaskID, ByVal mPDMSheet, ByVal SheetName)
	Reporter.ReportNote "Function Execution - [[fn_SI_WorkFlowTaskCloseTreeView]]"
	'Variable Declartion
	Dim intCounter, iCounter
	Dim strRecords, strTaskName, strTaskOwnerName, strImageSrc, strWelComeUser
	Dim objLink
	Dim oToggleDesc, oTreeElementDesc, oTreeViewElements
	Dim elmToggle, elmTreeItemHeader
	Dim oTreeViewEle
	
	strWelcomeUser = UCase(Browser("creationtime:=0").Page("title:=.*").WebElement("class:=header_right rfloat welcome_user", "index:=0").GetROProperty("innertext"))
	
	'Skip the Search Order Again if the User is Workflow Controller
	If Instr(strWelcomeUser, "WORKFLOW CONTROLLER") = 0 Then
		blnResult = BuildWebReference("brwSIMain", "pgSIMain", "")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Call fn_SI_WorkFlowSearchOrder(OrderID) 
			If Not Environment("Action_Result") Then Exit Function
		Call fn_SI_ToggleTaskDetail() 
			If Not Environment("Action_Result") Then Exit Function
	End if
	
	For intCounter = 1 To 5
		blnExist = Browser("brwSIWorkflow").Page("pgSIWorkflow").Exist(30)
		If blnExist Then Exit For
	Next
	
	blnResult = BuildWebReference("brwSIWorkflow", "pgSIWorkflow", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	''To Expand the Table
	'If objPage.WebElement("elmRecordsPerPage").Exist(5) Then
	'	strRecords = Split(UCase(objPage.WebElement("elmRecordsPerPage").GetROProperty("innertext")), "OF")
	'	If Trim(strRecords(1)) > 10 Then
	'		objPage.WebList("lstRecordPerPage").Select CStr("100")
	'		For intCounter = 1 to 5
	'			objPage.WbfGrid("grdTaskGrid").RefreshObject
	'			If objPage.WbfGrid("grdTaskGrid").RowCount > 12 Then
	'				Exit For
	'			Else
	'				Wait 10
	'				objPage.WbfGrid("grdTaskGrid").RefreshObject
	'			End If
	'		Next
	'	End If
	'End If
	
	Browser("brwSIWorkflow").Page("pgSIWorkflow").Sync

	'Skip this step if Workflow Controller is closing the task
	If Instr(strWelcomeUser, "WORKFLOW CONTROLLER") = 0 Then
		For intCounter = 1 to 20
			intRow = objPage.WbfGrid("grdTaskGrid").fGetRowWithCellText(TaskID, 5)
			strTaskOwnerName =  Trim(objPage.WbfGrid("grdTaskGrid").GetCellData(intRow, intTaskOwnerCol))
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
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	Browser("brwSIWorkflow").Page("pgSIWorkflow").Sync
	Wait 2
	objPage.WbfGrid("grdTaskGrid").RefreshObject
	
	intRow = objPage.WbfGrid("grdTaskGrid").fGetRowWithCellText(TaskID, intTaskIDCol)
	strTaskName =  Trim(objPage.WbfGrid("grdTaskGrid").GetCellData(intRow, intTaskNameCol))
	Set objLink = objPage.WbfGrid("grdTaskGrid").ChildItem(intRow, intTaskIDCol, "Link", 0)

	If objLink.Exist Then
		objLink.HighLight
		objLink.Click
	End If

	For intCounter = 1 to 5
		blnExist = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebButton("btnCloseTask").Exist(60)
		If blnExist Then
			Exit For
		End If
	Next

	blnResult = BuildWebReference("brwTaskDetails", "pgTaskDetailsPage", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	objBrowser.fMaximize

	blnResult = clickImage("imgToggleOrderItemList")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 3
	
	' = = = = = = = = = = = = = = = = = = = = = = Logic To work with jqTree = = = = = = = = = = = = = = = = = = = = = =
	
	Set oTreeViewEle = objPage.WebElement("html id:=tree1", "index:=0")
	If Not oTreeViewEle.Exist(60) Then
		Call ReportLog("TreeView", "TreeView Element Properties have been changed", "Contact Automation Team</BR> fn_SI_WorkFlowTaskCloseTreeView", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Set oToggleDesc = Description.Create
	Set oTreeElementDesc = Description.Create
	Set oImageDesc = Description.Create
	
	oTreeElementDesc("micclass").Value = "WebElement"
	oTreeElementDesc("class").Value = "jqtree-element jqtree_common"
	Set oTreeViewElements = oTreeViewEle.ChildObjects(oTreeElementDesc)
	
	oImageDesc("micclass").Value = "Image"
	oImageDesc("file name").Value = "GreenTick2\.png|GreenTick2Disabled\.png|RedCross2\.png"
	Set oImages = oTreeViewEle.ChildObjects(oImageDesc)
	
	For iCounter = 0 To oTreeViewElements.Count - 1
		Set elmTreeView = oTreeViewElements(iCounter)
		'Get the Image details of Line Items
		'strImageSrc = elmTreeView.Image("index:=0").GetROProperty("file name")
		strImageSrc = oImages(iCounter).GetROProperty("file name")
		'Description for Toggling
		oToggleDesc("micclass").Value = "WebElement"
		oToggleDesc("class").Value = "jqtree_common jqtree-toggler|jqtree_common jqtree-toggler jqtree-closed"
		Set elmToggle = elmTreeView.ChildObjects(oToggleDesc)
		If elmToggle.Count = 1 Then
			If elmToggle(0).GetROProperty("class") = "jqtree_common jqtree-toggler jqtree-closed" Then
				elmToggle(0).HighLight
				elmToggle(0).Click
				Wait 2
			End If
		End If
		
		Set elmTreeItemHeader = oTreeViewEle.WebElement("class:=jqtree-title jqtree_Header", "html tag:=span", "index:=" & iCounter)
		'Set elmTreeItemHeader = oTreeViewElements(iCounter).WebElement("class:=jqtree-title jqtree_Header", "html tag:=span", "index:=0")
		If elmTreeItemHeader.Exist(60) Then
			LineItem = elmTreeItemHeader.GetROProperty("innertext")
			elmTreeView.Click
		Else
			Call ReportLog("Child Elements > TreeView", "Child Elements > TreeView Properties have been changed", "Contact Automation Team</BR> fn_SI_WorkFlowTaskCloseTreeView", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		'Handling Whether an updatable attributes are there or not
		Select Case strImageSrc
			Case "GreenTick2.png", "GreenTick2Disabled.png"
				'Function Call which starts verifying the ReadOnly attributes and updates mandatory attributes
				Call fn_SI_VerifyLineItemsTreeView(strTaskName, LineItem, strImageSrc, mPDMSheet, SheetName)
					If Not Environment("Action_Result") Then Exit Function
				
			Case "RedCross2.png"
					
					Select Case Trim(strTaskName)
								
							Case "Provide Trunk Group Friendly Name (OCC Contract)"							
									'Function Call which starts verifying the ReadOnly attributes and updates mandatory attributes
									Call fn_SI_VerifyLineItemsTreeView(strTaskName, LineItem, strImageSrc, mPDMSheet, SheetName)
										If Not Environment("Action_Result") Then Exit Function
										
									'Get Attributes
									GrpCACLimit = GetAttributeValue("dGrpCACLimit")
									TGrpCACLimit = GetAttributeValue("dTGrpCACLimit")
									TCACLimit = GetAttributeValue("dTCACLimit")
									TCACBandwidthLimit = GetAttributeValue("dTCACBandwidthLimit")	
									Call fn_SI_UpdateMandateValues(LineItem, GrpCACLimit, TGrpCACLimit, TCACLimit, TCACBandwidthLimit)
										If Not Environment("Action_Result") Then Exit Function
									
									'Update is Valid only for TrunkGroup and Trunk LineItem
									If LineItem <> "One Cloud Cisco"  Then
											'Click on Update button
											blnResult = clickButton("btnUpdate")
												If Not blnResult Then Environment("Action_Result") = False : Exit Function
											
											Wait 30
											
											If objPage.Image("imgToggleOrderItemList").Exist(5) Then
												If objPage.Image("imgToggleOrderItemList").GetROProperty("file name") = "expand.png" Then
													objPage.Image("imgToggleOrderItemList").Click : Wait 3
												End If
											End If
											
											'Call fn_SI_ExpandLineItems(iCounter)
											'Not sure on this - as Object Reference is lost when above function call is made - Nagaraj V
											Set oTreeViewElements = objPage.WebElement("html id:=tree1", "index:=0").ChildObjects(oTreeElementDesc)
											Set oTreeViewEle = objPage.WebElement("html id:=tree1", "index:=0")
											Set oImages = oTreeViewEle.ChildObjects(oImageDesc)
									End If
							
							Case "Handle Automation Failure-Deconfigure Switch Manager for Trunk - OCC", "Handle Automation Failure-Deconfigure Switch Manager for Trunk Group - OCC",_
								"Handle Automation Failure-Deconfigure Switch Manager (OCC Contract)"
									
									TGrpCACLimit = GetAttributeValue("dTGrpCACLimit")
									
									Call fn_SI_UpdateAutomationHandlerMandateValues(LineItem, TGrpCACLimit)
										If Not Environment("Action_Result") Then Exit Function
									
									Call fn_SI_ExpandLineItems(iCounter)
									'Not sure on this - as Object Reference is lost when above function call is made - Nagaraj V
									Set oTreeViewElements = objPage.WebElement("html id:=tree1", "index:=0").ChildObjects(oTreeElementDesc)
							
							Case Else
									If Instr(strTaskName, "Notify Customer Service is Ready") > 0 Then
											dtNCSR = Date + 7
											objPage.WbfGrid("grdNCSR").WebEdit("txtNotifyServiceReadyDate").Click
											Wait 2
											
											If Not objPage.WebElement("class:=ui-datepicker-month", "html tag:=SPAN", "index:=0").Exist(10) Then
												Call RepotLog("Date Picker", "Calendar should be Visible", "Calendar is not visible", "FAIL", True)
												Environment("Action_Result") = False : 
											End If
											strMonthDisplayed = objPage.WebElement("class:=ui-datepicker-month", "html tag:=SPAN", "index:=0").GetROProperty("innertext")
											strActualMonth = MonthName(Month(dtNCSR))
											If strMonthDisplayed <> strActualMonth Then
												If objPage.WebElement("class:=ui-icon ui-icon-circle-triangle-e","innertext:=Next", "index:=0").Exist Then
													objPage.WebElement("class:=ui-icon ui-icon-circle-triangle-e","innertext:=Next", "index:=0").Click
												Else
													Call ReportLog("Date Selection", "Month Selector Tab should be visible", "Month Selector is not visible", "FAIL", True)
													Environment("Action_Result") = False : Exit Function
												End If
											End If
											
											strDate = Day(dtNCSR)
											objPage.Link("html tag:=A","innerhtml:=" & strDate).Click
											
											'Click on Update Button
											blnResult = clickButton("btnUpdate")
												If Not blnResult Then Environment("Action_Result") = False : Exit Function
													
											Wait 30
											
											If objPage.Image("imgToggleOrderItemList").Exist(5) Then
												If objPage.Image("imgToggleOrderItemList").GetROProperty("file name") = "expand.png" Then
													objPage.Image("imgToggleOrderItemList").Click : Wait 3
												End If
											End If
											
											'Call fn_SI_ExpandLineItems(iCounter)
											'Not sure on this - as Object Reference is lost when above function call is made - Nagaraj V
											Set oTreeViewElements = objPage.WebElement("html id:=tree1", "index:=0").ChildObjects(oTreeElementDesc)
											Set oTreeViewEle = objPage.WebElement("html id:=tree1", "index:=0")
											Set oImages = oTreeViewEle.ChildObjects(oImageDesc)
									Else
											Call ReportLog("New Task Encountered", "Scripting has not been completed to update task - " & strTaskName, "Contact Automation Team", "FAIL", True)
											Environment("Action_Result") = False : Exit Function
									End If
					End Select
			
		End Select '#strImageSrc
	Next '#iCounter
	
	'Click on Close Task
	blnResult = clickButton("btnCloseTask")
		If Not blnResult Then	Environment("Action_Result") = False : Exit Function

	For intCounter = 1 to 5
		blnExist = objPage.WebElement("elmCloseTask").Exist(10)
			If blnExist Then Exit For
	Next

	blnResult = clickButton("btnOK")
		If Not blnResult Then	Environment("Action_Result") = False : Exit Function
		
	blnFlagActionClosure = True
	For intCounter = 1 to 20
		blnExist = objPage.WebElement("elmTaskClosedSuccessfully").Exist(60)
		If blnExist Then
			Call ReportLog("Task Closure", "<B>" & strTaskName & " </B> should be closed successfully", "Task is closed Successfully", "PASS", True)
			objBrowser.Close
			Environment("Action_Result") = True : Exit Function
		End If
		
		blnRequiresActionClose = objPage.WebElement("elmActionClose").Exist(0)
		If blnRequiresActionClose AND blnFlagActionClosure Then
			TaskPageURL = objBrowser.GetROProperty("url")
			Call fn_SQE_ActionClosure(TaskPageURL)
				If Not Environment("Action_Result") Then Exit Function
			blnFlagActionClosure = False
			
			'Click on Close Task
			blnResult = clickButton("btnCloseTask")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			For intInnerCounter = 1 to 5
				blnExist = objPage.WebElement("elmCloseTask").Exist(10)
					If blnExist Then Exit For
			Next
		
			blnResult = clickButton("btnOK")
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
		End If
	Next

	Call ReportLog("Task Closure", "<B>" & strTaskName & " </B> should be closed successfully", "Task is not closed", "FAIL", True)
	Environment("Action_Result") = False
	
End Function

'###########################################################################################################################################
'									Verifies Line Items displayed in Application and mPDM Sheet
'###########################################################################################################################################
Function fn_SI_VerifyLineItemsTreeView(ByVal TaskName, Byval LineItemName, ByVal ImageSrc, ByVal mPDMSheet, ByVal SheetName)
	Reporter.ReportNote "Function Execution - [[fn_SI_VerifyLineItemsTreeView]]"
	Dim arrLineItems
	Dim strLineItemName, strReadOnlyAttr
	Dim intActualReadOnlyAttrCnt, intmPDMReadOnlyAttrCount 
	Dim arrReadOnlyAttr
	
	'Variable Initialization
	intActualReadOnlyAttrCnt = 0
	intmPDMReadOnlyAttrCount = 0
	
	blnResult = BuildWebReference("brwTaskDetails", "pgTaskDetailsPage", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Call ReportLinerMessage("Read Only Attribute Check for Line Item - <B>" & LineItemName & "</B>")
	'Function Call to Get the Read Only Attributes from mPDM Sheet
	strReadOnlyAttr = fn_SI_FetchTaskLineItemDetails(TaskName, LineItemName, mPDMSheet, SheetName)
		If Not Environment("Action_Result") Then Exit Function 'Exit If mPDM Sheet has errors
		
	If strReadOnlyAttr <> "" Then
		arrReadOnlyAttr = Split(strReadOnlyAttr, ";")
		intmPDMReadOnlyAttrCount = UBound(arrReadOnlyAttr) + 1
	Else
		If objPage.WbfGrid("grdReadOnlyAttribute").Exist(0) Then
			If Trim(objPage.WbfGrid("grdReadOnlyAttribute").GetROProperty("text")) = "" Then
				'Exit the Function If there exists a table and no text present inside the GRID
				Call ReportLog("Line Item Check", "No Read Only Attributes should be displayed for <B>" & LineItemName & "</B>", "No Read only attributes are displayed", "Information", False)
				Exit Function '#fn_SI_VerifyLineItemsTreeView
			Else
				objPage.WbfGrid("grdReadOnlyAttribute").HighLight : Wait 2
				intActualReadOnlyAttrCnt = objPage.WbfGrid("grdReadOnlyAttribute").RowCount	 - 1
				Call ReportLog("ReadOnly Attr Check", "mPDM Sheet has no attributes against <B> " & LineItemName & "</B>", "Application is displaying <B>[" & intActualReadOnlyAttrCnt & "]</B>", "FAIL", True)
				Exit Function '#fn_SI_VerifyLineItemsTreeView
			End If
		Else
			'Exit the Function If there is no read only attribute and Grid doesn't Exist
			Call ReportLog("Line Item Check", "No Read Only Attributes should be displayed for <B>" & LineItemName & "</B>", "No Read only attributes are displayed", "Information", False)
			Exit Function '#fn_SI_VerifyLineItemsTreeView
		End If
	End If
	
	'Function Call to Verify Read Only attributes displayed in application with mPDM Sheet
	Call fn_SI_CheckReadOnlyOrderLineItemAttributes(strReadOnlyAttr, LineItemName)

End Function


'###########################################################################################################################################
'									Returns Read only attribute from mPDM Sheets as a String
'###########################################################################################################################################
Public Function  fn_SI_FetchTaskLineItemDetails(ByVal strTaskName, ByVal strLineItemName, ByVal dMPDMSheet,ByVal dSheetName)
	Reporter.ReportNote "Function Execution - [[fn_SI_FetchTaskLineItemDetails]]"
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

'###########################################################################################################################################
'									Function to Check Read Only Attributes of mPDM Sheet and Application
'###########################################################################################################################################
Public Function fn_SI_CheckReadOnlyOrderLineItemAttributes(ByVal ReadOnlyAttributesData, ByVal LineItem)
	On Error Resume Next
	Reporter.ReportNote "Function Execution - [[fn_SI_CheckReadOnlyOrderLineItemAttributes]]"
	Dim arrReadOnlyAttributes, arrFinalData
	Dim iCounter, intHeight, intRows, iRow
	Dim strFinalData
	
	arrReadOnlyAttributes = Split(ReadOnlyAttributesData, ";")
	Set oWbfGrid = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WbfGrid("grdReadOnlyAttribute")
	strFinalData = ""
	
	BrowserHeight = Browser("brwTaskDetails").Object.document.body.clientHeight
	Browser("brwTaskDetails").object.document.parentwindow.scrollBy 0, BrowserHeight
	
	If Not oWbfGrid.Exist(30) And ReadOnlyAttributesData <> "" Then
		'intHeight = objBrowser.GetROProperty("height")
		'objBrowser.object.document.parentwindow.scrollBy 0, intHeight
		Call ReportLog("ReadOnly Attribute", "<B>" & ReadOnlyAttributesData & "</B> are to be checked", "Read Only Attribute table is only not displayed against <B>" & LineItem & "</B>", "FAIL", True)
		Exit Function
	End If
	
	For iCounter = LBound(arrReadOnlyAttributes) To UBound(arrReadOnlyAttributes)
		strReadOnlyAttribute = Trim(arrReadOnlyAttributes(iCounter))
		intRow = WbfGridGetRowWithCellText(oWbfGrid, strReadOnlyAttribute)
		If intRow > 0 Then
			strAttibuteValue = oWbfGrid.GetCellData(intRow, 2)
			strAttibuteValue2 = oWbfGrid.GetCellData(intRow, 3)
			If Trim(strAttibuteValue2) <> "" Then
				Call ReportLog("ReadOnly Attribute", "<B>" & strReadOnlyAttribute & "</B> should be displayed in application", "Attribute is displayed and found to be</BR>" & strReadOnlyAttribute & " : " & strAttibuteValue & " : " & strAttibuteValue2, "Information", False)
			Else
				Call ReportLog("ReadOnly Attribute", "<B>" & strReadOnlyAttribute & "</B> should be displayed in application", "Attribute is displayed and found to be</BR>" & strReadOnlyAttribute & " : " & strAttibuteValue, "Information", False)
			End If
			If strFinalData = "" Then
				strFinalData = strReadOnlyAttribute
			Else
				strFinalData = strFinalData & ";" & strReadOnlyAttribute
			End If
		Else
			Call ReportLog("ReadOnly Attribute", "<B>" & strReadOnlyAttribute & "</B> should be displayed in application", "Attribute is not displayed in application", "Warnings", True)
			blnWarnings = True
		End If
		
	Next '#iCounter
	
	arrFinalData = Split(strFinalData, ";")
	
	'To highlight mPDM sheet missmatch with Application displayed attrinutes 
	If Ubound(arrReadOnlyAttributes) <> Ubound(arrFinalData)Then
		Call ReportLog("Read Only Attribute Check", "mPDM Sheet has extracted below attributes</BR>" & ReadOnlyAttributesData, "SI is not displaying all attributes </BR>" &_
									"Application is Displaying only <B>" & Ubound(arrFinalData) + 1 &"</B> against <B>" & Ubound(arrReadOnlyAttributes) + 1 & "</B> of mPDM Sheet" &_
									"Matched Values - " & Join(arrFinalData, ";"),"Warnings", True)		
	End If
	
	Reporter.Filter = rfDisableAll
	intRows = 0
	If oWbfGrid.Exist(0) Then
		For iRow = 1 To oWbfGrid.RowCount
			If Trim(oWbfGrid.GetCellData(iRow, 1)) <> "" Then
				intRows = intRows + 1
			End If
		Next
	End If
	Reporter.Filter = rfEnableAll
	
	'To Display Mismatch attribute count of Application and mPDM Sheet
	If UBound(arrReadOnlyAttributes) + 1 <> intRows Then
		Call ReportLog("Read Only Attribute Check", "mPDM and application attribute count should match", "mPDM Sheet has <B>" & UBound(arrReadOnlyAttributes) + 1 & " </B>Attributes</BR>"&_
				"Application is displaying <B>" & intRows & "</B> attributes", "Warnings", True)
		Call ReportLinerMessage("mPDM Sheet consists of <B> " & ReadOnlyAttributesData & "</B> as read only attribute")
		Call ReportLinerMessage("<TABLE>" & oWbfGrid.GetROProperty("innerHTML") & "</TABLE>")
	End If
	
End Function


'###########################################################################################################################################
'									Function to Simulate GetRowWithCellText for WbfGrid
'###########################################################################################################################################
Public Function WbfGridGetRowWithCellText(ByVal GridObject, ByVal CellData)
	Reporter.Filter = rfDisableAll
	Dim intRows, intColumns
	Dim strCapturedCellData 
	
	WbfGridGetRowWithCellText = -1
	If Not GridObject.Exist(0) Then Exit Function
	
	intRows = GridObject.RowCount
	For iRow = 1 To intRows
		intColumns = GridObject.ColumnCount(iRow)
		For iCol = 1 To intColumns
			strCapturedCellData =GridObject.GetCellData(iRow, iCol)
			If strCapturedCellData = CellData Then
				WbfGridGetRowWithCellText = iRow
				Reporter.Filter = rfEnableAll
				Exit Function
			End If
		Next
	Next
	Reporter.Filter = rfEnableAll
End Function

'###########################################################################################################################################
'									Function to update mandate values for Line Items containing Mandatory attributes
'###########################################################################################################################################
Public Function fn_SI_UpdateMandateValues(ByVal LineItem, ByVal GrpCACLimit, ByVal TGrpCACLimit, ByVal TCACLimit, ByVal TCACBandwidthLimit)
	Reporter.ReportNote "Function Execution - [[fn_SI_UpdateMandateValues]]"
	On Error Resume Next
		Call writeLogFile("===== Function Call ::: fn_SI_UpdateMandateValues =====")
		Dim intRow, iRow, iCol, intCol
		Dim strAttributeName
		Dim blnFound
		
		Set oGrdMandateAttribute = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WbfGrid("grdMandateAttributes")
	
		Call ReportLog("Mandate Values", "Update Line Items Attributes<B>" & LineItem & "</B>", "Update Line Items Attributes <B>" & LineItem & "</B>", "INFORMATION", False)
	
		Select Case Trim(LineItem)
		
			Case "Trunk Group - OCC"
					strAttributeName = "GROUP CAC LIMIT"
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, GrpCACLimit
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(GrpCACLimit) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & GrpCACLimit & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & GrpCACLimit & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If
					
					strAttributeName = "TRUNKGROUP CAC LIMIT"
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, TGrpCACLimit
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(TGrpCACLimit) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TGrpCACLimit & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TGrpCACLimit & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If

			Case "Trunk - OCC"
					
					'Setting TRUNK CAC LIMIT
					strAttributeName = "TRUNK CAC LIMIT"
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, TCACLimit
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(TCACLimit) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TCACLimit & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TCACLimit & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If
					
					'Setting up TRUNK CAC BANDWITH LIMIT
					strAttributeName = "TRUNK CAC BANDWIDTH LIMIT"
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, TCACBandwidthLimit
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(TCACBandwidthLimit) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TCACBandwidthLimit & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TCACBandwidthLimit & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If
					
					'Setting up HCS_FRIENDLY_TRUNK_ID					
					strAttributeName = "HCS_FRIENDLY_TRUNK_ID"
					strHCSFriendlyName = "AUT" & Replace(Replace(Replace(Now, "/", ""),":","")," ","")
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, strHCSFriendlyName
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(strHCSFriendlyName) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & strHCSFriendlyName & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & strHCSFriendlyName & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If
		End Select '#LineItem
End Function


'###########################################################################################################################################
'				Function to update mandate values for Line Items containing Mandatory attributes of Automation Handler Failure Tasks
'###########################################################################################################################################

Public Function fn_SI_UpdateAutomationHandlerMandateValues(ByVal LineItem, ByVal TGrpCACLimit)
	Reporter.ReportNote "Function Execution - [[fn_SI_UpdateAutomationHandlerMandateValues]]"
	On Error Resume Next
		Call writeLogFile("===== Function Call ::: fn_SI_UpdateAutomationHandlerMandateValues =====")
		Dim intRow, iRow, iCol, intCol
		Dim strAttributeName
		Dim blnFound
		
		Set oGrdMandateAttribute = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WbfGrid("grdMandateAttributes")
	
		Call ReportLog("Automation Handler", "Update Automation Handler Line Items <B>" & LineItem & "</B>", "Update Automation Handler Line Items <B>" & LineItem & "</B>", "INFORMATION", False)
		
		'Setting ACTION REQUIRED
		strAttributeName = "ACTION REQUIRED"
		intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
		If intRow <= 0 Then
			Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
			Environment("Action_Result") = False : Exit Function
		Else
			Set objActionRequired = oGrdMandateAttribute.ChildItem(intRow, 2, "WebList", 0)
			objActionRequired.Select "Complete"
			
			If CStr(objActionRequired.GetROProperty("selection")) = "Complete" Then
				Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>Complete</B> has been set successfully", "INFORMATION", False)	
			Else
				Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>Complete</B> has been set successfully", "FAIL", True)	
				Environment("Action_Result") = False : Exit Function
			End If
		End If
		
	
		Select Case Trim(LineItem)
			
			Case "One Cloud Cisco"
					strAttributeName = "TRUNKGROUP CAC LIMIT"
					intRow = WbfGridGetRowWithCellText(oGrdMandateAttribute, strAttributeName)
					If intRow <= 0 Then
						Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", strAttributeName & " is not displayed to set the value in Mandate Table", "FAIL", True)	
						Environment("Action_Result") = False : Exit Function
					Else
						oGrdMandateAttribute.SetCellData intRow, 2, TGrpCACLimit
						If CStr(oGrdMandateAttribute.GetCellData(intRow, 2)) = CStr(TGrpCACLimit) Then
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TGrpCACLimit & "</B> has been set successfully", "INFORMATION", False)	
						Else
							Call ReportLog("Set Value", "Setting value to task <B>" & strAttributeName & "</B>", "Value <B>" & TGrpCACLimit & "</B> has been set successfully", "FAIL", True)	
							Environment("Action_Result") = False : Exit Function
						End If
					End If
					
					'Click on Update Button
					blnResult = clickButton("btnUpdate")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
							
					Wait 30
							
					If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Exist(5) Then
						If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").GetROProperty("file name") = "expand.png" Then
							Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Click : Wait 3
						End If
					End If
					
			Case "Trunk - OCC", "Trunk Group - OCC"
			
					'Click on Update Button
					blnResult = clickButton("btnUpdate")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
							
					Wait 30
							
					If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Exist(5) Then
						If Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").GetROProperty("file name") = "expand.png" Then
							Browser("brwSITaskDetails").Page("pgSITaskDetails").Image("imgExpandOrderItemList").Click : Wait 3
						End If
					End If
					
			Case Else
					Call ReportLog("Automation Handler", "Automation Handler has encountered with new Line Item", "Please contact Automation Team", "Warnings", True)
					Environment("Action_Result") = False : Exit Function
		End Select '#LineItem
	
End Function
'###########################################################################################################################################
'								Function to Expand the Line Items as after update the Order Item List gets closed
'###########################################################################################################################################
Public Function fn_SI_ExpandLineItems(ByVal Counter)
	Dim iCounter
	Dim oToggleDesc, oTreeElementDesc, oTreeViewElements
	Dim elmTreeView, elmToggle
	
	Set oToggleDesc = Description.Create
	Set oTreeElementDesc = Description.Create
	
	oTreeElementDesc("micclass").Value = "WebElement"
	oTreeElementDesc("class").Value = "jqtree-element jqtree_common"
	Set oTreeViewElements = Browser("brwTaskDetails").Page("pgTaskDetailsPage").WebElement("html id:=tree1", "index:=0").ChildObjects(oTreeElementDesc)
	
	For iCounter = 0 To Counter
		Set elmTreeView = oTreeViewElements(iCounter)
		'Description for Toggling
		oToggleDesc("micclass").Value = "WebElement"
		oToggleDesc("class").Value = "jqtree_common jqtree-toggler|jqtree_common jqtree-toggler jqtree-closed"
		Set elmToggle = elmTreeView.ChildObjects(oToggleDesc)
		If elmToggle.Count = 1 Then
			If elmToggle(0).GetROProperty("class") = "jqtree_common jqtree-toggler jqtree-closed" Then
				elmToggle(0).HighLight
				elmToggle(0).Click
				Wait 2
			End If
		End If
	Next '#iCounter	
End Function

'###########################################################################################################################################
'								Function to Check for Order Completion
'###########################################################################################################################################
Private Function fn_SI_CheckOrderClosure()
	Dim intStatRow, intCol, iRow, iCol
	Dim strData, strStatus
	Reporter.ReportNote "Function Execution - [[fn_SI_CheckOrderClosure]]"
	Reporter.Filter = rfDisableAll
	With Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblOrderDetail")
		If .Exist Then
			intStatRow = .RowCount
			For iRow = 1 to intStatRow
				intCol = .ColumnCount(iRow)
				For iCol = 1 to intCol
					strData = Trim(.GetCellData(iRow, iCol))
					If strData = "Order Status :" Then
						strStatus = UCase(Trim(.GetCellData(iRow, iCol + 1)))
						If strStatus = "COMPLETE" Then
							Browser("brwSIWorkflow").Page("pgSIWorkflow").WebTable("tblOrderDetail").HighLight
							Reporter.Filter = rfEnableAll
							Call ReportLog("Order Closure on SI+", "Order should be closed on SI+", "Order is closed on SI+", "PASS", True)
							Environment("Action_Result") = True
							Exit Function
						Else
							Reporter.Filter = rfEnableAll
							Call ReportLog("Task Completion", "All tasks should be completed or closed", "New Task has not arrived", "Information", False)
							Environment("Action_Result") = False
							Exit Function
						End If
					End If
				Next '#iCol
			Next '#iRow
		End If
	End With
	Reporter.Filter = rfEnableAll
End Function

'###########################################################################################################################################
'								Function to Close the Action
'###########################################################################################################################################
Private Function fn_SQE_ActionClosure(ByVal TaskPageURL)
	If Browser("brwTaskDetails").Page("pgTaskDetailsPage").Image("imgTaskActionDetails").Exist(120) Then
		If Browser("brwTaskDetails").Page("pgTaskDetailsPage").Image("imgTaskActionDetails").GetROProperty("file name") = "expand.png" Then
			Browser("brwTaskDetails").Page("pgTaskDetailsPage").Image("imgTaskActionDetails").Click
		End If
	End If
	
	With Browser("brwTaskDetails").Page("pgTaskDetailsPage").WbfGrid("grdTaskActionDetails")
		If Not .Exist(60) Then
			Call ReportLog("Action Closure", "Task Action Details Table should exist", "Task Action Details Table doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		If Not .WaitProperty("rows", micGreaterThan(1), 1000*60*2) Then
			Call ReportLog("Action Closure", "Task Action Details Table should exist", "Task Action Details exists but data is not populated", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End if
		
		Set objActionLink = .ChildItem(2, 1, "WebElement", 0)
		If Not objActionLink.Exist(10) Then
			Call ReportLog("Action Closure", "ACTION_ID should exist", "Action ID doesn't exist to close the action", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Action Closure", "ACTION_ID should exist", "Action ID generated is " & objActionLink.GetROProperty("innertext"), "PASS", False)
		End If
		objActionLink.Click
		
	End With
	
	For iCounter = 1 To 5
		blnResult = Browser("brwUpdateActionDetails").Page("pgUpdateActionDetails").WebButton("btnClose").Exist(60)
			If blnResult Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("Update Action Details", "User should be navigated to Update Action Details", "User is not navigated to Update Action Details", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	With Browser("brwUpdateActionDetails").Page("pgUpdateActionDetails")
		For iCounter = 1 To 5
			.WebButton("btnClose").Click
			If .WebElement("elmActionCloseMsg").Exist(60) Then
				Exit For '#iCounter
			End If
		Next '#iCounter
		
		If Not .WebElement("elmActionCloseMsg").Exist(0) Then
			Call ReportLog("Action Closure", "Action Closure Message confirmation should exist", "Action Closure Message confirmation doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		If Not .WebButton("btnOK").Exist(0) Then
			Call ReportLog("Action Closure", "Action Closure Message confirmation should exist", "Action Closure Message confirmation doesn't exist with OK button", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			.WebButton("btnOK").Click
		End If
		
		If .WebElement("elmActionClosedSuccessfully").Exist(60*3) Then
			Call ReportLog("Action Closure", "Action should be closed", "Action is closed successfully", "PASS", True)
			Browser("brwUpdateActionDetails").Close
			'Browser("brwUpdateActionDetails").Navigate(TaskPageURL)
			
			For intCounter = 1 to 5
				If objPage.WebButton("btnCloseTask").Exist(60) Then Exit For
			Next '#intCounter
			Environment("Action_Result") = True
		Else
			Call ReportLog("Action Closure", "Action should be closed", "Action is closed successfully", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End With
End Function
