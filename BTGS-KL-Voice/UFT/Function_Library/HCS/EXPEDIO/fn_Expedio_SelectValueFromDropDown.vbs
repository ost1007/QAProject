Public Function fn_Expedio_SelectValueFromDropDown(ByVal objPage, ByVal SelectValue, ByVal objEditBoxObject)

	Dim blnFound
	Dim objElm

	blnResult = objPage.WebTable("class:=MenuTable").Exist
	If blnResult Then
			rowCnt =  objPage.WebTable("class:=MenuTable").RowCount
			blnFound = False
			strIterator = objPage.WebTable("class:=MenuTable").GetRowWithCellText(SelectValue, 1)
			If strIterator <= 0 Then
				Call ReportLog(SelectValue, SelectValue & " should be searched", "Could not locate the value in table", "FAIL", True)
				fn_Expedio_SelectValueFromDropDown = False
				Exit Function
			Else
				webElmNumber = strIterator - 1
			End If
			
			'If blnFound Then
					Set objDesc = Description.Create
					 objDesc("micClass").Value = "WebElement"
					 objDesc("class").value = "MenuEntryName.*"
					 Set objElm = objPage.WebTable("class:=MenuTable").ChildObjects(objDesc)
					 If objElm.Count >= 1 Then
						 objElm(webElmNumber).HighLight : Wait 1
						 objElm(webElmNumber).FireEvent "onmouseover"
						 objElm(webElmNumber).FireEvent "onclick"
						 Wait 2
						 'objElm(webElmNumber).Click
					 End If
			'End If

			If Trim(objEditBoxObject.GetROProperty("value")) =  SelectValue Then
					Call ReportLog(SelectValue, SelectValue & " should be selected", "<B>" & SelectValue & "</B> is selected", "PASS", False)
					fn_Expedio_SelectValueFromDropDown = True
			Else
					Call ReportLog(SelectValue, SelectValue & " should be selected", "Could not be selected", "FAIL", True)
					fn_Expedio_SelectValueFromDropDown = False
			End If

	Else
			Call ReportLog(SelectValue, SelectValue & " should be selected", "Drop Down List with WebTable is not displayed", "FAIL", True)
			fn_Expedio_SelectValueFromDropDown = False
	End If
End Function


Public Function fn_Expedio_SelectValueFromDropDownAlt(ByVal objPage, ByVal SelectValue, ByVal objEditBoxObject)

	Dim blnFound
	Dim objElm

	objEditBoxObject.Click
	objEditBoxObject.Object.Value = SelectValue
	Wait 2
	objEditBoxObject.Click
	CreateObject("WScript.Shell").SendKeys "{ENTER}"
	Wait 2

	If Trim(objEditBoxObject.GetROProperty("value")) =  SelectValue Then
			Call ReportLog(SelectValue, SelectValue & " should be selected", "<B>" & SelectValue & "</B> is selected", "PASS", False)
			fn_Expedio_SelectValueFromDropDownAlt = True
	Else
			Call ReportLog(SelectValue, SelectValue & " should be selected", "Could not be selected", "FAIL", True)
			fn_Expedio_SelectValueFromDropDownAlt = False
	End If

End Function
