'***************************************************************************************************************************************************************************
' Function Name 		:	fn_Expedio_Get_URL
' Purpose			: 	Function to to fetch the rSQE landing page URL and Quote Id
' Author				:	Anil Pal || 03/9/2014
' Modified by		 	: 	Nagaraj V || 07/09/2015 || Removed unwanted parameter and refined the code to handle failures
' Return Values	 	: 	Not Applicable
'***************************************************************************************************************************************************************************
Public Function fn_Expedio_Get_URL()

	Dim strQuoteID, strLandingPageURL
	Dim objExpedioErrorElement
	Err.Clear
	'Closing the Pop Message Box
	If Browser("brwBMCRemedyMidTier7.1").Dialog("dlgWindowsInternetExplorer").Exist(10) Then 
		Browser("brwBMCRemedyMidTier7.1").Dialog("dlgWindowsInternetExplorer").WinButton("btnYes").HighLight
		Browser("brwBMCRemedyMidTier7.1").Dialog("dlgWindowsInternetExplorer").WinButton("btnYes").Click
	End If		

	Set objIPSDKProductBundlingPage = Browser("name:=IPSDK Product Bundling").Page("title:=IPSDK Product Bundling")

	'Updating the Data Sheet with the Quote ID and rSQELanding Page URL
	If objIPSDKProductBundlingPage.Exist(120) Then
		strLandingPageURL = objIPSDKProductBundlingPage.GetROProperty("url")

		Set objExpedioErrorElement = objIPSDKProductBundlingPage.WebElement("innertext:=Could not retrieve required information form Expedio.*", "index:=0")
		If objExpedioErrorElement.Exist(5) And objExpedioErrorElement.GetROProperty("height") > 0 Then
			objIPSDKProductBundlingPage.HighLight
			CreateObject("WScript.Shell").SendKeys "{F5}"
			Wait 5
			objIPSDKProductBundlingPage.Sync
		End If

		If strLandingPageURL <> "" Then
			Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dSQEURL", strLandingPageURL)
			Call ReportLog("rSQE Landing Page URL","rSQE Landing Page URL","rSQE Landing Page URL is " & strLandingPageURL ,"INFORMATION", False)

			On Error Resume Next
				For intCounter = 1 to 5
					strQuoteID = Trim(objIPSDKProductBundlingPage.WebElement("innertext:=^\d+$", "index:=0").GetROProperty("innertext"))
					If Err.Number <> 0 OR strQuoteID = "" Then
						objIPSDKProductBundlingPage.HighLight
						CreateObject("WScript.Shell").SendKeys "{F5}"
						Wait 10
						Err.Clear
					Else
						Exit For
					End If
				Next
			On Error Goto 0
			If strQuoteID = "" Then
				Call ReportLog("rSQE Landing Page URL","rSQE Landing Page Quote ID should exist","rSQE Landing Page Quote ID is not populated", "FAIL", False)
				Environment("Action_Result") = False : Exit Function
			End If
				
			Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dQuoteID", strQuoteID)
			Call ReportLog("rSQE Landing Page URL","rSQE Landing Page URL and Quote ID should exist","rSQE Landing Page URL and Quote ID is "& strQuoteID ,"PASS","TRUE")
		Else 
			Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","rSQE Landing Page is not launched", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End if 
	ElseIf Browser("name:=SQE - Planned Maintenance").Exist(5) Then
		Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","Planned Maintenance is being carried out by SQE", "FAIL", True)
		Environment("Action_Result") = False
	Else
		Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","Could not navigate to rSQE Landing Page URL", "FAIL", True)
		Environment("Action_Result") = False
	End If
End Function
