'***************************************************************************************************************************************************************************
' Function Name 		:	fn_SQE_GetURLQuoteID
' Purpose				: 	Function to to fetch the rSQE landing page URL and Quote Id
' Author				:	Anil Pal || 03/9/2014
' Modified by		 	: 	Nagaraj V || 07/09/2015 || Removed unwanted parameter and refined the code to handle failures
' Return Values	 		: 	Not Applicable
'***************************************************************************************************************************************************************************
Public Function fn_SQE_GetURLQuoteID()

	Dim strQuoteID, strLandingPageURL
	Dim objExpedioErrorElement
	Dim intCounter
	
	Err.Clear	

	Set objIPSDKProductBundlingPage = Browser("brwIPSDKProductBundling").Page("pgIPSDKProductBundling")
	'Updating the Data Sheet with the Quote ID and rSQELanding Page URL
	If objIPSDKProductBundlingPage.Exist(120) Then
		Set objBrowser = Browser("brwIPSDKProductBundling")
		strLandingPageURL = objIPSDKProductBundlingPage.GetROProperty("url")
		
		For intCounter = 1 To 10
			Browser("brwIPSDKProductBundling").fSync
		Next
		
		For intCounter = 1 To 10
			blnResult = objIPSDKProductBundlingPage.WebElement("class:=fa fa-cog fa-spin", "index:=0").Exist(30)
			If blnResult Then
				Wait 30
			Else
				Exit For
			End If
		Next
		
		Set objExpedioErrorElement = objIPSDKProductBundlingPage.WebElement("innertext:=Could not retrieve required information form Expedio.*", "index:=0")
		If objExpedioErrorElement.Exist(5) Then
			If objExpedioErrorElement.GetROProperty("height") > 0 Then
				Browser("brwIPSDKProductBundling").WinToolbar("text:=Page Control", "index:=0").Press 1
				Browser("brwIPSDKProductBundling").Sync
				Browser("brwIPSDKProductBundling").Page("pgIPSDKProductBundling").Sync
				Wait 5	
			End If
		End If

		If strLandingPageURL <> "" Then
			Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dSQEURL", strLandingPageURL)
			Call ReportLog("rSQE Landing Page URL","rSQE Landing Page URL","rSQE Landing Page URL is " & strLandingPageURL ,"INFORMATION", False)
			Browser("brwIPSDKProductBundling").fMaximize
			On Error Resume Next
				For intCounter = 1 to 5
					arrQuoteText = Split(Trim(objIPSDKProductBundlingPage.WebElement("innertext:=^0\d+\s*\|\s*", "index:=0").GetROProperty("innertext")), "|")
					strQuoteID = Trim(arrQuoteText(0))
					If Err.Number <> 0 OR strQuoteID = "" Then
						Browser("brwIPSDKProductBundling").WinToolbar("text:=Page Control", "index:=0").Press 1
						Browser("brwIPSDKProductBundling").Sync
						Browser("brwIPSDKProductBundling").Page("pgIPSDKProductBundling").Sync
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
			Call ReportLog("rSQE Landing Page URL","rSQE Landing Page URL and Quote ID should exist","rSQE Landing Page URL and Quote ID is "& strQuoteID ,"PASS", True)
		Else 
			Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","rSQE Landing Page is not launched", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	ElseIf Browser("name:=SQE - Planned Maintenance").Exist(5) Then
		Set objBrowser = Browser("name:=SQE - Planned Maintenance")
		Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","Planned Maintenance is being carried out by SQE", "FAIL", True)
		Environment("Action_Result") = False
	Else
		Call ReportLog("rSQE Landing","rSQE Landing Page should Launch","Could not navigate to rSQE Landing Page URL", "FAIL", True)
		Environment("Action_Result") = False
	End If
End Function
