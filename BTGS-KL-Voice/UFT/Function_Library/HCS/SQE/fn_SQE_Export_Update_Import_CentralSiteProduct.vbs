'=============================================================================================================
'Description: Wrapper Function to Export, Update and import Cebtral Site Product
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			23/03/2015 	v1.0
'Modified By  :   Nagaraj			1902/2016	v1.1
'Example: fn_SQE_Export_Update_Import_CentralSiteProduct(dRFOLocation, TelephoneNumber)
'=============================================================================================================
Public Function fn_SQE_Export_Update_Import_CentralSiteProduct(ByVal dRFOLocation, ByVal TelephoneNumber,ByVal NoOfChannels, ByVal CustNWSetOSSID, ByVal ExistingIPAddressSpace)

	'Variable Declaration
	Dim strFilePath 
	
	strFilePath = fn_SQE_ExportRFO(dRFOLocation)
	If Not Environment("Action_Result") Then
		Call ReportLog("Export RFO","RFO Sheet should be downloaded successfully","Encountered Error while downloading RFO Sheet - " & Err.Number & " || " & Err.Description ,"FAIL","False")
		Exit Function
	End If

	Call fn_SQE_UpdateCentralSiteProductSheet(strFilePath, TelephoneNumber, NoOfChannels, CustNWSetOSSID, ExistingIPAddressSpace)
	If Not Environment("Action_Result") Then
		Call ReportLog("Update RFO","RFO Sheet should be Updated successfully","Encountered Error while Updating RFO Sheet - " & Err.Number & " || " & Err.Description  ,"FAIL","False")
		Exit Function
	End If

	Call fn_SQE_ImportRFO(strFilePath)
	If Not Environment("Action_Result") Then
		'Call ReportLog("Import RFO","RFO Sheet should be uploaded successfully","Encountered Error while Uploading RFO Sheet - " & Err.Number & " || " & Err.Description ,"FAIL","False")
		Exit Function
	End If	
End Function

'===============================================================================================================================================================================

'===============================================================================================================================================================================

