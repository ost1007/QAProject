'=============================================================================================================
'Description: Function to I,port RFO and save File
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			30/09/2014 	v1.0
'Example: fn_SQE_ImportRFO(dRFOLocation)
'=============================================================================================================
Public Function fn_SQE_ImportRFO(ByVal dRFOFilePath)
   On Error Resume Next

	'Declaring of variables
	Dim blnResult
	Dim strRetrievedText
	Dim arrColumnNames
	Dim intConfiguredCol, intStatusCol, intCounter
	
	intConfiguredCol = -1 : intStatusCol = -1

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	'Click on Import RFO
	blnResult = objPage.Image("imgImportRFO").Exist
	If blnResult Then
		blnResult = clickImage("imgImportRFO")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Import RFO","Import RFO image should exist","Import RFO image does not exist","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 to 20
        If objPage.WebFile("webFileRFOSheetBrowse").Exist(15) Then
			Exit For
		End If
	Next
	
	'Click on Browse
	blnResult = objPage.WebFile("wfBrowseFileRFOSheet").Exist(60)
	If Not blnResult Then
		Call ReportLog("Click on Browse","Browse web file should exist","Browse web file does not exist","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	objPage.WebFile("wfBrowseFileRFOSheet").Click
	Call fn_SQE_HandleDialogChooseFileToUpload(dRFOFilePath)
		If Not Environment("Action_Result") Then Exit Function
	'objPage.WebFile("wfBrowseFileRFOSheet").Set dRFOFilePath : Wait 5

	'Check for upload option
	For intCounter = 1 to 10
		blnResult = objPage.WebButton("btnUpload").Exist(30)
		If blnResult Then
			objPage.WebButton("btnUpload").Click
			Exit For
		Else
			Wait 5
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Upload button","Upload button should exist","Upload button does not exist","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	blnResult = objPage.WebElement("elmUploadMsg").Exist(60*7)
	If blnResult Then
		strRetrievedText = UCase(Trim(GetWebElementText("elmUploadMsg")))
		If strRetrievedText = "UPLOAD UNSUCCESSFUL" Then
			Call ReportLog("Upload Successful","Upload should be successful","Upload was unsuccessful","FAIL", True)
			Environment.Value("Action_Result") = False
		ElseIf strRetrievedText = "UPLOAD SUCCESSFUL" Then
			Call ReportLog("Upload Successful","Upload should be successful","Upload was successful", "PASS", True)
			Wait 2
			blnResult = clickButton("btnDone")
			objBrowser.Sync : objPage.Sync
			
			If objPage.WebTable("tblOrder").Exist(120) Then
				arrColumnNames = Split(objPage.WebTable("tblOrder").GetROProperty("column names"), ";")
				For intCounter = 1 To UBound(arrColumnNames)
					If arrColumnNames(intCounter) = "Status" Then 
						intStatusCol = intCounter + 1
					ElseIf arrColumnNames(intCounter) = "Configured" Then
						intConfiguredCol = intCounter + 1
					End If
				Next
				
				If intStatusCol = -1 OR intConfiguredCol = -1 Then
					Call ReportLog("Orders Table", "Orders Table Column names have been changed", "Orders Table Column names[Status,Configured] have been changed", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					For intCounter = 1 To 10
						strStatus = UCase(Trim(objPage.WebTable("tblOrder").GetCellData(2, intStatusCol)))
						strConfigured = UCase(Trim(objPage.WebTable("tblOrder").GetCellData(2, intConfiguredCol)))
						If strStatus = "CREATED" AND strConfigured = "RFO VALID" Then
							Call ReportLog("RFO Upload Status", "Status should be 'Created' And RFO should be Valid", "Status is <B>" & strStatus & "</B></BR>Configured is <B>" & strConfigured & "</B>", "PASS", True)
							Exit For
						Else
							Wait 10
							objPage.HighLight : CreateObject("WScript.Shell").SendKeys "{F5}" : Wait 5
							objBrowser.fSync
							objPage.WebTable("tblOrder").WaitProperty "rows", micGreaterThan(1), 1000*60*1
						End If
					Next '#intCounter
				End If
				
				If Not ( strStatus = "CREATED" ) Then
					Call ReportLog("RFO Upload Status", "Status should be 'Created' And RFO should be Valid", "Status is <B>" & strStatus & "</B></BR>Configured is <B>" & strConfigured & "</B>", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			Else
				Call ReportLog("Orders Table", "Orders Table should be loaded", "Either Order Table is not loaded or object property has been changed", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			Environment.Value("Action_Result") = True
		Else
			Call ReportLog("Upload Successful","Upload should be successful","Upload was unsuccessful","FAIL", True)
			Environment.Value("Action_Result") = False
		End If
	Else
		Call ReportLog("Import RFO", "Upload Status should be displayed", "Upload message was not visible @:= " & Now, "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
End Function
