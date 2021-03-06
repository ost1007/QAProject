'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ConferSiteLocationDetails()
' Purpose	 	 : Function to enter Site Location Details
' Author	 	 : Biswabharati Sahoo
' Creation Date  	 : 26/08/2013                                     					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_ConferSiteLocationDetails()

   	Dim strRetrievedText,objMsg

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'-----------------------------------Capturing the values of  Text boxes-----------------------------------------------------------
	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtSiteName").GetROProperty("Value")
	Call ReportLog("Site Name","Site Name  should be populated","Site Name  is populated with the value - "&strRetrievedText,"PASS","") 

	strRetrievedText =Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtBusinessCustName").GetROProperty("Value")
	Call ReportLog("BusinessCust   Name","BusinessCust Name  should be populated","BusinessCust Name   is populated with the value - "&strRetrievedText,"PASS","") 

	'--------------------------Click on Next Button-----------------------------------------
	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site Address Details Page
	Set objMsg = objPage.Webelement("webElmSiteAddress")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Adree Details page","Should be navigated to Site Address t Details  page on clicking Next Buttton","Not navigated to Site Address  Details page on clicking Next Buttton","FAIL","TRUE")
		
	Else
		strMessage = GetWebElementText("webElmSiteAddress")
		Call ReportLog("Site Address  Details page","Should be navigated to Site Address  Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End function

'*************************************************************************************************************************************
'	End of function
'**************************************************************************************************************************************

