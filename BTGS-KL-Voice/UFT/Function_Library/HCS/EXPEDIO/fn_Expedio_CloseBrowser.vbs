'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Login
' Purpose	 	 : Function to login to EXPEDIO Application.
' Author	 	 : Anil Kumar Pal
' Creation Date  : 19/08/2014
' Modified By	: Nagaraj V || 16/3/2015
' Parameters	 :  
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_CloseBrowser()

	Dim objShellApp, objShellWindows 
	Dim objArr
	Dim intCounter

	Wait 60

	ReDim objArr(1)

	Set objShellApp = CreateObject("Shell.Application")
	For loopCounter = 1 to 20
		Set objShellWindows = objShellApp.Windows
		intCounter = 0
		For Each object in objShellWindows
			If object.Name = "Internet Explorer" Or object.Name = "Windows Internet Explorer" Then
				ReDim Preserve objArr(intCounter + 1)
				Set objArr(intCounter) = object
				intCounter = intCounter + 1
			End If
		Next

		If intCounter > 2 Then
			Exit For
		Else
			Wait 10
		End If
	Next
	
	ReDim Preserve objArr(intCounter - 1)
	
	For Each obj in objArr
		If Instr(obj.LocationURL, "Home+Page/Default") = 0 Then
			'To Check If Bowser is Busy Or Not
			For intCounter = 1 to 30
				If obj.Busy Then
					Wait 5
				Else
					Exit For
				End If
			Next
			obj.Quit
		End If
	Next
    
End Function
