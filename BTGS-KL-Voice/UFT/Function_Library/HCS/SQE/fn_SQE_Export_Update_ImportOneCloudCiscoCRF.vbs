'=============================================================================================================
'Description: Wrapper Function to Export, Update and import One Cloud Product RFo Sheet uploaded via CRF Sheet
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			22/12/2014 	v1.0
'Example: fn_SQE_Export_Update_ImportOneCloudCiscoCRF(dRFOLocation)
'=============================================================================================================
Public Function fn_SQE_Export_Update_ImportOneCloudCiscoCRF(ByVal dProduct, ByVal dRFOLocation, ByVal dCustNwSetID)
	On Error Resume Next
		Dim strFilePath 
		
		strFilePath = fn_SQE_ExportRFO(dRFOLocation)
		If Not Environment("Action_Result") Then Exit Function

		Wait 10 : Err.Clear
		Set objFSO = CreateObject("Scripting.FileSystemObject")

		If Err.Number <> 0 Then
			Set objFSO = Nothing
			Call ReportLog("File System Object","File System Object should get created","File System Object is not created","FAIL","True")
			On Error GoTo 0
			Environment("Action_Result") = False : Exit Function
		End If		
		
		'Create Excel Application Object	   
		Set objExcel = CreateObject("Excel.Application")
		If Err.Number <> 0 Then
			Set objFSO = Nothing		
			Set objExcel = Nothing
			Call ReportLog("EXCELObject","Excel Object should get created","Excel Object is not created","FAIL","True")
			On Error GoTo 0
			Environment("Action_Result") = False : Exit Function
		End If	
	
		'Check file is exist or not
		If objFSO.FileExists(strFilePath) Then
			objExcel.Workbooks.Open strFilePath
			objExcel.Application.Visible = False
			objExcel.DisplayAlerts = False
		Else
			Call ReportLog("RFO Sheet Exist","RFO Sheet should exist in the location - " & strFilePath,"RFO Sheet does not exist in the location - " & strFilePath,"FAIL", False)
			Environment.Value("Action_Result") = False  
			Exit Function
		End If
	
		'Fill the Details in Order Details Sheet
		iColCounter = objExcel.Worksheets("Order Details").Columns.Count
		intRows = objExcel.Worksheets("Order Details").UsedRange.Rows.Count
		For iRow = 2 To intRows
			For intCounter = 1 to iColCounter
				strColName = objExcel.Worksheets("Order Details").Cells(1, intCounter).Value
				If strColName <> "" Then
					Select Case Trim(strColName)
						Case "Order Form Signed Date (M)", "Order Form Signed Date (M) (dd/mm/yyyy)", "Order Form Signed Date [DD/MM/YYYY] (M)", "Order Form Signed Date [YYYY-MMM-DD] (M)"
							objExcel.Worksheets("Order Details").Cells(iRow, intCounter).Value = Date
						Case "Customer Required Date (M)", "Customer Required Date (M) (dd/mm/yyyy)", "Customer Required Date [DD/MM/YYYY] (M)", "Customer Required Date [YYYY-MMM-DD] (M)"
							objExcel.Worksheets("Order Details").Cells(iRow, intCounter).Value = DateAdd("d", 10, Date)
						Case "Billing Id (M)", "Billing Id - Billing Account Name (M)"
							Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
							If objExcel.Worksheets("Order Details").Cells(iRow, intCounter).Locked Then
								If Trim(objExcel.Worksheets("Order Details").Cells(2, intCounter)) = "" Then
									Call ReportLog("Order Details Sheet", "Billing id is locked for editing","Billing id is locked for editing and is #BLANK", "FAIL", False)
									Environment("Action_Result") = False : Exit Function
								End If
							Else
								If objRange.Validation.Type = 3 Then
									arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
									'strValue = Split(objRange.Validation.Formula1, ",")
								End If
								
								If IsArray(arrValues) Then
									objExcel.Worksheets("Order Details").Cells(iRow, intCounter).Value = arrValues(1,1)
								Else
									objExcel.Worksheets("Order Details").Cells(iRow, intCounter).Value = arrValues
								End If
							End If '#locked
					End Select
				Else
					Exit For
				End If
			Next
		Next '#iRow

		Set shtProduct = objExcel.Worksheets(dProduct)
		iColCounter = shtProduct.Columns.Count
		For iCol = 1 To iColCounter
			strColName = Trim(shtProduct.Cells(2, iCol).Value)
			If strColName <> "" Then
				Select Case strColName
					Case "Cust NW Set OSS ID (M)"
						If Not shtProduct.Cells(3, iCol).Locked Then shtProduct.Cells(3, iCol).Value = dCustNwSetID
				End Select
			Else
				Exit For
			End If
		Next
		
		'Save XL book
		objExcel.ActiveWorkbook.Save
	
		 If Err.Number <> 0 Then
			Set objExcel = Nothing
			Set objFSO = Nothing
			Call ReportLog("RFO Sheet","Encountered Error while saving", Err.Number & "</BR>" & Err.Description,"FAIL", False)
			Environment("Action_Result") = False
			On Error GoTo 0
			Exit Function
		End If				
		
		'Close workbook and quit Excel.	
		objExcel.ActiveWorkbook.Close(True)
		objExcel.Application.Quit
		
		'Deinitialise created objects	
		Set objFso = Nothing		
		Set objExcel = Nothing
	
		Call fn_SQE_ImportRFO(strFilePath)
			If Not Environment("Action_Result") Then Exit Function
End Function
