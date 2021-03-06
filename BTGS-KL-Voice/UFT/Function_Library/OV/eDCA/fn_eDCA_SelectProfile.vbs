'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SelectProfile
' Purpose	 	 : Function to select required Profile in eDCA Portal Application.
' Author	 	 : Linta CK
' Creation Date  : 14/05/2013
' Parameters	 : ProfileName		: Contains Profile name to be selected to login to eDCA Portal application            				     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_SelectProfile(dSalesProfile)

	'Variable Declaration Section
	Dim strUserProfileName
	Dim strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strUserProfileName = dSalesProfile

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Select profile
	blnResult = selectValueFromPageList("lstProfile",strUserProfileName)
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLog("Select Profile","User should be able to select profile","Profile selected successfully","PASS","TRUE")
	
	'Select Product
	strSelectProduct = objpage.WebRadioGroup("radProducts").GetROProperty("checked")
	If strSelectProduct= "0" Then
		objpage.WebRadioGroup("radProducts").Select "1"
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLog("Select Profile","User should be able to select product","Product selected successfully","PASS","TRUE")

	'Click on Continue button
	blnResult = clickButton("btnContinue")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
