'========================================================================================================================
' Procedure Name: fn_SQE_GetCoordinatesOfElementAddNew
' Purpose : Procedure to provide the Coordinates of a Base Config Table
' Created By : Nagaraj V || 19-Feb-2016 || v1.0
' Return Values : Not Applicable
'========================================================================================================================
Public Sub fn_SQE_GetCoordinatesOfElementAddNew(ByVal FieldName, ByVal WebElementObject, ByRef x, ByRef y)
	Dim oQuantityNewValDesc
	Dim height, width, x_axis, y_axis
	
	Set oQuantityNewValDesc = Description.Create
	oQuantityNewValDesc("micclass").Value = "WebElement"
	oQuantityNewValDesc("class").Value = "grid_Add_newVal text-content.*"
	oQuantityNewValDesc("html tag").Value = "DIV"
	
	Set oAddNewVals = WebElementObject.ChildObjects(oQuantityNewValDesc)
	If oAddNewVals.Count = 0 Then
		Call ReportLog(FieldName, FieldName & " - WebElement should contain [grid_Add_newVal text-content] as class property", "Locating WebElement failed", "FAIL", True)
		Environment("Action_Result") = False : Exit Sub
	End If
	
	x_axis = oAddNewVals(0).GetROProperty("abs_x")
	y_axis = oAddNewVals(0).GetROProperty("abs_y")
	
	height = oAddNewVals(0).GetROProperty("height") / 2
	width = oAddNewVals(0).GetROProperty("width") / 2
	
	x = x_axis + width
	y = y_axis + height
	Environment("Action_Result") = True
	
End Sub
