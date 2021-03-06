'========================================================================================================================================================
' Function Name	: fn_Expedio_ClickQuickLink
' Purpose	 	: Function to click on Quick Link
' Author	 	 	: Linta CK
' Creation Date  	: 16/07/2014
' Parameters		: dTypeOfOrder, dQuickLinkName                					     
' Return Values	: Not Applicable
'========================================================================================================================================================
Public Function fn_Expedio_ClickQuickLink(ByVal QuickLinkName)

	'Variable Declaration Section
	Dim strMessage, strQuickLinkName
	Dim blnResult
	Dim intCounter
	Dim elm

	'Assignment of Variables
	Select Case QuickLinkName
		Case "IPSDK WEB GUI"
			strQuickLinkName = "lnkIPSDKWEBGUI"
			Set elm = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebElement("elmSalesChannel")
		Case "IPSDK Track Orders"
			strQuickLinkName = "lnkIPSDKTrackOrders"
			Set elm = Browser("brwIPSDKTrackOrder").Page("pgIPSDKTrackOrder").WebElement("elmSearchOrder")
	End Select

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwHomePage(Search)","pgHomePage(Search)","")
		If Not blnResult Then Environment("Action_Result")=False  : Exit Function
		
	Browser("brwHomePage(Search)").Page("pgHomePage(Search)").Sync

	blnResult = objPage.Link(strQuickLinkName).Exist(60)
	If blnResult Then
		blnResult = clickLink(strQuickLinkName)
			If Not blnResult Then Environment("Action_Result")=False  : Exit Function
	Else
		Call ReportLog("EXPEDIO Quick Link","User should be able to view the Quick Link - " & strQuickLinkName & " on Application List Frame.","User is not able to view the Quick Link - " & strQuickLinkName & " on Application List Frame.","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 to 50
		blnResult = elm.Exist(30)
		If Not blnResult Then
			Wait 5
		Else
			strMessage = elm.GetROProperty("innertext")
			Call ReportLog("Navigation on clicking Quick Link","User navigation should be succesful","User succesfully navigated to page - " & strMessage ,"PASS", False)
			Exit For
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Navigation on clicking Quick Link","User navigation should be succesful","User navigation is not succesful", "FAIL", True)
		Environment.Value("Action_Result")=False : Exit Function
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
