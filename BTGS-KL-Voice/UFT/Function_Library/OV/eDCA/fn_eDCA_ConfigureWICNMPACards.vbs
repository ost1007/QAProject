'****************************************************************************************************************************
' Function Name	 : fncConfigureWICNMPACards
' Purpose	 	 : Function to configure WIC,NM  and PA cards
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 24/06/2013
' Return Values	 : Not Applicable

'******************************************************************************************************************************
Public function fn_eDCA_ConfigureWICNMPACards(dTypeOfOrder,dPortTypeWIC1,dCardWIC1,dPortTypeWIC2,dCardWIC2)

	'Variable declaration
    Dim blnResult
    Dim objMsg
	Dim strCardWIC1,strCardWIC2,strPortTypeWIC1,strPortTypeWIC2

	'Assignment of variables
	strCardWIC1 = dCardWIC1
	strCardWIC2 = dCardWIC2
	strPortTypeWIC1 = dPortTypeWIC1
	strPortTypeWIC2 = dPortTypeWIC2

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	If  dTypeOfOrder <> "OB_FULLPSTN_MODIFY" Then

		If objPage.WebList("lstPortTypeWIC1").Exist Then
			'Select PortTypeWIC1 from drop down list
			blnResult = selectValueFromPageList("lstPortTypeWIC1",strPortTypeWIC1)
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If objPage.WebList("lstCardWIC1").Exist Then
			'Select WIC1 from drop down list
			blnResult = selectValueFromPageList("lstCardWIC1",strCardWIC1)
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If objPage.WebList("lstPortTypeWIC2").Exist Then
			'Select PortTypeWIC2 from drop down list
			blnResult = selectValueFromPageList("lstPortTypeWIC2",strPortTypeWIC2)
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If    

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		If objPage.WebList("lstCardWIC2").Exist Then
			'Select WIC2 from drop down list
			blnResult = selectValueFromPageList("lstCardWIC2",strCardWIC2)
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If	

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

		If objPage.WebButton("btnNext").Exist Then
			'Click on Next Button
			blnResult = clickButton("btnNext")
			If blnResult = False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		blnResult = clickButton("btnNext")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End if
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if Navigated to VPN Page
	If dTypeOfOrder = "OB_FULLPSTN_MODIFY"  Then
		Set objMsg = objpage.Webelement("webElmSIPTrunkingDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("ConfigureWICNMPACards","Should be navigated to VPN page on clicking Next Buttton","Not navigated to VPN page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmSIPTrunkingDetails")
			Call ReportLog("ConfigureWICNMPACards","Should be navigated to VPN page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If	
	
	Else
		Set objMsg = objpage.Webelement("webElmVPN")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("ConfigureWICNMPACards","Should be navigated to VPN page on clicking Next Buttton","Not navigated to VPN page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmVPN")
			Call ReportLog("ConfigureWICNMPACards","Should be navigated to VPN page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If	
	End If
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************