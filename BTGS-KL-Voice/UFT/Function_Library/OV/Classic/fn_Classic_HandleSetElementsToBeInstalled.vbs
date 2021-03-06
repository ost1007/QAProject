'Public Function fn_Classic_HandleSetElementsToBeInstalled()
'	
'	'Variable Declaration
'	Dim iRowm, intRows
'	Dim blnTaskFound : blnTaskFound = False
'	
'	'Wait for Window - Commercial Project
'	Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject")
'	Call waitForWindowControl(oWndControl, 60)
'	
'	'Build Amdocs Reference
'	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSales", "CommercialProject")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Select Tasks from WinTab
'	blnResult = selectItemFromWinTab("tbSubHeader", "Tasks")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 10
'	
'	'Wait For Installation Complete Text to appear
'	Set oWndControl = oParentWindow.Window("CommercialProject").WinButton("btnCreateEWO")
'	blnResult = waitForWindowControl(oWndControl, 60)
'	If Not blnResult Then 
'		Call ReportLog("Navigation", "Should be Navigated to CommercialProject Window", "Could not be navigated to CommercialProject Window", "FAIL", True)
'		Environment("Action_Result") = False 
'		Exit Function
'	Else
'		Call ReportLog("Navigation", "Should be Navigated to CommercialProject Window", "Navigated to CommercialProject Window", "Information", True)
'	End If
'	
'	With Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinTable("grdTasks")
'		intRows = .RowCount
'		For iRow = 1 To intRows
'			strTaskName = .GetCellData("#" & iRow, 3)
'			If Instr(UCase(strTaskName), "SET ELEMENTS TO INSTALLED") > 0 Then
'				.SelectRow "#" & iRow
'				Wait 5 : 	blnTaskFound = True
'				Exit For '#iRow
'			End If
'		Next '#iRow
'		
'		If Not blnTaskFound Then
'			Call ReportLog("Task Handle", "Set Elements to be installed task has to be handled", "Set Elements to be installed task could not be found", "FAIL", True)
'			Environment("Action_Result") = False : Exit Function
'		End If
'	End With
'	
'	
'	'Click on View Case
'	blnResult = clickChildWindowButton("btnViewCase")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Wait For SubCases button to appear to appear
'	Set oWndControl = Window("AmdocsCRM").Window("TaskCase").WinButton("btnSubcases")
'	blnResult = waitForWindowControl(oWndControl, 60)
'	If Not blnResult Then 
'		Call ReportLog("Navigation", "Should be Navigated to TaskCase Window", "Could not be navigated to TaskCase Window", "FAIL", True)
'		Environment("Action_Result") = False 
'		Exit Function
'	Else
'		Call ReportLog("Navigation", "Should be Navigated to TaskCase Window", "Navigated to TaskCase Window", "Information", True)
'	End If
'	
'	'Close Commercial Project Screen
'	Wait 30
'	Set oDescWindow = Description.Create
'	oDescWindow("micclass").Value = "Window"
'	Set oChildWindows = Window("regexpwndtitle:=Amdocs CRM.*").ChildObjects(oDescWindow)
'	If oChildWindows.Count > 0 Then
'		For iCounter = 0 To oChildWindows.Count - 1
'			If Instr(oChildWindows(iCounter).GetROProperty("text"), "Commercial Project") > 0 Then
'				oChildWindows(iCounter).Close
'				Wait 30
'				Exit For '#iCounter
'			End If
'		Next '#iCounter
'	End If
'
'	'Build Amdocs Reference
'	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "TaskCase")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	
'	'Click on View Case
'	blnResult = clickChildWindowButton("btnSubcases")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Wait For Open button to appear
'	Set oWndControl = oParentWindow.Window("SubcaseList").WinButton("btnOpen")
'	blnResult = waitForWindowControl(oWndControl, 60)
'	If Not blnResult Then 
'		Call ReportLog("Navigation", "Should be Navigated to SubcaseList Window", "Could not be navigated to SubcaseList Window", "FAIL", True)
'		Environment("Action_Result") = False 
'		Exit Function
'	Else
'		Call ReportLog("Navigation", "Should be Navigated to SubcaseList Window", "Navigated to SubcaseList Window", "Information", True)
'	End If
'	
'	Wait 15
'	'Close Case
'	If Window("AmdocsCRM").Window("TaskCase").Exist(10) Then
'		Window("AmdocsCRM").Window("TaskCase").Close
'		Wait 30
'	End If
'
'	'Build Amdocs Reference
'	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "SubcaseList")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	blnTaskFound = False
'	With oChildWindow.WinTable("grdSubCases")
'		If Not .Exist(60) Then
'			Call ReportLog("SubCases List", "SubCases list Grid should exist", "SubCases List Grid doesn't exist", "FAIL", True)
'			Environment("Action_Result") = False : Exit Function
'		End If
'		intRows = .RowCount
'		For iRow = 1 To intRows
'			strTaskName = .GetCellData("#" & iRow, "#2")
'			If Instr(UCase(strTaskName), "SET ELEMENTS TO INSTALLED") Then
'				.SelectRow "#" & iRow
'				Wait 5 : 	blnTaskFound = True
'				Exit For '#iRow
'			End If
'		Next '#iRow
'		
'		If Not blnTaskFound Then
'			Call ReportLog("Task Handle", "Set Elements to be installed task has to be handled", "Set Elements to be installed task could not be found on SubCase List", "FAIL", True)
'			Environment("Action_Result") = False : Exit Function
'		End If
'	End With
'	
'	If Not oChildWindow.WinButton("btnOpen").WaitProperty("enabled", True, 1000*60*2) Then
'		Call ReportLog("Open Button", "Open Button should be enabled on selection of subcase", "Open button is disabled on selection of subcase", "FAIL", True)
'		Environment("Action_Result") = False : Exit Function
'	End If
'	
'	'Click on Open
'	blnResult = clickChildWindowButton("btnOpen")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 5
'	
'	With Dialog("dlgAmdocsCRM")
'		Do
'			If .Exist(60) Then     .WinButton("btnOK").Click
'		Loop While .Exist(60)
'	End With
'
'	'Wait For Open Task button to appear
'	With Window("AmdocsCRM-ClearSupport")
'		Set oWndControl = .Window("ReadSubcase").WinButton("btnOpenTask")
'		blnResult = waitForWindowControl(oWndControl, 60)
'		If Not blnResult Then
'			Call ReportLog("Navigation", "Should be Navigated to ReadSubcase Window", "Could not be navigated to ReadSubcase Window", "FAIL", True)
'			Environment("Action_Result") = False 
'			Exit Function
'		Else
'			Call ReportLog("Navigation", "Should be Navigated to ReadSubcase Window", "Navigated to ReadSubcase Window", "Information", True)
'		End If
'	End With
'	
'	Wait 15
'	'Close Subcase Window
'	If Window("regexpwndtitle:=Amdocs CRM.*").Window("regexpwndtitle:=Subcase list for case.*").Exist(10) Then
'		Window("regexpwndtitle:=Amdocs CRM.*").Window("regexpwndtitle:=Subcase list for case.*").Close
'		Wait 30
'	End if
'
'	If Not Window("AmdocsCRM-ClearSupport").Window("ReadSubcase").WinButton("btnCloseTask").GetROProperty("enabled") Then
'		'Yank the SubCase
'		Call fn_Classic_YankUnderSubcase()
'			If Not Environment("Action_Result") Then Exit Function
'	End If
'		
'	'Check For Close Task button is enabled or not
'	blnResult = Window("AmdocsCRM-ClearSupport").Window("ReadSubcase").WinButton("btnCloseTask").WaitProperty("enabled", True, 1000*60*5)
'	If Not blnResult Then
'		Call ReportLog("Close Task", "Close Task button should be enabled after yanking on Read Subcase Window", "Close Task button is disabled after yanking on Read Subcase Window", "FAIL", True)
'		Environment("Action_Result") = False : Exit Function
'	End If
'
'	'Build Amdocs Reference
'	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSupport", "ReadSubcase")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Click on View Subsubcase
'	blnResult = clickChildWindowButton("btnOpenTask")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Wait For Save/Done button to appear
'	Set oWndControl = Window("AmdocsCRM-ClearSupport").Window("SetElements2Installed").WinButton("btnSave/Done")
'	blnResult = waitForWindowControl(oWndControl, 60)
'	If Not blnResult Then 
'		Call ReportLog("Navigation", "Should be Navigated to SetElements2Installed Window", "Could not be navigated to SetElements2Installed Window", "FAIL", True)
'		Environment("Action_Result") = False 
'		Exit Function
'	Else
'		Call ReportLog("Navigation", "Should be Navigated to SetElements2Installed Window", "Navigated to SetElements2Installed Window", "Information", True)
'	End If
'	
'	'Close the Read Subcase window
'	If oChildWindow.Exist(10) Then oChildWindow.Close : Wait 30
'	
'	'Build Amdocs Reference
'	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSupport", "SetElements2Installed")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	
'	'Select as Ended from Status
'	blnResult = selectFromChildWindowComboBox("cmdStatus", "Ended")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 5
'	
'	'Click on View btnSave/Done
'	blnResult = clickChildWindowButton("btnSave/Done")
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	
'End Function
