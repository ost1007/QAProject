'==============================================================================================================================
'Description: Function to Handle Notifcation of File to Save into System
'==============================================================================================================================
Public Function fn_SQE_HandleNotificationBar()
	Dim blnExist
	Dim intCounter, intSelectCounter
	Dim oNotificationBar1, oNotificationBar2
	
	blnExist = False
	If Environment("ProductName") = "HP Unified Functional Testing" Then
		Set oNotificationBar1 = Browser("brwSalesQuoteEngine").WinObject("Notification")
		Set oNotificationBar2 = Dialog("regexpwndtitle:=Internet Explorer")
		For intCounter = 1 to 10
			If oNotificationBar1.Exist(10) Then
				blnExist = True
				Exit For '#intCounter
			ElseIf oNotificationBar2.Exist(10) Then
				blnExist = True
				Exit For '#intCounter
			End If
		Next '#intCounter
	
		If Not blnExist Then
			Call ReportLog("Notification Bar", "Notification Bar should exist", "Notification Bar doesn't Exist", "FAIL", True)
			fn_SQE_HandleNotificationBar = False : Exit Function
		End If

		If oNotificationBar1.Exist(10) Then
			For intSelectCounter = 1 To 5 Step 1
				If oNotificationBar1.WinButton("btnSaveAs").Exist Then
					oNotificationBar1.WinButton("btnSaveAs").Click , , micLeftBtn : Wait 2
					If Browser("brwSalesQuoteEngine").WinMenu("ContextMenu").Exist(5) Then
						Browser("brwSalesQuoteEngine").WinMenu("ContextMenu").Select "Save as"
						Wait 10
					End If
					If Browser("brwSalesQuoteEngine").Dialog("dlgSaveAs").Exist(5) Then
						fn_SQE_HandleNotificationBar = True
						Exit Function 
					End If
				End If
			Next '#intSelectCounter
		ElseIf oNotificationBar2.Exist(10) Then
			For intSelectCounter = 1 To 5 Step 1
				If oNotificationBar2.WinButton("regexpwndtitle:=Save &as").Exist Then
					oNotificationBar2.WinButton("regexpwndtitle:=Save &as").Click
					Wait 5
					If Browser("brwSQE").Dialog("dlgSaveAs").Exist(5) Then
						fn_SQE_HandleNotificationBar = True
						Wait 10
						Exit Function 
					End If
				End If
			Next '#intSelectCounter
		End If
	Else
		For intCounter = 1 to 60
			blnExist = Browser("creationtime:=0").WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Exist(5)
			If blnExist Then
				Exit For
			End If
		Next
		
		On Error Resume Next
		For intCounter = 1 to 5
			If Not Browser("brwSQE").Dialog("dlgSaveAs").Exist(1) Then
				Browser("creationtime:=0").WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Highlight
				Browser("creationtime:=0").WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Click
				Wait 1
				Browser("creationtime:=0").WinObject("nativeclass:=DirectUIHWND","regexpwndclass:=DirectUIHWND", "index:=0").Clickontext "Save",,,,,true, micRightBtn, true
				Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
				DeviceReplay.PressKey 208 'Presses 'down arrow' key
				DeviceReplay.PressKey 30 'Presses 'a' key
			Else
				fn_SQE_HandleNotificationBar = True
			End If
		Next
		On Error Goto 0
	End If
	
	fn_SQE_HandleNotificationBar = False
End Function

