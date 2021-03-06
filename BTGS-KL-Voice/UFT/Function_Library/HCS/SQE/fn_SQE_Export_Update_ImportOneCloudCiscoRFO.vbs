'=============================================================================================================
'Description: Wrapper Function to Export, Update and import One Cloud Product RFo Sheet
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			30/09/2014 	v1.0
'Example: fn_SQE_Export_Update_ImportOneCloudCiscoRFO(dRFOLocation, dCustNwSetID, dInternalTrunkRef)
'=============================================================================================================
Public Function fn_SQE_Export_Update_ImportOneCloudCiscoRFO(ByVal dRFOLocation, ByVal dCustNwSetID, ByVal dInternalTrunkRef, ByVal dStartTelephoneNumber, ByVal dEndTelephoneNumber, ByVal dStartExtn, ByVal dEndExtn)

	Dim strFilePath 
	
	strFilePath = fn_SQE_ExportRFO(dRFOLocation)
	If Not Environment("Action_Result") Then
		Call ReportLog("Export RFO","RFO Sheet should be downloaded successfully","Encountered Error while downloading RFO Sheet - " & Err.Number & " || " & Err.Description ,"FAIL","False")
		Exit Function
	End If

	Call fn_SQE_UpdateOneCloudCiscoSiteSheet(strFilePath, dCustNwSetID, dInternalTrunkRef, dStartTelephoneNumber, dEndTelephoneNumber, dStartExtn, dEndExtn)
	If Not Environment("Action_Result") Then
		Call ReportLog("Update RFO","RFO Sheet should be Updated successfully","Encountered Error while Updating RFO Sheet - " & Err.Number & " || " & Err.Description  ,"FAIL","False")
		Exit Function
	End If

	Call fn_SQE_ImportRFO(strFilePath)
	If Not Environment("Action_Result") Then
		Call ReportLog("Import RFO","RFO Sheet should be uploaded successfully","Encountered Error while Uploading RFO Sheet - " & Err.Number & " || " & Err.Description ,"FAIL","False")
		Exit Function
	End If	
End Function
