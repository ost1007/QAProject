'****************************************************************************************************************************
' Function Name	 : fn_AIB_Logout
'
' Purpose	 	 : Logout from AIB Application
'
' Author	 	 :Suresh HS
'
' Creation Date  : 15/4/2014
'
' Parameters	 :
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_AIB_Logout()

	If Browser("brwAIB").Exist(0) Then
		'Build web reference
		blnResult = BuildWebReference("brwAIB","pgAIB","")
		If blnResult= "True" Then
			objBrowser.Close
			blnResult = Browser("brwAIB").Page("pgAIB").Exist(3)
			If blnResult = "True" Then
				Call ReportLog("AIB Logout","Should be able to close AIB Application","AIB Application is not yet closed","FAIL","True")
				Environment("Action_Result") = False
			Else 
				Call ReportLog("AIB Logout","Should be able to close AIB Application","AIB  Application is closed","PASS","")
				Environment("Action_Result") = True
			End If
		End If
	End If

End function
