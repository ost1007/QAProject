'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_ConfirmAccessInstallation
'
' Purpose	 	 : Function to enter Access Supplier details
'
' Author	 	 : Linta Ck
'
' Creation Date  	 : 15/05/2014
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_ConfirmAccessInstallation(dCONFIRM_ACCESS_INSTALLATION)

	'Declaration of variables
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
	Dim arrCONFIRM_ACCESS_INSTALLATION,arrValues
	arrCONFIRM_ACCESS_INSTALLATION = Split(dCONFIRM_ACCESS_INSTALLATION,",")
	intUBound = UBound(arrCONFIRM_ACCESS_INSTALLATION)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrCONFIRM_ACCESS_INSTALLATION(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrCONFIRM_ACCESS_INSTALLATION(intCounter),":")(1)
	Next	

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Access Supplier Installation Complete date
	blnResult = objFrame.WebEdit("txtAccessSupplierInstallationCompleteDate").Exist
	If blnresult = "True" Then
		blnResult =  clickFrameImage("imgCalendarAccessSupplierInstallationCompleteDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
	
		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(15) Then
			Call ReportLog("AccessSupplier Installation Complete Date","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("AccessSupplier Installation Complete Date","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	
	End If

	'Access supplier advised BT of Access Completion
	blnResult = objFrame.WebEdit("txtDateAccessSupplierAdvisedBTOfAccessCompletion").Exist
	If blnresult = "True" Then

		blnResult =  clickFrameImage("imgCalendarDateAccessSupplierAdvisedBTOfAccessCompletion")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Clicking on todays date
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

		'Checking whether the calendar got closed or not
		If Not Browser("brwCalendar").Page("pgCalendar").Exist(15) Then
			Call ReportLog("Date Access Supplier Advised BT Of Access Completion","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("Date Access Supplier Advised BT Of Access Completion","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If	
	End If

	'Access Supplier circuit Id
	blnResult = objFrame.WebEdit("txtAccessSupplierCircuitID").Exist
	If blnresult = "True" Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessSupplierCircuitID" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = enterFrameText("txtAccessSupplierCircuitID",strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	'Access Delivery Status
	If objFrame.WebList("lstAccessDeliveryStatus").Exist(20) then

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
	End If

	'Access Supplier Contract Term
	If objFrame.WebList("lstAccessSuppliersContractTerm").Exist(20) then

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
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
End Function


'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
