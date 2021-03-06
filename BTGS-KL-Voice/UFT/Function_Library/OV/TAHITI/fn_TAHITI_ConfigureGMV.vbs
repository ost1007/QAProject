'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_ConfigureGMV
'
' Purpose	 	 : Function to Configure GMV task
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_ConfigureGMV(dCONFIGURE_GMV)

	'Declaration of variables
	Dim intUBound
	Dim arrConfigureGMV,arrValues

	'Assigning values to an array
	arrCONFIGURE_GMV = Split(dCONFIGURE_GMV,",")
	intUBound = UBound(arrCONFIGURE_GMV)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrCONFIGURE_GMV(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrCONFIGURE_GMV(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	If objFrame.WebEdit("txtPresentationCLI").Exist(10) Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "PresentationCLI" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
	
		'PresentationCLI  Executed
		blnResult = enterFrameText("txtPresentationCLI",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

    If objFrame.WebEdit("txtDefaultExtensionNumber").Exist(10) Then

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "DefaultExtensionNumber" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
	
		'DefaultExtensionNumber Result
		blnResult = enterFrameText("txtDefaultExtensionNumber",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End if

	If objFrame.WebEdit("txtSwitchCode").Exist(10) Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "SwitchCode" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
	
		'DefaultExtensionNumber Result
		blnResult = enterFrameText("txtSwitchCode",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End if

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
