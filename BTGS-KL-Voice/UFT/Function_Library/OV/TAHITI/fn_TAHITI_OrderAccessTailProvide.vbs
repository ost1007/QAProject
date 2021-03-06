'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_OrderAccessTailProvide
'
' Purpose	 	 : Function to fill in details for order Access Tail Provide
'
' Author	 	 : Linta
'
' Creation Date  : 02/06/2014
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public function fn_TAHITI_OrderAccessTailProvide(dOrderAccessTailProvide)

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
	Dim arrOrderAccessTailProvide,arrValues
	arrOrderAccessTailProvide = Split(dOrderAccessTailProvide,",")
	intUBound = UBound(arrOrderAccessTailProvide)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrOrderAccessTailProvide(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrOrderAccessTailProvide(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If

	'Enter Access Circuit Required By Date
	If objFrame.WebEdit("txtAccessCircuitRequiredByDate").Exist then

		blnResult =  clickFrameImage("imgCalendarAccessCircuitRequiredByDate")
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
	
		'Checking whether the calendar got closed or not
		If Browser("brwCalendar").Page("pgCalendar").Exist = "False"Then
			Call ReportLog("Access Circuit Required By Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Access Circuit Required By Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End if

	'Enter Access Order Raised By BT With Supplier Date
	If objFrame.WebEdit("txtAccessOrderRaisedByBTWithSupplierDate").Exist then

		blnResult =  clickFrameImage("imgCalendarAccessOrderRaisedByBTWithSupplierDate")
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
	
		'Checking whether the calendar got closed or not
		If Browser("brwCalendar").Page("pgCalendar").Exist = "False"Then
			Call ReportLog("Access Order Raised By BT With Supplier Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Access Order Raised By BT With Supplier Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End if

	' select the value For Access Delivery Status
	If objFrame.WebList("lstAccessDeliveryStatus").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstAccessDeliveryStatus").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstAccessDeliveryStatus").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessDeliveryStatus" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstAccessDeliveryStatus",strData)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

	' select the value For Access Delivery Type
	If objFrame.WebList("lstAccessDeliveryType").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstAccessDeliveryType").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstAccessDeliveryType").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessDeliveryType" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstAccessDeliveryType",strData)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

	' select the value For Access Suppliers Contract Term
	If objFrame.WebList("lstAccessSuppliersContractTerm").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstAccessSuppliersContractTerm").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstAccessSuppliersContractTerm").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessSuppliersContractTerm" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstAccessSuppliersContractTerm",strData)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If
'====================================Adding for Closure of MPLS Task'====================================
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