Public Function fn_SQE_UpdateCentralSiteProductSheet(ByVal dRFOFilePath, ByVal TelephoneNumber, ByVal NoOfChannels, ByVal CustNWSetOSSID, ByVal ExistingIPAddressSpace)
	On Error Resume Next
	Dim objFSO
	Dim strProductName

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
		strActualValue = Trim(objExcel.Worksheets("Order Details").Cells(2, intCounter).Value)
		If strColName <> "" Then
				If Instr(strColName, "Product Name") > 0 Then
					strProductName = objExcel.Worksheets("Order Details").Cells(2, intCounter).Value
					
				ElseIf strColName = "Sublocation Name (M)" OR strColName = "SubLocation ID (M)" OR strColName = "Room (M)" OR strColName = "Floor (M)" Then						
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
						
				
				ElseIf Instr(strColName, "Order Form Signed Date") > 0  Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date					
						End If
						
				ElseIf Instr(strColName, "Customer Required Date") Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d", 7, Date)
						End If

				ElseIf Instr(strColName, "Contract Start Date") Then
						If objExcel.Worksheets("Order Details").Cells(2, intCounter).Locked And objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = "" Then
							Call ReportLog("RFO Sheet", strColName & " is disabled in RFO Sheet", strColName & " is disabled in RFO Sheet, please raise an issue with Component Team", "FAIL", False)
							Environment("Action_Result") = False
						Else
							objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("m", -2, Date)
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
		
				'Select Case Trim(strColName)
				'	Case "Product Name"
				'		strProductName = objExcel.Worksheets("Order Details").Cells(2, intCounter).Value 
				'	Case "Order Form Signed Date (M)", "Order Form Signed Date (M) (dd/mm/yyyy)", "Order Form Signed Date [DD/MM/YYYY] (M)", "Order Form Signed Date [YYYY-MMM-DD] (M)"
				'		objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = Date
				'	Case "Customer Required Date (M)", "Customer Required Date (M) (dd/mm/yyyy)", "Customer Required Date [DD/MM/YYYY] (M)", "Customer Required Date [YYYY-MMM-DD] (M)"
				'		objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = DateAdd("d", 10, Date)
				'	Case "Billing Id (M)", "Billing Id - Billing Account Name (M)"
				'		Set ObjRange = objExcel.Worksheets("Order Details").Cells(2,intCounter)
				'		If ObjRange.Validation.Type = 3 Then
				'			arrValues = objExcel.Worksheets("Order Details").Range(objRange.Validation.Formula1).Value
				'		End If
				'		If IsArray(arrValues) Then
				'			objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues(1,1)
				'		Else
				'			objExcel.Worksheets("Order Details").Cells(2, intCounter).Value = arrValues
				'		End If
				'End Select
		Else
			Exit For
		End If
	Next

	If strProductName = "Operator Console (Seat)" OR strProductName = "Auto Attendant Starter Pack" Then
			Err.Clear
			Set objSheet = objExcel.Worksheets(strProductName)
			If Err.Number <> 0 Then
				Err.Clear
				Set objSheet = objExcel.Worksheets(strProductName)
			End If
		
			objSheet.Activate
		
			iColCounter = objSheet.UsedRannge.Columns.Count
			iRowCounter = objSheet.UsedRange.Rows.Count
		
			For intCounter = 1 to iColCounter
				Err.Clear
				strColName = objSheet.Cells(2, intCounter).Value
				If strColName <> "" Then
					Select Case Trim(strColName)
						Case "Existing IP Address Space (M)"
							objSheet.Cells(3, intCounter).Value = ExistingIPAddressSpace
						Case "Telephone Number (M)"
							objSheet.Cells(3, intCounter).Value = TelephoneNumber					
					End Select
				Else
					Exit for
				End If
			Next
	ElseIf strProductName = "SIP Trunk Service" Then
			Set objSheet = objExcel.Worksheets(strProductName)
			objSheet.Activate
			iColCounter = objSheet.UsedRannge.Columns.Count
			iRowCounter = objSheet.UsedRange.Rows.Count
			For intCounter = 1 to iColCounter
				Err.Clear
				strColName = objSheet.Cells(2, intCounter).Value
				If strColName <> "" Then
					Select Case Trim(strColName)
						Case "Number of Channels (M)"
							objSheet.Cells(3, intCounter).Value = NoOfChannels
						Case "Cust NW Set OSS ID (M)"
							objSheet.Cells(3, intCounter).Value = CustNWSetOSSID
					End Select
				Else
					Exit for
				End If
			Next '#intCounter
			
	ElseIf strProductName = "Voice Lync Integration" Then
			
			Set objSheet = objExcel.Worksheets(strProductName)
			objSheet.Activate
			iColCounter = objSheet.UsedRannge.Columns.Count
			iRowCounter = objSheet.UsedRange.Rows.Count
			For intCounter = 1 to iColCounter
				Err.Clear
				strColName = objSheet.Cells(2, intCounter).Value
				If strColName <> "" Then
					Select Case Trim(strColName)
						Case "Existing IP Address Space (M)"
							objSheet.Cells(3, intCounter).Value = ExistingIPAddressSpace
					End Select
				Else
					Exit for
				End If
			Next '#intCounter
		
	End If '#strProductName

	'Save XL book
	objExcel.ActiveWorkbook.Save

	'If Err.Number <> 0 Then
	'	Set objExcel = Nothing
	'	Set objFSO = Nothing
	'	Call ReportLog("RFO Sheet","Error Encountered while updating sheets","Error Encountered while updating sheets","FAIL",False)
	'	On Error GoTo 0
	'	Exit Function
	'End If				
		
	'Close workbook and quit Excel.	
	objExcel.ActiveWorkbook.Close(True)
	objExcel.Application.Quit
	
	'Deinitialise created objects	
	Set objFso = Nothing		
	Set objExcel = Nothing
End Function
