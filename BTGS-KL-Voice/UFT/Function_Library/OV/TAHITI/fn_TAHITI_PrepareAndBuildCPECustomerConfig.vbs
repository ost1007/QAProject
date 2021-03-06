'=============================================================================================================
'Description: Function to handle PrepareAndBuildCPECustomerConfig
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			06/08/2015 				NA
'Return Values : Boolean
'Example: PrepareAndBuildCPECustomerConfig("URL", "Username", "Password")
'=============================================================================================================
Public Function fn_TAHITI_PrepareAndBuildCPECustomerConfig(ByVal AIBURL, ByVal AIBUserName, ByVal AIBPassword)
	
	Dim intCounter
	
	fn_TAHITI_PrepareAndBuildCPECustomerConfig = True
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Click on Update rPACS Button
	If objFrame.WebButton("btnUpdaterPACS").Exist Then
		blnResult = clickFrameButton("btnUpdaterPACS")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = fn_TAHITI_HandleInteractionProcess(AIBURL, AIBUserName, AIBPassword)
			If Not blnResult Then  fn_TAHITI_PrepareAndBuildCPECustomerConfig = blnResult : Exit Function
	End If
	
End Function
