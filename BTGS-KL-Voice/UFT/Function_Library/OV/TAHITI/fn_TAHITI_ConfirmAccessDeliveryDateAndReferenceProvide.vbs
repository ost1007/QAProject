'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_ConfirmAccessDeliveryDateAndReferenceProvide
'
' Purpose	 	 : Function to hand over the task to maintenance
'
' Author	 	 : Vamshi Krishna G
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_ConfirmAccessDeliveryDateAndReferenceProvide(dCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE)
	'Declaration of variables
	Dim blnResult
	Dim strData, strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
	Dim arrCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE,arrValues
	
	
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
	arrCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE = Split(dCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE,",")
	intUBound = UBound(arrCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter Date Order Received with the Access Supplier
	If objFrame.WebEdit("txtDateOrderReceivedWithTheAccessSupplier").Exist then

		blnResult =  clickFrameImage("imgCalendarDateOrderReceivedWithTheAccessSupplier")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
			Call ReportLog("Date Order Received with the Access Supplier","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Date Order Received with the Access Supplier","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

	End if

	'Enter Access Supplier's Order Approved Date
	If objFrame.WebEdit("txtAccessSuppliersOrderApprovedDate").Exist then

		blnResult =  clickFrameImage("imgCalendarAccessSuppliersOrderApprovedDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
			Call ReportLog("Access Supplier's Order Approved Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Access Supplier's Order Approved Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

	End if

	'Enter Date Access Supplier's Inform BT of Commit Delivery Date:
	If objFrame.WebEdit("txtDateAccessSuppliersInformBTOfCommitDeliveryDate").Exist then

		blnResult =  clickFrameImage("imgCalendarDateAccessSuppliersInformBTOfCommitDeliveryDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
			Call ReportLog("Date Access Supplier's Inform BT of Commit Delivery Date:","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Date Access Supplier's Inform BT of Commit Delivery Date:","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

	End if

	'Enter Access Supplier's Commit Delivery Date
	If objFrame.WebEdit("txtAccessSuppliersCommitDeliveryDate").Exist then

		blnResult =  clickFrameImage("imgCalendarAccessSuppliersCommitDeliveryDate")
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
			Call ReportLog("Access Supplier's Commit Delivery Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Access Supplier's Commit Delivery Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

	End if

	' select the value For Access Supplier's Commit Date Type:
	If objFrame.WebList("lstAccessSuppliersCommitDateType").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstAccessSuppliersCommitDateType").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstAccessSuppliersCommitDateType").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessSuppliersCommitDateType" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstAccessSuppliersCommitDateType",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

	'Enter AccessSupplierOrderRefNo
	If objFrame.WebEdit("txtAccessSuppliersOrderReferenceNo").Exist(20) Then
        	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessSuppliersOrderReferenceNo" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = enterFrameText("txtAccessSuppliersOrderReferenceNo",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

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
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

	'Enter Date Access Supplier's Provide price proposal
	If objFrame.WebEdit("txtDateAccessSuppliersProvidePriceProposal").Exist then

		blnResult =  clickFrameImage("imgCalendarDateAccessSuppliersProvidePriceProposal")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(5) Then
			Call ReportLog("Date Access Supplier's Provide price proposal","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Date Access Supplier's Provide price proposal","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	

	End if

	' select the value For Currency
	If objFrame.WebList("lstCurrency").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstCurrency").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstCurrency").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "Currency" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstCurrency",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

	'Enter OneTimeCost
	If objFrame.WebEdit("txtOneTimeCost").Exist(20) Then
        	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "OneTimeCost" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = enterFrameText("txtOneTimeCost",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	'Enter RecurringCost
	If objFrame.WebEdit("txtRecurringCost").Exist(20) Then
        	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "RecurringCost" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = enterFrameText("txtRecurringCost",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	' select the value For Access Order Accepted
	If objFrame.WebList("lstAccessOrderAccepted").Exist(20) Then
		wait 3
		For i = 1 to 5
			objFrame.WebList("lstAccessOrderAccepted").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstAccessOrderAccepted").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next
	
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessOrderAccepted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
			
		blnResult = selectValueFromList("lstAccessOrderAccepted",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
