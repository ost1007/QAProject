
Public Function fn_SQE_UpdateRFOSheet(dRFOLocation,dCustNwSetID,dOrderType)
	'Declaring Variables
	Dim strRFOLocation, strBillingID
	Const xlCellTypeVisible = 12, xlCellTypeAllValidation = -4174
	Dim blnUpdateError

	'Assigning Variables
	strRFOLocation = dRFOLocation
	strCustNwSetID = dCustNwSetID
	Err.Clear
	
	'Create file system object   
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Wait 5	
      If Err.Number <> 0 Then
		Set objFSO = Nothing
		Call ReportLog("File System Object","File System Object should get created","File System Object is not created","FAIL","True")
		On Error GoTo 0
		Exit Function
	End If
	
	'Create Excel Application Object	   
	Set objExcel = CreateObject("Excel.Application")
	Wait 5
	If Err.Number <> 0 Then
		Set objFSO = Nothing		
		Set objExcel = Nothing
		Call ReportLog("EXCELObject","Excel Object should get created","Excel Object is not created","FAIL","True")
		On Error GoTo 0
		Exit Function
	End If	

	'Check file is exist or not
	If objFSO.FileExists(strRFOLocation) Then
		objExcel.Workbooks.Open strRFOLocation
		objExcel.Application.Visible = False
		objExcel.DisplayAlerts = False
	Else
		Call ReportLog("RFO Sheet","RFO Sheet should exist in the location - "&strRFOLocation,"RFO Sheet does not exist in the location - "&strRFOLocation,"FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

      iColCounter = objExcel.Worksheets("Order Details").Columns.Count

	For intCounter = 1 to iColCounter
		blnUpdateError = False
		strColName = Trim(objExcel.Worksheets("Order Details").Cells(1, intCounter).Value)
		If strColName <> "" Then
				If strColName = "Sublocation Name (M)" OR strColName = "SubLocation ID (M)" OR strColName = "Room (M)" OR strColName = "Floor (M)" Then
						Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
						If ObjRange.Value = "" Then
							On Error Resume Next
								Err.Clear
								If ObjRange.Validation.Type = 3 Then 'Validation for Cell have been applied
									arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
									If IsArray(arrValues) Then
										objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues(1,1)
									Else
										objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues
									End If
								End If
								Set ObjRange = Nothing
								If Err.Number <> 0 Then blnUpdateError = True					
							On Error Goto 0
						End If
						
						If blnUpdateError Then
							Call ReportLog("Update Error", strColName & " - Unable to update Column", "Please contact Automation Team</BR" & Err.Number & "</BR>" & Err.Description, "FAIL", False)
							objExcel.ActiveWorkbook.Close(True)
							objExcel.Application.Quit
							Err.Clear
							Environment("Action_Result") = False
							Exit Function
						End If
						
						'Below Code works when Sheet is unprotected
						'Set intersectRange = objExcel.Application.Intersect(objExcel.Worksheets("Order Details").UsedRange.SpecialCells(xlCellTypeAllValidation), _
						'		objExcel.Worksheets("Order Details").UsedRange.SpecialCells(xlCellTypeVisible))
						'If objExcel.Application.Intersect(ObjRange, intersectRange) Is Nothing Then 'Has Validation Applied
							
						'End If						
				
				ElseIf Instr(strColName, "Order Form Signed Date") > 0 Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date					
						End If
				
				ElseIf Instr(strColName, "Contract Start Date") > 0 Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date + 1				
						End If
						
				ElseIf Instr(strColName, "Customer Required Date") Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d", 7, Date)
						End If
						
				ElseIf Instr(strColName, "Billing Id") Then
						Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked Then
							strBillingID = Trim(objExcel.Worksheets("Order Details").Cells(2, intCounter).Value)
							If strBillingID <> "" Then
								Call ReportLog("RFO Sheet", "Billing ID is autoPopulated", "Billing ID is populated with " & strBillingID, "Information", False)
							Else
								Call ReportLog("RFO Sheet", "Billing ID Field is locked", "Billing ID Cell is locked, please raise an issue with Component Team", "FAIL", False)
								Environment("Action_Result") = False
							End If
						Else
							If Trim(objExcel.Worksheets("Order Details").Cells(2,intCounter).Value) = "" Then
								If ObjRange.Validation.Type = 3 Then
									arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
									If IsArray(arrValues) Then
										objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues(1,1)
									Else
										objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues
									End If
								End If
							End If
						End If
				End If
		Else
				Exit For
		End If
	Next

	If Not (dOrderType = "Cease" OR dOrderType = "Modify") Then
		'Fill the 2nd sheet - One Cloud Cisco Contract
		objExcel.Worksheets("One Cloud Cisco").Activate
		iColCounter = objExcel.Worksheets("One Cloud Cisco").Columns.Count
		iColCounter = objExcel.Worksheets("One Cloud Cisco").Columns.Count
		VPN_Number = RandomNumber(10000,999999)
		For intCounter = 1 to iColCounter
			strColName = objExcel.Worksheets("One Cloud Cisco").Cells(2, intCounter).Value
			If strColName <> "" Then
				Select Case Trim(strColName)
					Case "VPNN Identifier (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "VPNN"&VPN_Number
						End If
					Case "VPN Identifier (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "VPN"&VPN_Number
						End If
					Case "FTIP Identifier (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "FTIP"&VPN_Number
						End If
					Case "Customer Network Set OSS ID (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = strCustNwSetID
						End If
					Case "Call Commitment (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "yes"
						End If
					Case "Existing IP Address Space (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "192.10.1.1/24"
						End If
					Case "Softex Report Required (M)" '''''Test
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "No"
						End If
					Case "PGW Customer Identifier (M)"
						If objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Locked And objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("One Cloud Cisco").Cells(3, intCounter).Value = "99"
						End If
				End Select
			Else
				Exit for
			End If
		Next
	End If
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
	objExcel.ActiveWorkbook.Close
	objExcel.Application.Quit
	
	'Deinitialise created objects	
	Set objFSO = Nothing		
	Set objExcel = Nothing

End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
