'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_OrderCPEProvide
' Purpose	 	 : Function to Configure GMV task
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 18/12/2013
' Parameters	 :                                    					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_OrderCPEProvide()

	'Declaration of variables
	Dim blnResult
	Dim strData
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
	
	'Variable Assignment
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
	'Dim arrOrderCPEProvide,arrValues
	'arrOrderCPEProvide = Split(dOrderCPEProvide,",")
	'intUBound = UBound(arrOrderCPEProvide)
	'ReDim arrValues(intUBound,1)
	'
	'For intCounter = 0 to intUBound
	'	arrValues(intCounter,0) = Split(arrOrderCPEProvide(intCounter),":")(0)
	'	arrValues(intCounter,1) = Split(arrOrderCPEProvide(intCounter),":")(1)
	'Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result")=False : Exit Function

	'Enter Date Order Raised by BT with Supplier: 
	If objFrame.WebEdit("txtDateOrderRaisedByBTWithSupplier").Exist(60) then
		blnResult =  clickFrameImage("imgCalendarDateOrderRaisedByBTWithSupplier")
			If Not blnResult Then Environment("Action_Result")=False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click	
	End if

	'Enter Required Date
	If objFrame.WebEdit("txtRequiredDate").Exist(60) then
		blnResult =  clickFrameImage("imgCalendarRequiredDate")
			If Not blnResult Then Environment("Action_Result")=False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click	
	End if
'====================================Adding for Closure of MPLS Task'====================================
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
