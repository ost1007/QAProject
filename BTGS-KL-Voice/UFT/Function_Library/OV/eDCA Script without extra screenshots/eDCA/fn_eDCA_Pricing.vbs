'****************************************************************************************************************************
' Function Name	 : fn_eDCA_Pricing
' Purpose	 	 : Function to enter Catalog prices
' Author	 	 : Vamshi Krishna G
' Creation Date    : 06/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_Pricing(dAccessPricing1,dAccessPricing2,dAccessPricing3,dAccessPricing4,dCPEPricing1,dCPEPricing2,dSLAPricing,dEnhanceServiceRestorationPricing)

	'Declaraing variables
	Dim strAccessPricing1,strAccessPricing2,strAccessPricing3,strAccessPricing4
    Dim  strCPEPricing1, strCPEPricing2
    Dim strSLAPricing
    Dim strEnhanceServiceRestorationPricing
    Dim blnResult,objMsg

	'Assignment of variables
	strAccessPricing1 = dAccessPricing1
	strAccessPricing2 = dAccessPricing2
	strAccessPricing3 = dAccessPricing3
	strAccessPricing4 = dAccessPricing4
	strCPEPricing1 = dCPEPricing1
	strCPEPricing2 = dCPEPricing2
	strSLAPricing = dSLAPricing
	strEnhanceServiceRestorationPricing = dEnhanceServiceRestorationPricing


	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'*************************************************************************************************************************
	'     Access Pricing - Leased Line
	'**************************************************************************************************************************
	'Assigning Catalog price to Non-Recurring charge with Commercial element 1 X MPLS Global Port 1024Kbps Install
	blnResult = enterText("txtAccessPricing1",strAccessPricing1)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Assigning Catalog price to Recurring charge with Commercial element 1 X MPLS Global Port 1024Kbps Mthly
	blnResult = enterText("txtAccessPricing2",strAccessPricing2)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Assigning Catalog price to Recurring charge with Commercial element 1 X MPLS Access 2048Kbps (E1) Mthly
	blnResult = enterText("txtAccessPricing3",strAccessPricing3)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Assigning Catalog price to Non-Recurring charge with Commercial element 1 X MPLS Access 2048Kbps (E1) Install
	blnResult = enterText("txtAccessPricing4",strAccessPricing4)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	If objPage.WebEdit("txtAccessPricing5").Exist(5) Then
		blnResult = enterText("txtAccessPricing5","50")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If
	
	If objPage.WebEdit("txtAccessPricing6").Exist(5) Then
		blnResult = enterText("txtAccessPricing6","50")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End If
	

	'************************************************************************************************************************************
	'		CPE Pricing
	'*************************************************************************************************************************************
	'Assigning Catalog Price to Non-Recurring price for Commercial element CISCO2921/K9 
	blnResult = enterText("txtCPEPricing1",strCPEPricing1)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Assigning Catalog Price to Recurring price for Commercial element CISCO2921/K9 
	blnResult = enterText("txtCPEPricing2",strCPEPricing2)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'**************************************************************************************************************************************
	'		SLA Pricing
	'*************************************************************************************************************************************
	'Assigning Catalog Price 
	blnResult = enterText("txtSLAPricing",strSLAPricing)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'***************************************************************************************************************************************
	'		Enhance Serivce Restoration Pricing
	'****************************************************************************************************************************************
	'Assigning Catalog Price
	blnResult = enterText("txtEnhanceServiceRestorationPricing",strEnhanceServiceRestorationPricing)
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	'Click on Next Button
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to Sites Page
	Set objMsg = objpage.WebElement("webElmSites")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Pricing","Should be navigated to Sites page on clicking Next Buttton","Not navigated to Sites page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSites")
		Call ReportLog("Pricing","Should be navigated to Sites page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'*************************************************************************************************************************************
'	End of function
'**************************************************************************************************************************************
