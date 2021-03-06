'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_PricingDetails
' Purpose	 	 :  Collecting pricing details
' Author	 	 : Vamshi Krishna G
' Creation Date    : 16/08/2013
' Return values :	Nil
'**************************************************************************************************************************************	
Public function fn_eDCA_PricingDetails(dTypeOfOrder,dPriceValue,dPriceCatalog)

	'Declaration of variables
	Dim blnResult,objMsg,strRowCount,strPricevalue

	'Assignment of variables
	strPriceValue = dPriceValue
	strTypeOfOrder = dTypeOfOrder
	strPriceCatalog = dPriceCatalog

	strdiscount = split(strPriceValue,"|")
	strPriceCatalog= split(dPriceCatalog,"|")

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Assigning values to all the fields in table
	blnExist  = False
	'Loop for 15 mins to check whether the Pricing Details table is loaded or not
	For intCounter = 1 to 15
		blnExist = Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").Exist
		If blnExist Then
			Exit For
		End If
	Next

	If Not blnExist Then
		Call ReportLog("WebTable - Pricing Details", "WebTable should be loaded", "WebTable is not loaded", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	strRowCount=Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").RowCount

	For i = 2 to strRowCount
		If UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" Then
			strData = Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").GetCellData(i,2)
			If Trim(strData) = "BT One Voice Single Number Block - Setup" or Trim(strData) = "BT One Voice Single Number Block - Rental" Then
				Wait 1
			Else
				Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").SetCellData i,3,strPriceValue
			End If
		Else
            	Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").SetCellData i,3,strdiscount(0)
                Browser("brweDCAPortal").Page("pgeDCAPortal").WbfGrid("tblPricingDetails").SetCellData i,4,strPriceCatalog(0)
 		End If
	Next
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

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
		Call ReportLog("PricingDetails","Should be navigated to Sites page on clicking Next Buttton","Not navigated to Sites page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSites")
		Call ReportLog("PricingDetails","Should be navigated to Sites page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If


End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
