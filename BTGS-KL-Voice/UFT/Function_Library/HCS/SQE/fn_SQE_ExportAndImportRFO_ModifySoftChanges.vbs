'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ExportAndImportRFO
' Purpose				: 		Function to export and import RFO
' Author				:		Anil Pal
' Creation Date  		 : 		  08/7/2014
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_ExportAndImportRFO_ModifySoftChanges(dRFOLocation,dCustNwSetID)

	'Declaring of variables
	Dim blnResult
	Dim strRFOLocation

	'Assigning variables
	strRFOLocation = dRFOLocation
	strCustNwSetID = dCustNwSetID
	
	'Export RFO Sheet
	strFileName = fn_SQE_ExportRFO(dRFOLocation)
		If Not Environment("Action_Result") Then Exit Function
	
	'Open,Update,Save and Close RFOSheet from the saved location
	Call fn_SQE_UpdateRFOSheet_ModifySoft_Changes(strFileName, strCustNwSetID)
		If Not Environment("Action_Result") Then Exit Function
	
	'Import Updated RFO Sheet
	Call fn_SQE_ImportRFO(strFileName)
		If Not Environment("Action_Result") Then Exit Function
	
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
