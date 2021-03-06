'=============================================================================================================
'Description: To Search and Assign SOP
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			31/10/2014 	v1.0
'Example: fn_SI_SearchOrderAndAssignSOP(EIN, UserName, OrderID)
'=============================================================================================================
Public Function fn_SI_SearchOrderAndAssignSOP(ByVal EIN, ByVal UserName, ByVal OrderID)
   On Error Resume Next
	Dim oDesc, oDescText
	Set oDesc = Description.Create
	Set oDescText = Description.Create

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

' 	Call Search Order Function
	Call fn_SI_WorkFlowSearchOrder(OrderID)
	If Not Environment("Action_Result") Then
		Exit Function
	End If

	Set objPage = Browser("brwSIWorkflow").Page("pgSIWorkflow")
	
	blnRequiredICAssignment = True
	Set elmICAssigned = objPage.WebElement("xpath:=//TABLE[@id='ordDetails']//TD[normalize-space()='IC User Name :']/following-sibling::td[1]", "index:=0")
	If elmICAssigned.Exist(60) Then
		strICAssigned = elmICAssigned.GetROProperty("innerText")
		If Instr(strICAssigned, EIN) > 0 Then
			blnRequiredICAssignment = False
		End If
	End If
	
	If Not blnRequiredICAssignment Then
		Call ReportLog("Assign IC", "User should be able to assign IC", "IC is already assigned to EIN: " & EIN, "Information", True)
		Environment("Action_Result") = True : Exit Function
	End If

	With objPage
		blnExist = .Image("imgOrderContactDetailsToggle").Exist(10)
		If blnExist Then
			objBrowser.fMaximize
			.Image("imgOrderContactDetailsToggle").Click
			Wait 10
		Else
			Call ReportLog("Order Contact Detail Toggle", "Should Exist", "Doesn't Exist", "FAIL", False)
			Environment("Action_Result") = False
			Exit Function
		End If
	End With

	blnFound = False
	Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").WaitProperty "rows", micGreaterThan(2), 1000*60*2
	intRows = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").RowCount
	For iRow = 1 to intRows
		strText = UCase(Trim(Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").GetCellData(iRow, 1)))
		If strText = "INSTALLATION COORDINATOR" OR strText = "SERVICE ORDER PROCESSOR" Then
			blnFound = True
			Exit For
		End If
	Next
	
	oDesc("micclass").Value = "WebList"
	oDesc("visible").Value = True
	
	oDescText("micclass").Value = "WebEdit"
	oDescText("visible").Value = True
	
	blnWebListFound = False
	If blnFound Then
		Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 5, "Image", 0)
		oImage.Click
		Wait 2
		For intLoopCount = 1 to 10
			If Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildObjects(oDesc).Count >= 1 Then
				Exit For
			Else
				Wait 2
			End If
		Next

		Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 2, "Image", 0)
		oImage.Click
		Wait 15

		For intLoopCount = 1 to 10
			If Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildObjects(oDescText).Count >= 2 Then
				Exit For
			Else
				Wait 2
				Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 2, "Image", 0)
				oImage.Click
				Wait 10
			End If
		Next

		Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").SetCellData iRow, 2, EIN, 2
		Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").RefreshObject
		Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 2, "Image", 0)
		oImage.Click
		For intCounter = 1 to 3
			If Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildObjects(oDesc).Count >= 1 Then
				blnWebListFound = True
				Exit For
			Else
				Wait 5
			End If
		Next
		
		If Not blnWebListFound Then
			Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").SetCellData iRow, 2, UserName
			Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 2, "Image", 0)
			oImage.Click
			Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").RefreshObject
			For intCounter = 1 to 3
				If Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildObjects(oDesc).Count >= 1 Then
					blnWebListFound = True
					Exit For
				Else
					Wait 5
				End If
			Next
		End If
	
		If blnWebListFound Then
			Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").SetCellData iRow, 4, "Assign SOP"
			Set oImage = Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").ChildItem(iRow, 5, "Image", 0)
			oImage.Click
			Wait 2
		Else
			Call ReportLog("Assign SOP", "Assign SOP should be successful", "Assign SOP is unsuccessfull", "FAIL", False)
			Environment("Action_Result") = False
			Exit Function
		End If
		
		blnUpdate = False
		If Browser("creationtime:=1").Dialog("text:=Message from webpage").Exist(60) Then
			Browser("creationtime:=1").Dialog("text:=Message from webpage").WinButton("text:=OK").Click
			blnUpdate = True
		End If
		
		
		If Browser("brwSIWorkflow").Dialog("dlgMsgFromWebpage").Static("staticUpdateSuccessful").Exist(60) Then
			Browser("brwSIWorkflow").Dialog("dlgMsgFromWebpage").HighLight
			Browser("brwSIWorkflow").Dialog("dlgMsgFromWebpage").WinButton("btnOK").Click
			blnUpdate = True
			Wait 30
		End If

		With Browser("brwSIWorkflow").Page("pgSIWorkflow")
			blnExist = .Image("imgOrderContactDetailsToggle").Exist(10)
			If blnExist Then
				.Image("imgOrderContactDetailsToggle").Click
			Else
				Call ReportLog("Order Contact Detail Toggle", "Should Exist", "Doesn't Exist", "FAIL", False)
				Environment("Action_Result") = False
				Exit Function
			End If
		End With
		
		'For intCounter = 1 to 10
		'	If Browser("brwSIWorkflow").Page("pgSIWorkflow").WebElement("elmContactUpdateSuccessMsg").Exist Then
		'		blnUpdate = True	
		'		Exit For
		'	Else
		'		blnUpdate = False
		'	End If
		'Next
		
		Browser("brwSIWorkflow").Page("pgSIWorkflow").WbfGrid("tblOrderContactDetails").RefreshObject
		If blnUpdate Then
			Call ReportLog("Assign SOP", "Assign SOP should be successful", "Assign SOP is successfull at " & Now, "PASS", True)
			Environment("Action_Result") = True
		Else
			Call ReportLog("Assign SOP", "Assign SOP should be successful", "Assign SOP is unsuccessfull at " & Now, "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		For intCounter = 1 to 10
			With Browser("brwSIWorkflow").Page("pgSIWorkflow")
				Browser("brwSIWorkflow").Page("pgSIWorkflow").Sync
				If .WebButton("btnAccept").Exist(10) Then
					isDisabled = .WebButton("btnAccept").Object.disabled
					If isDisabled Then
						.HighLight
						CreateObject("WScript.Shell").SendKeys "{F5}"
						blnAccept = False
						Wait 10
						If Browser("title:=Si-Workflow").Dialog("regexpwndtitle:=Windows Internet Explorer").WinButton("text:=&Retry").Exist(60) Then
							Browser("title:=Si-Workflow").Dialog("regexpwndtitle:=Windows Internet Explorer").WinButton("text:=&Retry").Click
						End If
						Wait 60
					Else
						Call ReportLog("Accept Order", "Accept Button should be enabled", "Accept Button is Enabled @ " & Now, "PASS", True)
						.WebButton("btnAccept").Object.click
						For intInnerLoopCounter = 1 to 3
							If .WebElement("innertext:=You are about to accept the order", "index:=0").Exist Then
								Call ReportLog("Accept Order", "Accepting Order MessageBox should be visible", "Accepting Order MessageBox is visible and OK button is to be clicked", "PASS", True)
								.WebButton("html id:=btnOk", "index:=0", "visible:=True").Click
								Wait 10
								blnAccept = True
								Exit For 'intInnerLoopCounter
							End If
						Next
						'Exit The Outer Loop
						If blnAccept Then Exit For'intCounter
					End If
				Else
					Call ReportLog("WebButton: Accept", "Should be Visible", "Button doesn't Exist", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function
				End If
			End With
		Next

		If Not blnAccept Then
			Call ReportLog("WebButton: Accept", "Order should be accepted", "Accept Button was not enabled to Accept after 10mins", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
			
		For intInnerCounter = 1 to 10
			Browser("brwSIWorkflow").Page("pgSIWorkflow").Sync
			If Browser("brwSIWorkflow").Page("pgSIWorkflow").WebButton("btnAccept").Object.disabled Then
				Exit For
			Else
				Wait 10
			End If
		Next
		
		If Browser("brwSIWorkflow").Page("pgSIWorkflow").WebButton("btnAccept").Object.disabled Then
			Call ReportLog("Accept Order", "Order should be accepted", "Order has been accepted", "PASS", True)
			Wait 60
		Else
			Call ReportLog("Accept Order", "Order should be accepted", "Order has not been accepted as Accept button is still enabled", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
	Else
		Call ReportLog("Assign SOP", "Service Order processor should be present", "Service Order processor/Installation Coordinator is not present", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If


End Function
