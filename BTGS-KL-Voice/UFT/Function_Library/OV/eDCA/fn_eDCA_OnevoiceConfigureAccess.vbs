'****************************************************************************************************************************
' Function Name	 : fn_eDCA_OnevoiceConfigureAccess()
' Purpose	 	 :  Checking the presence of  configure access page and entering the details 
' Author	 	 :  Vamshi Krishna G
' Modified By :  Biswabharati Sahop
' Creation Date    :  07/06/2013
' Modification Date :10/09/2013
'Return values :  		NA
'****************************************************************************************************************************		
Public function fn_eDCA_OnevoiceConfigureAccess(dTypeOfOrder,dGPoPEthernet,dAccessSupplierEthernet,dSuppliersContractTerm, dAccessEnhancedServiceRestoration)

	'Declaration of variables
	Dim objMsg,strMessage
	Dim strGPoPEthernet,strAccessSupplierEthernet,strSuppliersContractTerm,strAccessEnhancedServiceRestoration

	'Assignment of variables
	strGPoPEthernet = GPoPEthernet
	strAccessSupplierEthernet = AccessSupplierEthernet
	strSuppliersContractTerm = SuppliersContractTerm
	strAccessEnhancedServiceRestoration = AccessEnhancedServiceRestoration
	strGPoPEthernet = dGPoPEthernet
	strAccessSupplierEthernet = dAccessSupplierEthernet
	strSuppliersContractTerm = dSuppliersContractTerm

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Entering particulars for Ethernet Product 
	If  UCase(dTypeOfOrder) = "ETHERNETPROVIDE" or UCase(dTypeOfOrder) = "TDMPROVIDE" or dTypeOfOrder = "P2PEtherNetProvide" Then
		'Selecting GPoP value from drop down 
		blnResult = selectValueFromPageList("lstGPoPEthernet",strGPoPEthernet)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Selecting AccessSupplier form drop down list
		blnResult = selectValueFromPageList("lstAccessSupplierEthernet",strAccessSupplierEthernet)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

				'Entering Supplier's contract term
		blnResult = enterText("txtSuppliersContractTerm",strSuppliersContractTerm)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End if 

	'Selecting Access Enhanced Service Restoration from drop down
	If  UCase(dTypeOfOrder) = "TDMPROVIDE"  Then
		blnResult = selectValueFromPageList("lstTDMAccessRestoration",strAccessEnhancedServiceRestoration)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If  UCase(TypeOfOrder) = "ETHERNETPROVIDE" Then
		'Entering Supplier's contract term
		blnResult = enterText("txtSuppliersContractTerm",strSuppliersContractTerm)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If

	'Configure Access notification message for GSIP product
	
	If  UCase(dTypeOfOrder) = "GSIPPROVIDE" OR UCase(dTypeOfOrder) = "GSIPMODIFY" or UCase(dTypeOfOrder) = "GVPNBUNDLEDMODIFY"Then

		'Retrive alert message in the browser 
		strRetrivedText = objPage.WebElement("webElmConfigureAccessNotification").GetROProperty("innertext")
		If strRetrivedText<> "" Then
			Call ReportLog("ConfigureAccessNotification","ConfigureAccessNotification should be retrived","ConfigureAccessNotification retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("ConfigureAccessNotification","ConfigureAccessNotification should be retrived","ConfigureAccessNotification is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If

	End If 
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	' Clicikng on Next button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to OnevoiceAccessDetails page
	Set objMsg = objpage.WebElement("webElmOnevoiceAccessDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("OnevoiceConfigureAccess","Should be navigated to OnevoiceAccessDetails page on clicking Next Buttton","Not navigated to OnevoiceAccessDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmAccessDetails")
		Call ReportLog("OnevoiceConfigureAccess","Should be navigated to OnevoiceAccessDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
