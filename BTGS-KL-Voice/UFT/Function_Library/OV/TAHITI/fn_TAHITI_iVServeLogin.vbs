Public Function fn_TAHITI_iVServeLogin(ByVal URL, ByVal UserName, ByVal Password)
	
	SystemUtil.Run "iexplore.exe", URL, , , 3
	
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgiVServeLogin").Link("lnkLog2OrderServiceMgmt").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Building reference
	blnResult = BuildWebReference("brwiVServe","pgiVServeLogin","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Log into Order and Service Management 
	blnResult = clickLink("lnkLog2OrderServiceMgmt")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	objPage.Sync
	
	'Wait for the UserName textbox to apear
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgiVServeLogin").WebEdit("txtUserName").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Enter UserName
	blnResult = enterText("txtUserName", UserName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Password
	blnResult = enterText("txtPassword", Password)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Login Button
	blnResult = clickButton("btnLogin")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait for the Yes button to appear
	For intCounter = 1 To 3
		blnResult = Browser("brwiVServe").Page("pgTryLogin").WebButton("btnYES").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Building reference
	blnResult = BuildWebReference("","pgTryLogin","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Yes Button
	blnResult = clickButton("btnYES")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgLaunchPadApplications").Link("lnkVserve").Exist(60)
		If blnResult Then 
			Call ReportLog("iVServe Login", "Should get navigated to LaunchPad Applications Page", "Navigated to LaunchPad Applications Page", "PASS", True)
			Exit For
		End If
	Next
	
	If Not blnResult Then
		Call ReportLog("iVServe Login", "Should get navigated to LaunchPad Applications Page", "Couldn't navigate to LaunchPad Applications Page", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

End Function
