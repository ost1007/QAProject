'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ConferSiteAddress()
' Purpose	 	 : Function to enter values in Site address
' Author	 	 : Biswabharati Sahoo
' Creation Date    : 14/08/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_ConferSiteAddress()

	Dim strRetrievedText,objMsg

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
	'-----------------------------------Capturing the values in Site Address page-----------------------------------------------------------

	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtFloor").GetROProperty("Value")
	Call ReportLog("Floor No","Floor No  should be populated","Floor No  is populated with the value - "&strRetrievedText,"PASS","")

	strRetrievedText =	Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtRoom").GetROProperty("Value")
	Call ReportLog("Room No","Room No  should be populated","RoomNo  is populated with the value - "&strRetrievedText,"PASS","")

	strRetrievedText =Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtBuildingNumber").GetROProperty("Value")
	Call ReportLog("Building No","Building No  should be populated","Building No  is populated with the value - "&strRetrievedText,"PASS","")

	strRetrievedText =Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtStreet").GetROProperty("Value")
	Call ReportLog("StreetNo","Street  No should be populated","Street No  is populated with the value - "&strRetrievedText,"PASS","")

	strRetrievedText =Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtCity").GetROProperty("Value")
	Call ReportLog("City No","City No  should be populated","City No  is populated with the value - "&strRetrievedText,"PASS","")

	strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtPostOrZIPCode").GetROProperty("Value")
	Call ReportLog("Post No","Post No  should be populated","Post No  is populated with the value - "&strRetrievedText,"PASS","")

	'--------------------------Click on Next Button-----------------------------------------

	blnResult = clickButton("btnNext")
	If blnResult = False Then
		Environment("Action_Result") = False
		Call EndReport()
		Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site Contact  Details Page
	Set objMsg = objPage.Webelement("webElmSiteContactDetails")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Contact Details page","Should be navigated to Site Contact Details  page on clicking Next Buttton","Not navigated to Site Contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSiteContactDetails")
    	Call ReportLog("Site Contact Details page","Should be navigated to Site Contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'*************************************************************************************************************************************
'	End of function
'**************************************************************************************************************************************