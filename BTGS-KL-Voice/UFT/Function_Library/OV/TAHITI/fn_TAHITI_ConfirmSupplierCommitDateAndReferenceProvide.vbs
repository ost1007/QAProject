'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_ConfirmSupplierCommitDateAndReferenceProvide
' Purpose	 	 : Function to fill in details for Confirm Supplier Commit Date And Reference (Provide)
' Author	 	 : Linta
' Creation Date  : 02/06/2014
' Parameters	 : 			     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_ConfirmSupplierCommitDateAndReferenceProvide()
	'Declaration of variables
	Dim blnResult
	Dim strData
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
	
	strcurrentdate =  Date
	strmonth = Split(strcurrentdate,"/")
	strcurrentmonth = strmonth(1)
	If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
		strmonth =  MonthName(strcurrentmonth, False)
	ElseIf strcurrentmonth = "09" Then
		strmonth =  Left(MonthName(strcurrentmonth, False), 4)
	Else
		strmonth =  MonthName(strcurrentmonth, True)
	End If
	strdate = Day(Now)
	stryear = Year(Now)

	'Assigning values to an array
	'Dim arrCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE,arrValues
	'arrCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE = Split(dCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE,",")
	'intUBound = UBound(arrCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE)
	'ReDim arrValues(intUBound,1)
	'
	'For intCounter = 0 to intUBound
	'	arrValues(intCounter,0) = Split(arrCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE(intCounter),":")(0)
	'	arrValues(intCounter,1) = Split(arrCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE(intCounter),":")(1)
	'Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Planned Installation Date
	If objFrame.WebEdit("txtPlannedInstallationDate").Exist then

		blnResult =  clickFrameImage("imgCalendarPlannedInstallationDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Browser("brwCalendar").Page("pgCalendar").Exist = "False"Then
			Call ReportLog("Planned Installation Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Planned Installation Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End if

'====================================Adding for Closure of MPLS Task'====================================
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
