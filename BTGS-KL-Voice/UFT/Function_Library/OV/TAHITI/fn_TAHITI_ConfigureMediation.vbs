'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_ConfigureMediation
'
' Purpose	 	 : Function to Configure Mediation
'
' Author	 	 : Vamshi Krishna G
'Modified by	 : Linta C.K.
'
' Creation Date  	 : 18/12/2013
'Modified date	:	02/05/2014
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_TAHITI_ConfigureMediation(dCONFIGURE_MEDIATION)

	'Assigning values to an array
	Dim arrCONFIGURE_MEDIATION,arrValues
	arrCONFIGURE_MEDIATION = Split(dCONFIGURE_MEDIATION,",")
	intUBound = UBound(arrCONFIGURE_MEDIATION)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrCONFIGURE_MEDIATION(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrCONFIGURE_MEDIATION(intCounter),":")(1)
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		
		Exit Function
	End If
	
	If objFrame.WebEdit("txtServiceLocationID").Exist Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "ServiceLocationID" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		'Entering the Service Location ID
		objFrame.WebEdit("txtServiceLocationID").Click
		blnResult = enterFrameText("txtServiceLocationID",strData)			'strServiceLocationID)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	End If
		

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

