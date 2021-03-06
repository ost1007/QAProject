Public Function fn_Classic_Navigate2Project()
	Dim intRows
	Dim blnMultiSubProject, blnViewProjectEnabled, isGONEVServiceTypePresent
	Dim strServiceName, strServiceType

	blnMultiSubProject = False : blnViewProjectEnabled = False : isGONEVServiceTypePresent = True
	
	'Wait For Save/Done button to appear
	Set oWndControl = Window("AmdocsCRM").Window("QuoteWindow")
	Call waitForWindowControl(oWndControl, 120)
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "QuoteWindow")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Select Service/Subproject from WinTab
	blnResult = selectItemFromWinTab("tbHeader", "Service/Subproject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Wait For View Project button to appear
	Set oWndControl = oParentWindow.Window("QuoteWindow").WinButton("btnViewProject")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	If Not oChildWindow.WinTable("grdSubProject").Exist(60) Then
		Call ReportLog("SubProject Grid", "SubProject Grid should exist", "SubProject Grid doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		intRows = oChildWindow.WinTable("grdSubProject").RowCount
		If intRows > 1 Then blnMultiSubProject = True
		For iRow = 1 To intRows
			oChildWindow.WinTable("grdSubProject").SelectRow "#" & iRow
			Wait 5
			strServiceType = oChildWindow.WinTable("grdServicesOfSubProject").GetCellData("#1","#2")
			If strServiceType = "GONEV" Then
				strServiceName = oChildWindow.WinTable("grdSubProject").GetCellData("#" & iRow,"#1")
				isGONEVServiceTypePresent = True
				Exit For '#iRow
			End If
		Next
		
		If Not isGONEVServiceTypePresent Then
			Call ReportLog("Service Type", "Service Type GONEV should be present", "Could not locate GONEV service type in this order", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
	End If
	
	blnViewProjectEnabled = oChildWindow.WinButton("btnViewProject").GetROProperty("enabled")
	If Not blnViewProjectEnabled Then
		Call ReportLog("View Project", "View Project BUtton should be enabled", "View Project button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on View Project button
	blnResult = clickChildWindowButton("btnViewProject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For B-End Select button to appear
	Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnB-EndSelect")
	blnResult = waitForWindowControl(oWndControl, 120)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	If Window("regexpwndtitle:=Amdocs CRM.*").Window("regexpwndtitle:=Quote.*").Exist(0) Then Window("regexpwndtitle:=Amdocs CRM.*").Window("regexpwndtitle:=Quote.*").Close
	Wait 5
	
	fn_Classic_Navigate2Project = 	strServiceName
	Environment("Action_Result") = True
End Function
