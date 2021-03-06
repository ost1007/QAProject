'****************************************************************************************************************************
' Function Name	 : fn_eDCA_VPN()
' Purpose	 	 : Function to add a new VPN 
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 06/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_eDCA_VPN()

	'Declaration of variables
	Dim objMsg

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Add VPN button

	blnResult = clickButton("btnAddVPN")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Add New VPN
	If ObjPage.WebButton("btnAddNewVPN").Exist Then
		blnResult = clickButton("btnAddNewVPN")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			Exit Function
		End If
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	For intCounter = 1 to 5
		If Browser("brweDCAPortal").Dialog("dlgVpnalert").Exist Then
			Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Highlight
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Click
			Exit For
		End if 
	Next

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	wait 5
	
	'Clicking on Edit button	
	If ObjPage.WebButton("btnEdit").Exist Then
		blnResullt = clickButton("btnEdit")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End if
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Check if  it is navigated to VPN connection page 
	Set objMsg = objpage.WebElement("webElmVPNConnection")
    'objMsg.WaitProperty "visible", True, 1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("VPN","Should be navigated to VPN Connection page on clicking Edit Buttton","Not navigated to VPN connection page on clicking Edit Buttton","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Exit Function
	Else
		strMessage = GetWebElementText("webElmVPNConnection")
		Call ReportLog("VPN","Should be navigated to VPN Connection page on clicking Edit Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment.Value("Action_Result")=True
	End If
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
