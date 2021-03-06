Public Function fn_Classic_ValidateOrder_CreateProject_LaunchTask(ByVal ProjectLeaderFirstName, ByVal ProjectLeaderLastName, ByVal ProjectCoordinatorFirstName, ByVal ProjectCoordinatorLastName, _
		ByVal InCountryControllerFirstName, ByVal InCountryControllerLastName)
	Dim intRows
	Dim blnMultiSubProject, blnViewProjectEnabled, isGONEVServiceTypePresent

	blnMultiSubProject = False : blnViewProjectEnabled = False : isGONEVServiceTypePresent = True
	
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
		intRows = oChildWindow.WinTable("grdServicesOfOrder").RowCount
		If intRows > 1 Then blnMultiSubProject = True
	End If
	
	If blnMultiSubProject Then
		'To be scripted by seeing the order :(
	End If
	
	intRows = oChildWindow.WinTable("grdSubProject").RowCount
	For iRow = 1 To intRows
		oChildWindow.WinTable("grdSubProject").SelectRow "#" & iRow
		Wait 5
		strServiceType = oChildWindow.WinTable("grdSubProject").GetCellData("#1","#2")
		If strServiceType = "GONEV" Then
			strServiceName = oChildWindow.WinTable("grdServicesOfSubProject").GetCellData("#1","#2")
			isGONEVServiceTypePresent = True
			Exit For '#iRow
		End If
	Next
	
	If Not isGONEVServiceTypePresent Then
		Call ReportLog("Service Type", "Service Type GONEV should be present", "Could not locate GONEV service type in this order", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	
	blnGMPLS = False
	intRows = oChildWindow.WinTable("grdServicesOfOrder").RowCount
	If intRows >= 2 Then
		blnGMPLS = True
	End If

	If blnGMPLS Then
			intServSubPrjRows = oChildWindow.WinTable("grdServicesOfSubProject").RowCount
			For iRow = 1 To intServSubPrjRows
				strServiceType = oChildWindow.WinTable("grdServicesOfSubProject").GetCellData("#" & iRow, 2)
				If Instr(strServiceType, "GMPLS") > 0 Then
					oChildWindow.WinTable("grdServicesOfSubProject").SelectRow "#" & iRow
					oChildWindow.WinButton("btnPassLeft").Click
					Wait 10
					Exit For' #iRow
				End If
			Next '#iRow
			
			blnServicesRowProp = False
			For intRowLoadCounter = 1 To 10
				oChildWindow.WinTable("grdServicesOfSubProject").RefreshObject
				intServSubPrjRows = oChildWindow.WinTable("grdServicesOfSubProject").RowCount
				If intServSubPrjRows = 1 Then
					blnServicesRowProp = True
					Exit For '#intRowLoadCounter
				Else
					Wait 5
				End If
			Next '#intRowLoadCounter
			
			If Not blnServicesRowProp Then
				Call ReportLog("Subproject Services", "Services Associated with Subproject Table should contain 1 Row", "Did not achieve the prop", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			strSubProjectName = "AutoSite" & Replace(Replace(Replace(Now, ":", ""), "/", ""), Space(1), "")
			blnResult = enterChildWindowText("txtSubProjectName", strSubProjectName)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 5
			
			blnResult = clickChildWindowButton("btnAdd")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			intRows = oChildWindow.WinTable("grdSubProject").RowCount
			For iRow = 1 To intRows
				strProjectName = oChildWindow.WinTable("grdSubProject").GetCellData("#" & iRow, 1)
				If strProjectName = strSubProjectName Then
					If iRow = 1 Then
						oChildWindow.WinTable("grdSubProject").SelectRow "#" & intRows
						Wait 5						
					End If
					oChildWindow.WinTable("grdSubProject").SelectRow "#" & iRow
					Exit For
				End If
			Next
			
			intServicesAsssociated = oChildWindow.WinTable("grdServicesOfOrder").RowCount
			For iRow = 1 To intServicesAsssociated
				strServiceType = oChildWindow.WinTable("grdServicesOfOrder").GetCellData("#" & iRow, 2)
				If Instr(strServiceType, "GMPLS") > 0 Then
					oChildWindow.WinTable("grdServicesOfOrder").SelectRow "#" & iRow
					oChildWindow.WinButton("btnPassRight").Click
					Wait 10
					Exit For' #iRow
				End If
			Next '#iRow
	End If '#blnGMPLS
	
	'Click on Validate Order button
	blnResult = clickChildWindowButton("btnValidateOrder")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 60
	
	If Not oParentWindow.Dialog("DialogValidation").WinObject("msgValidationResult").Exist(900) Then
		Call ReportLog("Validate Order", "Services should be validated", "Services were not validated even after a period of 15mins", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check whether services are validate or not
	strValidationMessgae = oParentWindow.Dialog("DialogValidation").WinObject("msgValidationResult").GetROProperty("text")
	If InStr(strValidationMessgae, "has been validated.") > 0 OR InStr(strValidationMessgae, "have been validated.") Then
		Call ReportLog("Validate Order", "Services should be validated", strValidationMessgae, "PASS", True)
		Window("AmdocsCRM").Dialog("DialogValidation").WinButton("btnOk").Click
		Wait 10
	Else
		Call ReportLog("Validate Order", "Services should be validated", strValidationMessgae, "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Create Project exists or not
	blnResult = Window("AmdocsCRM").Window("QuoteWindow").WinButton("btnCreateProject").Exist(180)
	If blnResult Then
		blnResult = Window("AmdocsCRM").Window("QuoteWindow").WinButton("btnCreateProject").WaitProperty("enabled", True, 1000*60*5)
		If Not blnResult Then
			Call ReportLog("Create Project", "Create Project button should be enabled", "Create Project button is disabled", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		'Click on Create Project button
		blnResult = clickChildWindowButton("btnCreateProject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Wait 60
	End If
	
	'Wait For B-End Select button to appear
	Set oWndControl = oChildWindow.WinButton("btnViewProject")
	blnResult = waitForWindowControl(oWndControl, 480)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait For View Project Button to be enabled
	blnViewProjectEnabled = oChildWindow.WinButton("btnViewProject").WaitProperty("enabled", True, 1000*60*5)
	If Not blnViewProjectEnabled Then
		Call ReportLog("View Project", "View Project Button should be enabled", "View Project button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		'Click on View Project button
		blnResult = clickChildWindowButton("btnViewProject")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		Wait 60
	End If
	
	
	Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnB-EndSelect")
	If Not oWndControl.Exist(180) Then
		blnResult = clickChildWindowButton("btnViewProject")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	'Wait For B-End Select button to appear
	blnResult = waitForWindowControl(oWndControl, 180)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSales", "CommercialProject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Enter Project Leader Contact Details
	blnResult = enterChildWindowText("txtProjectLeaderFirstName", ProjectLeaderFirstName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	blnResult = enterChildWindowText("txtProjectLeaderLastName", ProjectLeaderLastName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	blnResult = clickChildWindowButton("btnValidateProjectLeaderDet")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Enter Project Coordinator Contact Details	
	blnResult = enterChildWindowText("txtProjectCoordinatorFirstName", ProjectCoordinatorFirstName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	blnResult = enterChildWindowText("txtProjectCoordinatorLastName", ProjectCoordinatorLastName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	blnResult = clickChildWindowButton("btnValidateProjectCoordinatorDet")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Subproject from WinTab
	blnResult = selectItemFromWinTab("tbSubHeader", "Subproject")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 15
	
	'Wait For B-End Select button to appear
	Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnB-EndSelect")
	blnResult = waitForWindowControl(oWndControl, 180)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Assigning Incountry Controller to all subProjects
	arrAllItems = Split(oChildWindow.WinComboBox("cmSubProjectName").GetROProperty("all items"), Chr(10)) '10 stands for LineFeed
	For Each SubProject In arrAllItems
		If SubProject <> "All" AND SubProject <> "Common" Then
		
			'Select SubProject
			blnResult = selectFromChildWindowComboBox("cmSubProjectName", SubProject)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			'Wait For B-End Select button to appear
			Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnB-EndSelect")
			blnResult = waitForWindowControl(oWndControl, 180)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			'B-End Select
			blnResult = clickChildWindowButton("btnB-EndSelect")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			
			blnInvalidRelation = False
			If oParentWindow.Dialog("dlgAmdocsCRM").Static("msgRelationofSubProjectInvalid").Exist(30) Then
				oParentWindow.Dialog("dlgAmdocsCRM").WinButton("btnOK").Click
				blnInvalidRelation = True
			End If
			
			'Select B-End Entity
			If oParentWindow.Window("B-EndEntitiesSelection").WinTable("grdB-EndEntity").Exist(60) Then
				oParentWindow.Window("B-EndEntitiesSelection").WinTable("grdB-EndEntity").SelectRow "#1"
				Wait 5
				oParentWindow.Window("B-EndEntitiesSelection").WinButton("btnDone").Click
				Wait 5
			End If
			
			Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinTab("tbSubHeader")
			blnResult = waitForWindowControl(oWndControl, 120)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			'Select Subproject from WinTab
			blnResult = selectItemFromWinTab("tbSubHeader", "Subproject")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			Set oWndControl = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinEdit("txtInCountryControllerFN")
			blnResult = waitForWindowControl(oWndControl, 120)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Enter Project Incountry Controller	
			blnResult = enterChildWindowText("txtInCountryControllerFN", InCountryControllerFirstName)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			blnResult = enterChildWindowText("txtInCountryControllerLN", InCountryControllerLastName)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			blnResult = clickChildWindowButton("btnValidateInCountryController")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		End If
	Next '#SubProject
	
	'Select Tasks from WinTab
	blnResult = selectItemFromWinTab("tbSubHeader", "Tasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		
	For intCounter = 1 To 5
		blnResult = Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnFind").Exist(60)
		If blnResult Then
			Exit For
		Else
			'Select Tasks from WinTab
			blnResult = selectItemFromWinTab("tbSubHeader", "Tasks")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
	Next
	
	blnProjectLaunched = False
	'Launch and find Tasks for Min of 5 Mins
	For intCounter = 1 To 5
		
		If Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnFind").Exist(180) Then		
			'Click on Launch Project
			blnResult = clickChildWindowButton("btnLaunchProject")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 60
		End If
		
		If Window("AmdocsCRM-ClearSales").Dialog("dlgAmdocsCRM").Static("msgCBOConnectionError").Exist(30) Then
			If Window("AmdocsCRM-ClearSales").Dialog("dlgAmdocsCRM").WinButton("btnOK").Exist(10) Then
				Call ReportLog("CBO Connection Error", "Application is down", "Please check with Component team", "FAIL", True)
				Window("AmdocsCRM-ClearSales").Dialog("dlgAmdocsCRM").WinButton("btnOK").Click
				Environment("Action_Result") = False : Exit Function
			End If
		End If

		If Window("AmdocsCRM-ClearSales").Window("CommercialProject").WinButton("btnFind").Exist(300) Then
			'Click on Launch Project
			blnResult = clickChildWindowButton("btnFind")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 10
		End If
		
		oParentWindow.Window("CommercialProject").WinTable("grdTasks").RefreshObject
		If oParentWindow.Window("CommercialProject").WinTable("grdTasks").RowCount > 0 Then
			blnProjectLaunched = True
			Exit For '#intCounter
		End If
	Next '#intCounter
	
	If Not blnProjectLaunched Then
		Call ReportLog("Launch Project", "Tasks should be visible on Classic within 5Mins", "Tasks are not visible", "FAIL", True)
		Environment("Action_Result") = False
	Else
		Call ReportLog("Launch Project", "Tasks should be visible on Classic within 5Mins", "Tasks are visible", "PASS", True)
		Environment("Action_Result") = True
	End If
	
End Function
