Sub fn_SQE_PleaseWait(ByVal objPage)
	Dim intCounter
	For intCounter = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(5) Then
			Wait 10
		Else
			Exit For
		End If
	Next
End Sub
