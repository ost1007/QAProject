'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ExportAndImportRFO
' Purpose				: 		Function to Export and Import RFO
' Author				:		Linta C.K.
' Creation Date  		: 		08/7/2014
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ExportAndImportRFO(dRFOLocation, dCustNwSetID, dOrderType)

	'Declaring of variables
	Dim blnResult
	Dim strRFOLocation, strFileName

	'Assigning variables
	strRFOLocation = dRFOLocation
	strCustNwSetID = dCustNwSetID

	'---commented download RFO manually---
	strFileName = fn_SQE_ExportRFO(dRFOLocation)
		If Not Environment("Action_Result") Then Exit Function
	'-------------------------------------

	'Open,Update,Save and Close RFOSheet from the saved location
	Call fn_SQE_UpdateRFOSheet(strFileName, dCustNwSetID, dOrderType)
		If Not Environment("Action_Result") Then Exit Function
	
	'Import Updated RFO Sheet
	Call fn_SQE_ImportRFO(strFileName)
		If Not Environment("Action_Result") Then Exit Function

End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
