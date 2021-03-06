'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_HandOverIntoMaintenance
'
' Purpose	 	 : Function to hand over the task to maintenance
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_HandOverIntoMaintenance(dHANDOVER_INTO_MAINTENANCE)

'fncHandOverItToMaintenance(CSCAccepted)

'	'Declaration of variables
'	Dim strCSCAccepted
'
'	'Assignment of variables
'	strCSCAccepted = CSCAccepted

	'Assigning values to an array
	Dim arrHANDOVER_INTO_MAINTENANCE,arrValues
	arrHANDOVER_INTO_MAINTENANCE = Split(dHANDOVER_INTO_MAINTENANCE,",")
	intUBound = UBound(arrHANDOVER_INTO_MAINTENANCE)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrHANDOVER_INTO_MAINTENANCE(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrHANDOVER_INTO_MAINTENANCE(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment("Action_Result") = False
		Exit Function
	End If

    If objFrame.WebList("lstCSCAccepted").Exist(10) Then

		wait 3
		For i = 1 to 5
			'Make the CSC accepted as Yes
			objFrame.WebList("lstCSCAccepted").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstCSCAccepted").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "CSCAccepted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

        blnResult = selectValueFromList("lstCSCAccepted",strData)			'strCSCAccepted)
		If blnResult= False Then
			Environment("Action_Result") = False
			Exit Function
		End If
	
	End If
    
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

