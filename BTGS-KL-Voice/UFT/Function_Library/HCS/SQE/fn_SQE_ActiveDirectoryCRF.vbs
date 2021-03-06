'****************************************************************************************************************************
' Description			  :		To Create a Loader file for Active Data Integration
' History				   : Name				Date			Changes Implemented
'			Created By   : Nagaraj V		04/06/2015			NA
'			Modified By  :
' Return Values	 	    : 			Not Applicable
' Example				 : fn_SQE_ActiveDirectoryCRF "ID|LDA ID", "C:\ADICRF.xlsx"
'****************************************************************************************************************************
Public Function fn_SQE_ActiveDirectoryCRF(ByVal ColumnNames, ByVal CRFSaveLocation)

		'Variable Declaration
		Dim wkADI, wkSheets, wkTestData, shtTestData, shtControl, shtADI
		Dim strCellValue, strColumnNameValue, strTestCaseIDRowValue, strFileFolderPath
		Dim intColumn,intColumnCounter, intTCIDRow
		Dim arrColumnNames
		
		Rem Check whether the Folder exists or not
		strFileFolderPath = Mid(CRFSaveLocation, 1, InStrRev(CRFSaveLocation, "\"))
		blnResult = CreateObject("Scripting.FileSystemObject").FolderExists(strFileFolderPath)
		If Not blnResult Then
			Call ReportLog("AD CRF Path", 	strFileFolderPath & " should exist", "Enter path <I>" & strFileFolderPath & "</I> doesn't exist", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	
		Set objExcel = CreateObject("Excel.Application")
		objExcel.Application.Visible = False
		objExcel.Application.DisplayAlerts = False
		Set wkADI = objExcel.Workbooks.Add
		Set wkSheets = wkADI.Worksheets
	
		'If only one sheet is added
		If wkSheets.Count = 1 Then
			Eval("wkADI.Sheets.Add(, wkADI.Sheets(wkADI.Sheets.Count))")
		End If
		
		'Delete all the worksheets
		For Each Sheet in wkSheets
			If Sheet.Name <> "Sheet1" AND Sheet.Name <> "Sheet2" Then
				Sheet.Delete
			End If
		Next
		
		wkADI.Sheets("Sheet1").Name = "Control Sheet"
		wkADI.Sheets("Sheet2").Name = "Active Directory Integration"
	
		'Set the Values of Control Sheet
		Set shtControl = wkADI.Sheets("Control Sheet")
		shtControl.Cells(1,1) = "'Scode" : shtControl.Cells(2,1) = "'S0336412"
		shtControl.Cells(1,2) = "'Sheet Name" : shtControl.Cells(2,2) = "'Active Directory Integration"
		shtControl.Cells.ColumnWidth = 30
	
		'Getting Reference of Test Data Sheet for Input Values
		Set wkTestData = objExcel.Workbooks.Open(Environment("TestDataPath"))
		Set shtTestData = wkTestData.Sheets(Environment("StrTestDataSheet"))
		Set strTestCaseIDRowValue = shtTestData.Cells.Find(StrTCID)
		If Not strTestCaseIDRowValue is Nothing Then
			intTCIDRow = strTestCaseIDRowValue.Row
		Else
			Call ReportLog("Get CRF Data", "Data should be searched successfully", "Unable to find Test Data for [" & StrTCID & "] in [" & Environment("TestDataPath") & "]", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
		
		Set shtADI = wkADI.Sheets("Active Directory Integration")
		arrColumnNames = Split(ColumnNames, "|")
		intColumnCounter = 1
		For Each ColumnName in arrColumnNames
			With shtADI
				.Cells(1, intColumnCounter) = Trim(ColumnName)
				.Cells(2, intColumnCounter) = Trim(ColumnName)
	
				'================== To find the ColumnHeader Values and corresponding data
				Set strColumnNameValue = shtTestData.Cells.Find("d" & Replace(Trim(ColumnName), " ", "_"))
				If Not strColumnNameValue is Nothing Then
					intColumn = strColumnNameValue.Column
				Else
					Call ReportLog("Get CRF Data", "Data should be searched successfully", "Unable to find Test Data for [" & ColumnName & "] in [" & Environment("StrTestDataSheet") & "]", "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
				strCellValue = shtTestData.Cells(intTCIDRow, intColumn)
				.Cells(3, intColumnCounter) = "'" & Trim(strCellValue)
				'================== End 
			End With
			intColumnCounter = intColumnCounter + 1
		Next

		shtADI.Cells.ColumnWidth = 30
		wkADI.SaveAs(CRFSaveLocation)
		wkTestData.Close(False)
	
		Set wkADI = Nothing
		Set wkTestData = Nothing
		objExcel.Application.DisplayAlerts = True
		objExcel.Quit
		Call ReportLog("Active Directory CRF", "CRF should be created", "Active Directory Sheet is created and stored @ " & CRFSaveLocation, "Information", False)
End Function
