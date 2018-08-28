'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_Logout
' Purpose	 	 : Function to Verify technical Elements displayed in Application
' Author	 	  	: Nagaraj V || 19/11/2015 || #N/A
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_TAHITI_Logout()
	'Building Reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	clickLink("lnkLogout")
	Wait 5
	
	objBrowser.CloseAllTabs
End Function
