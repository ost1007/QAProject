'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CaptureInstanceCharacteristics
'
' Purpose					: 			Function to capture values from Instance Characteristics table for tasks
'
' Author					:		  	Linta CK
'Modified by			  : 		
' Creation Date   		: 			22/06/2014
'Modified Date   			:				
' Parameters	 		 :			objTbl
'                  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_AIB_CaptureInstanceCharacteristics(objTbl)

	Set objTable = objTbl
	
	'Capture the valus inside that inner table.
	intColsInstanceCharacteristics = 4		' Column No inside Instance Characteristics WebTable(bcoz its capturing the no. of columns as 1)
	intRowsInstanceCharacteristics = objTable.GetROProperty("rows")
	ReDim strColumnName(intColsInstanceCharacteristics-1)
	ReDim strColumnValue(intColsInstanceCharacteristics-1)
	For k = 3 to intRowsInstanceCharacteristics
		strResult = ""
		For j = 1 to intColsInstanceCharacteristics
			strColumnName(j-1) = objTable.GetCellData(2,j)
			strColumnValue(j-1) = objTable.GetCellData(k,j)
			If Trim(strColumnName(j-1)) = "Item Status"  Then
				If Trim(strColumnValue(j-1)) <> "Open" AND Trim(strColumnValue(j-1)) <> "Complete" Then
					Call ReportLog("Item Status","Item status should be retrived and should be 'Open/Completed'.","Item Status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
					Exit Function
				End If
			End If
			If Trim(strColumnName(j-1)) = "Item Sub-status"  Then
				If Trim(strColumnValue(j-1)) <> "In Progress" AND Trim(strColumnValue(j-1)) <> "Closed" Then
					Call ReportLog("Item Sub-status","Item Sub-status should be retrived and should be 'In Progress/Closed'.","Item Sub-status retrieved is <B>" &strColumnValue(j-1) &"<B>","FAIL","")
					Exit Function
				End If
			End If
			If strResult = "" Then
				strResult = strColumnName(j-1) & " : " & strColumnValue(j-1) 
			Else
				strResult = strResult &"<br>" & strColumnName(j-1) & " : " & strColumnValue(j-1)
			End If
		Next
		Call ReportLog("Inner Order Item table","Order Item Details should be retrived" , strResult& "<B>","PASS","")
	Next
End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************
