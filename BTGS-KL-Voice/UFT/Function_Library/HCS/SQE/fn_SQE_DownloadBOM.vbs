'****************************************************************************************************************************
' Description			  :		Function to Download BOM XML
' History				   : Name				Date			Changes Implemented
'			Created By   : Nagaraj V		17/08/2016			NA
'			Modified By  :
' Return Values	 	    : 			Not Applicable
' Example				 : fn_SQE_DownloadBOM "C:/Users/"
'****************************************************************************************************************************
Public Function fn_SQE_DownloadBOM(ByVal RFOLocation)
	
	Dim intCounter, intSelectCounter
	Dim blnSaveAsAppeared

	For intCounter = 1 To 10
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Image("imgDownloadBOM").Exist(30)	
		If blnResult Then
			Exit For '#intCounter
		End If
	Next '#intCounter
	
	If Not blnResult Then
		Call ReportLog("Download BOM", "Download BOM image should exist", "Download BOM image doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Click on Download BOM
	blnResult = clickImage("imgDownloadBOM")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	objBrowser.fSync
	
	For intCounter = 1 To 20
		blnResult = Browser("brwSalesQuoteEngine").WinObject("Notification").Exist(30)
		If blnResult Then Exit For	
	Next
	
	If Not blnResult Then
		Call ReportLog("Download BOM", "Notification bar should be displayed", "Notification bar is not being displayed even after 5mins", "FAIL", True)
		Environment("Action_Result") = False : EXit Function
	End If
	
	For intSelectCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").WinObject("Notification").WinButton("btnSaveAs").Exist Then
			Browser("brwSalesQuoteEngine").WinObject("Notification").WinButton("btnSaveAs").Click , , micLeftBtn : Wait 2
			If Browser("brwSalesQuoteEngine").WinMenu("ContextMenu").Exist(5) Then
				Browser("brwSalesQuoteEngine").WinMenu("ContextMenu").Select "Save as"
				Wait 10
			End If
			
			blnSaveAsAppeared = Browser("brwSalesQuoteEngine").Dialog("dlgSaveAs").Exist(5)
			If blnSaveAsAppeared Then
				Exit For '#intSelectCounter
			End If
		End If
	Next '#intSelectCounter
	
	If Not blnSaveAsAppeared Then
		Call ReportLog("SaveAs Dialog", "SaveAs Dialog box should be visible", "SaveAs dialog is not visible even after acting on Notification", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strFileName = fn_SQE_SaveFile(RFOLocation)
	If Not Environment("Action_Result") Then
		Exit Function
	Else
		Call ReportLog("Download BOM", "BOM XML must be downloaded", "BOM is stored in path: " & strFileName, "PASS", False)
		Call ReportLinerMessage("<a href='" & strFileName & "' target='_blank'>Click here to view Downloaded BOM</a>")
	End If
	
	blnResult = Browser("brwSalesQuoteEngine").WinObject("DownloadNotification").Exist(120)
	If blnResult Then
		Wait 5
		Call ReportLog("BOM Download", "BOM should be downloaded successfully", "BOM download completed message appeared", "Information", True)
		Browser("brwSalesQuoteEngine").WinObject("DownloadNotification").WinButton("btnClose").Click
	End If
	
	Environment("Action_Result") = True
End Function
