
Public Function fn_SQE_UpdateRFOSheet_ModifySoft_Changes(dRFOLocation,dCustNwSetID)
	On Error Resume Next
	'Declaring Variables
	Dim strRFOLocation

	'Assigning Variables
	strRFOLocation = dRFOLocation
	strCustNwSetID = dCustNwSetID
	
	Err.Clear
	'Create file system object   
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Wait 5 

  	If Err.Number <> 0 Then
		Set objFso = Nothing
		Call ReportLog("File System Object","File System Object should get created","File System Object is not created","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If		
	
	'Create Excel Application Object	   
	Set objExcel = CreateObject("Excel.Application")
	If Err.Number <> 0 Then
		Set objFso = Nothing		
		Set objExcel = Nothing
		Call ReportLog("EXCELObject","Excel Object should get created","Excel Object is not created","FAIL","True")
		Reporter.Reportevent micFail, "WriteResults", "Fail to create Excel Object"
		Exit Function
	End If	

	'Check file is exist or not
	If objFso.FileExists(strRFOLocation) Then
		Set wkBook = objExcel.Workbooks.Open(strRFOLocation)
		objExcel.Application.Visible = False
		objExcel.DisplayAlerts = False
	Else
		Call ReportLog("RFO Sheet","RFO Sheet should exist in the location - "&strRFOLocation,"RFO Sheet does not exist in the location - "&strRFOLocation,"FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

    iColCounter = objExcel.Worksheets("Order Details").Columns.Count
    iRowsCounter = objExcel.Worksheets("Order Details").UsedRange.Rows.Count

	For intCounter = 1 to iColCounter
		strColName = objExcel.Worksheets("Order Details").Cells(1, intCounter).Value
		If strColName <> "" Then
			Select Case Trim(strColName)
				Case "Order Form Signed Date (M) (dd/mm/yyyy)", "Order Form Signed Date (M)", "Order Form Signed Date [DD/MM/YYYY] (M)", "Order Form Signed Date [YYYY-MMM-DD] (M)"
					For Iterator = 2 To iRowsCounter
						objExcel.Worksheets("Order Details").Cells(Iterator, intCounter).Value = Date	
					Next
					'objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date
					'objExcel.Worksheets("Order Details").Cells(3, intCounter).Value = Date
				Case "Customer Required Date (M) (dd/mm/yyyy)", "Customer Required Date (M)", "Customer Required Date [DD/MM/YYYY] (M)", "Customer Required Date [YYYY-MMM-DD] (M)"
					'Case "Customer Required Date (M)"
					For Iterator = 2 To iRowsCounter
						objExcel.Worksheets("Order Details").Cells(Iterator, intCounter).Value = DateAdd("d",7,Date)
					Next
					'objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d",7,Date)
					'objExcel.Worksheets("Order Details").Cells(3, intCounter).Value = DateAdd("d",7,Date)
				Case "Billing Id (M)", "Billing Id - Billing Account Name (M)"
					Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
					If ObjRange.Validation.Type = 3 Then
						'strValue = objRange.Validation.Formula1
						'strValueOne = Split(strValue, ",")
						arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
					End If
					
					If IsArray(arrValues) Then
						For Iterator = 2 To iRowsCounter
							objExcel.Worksheets("Order Details").Cells(Iterator, intCounter).Value = arrValues(1,1)
						Next
						
						'objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues(1,1)
						'objExcel.Worksheets("Order Details").Cells(3, intCounter).Value = arrValues(1,1)
					Else
						For Iterator = 2 To iRowsCounter
							objExcel.Worksheets("Order Details").Cells(Iterator, intCounter).Value = arrValues
						Next
						'objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues
						'objExcel.Worksheets("Order Details").Cells(3, intCounter).Value = arrValues
					End If
			End Select
		Else
			Exit For
		End If
	Next
	
	Err.Clear
	'Save XL book
	wkBook.Save
	'objExcel.ActiveWorkbook.Save

  	If Err.Number <> 0 Then
		Set objExcel = Nothing
		Set objFso = Nothing
		Call ReportLog("RFO Sheet","RFO Sheet should be saved in the location - "&strRFOLocation,"RFO Sheet cannot be saved in the location - "&strRFOLocation,"FAIL","True")
		Call ReportLog("RFO Sheet","RFO Sheet should be saved in the location - "&strRFOLocation, Err.Description,"FAIL","True")
		Reporter.Reportevent micFail, "WriteResults", "Fail to save excel file " & gsResultPath
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

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************

	'Fill the 2nd sheet - One Cloud Cisco Contract
'	 objExcel.Worksheets("One Cloud Cisco Site").Activate
'	 iColCounter = objExcel.Worksheets("One Cloud Cisco Site").Columns.Count
'	 iColCounter = objExcel.Worksheets("One Cloud Cisco Site").Columns.Count
'	For intCounter = 1 to iColCounter
'		strColName = objExcel.Worksheets("One Cloud Cisco Site").Cells(2, intCounter).Value
'
'		If strColName <> "" Then
'			Select Case Trim(strColName)
'				Case "VPNN Identifier (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "VPNN"& RandomNumber(100,999)
'				Case "VPN Identifier (M)"
'					objExcel.Worksheets("v").Cells(3, intCounter).Value = "VPN"& RandomNumber(100,999)
'				Case "FTIP Identifier (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "FTIP"& RandomNumber(100,999)
'				Case "Customer Network Set OSS ID (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = strCustNwSetID
'				Case "Call Commitment (M)"
'					objExcel.Worksheets("v").Cells(3, intCounter).Value = "YES"
'				Case "Existing IP Address Space (M)"
'					objExcel.Worksheets("v").Cells(3, intCounter).Value = "192.0.1.1 /24"
'				Case "Softex Report Required (M)"
'					objExcel.Worksheets("v").Cells(3, intCounter).Value = "No"
'				Case "PGW Customer Identifier (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = RandomNumber(100,999)
'				Case "Trunk Group CAC Limit (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(5, intCounter).Value = RandomNumber(100,999)
'				Case "Trunk Group Friendly Name (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(5, intCounter).Value = "IDTRUNKGROUP"
'				Case "Trunk CAC Bandwidth Limit (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(5, intCounter).Value = RandomNumber(100,999)
'				Case "Trunk CAC Limit (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(5, intCounter).Value = RandomNumber(100,999)
'				Case "Trunk Friendly Name (M)"
'					objExcel.Worksheets("One Cloud Cisco").Cells(5, intCounter).Value = "IDTRUNKFRIENDLY"
'			End Select
'		Else
'			Exit for
'		End If

'	Next
