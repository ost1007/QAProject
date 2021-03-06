Public Function fn_Classic_SetDialogDate(ByVal DialogDateTime)
	'Build Amdocs Reference
	'blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	dDate = Right("0" & Day(DialogDateTime), 2)
	dMonth = Right("0" &  Month(DialogDateTime), 2)
	dYear = Year(DialogDateTime)
	
	blnResult = oParentWindow.Dialog("DateTimeEntry").Exist(120)
	
	'Enter Date
	blnResult = enterDialogText("DateTimeEntry", "txtDay", dDate)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Month
	blnResult = enterDialogText("DateTimeEntry", "txtMonth", dMonth)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Enter Year
	blnResult = enterDialogText("DateTimeEntry", "txtYear", dYear)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Ok
	blnResult = clickDialogButton("DateTimeEntry", "btnOK")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Environment("Action_Result") = True
End Function


Public Function fn_Classic_SetDialogDate_ClearSales(ByVal DialogDateTime)
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM-ClearSales", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	dDate = Right("0" & Day(DialogDateTime), 2)
	dMonth = Right("0" &  Month(DialogDateTime), 2)
	dYear = Year(DialogDateTime)
	
	blnResult = oParentWindow.Dialog("DateTimeEntry").Exist(120)
	
	'Enter Date
	blnResult = enterDialogText("DateTimeEntry", "txtDay", dDate)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Enter Month
	blnResult = enterDialogText("DateTimeEntry", "txtMonth", dMonth)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Enter Year
	blnResult = enterDialogText("DateTimeEntry", "txtYear", dYear)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Ok
	blnResult = clickDialogButton("DateTimeEntry", "btnOK")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Environment("Action_Result") = True
End Function
