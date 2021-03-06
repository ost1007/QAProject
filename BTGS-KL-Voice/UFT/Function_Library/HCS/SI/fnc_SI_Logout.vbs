'****************************************************************************************************************************
' Function Name	 : fnc_SI_Logout
'
' Purpose	 	 : Function to logout from SI Application
'
' Author	 	 : Linta CK
'
' Creation Date  : 08/07/2013
'
' Parameters	 : 
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fnc_SI_Logout()

	'Variable Declaration Section
	Dim blnResult
	
	If Not Browser("brwSITaskDetails").Exist(10) Then
		Environment("Action_Result") = True
		Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSITaskDetails","pgSITaskDetails","")
	If blnResult= "True" Then
		hwnd = objBrowser.GetROProperty("hwnd")
		Window("hwnd:=" & hwnd).Activate
	
		blnResult = objPage.Link("lnkLogOut").Exist
		If blnResult = "True" Then
			objPage.Link("lnkLogOut").Click
			Wait 5
			blnResult = Browser("brwSITaskDetails").Dialog("dlgMsgFromWebpage").WinButton("btnOK").Exist(2)
			If blnResult Then
				Browser("brwSITaskDetails").Dialog("dlgMsgFromWebpage").WinButton("btnOK").Type micReturn
			End If
			
			blnResult = Browser("brwSITaskDetails").Window("Recently Assigned Task").Page("Recently Assigned Task").WebButton("OK").Exist(2)
			If blnResult = "True" Then
				Browser("brwSITaskDetails").Window("Recently Assigned Task").Page("Recently Assigned Task").WebButton("OK").Click
			End If

			blnResult = Browser("brwSITaskDetails").Dialog("Windows Internet Explorer").WinButton("btnYes").Exist(2)
			If blnResult Then
				Browser("brwSITaskDetails").Dialog("Windows Internet Explorer").WinButton("btnYes").Click
			End If

			If Dialog("dlgIEClose").Exist(5) Then
				Dialog("dlgIEClose").WinButton("btnYes").Click
			End If
		End If
	End If

	Wait 5

	SystemUtil.CloseProcessByName("iexplore.exe") 

	Environment.Value("Action_Result") = True
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

