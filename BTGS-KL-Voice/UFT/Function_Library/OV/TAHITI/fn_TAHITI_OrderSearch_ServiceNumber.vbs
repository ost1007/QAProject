'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_OrderSearch_ServiceNumber
' Purpose	 	 : Function to search order in Tahiti Portal 
' Modified By : Nagaraj V || 01/12/2015 || Created New Function For Clocking on Specific Service Number
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_TAHITI_OrderSearch_ServiceNumber(ByVal OrderID, ByVal LinkName, ByVal ServiceNumber)

	'Variable Declaration Section
	Dim objMsg
	Dim blnResult

	'Building Reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	
	'Click My Orders Link
	blnResult = clickLink("lnkMyOrders")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	Wait 5

	'Click on Order Search button
	blnResult = clickButton("btnOrderSearch")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Entering Order ID
	blnResult = enterText("txtSearchOrderId", OrderID)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function	

	'Clicking on Search Button
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function	

	Browser("brwTahitiPortal").Sync
	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Checking for the order details retrived
	NoOfRowsRetrived = Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebTable("tblOrderDetails").RowCount
	If NoOfRowsRetrived = 1 Then
		strRetrivedText = Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebTable("tblOrderDetails").GetCellData(1,1)
		If strRetrivedText = "No result was found" Then
			Call ReportLog("Order Search Verification","Order Details should be retrived on clicking on Search button","Search result retrived as: "&strRetrivedText,"PASS","")
		End If
	End If

	If NoOfRowsRetrived = 4 Then
		strRetrivedText = Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebTable("tblOrderDetails").GetCellData(1,1)
		Call ReportLog("Order Search Verification","Order Details should be retrived on clicking on Search button","Search result retrived as: "&strRetrivedText,"PASS","")
	End If

	'Click on the Order retrived
	Browser("brwTahitiPortal").Page("pgTahitiPortal").WebRadioGroup("radSelectOrderId").Click

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Click on Order Detail  button
	blnResult = clickButton("btnOrderDetail")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	Wait 5

	'Set objpage = Browser("FlexApp").Page("Tahiti Portal")
	Set objDesc = Description.Create()
	objDesc("micClass").Value = "link"
	objDesc("text").Value = ServiceNumber & ".*"
	objDesc("html tag").Value = "A"

	Set a = objPage.ChildObjects(objDesc)
	If Not IsNull(a) Then
		a(0).Click
	Else
		Set objDesc = Description.Create()
		objDesc("micClass").Value = "link"
		objDesc("text").Value = ServiceNumber & ".*"
		objDesc("html tag").Value = "A"
		
		Set a = objPage.ChildObjects(objDesc)
		a(0).Click
	End If

	'Building Reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Check if navigated to My Tasks page
	Set objMsg = objFrame.WebTable("tblServiceDetails")
	objMsg.WaitProperty "visible","True",100000
	If Not objMsg.Exist Then
		Call ReportLog("Service Details","Should be navigated to Service details on clicking Order Detail Buttton","Not navigated to Service details page on clicking Order Detail Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmServiceName")
		Call ReportLog("Service Details","Should be navigated to Service details page on clicking Order Detail Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

	If LinkName = "All Tasks" Then
			'Click on All Tasks link
			blnResult = clickFrameLink("lnkAllTasks")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
			'Check if navigated to Task list page
			Set objMsg = objFrame.WebElement("webElmAllTasksForService")
			objMsg.WaitProperty "visible","True",100000
			If objMsg.Exist = False Then
				Call ReportLog("AllTasksForService","Should be navigated to Tasks In Service page list on clicking All Tasks link","Not navigated to Tasks In Service page list on clicking All Tasks link","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			Else
				strMessage = GetWebElementText("webElmAllTasksForService")
				Call ReportLog("AllTasksForService","Should be navigated to Tasks In Service page list on clicking All Tasks link","Navigated to the page - "&strMessage,"PASS","")
			End If
	ElseIf LinkName = "All Technical Elements" Then
			'Click on All Tasks link
			blnResult = clickFrameLink("lnkAllTechnicalElements")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			
			'Check if navigated to Technical Element List
			Set objMsg = objFrame.WebElement("elmAllTechnicalElements")
			objMsg.WaitProperty "visible","True",100000
			If objMsg.Exist = False Then
				Call ReportLog("All Technical Elements","Should be navigated to Technical Elements list page list on clicking All Technical Elements link","Not navigated to Tasks In Service page list on clicking All Technical Elements link","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			Else
				strMessage = GetWebElementText("webElmAllTasksForService")
				Call ReportLog("All Technical Elements","Should be navigated to Technical Elements list page list on clicking All Technical Elements link","Navigated to the page - "&strMessage,"PASS","")
			End If
			
	End If
	
	

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
