'=============================================================================================================
'Description: Function to Update One Cloud Cisco Site RFO Sheet
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			30/09/2014 	v1.0
'Example: fn_SQE_UpdateOneCloudCiscoSiteSheet(dRFOFilePath, dCustNwSetID, dInternalTrunkRef)
'=============================================================================================================
Public Function fn_SQE_UpdateOneCloudCiscoSiteSheet(ByVal dRFOFilePath, ByVal dCustNwSetID, ByVal dInternalTrunkRef,ByVal dStartTelephoneNumber, ByVal dEndTelephoneNumber, ByVal dStartExtn, ByVal dEndExtn)
	On Error Resume Next
		Set objFSO = CreateObject("Scripting.FileSystemObject")

    If Err.Number <> 0 Then
		Set objFSO = Nothing
		Call ReportLog("File System Object","File System Object should get created","File System Object is not created","FAIL","True")
		On Error GoTo 0
		Exit Function
	End If		
	
	'Create Excel Application Object	   
	Set objExcel = CreateObject("Excel.Application")
	If Err.Number <> 0 Then
		Set objFSO = Nothing		
		Set objExcel = Nothing
		Call ReportLog("EXCELObject","Excel Object should get created","Excel Object is not created","FAIL","True")
		On Error GoTo 0
		Exit Function
	End If	

	'Check file is exist or not
	If objFSO.FileExists(dRFOFilePath) Then
		objExcel.Workbooks.Open dRFOFilePath
		objExcel.Application.Visible = False
		objExcel.DisplayAlerts = False
	Else
		Call ReportLog("RFO Sheet","RFO Sheet should exist in the location - "&strRFOLocation,"RFO Sheet does not exist in the location - "&strRFOLocation,"FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If

	'Fill the Details in Order Details Sheet
    iColCounter = objExcel.Worksheets("Order Details").Columns.Count
	For intCounter = 1 to iColCounter
		strColName = objExcel.Worksheets("Order Details").Cells(1, intCounter).Value
		If strColName <> "" Then
			Select Case Trim(strColName)
				Case "Order Form Signed Date (M)", "Order Form Signed Date (M) (dd/mm/yyyy)", "Order Form Signed Date [YYYY-MMM-DD] (M)"
					objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date
'				Case "Contract Start Date (M)" 
'					objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d", 10, Date)
				Case "Customer Required Date (M)", "Customer Required Date (M) (dd/mm/yyyy)", "Customer Required Date [YYYY-MMM-DD] (M)"
					objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d", 10, Date)
				Case "Billing Id (M)", "Billing Id - Billing Account Name (M)"
					Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
					If ObjRange.Validation.Type = 3 Then
						'strValue = objRange.Validation.Formula1
						arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
					End If
					'objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = strValue				
					If IsArray(arrValues) Then
						objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues(1,1)
					Else
						objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues
					End If
			End Select
		Else
			Exit For
		End If
	Next
   
	'Fill the 2nd sheet -  One Cloud Cisco - Site
	Err.Clear
	Set objSheet = objExcel.Worksheets("One Cloud Cisco - Site")
	If Err.Number <> 0 Then
		Err.Clear
		Set objSheet = objExcel.Worksheets("One Cloud Cisco Site")
	End If

	objSheet.Activate

	iColCounter = objSheet.UsedRannge.Columns.Count
	iRowCounter = objSheet.UsedRange.Rows.Count

	For intCounter = 1 to iColCounter
		Err.Clear
		strColName = objSheet.Cells(2, intCounter).Value
		If strColName <> "" Then
			Select Case Trim(strColName)
				Case "Maximum Concurrent Voice Calls (M)"
					objSheet.Cells(3, intCounter).Value = "50"

				Case "Maximum Concurrent Video Calls (M)"
					objSheet.Cells(3, intCounter).Value = "50"

				Case "Break-In Break-Out Mode (M)"
					objSheet.Cells(3, intCounter).Value = "Central BIBO"

				Case "Existing IP Address Space (M)"
					objSheet.Cells(3, intCounter).Value = "192.10.14.21"

				Case "Cust NW Set OSS ID (M)"
					objSheet.Cells(3, intCounter).Value = dCustNwSetID

				Case "StartTelephone Number (M)", "Start Telephone Number (M)"
					iCol = objSheet.Cells.Find("Private_SLC (O)").Column
					For iRow = 3 to iRowCounter
						If CStr(objSheet.Cells(iRow, iCol)) <> ""  Then
							objSheet.Cells(iRow, intCounter) = dStartTelephoneNumber
						End If
					Next

				Case "start_pvt_ext_no (O)"
					iCol = objSheet.Cells.Find("Private_SLC (O)").Column
					For iRow = 3 to iRowCounter
						If CStr(objSheet.Cells(iRow, iCol)) <> ""  Then
							objSheet.Cells(iRow, intCounter) = dStartExtn
						End If
					Next

				Case "End Telephone number (M)", "End Telephone Number (M)"
					iCol = objSheet.Cells.Find("Private_SLC (O)").Column
					For iRow = 3 to iRowCounter
						If CStr(objSheet.Cells(iRow, iCol)) <> ""  Then
							objSheet.Cells(iRow, intCounter) = dEndTelephoneNumber
						End If
					Next

				Case "end_pvt_ext_no (O)"
					iCol = objSheet.Cells.Find("Private_SLC (O)").Column
					For iRow = 3 to iRowCounter
						If CStr(objSheet.Cells(iRow, iCol)) <> ""  Then
							objSheet.Cells(iRow, intCounter) = dEndExtn
						End If
					Next

				Case "Internal Trunk Reference (M)"
					iCol = objSheet.Cells.Find("Private_SLC (O)").Column
					For iRow = 3 to iRowCounter
						If CStr(objSheet.Cells(iRow, iCol)) <> ""  Then
							objSheet.Cells(iRow, intCounter) = dInternalTrunkRef
						End If
					Next

			End Select
		Else
			Exit for
		End If
	Next

	'Save XL book
	objExcel.ActiveWorkbook.Save

     If Err.Number <> 0 Then
		Set objExcel = Nothing
		Set objFSO = Nothing
		Call ReportLog("RFO Sheet","RFO Sheet should be saved in the location - "&strRFOLocation,"RFO Sheet cannot be saved in the location - "&strRFOLocation,"FAIL","True")
		On Error GoTo 0
		Exit Function
	End If				
	
	'Close workbook and quit Excel.	
	objExcel.ActiveWorkbook.Close(True)
	objExcel.Application.Quit
	
	'Deinitialise created objects	
	Set objFso = Nothing		
	Set objExcel = Nothing

End Function
