Public Function fn_TAHITI_iVServeCheckLBM(ByVal Cartridge, ByVal ReferenceNumber, ByRef Loopbackmode)
	
	Dim intCounter
	
	Loopbackmode = "NO"
	
	'Building reference
	blnResult = BuildWebReference("brwiVServe","pgLaunchPadApplications","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Click on VServce Link
	blnResult = clickLink("lnkVserve")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait for New Order Image to appear
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgWorklist").Image("imgCreateNewOrder").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Building reference
	blnResult = BuildWebReference("brwiVServe","pgWorklist","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Click on CreateNewOrder
	blnResult = clickImage("imgCreateNewOrder")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Wait for List Cartridges to be visible
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgCreateOrder").WebList("lstCartridges").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Building reference
	blnResult = BuildWebReference("brwiVServe","pgCreateOrder","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5
	
	'Select Catridges
	blnResult = selectValueFromPageList("lstCartridges", Cartridge)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	
	'Enter Reference Number
	blnResult = enterText("txtOrderReferenceNumber", ReferenceNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Create Button
	blnResult = clickButton("btnCreate")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	objBrowser.Sync
	objPage.Sync
	
	'Wait for Submit button to be visible
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgCreateOrder").WebButton("btnSubmit").Exist(60)
		If blnResult Then Exit For
	Next
	
	'Click on Submit Button
	blnResult = clickButton("btnSubmit")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	objBrowser.Sync
	objPage.Sync
	
	Wait 10
	
	'Select Create a New VPN
	blnResult = selectWebRadioGroup("rdActions", "Create VPN")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	objBrowser.Sync
	objPage.Sync
	Wait 10
	
	'Wait for List Cartridges to be visible
	For intCounter = 1 To 5
		blnResult = Browser("brwiVServe").Page("pgCreateOrder").WebEdit("txtLoopbackmode").Exist(60)
		If blnResult Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("Check Loopback mode", "Loopback mode should be set as 'YES'", "Loopback mode textbox is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
		clickImage("imgLogout")
	Else
		Call ReportLog("Check Loopback mode", "Loopback mode should be set as 'YES'", "Snapshot", "Information", True)
	End If
	
	Loopbackmode = Browser("brwiVServe").Page("pgCreateOrder").WebEdit("txtLoopbackmode").GetROProperty("value")
	clickImage("imgLogout")
	Browser("name:=Successfully logged out", "creationtime:=0").CloseAllTabs
	Environment("Action_Result") = True	
End Function
