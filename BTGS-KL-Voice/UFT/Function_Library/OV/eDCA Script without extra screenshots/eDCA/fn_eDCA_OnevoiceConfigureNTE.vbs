'****************************************************************************************************************************
' Function Name	 : fncOnevoiceConfigureNTE
' Purpose	 	 :  Checking the presence of  ConfigureNTE avialability  for GSIP
' Author	 	 : Vamshi Krishna G
' Creation Date    : 10/06/2013
' Return values :	NA
'****************************************************************************************************************************		
Public function fn_eDCA_OnevoiceConfigureNTE(dTypeOfOrder,dCNTEContractTerm)

	'Declaration of variables
	Dim objMsg,strMessage
	Dim strContractTerm

	'Assignment of variables
	strCNTEContractTerm = dCNTEContractTerm

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Etntering the particulars for Ethernet Product

	If  UCase(dTypeOfOrder) = "ETHERNETPROVIDE" or dTypeOfOrder = "P2PEtherNetProvide" Then

		'Retrive the value in NTE Bundle
		strRetrivedText = objPage.webList("lstNTEBundle").GetROProperty("value")
		If strRetrivedText<> "" Then
			Call ReportLog("NTEBundle","NTEBundle should be retrived","NTEBundle retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("NTEBundle","NTEBundle should be retrived","NTEBundle  is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If

		'Retrive the value in NTE Description
		strRetrivedText = objPage.webEdit("txtNTEDescription").GetROProperty("value")
		If strRetrivedText<> "" Then
			Call ReportLog("NTEDescription","NTEDescription should be retrived","NTEDescription retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("NTEDescription","NTEDescription should be retrived","NTEDescription is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

		'Select Contract Term from drop down list
		blnResult = selectValueFromPageList("lstCNTEContractTerm",strCNTEContractTerm)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
		
	End If

	'Checking the NTE notrfication message for GSIP Product and TDM  product
	
	If  UCase(dTypeOfOrder) = "GSIPPROVIDE" or UCase(dTypeOfOrder) = "TDMPROVIDE" Then
		'Retrive alert message in the browser 
		strRetrivedText = objPage.WebElement("webElmConfigureNTENotification").GetROProperty("innertext")
		If strRetrivedText<> "" Then
			Call ReportLog("ConfigureNTENotification","ConfigureNTENotification should be retrived","ConfigureNTENotification retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("ConfigureNTENotification","ConfigureNTENotification should be retrived","ConfigureNTENotification is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If

	End If

	' Clicikng on Next button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to ConfigureVlan page
	Set objMsg = objpage.Webelement("webElmOnevoiceConfigureVlan")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("OnevoiceConfigureNTE","Should be navigated to OnevoiceConfigureVlan page on clicking Next Buttton","Not navigated to OnevoiceConfigureVlan page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmOnevoiceConfigureVlan")
		Call ReportLog("OnevoiceConfigureNTE","Should be navigated to OnevoiceConfigureVlan page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
