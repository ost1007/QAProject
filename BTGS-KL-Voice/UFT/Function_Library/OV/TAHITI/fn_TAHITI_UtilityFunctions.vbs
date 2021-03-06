'==================================================================================================================================
'Description : Select the value from the WebList passed by Called Function
'==================================================================================================================================

Public Function fn_TAHITI_SelectValue(ByVal WebListName, ByVal WebListValue)
		Dim iCounter
		Dim blnLoaded

		For iCounter = 1 To 5
			objFrame.WebList(WebListName).Click
			Wait 2
			objPage.Sync
			blnLoaded = objFrame.WebList(WebListName).WaitProperty("items count", micGreaterThanOrEqual(1), 5000)
				If blnLoaded Then Exit For
		Next
	
		For iCounter = 1 To 5
			blnResult = selectValueFromList(WebListName, WebListValue)
				If Not blnResult Then fn_TAHITI_SelectValue = blnResult : Exit Function
	
			If objFrame.WebList(WebListName).GetROProperty("selection") = WebListValue Then
				fn_TAHITI_SelectValue = True : Exit Function
			Else
				Wait 5
			End If
		Next
	
		Call ReportLog(WebListName, WebListValue & " value should be selected", "value is not getting selected", "FAIL", True)
		fn_TAHITI_SelectValue = False
End Function

'==================================================================================================================================
'Description : Select the value from the WebList passed by Called Function
'==================================================================================================================================
Public Function fn_TAHITI_SelectValueFromObject(ByVal objList, ByVal WebListValue)
		Dim iCounter
		Dim blnLoaded

		For iCounter = 1 To 5
			objList.Click
			Wait 2
			objPage.Sync

			blnLoaded = objList.WaitProperty("items count", micGreaterThanOrEqual(1), 5000)
				If blnLoaded Then Exit For
		Next

		For iCounter = 1 To 5
			objList.Select(WebListValue)
	
			If objList.GetROProperty("selection") = WebListValue Then
				fn_TAHITI_SelectValueFromObject = True : Exit Function
			Else
				Wait 5
			End If
		Next
	
		
		fn_TAHITI_SelectValueFromObject = False

End Function


'==================================================================================================================================
'Description : Enter the Value to the specified Text Box
'==================================================================================================================================
Public Function fn_TAHITI_EnterValueToObject(ByVal objText, ByVal TextBoxValue)
		Dim iCounter

		For iCounter = 1 To 5
			objText.Set TextBoxValue
	
			If objText.GetROProperty("value") = TextBoxValue Then
				fn_TAHITI_EnterValueToObject = True : Exit Function
			Else
				Wait 5
			End If
		Next
		
		fn_TAHITI_EnterValueToObject = False

End Function
