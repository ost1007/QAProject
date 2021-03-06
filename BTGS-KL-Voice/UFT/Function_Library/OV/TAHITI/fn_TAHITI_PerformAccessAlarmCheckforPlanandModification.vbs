'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_PerformAccessAlarmCheck
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
Public function fn_TAHITI_PerformAccessAlarmCheckforPlanandModification(dPerformAccessAlarmCheck)
	
	'Variable Declaration
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
	Dim arrPerformAccessAlarmCheck,arrValues
	arrPerformAccessAlarmCheck = Split(dPerformAccessAlarmCheck,",")
	intUBound = UBound(arrPerformAccessAlarmCheck)
	ReDim arrValues(intUBound,1)
	arrPerformAccessAlarmCheck = Split(dPerformAccessAlarmCheck,",")
	intUBound = UBound(arrPerformAccessAlarmCheck)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrPerformAccessAlarmCheck(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrPerformAccessAlarmCheck(intCounter),":")(1)
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If

'''''''''Alarm
	If objFrame.WebList("lstAccAlarmTest").Exist(10) Then

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AccessAlarmTest" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		'Access AlarmTest  Executed
		ObjFrame.WebList("lstAccAlarmTest").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstAccAlarmTest").Select strData
'		blnResult = selectValueFromList("lstAccAlarmTest",strData)		'strAccessAlarmTestExecuted)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If


		'Execution Access Alarm Test Date
		blnResult =  clickFrameImage("imgCalendarAccessAlarmTest")
			If blnResult= False Then
				Environment.Value("Action_Result")=False 
				
				Exit Function
			End If

		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click


		'Checking whether the calendar got closed or not
		If Browser("brwDateTimePicker").Page("pgDateTimePicker").Exist = "False"Then
			Call ReportLog("AccessAlarmCheckDateSelection","Date is to be selected","Date is selected succesfully","PASS","")
		Else
			Call ReportLog("AccessAlarmCheckDateSelection","Date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End If

'''''''''FullserviceCPEtestRequired
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "FullserviceCPEtestRequired" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstModifyFullServiceCPETestRequired").Exist(10) Then

		'Access Alarm Test Result
		ObjFrame.WebList("lstModifyFullServiceCPETestRequired").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstModifyFullServiceCPETestRequired").Select strData
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If

		'Execution Access Alarm Test Date
		blnResult =  clickFrameImage("imgCalendarAccessOrderRaisedByBTWithSupplierDate")
			If blnResult= False Then
				Environment.Value("Action_Result")=False 
				Exit Function
			End If

		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

		'Checking whether the calendar got closed or not
		If Browser("brwDateTimePicker").Page("pgDateTimePicker").Exist = "False"Then
			Call ReportLog("Full service CPE test Required","Date is to be selected","Date is selected succesfully","PASS","")
		Else
			Call ReportLog("Full service CPE test Required","Date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End if

'''''''AllocateNewNetworkResources
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "AllocateNewNetworkResources" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstAllocateNewNetworkResource").Exist(10) Then
		ObjFrame.WebList("lstAllocateNewNetworkResource").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstAllocateNewNetworkResource").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if


'''***************************************************************************************************************************************************************************************
''''''''''BillingOnly
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "BillingOnly" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstBillingOnly").Exist(10) Then
		ObjFrame.WebList("lstBillingOnly").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstBillingOnly").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

''''''''CeaseExistingCPE
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "CeaseExistingCPE" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstCeaseExistingCPE").Exist(10) Then
		ObjFrame.WebList("lstCeaseExistingCPE").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstCeaseExistingCPE").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	End if

''''''''ChangeCPE
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "ChangeCPE" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstChangeCPE").Exist(10) Then
		ObjFrame.WebList("lstChangeCPE").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstChangeCPE").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

''''''''ChangeOLODSL
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "ChangeOLODSL" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstChangeOLODSL").Exist(10) Then
		ObjFrame.WebList("lstChangeOLODSL").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstChangeOLODSL").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
	End if

''''''ChangeTransmissionPath
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "ChangeTransmissionPath" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstChangeTransmissionPath").Exist(10) Then
		ObjFrame.WebList("lstChangeTransmissionPath").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstChangeTransmissionPath").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

'''''''NetworkReconfigurationRequired
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "NetworkReconfigurationRequired" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstNetworkReconfigurationRequired").Exist(10) Then
		ObjFrame.WebList("lstNetworkReconfigurationRequired").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstNetworkReconfigurationRequired").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if


''''''OwnaccessModification

	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "OwnaccessModification" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstOwnAccessModification").Exist(10) Then
		ObjFrame.WebList("lstOwnAccessModification").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstOwnAccessModification").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

''''''''ServiceOutageRequired
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "ServiceOutageRequired" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstServiceOutageRequired").Exist(10) Then
		ObjFrame.WebList("lstServiceOutageRequired").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstServiceOutageRequired").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if
'***************************************************************************************************************************************************************************************

''''''''''''''''''lstModifyOnSiteCPETestRequired
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "OnsiteCPETestRequired" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstModifyOnSiteCPETestRequired").Exist(10) Then

		'Access Alarm Test Result
		ObjFrame.WebList("lstModifyOnSiteCPETestRequired").Click
		Wait 5
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstModifyOnSiteCPETestRequired").Select strData
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If

		If UCase(strData) = "YES" Then
			'Execution Access Alarm Test Date
			blnResult =  clickFrameImage("imgCalendarDateAccessSuppliersInformBTOfCommitDeliveryDate")
				If blnResult= False Then
					Environment.Value("Action_Result")=False 
					Exit Function
				End If

			Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
			Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click

			'Checking whether the calendar got closed or not
			If Browser("brwDateTimePicker").Page("pgDateTimePicker").Exist = "False"Then
				Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
			Else
				Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
			End If	
		End If
		
End if

'''''''CeaseAccessTail
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "CeaseAccessTail" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstCeaseAccessTail").Exist(10) Then
		ObjFrame.WebList("lstCeaseAccessTail").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstCeaseAccessTail").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

''''''''RecoverOwnAccess
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "RecoverOwnAccess" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next

	If objFrame.WebList("lstRecoverOwnAccess").Exist(10) Then
		ObjFrame.WebList("lstRecoverOwnAccess").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstRecoverOwnAccess").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if

''''''''RecoverPort
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "RecoverPort" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstRecoverPort").Exist(10) Then
		ObjFrame.WebList("lstRecoverPort").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstRecoverPort").Select strData
    	If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End if
'***************************************************************************************************************************************************************************************
'''''''''''''''''Servicetestrequired
	For intLoop = 0 to intUBound
		If arrValues(intLoop,0) = "Servicetestrequired" Then
			strData = arrValues(intLoop,1)
			Exit For
		End If
	Next


	If objFrame.WebList("lstModifyServiceTestRequired").Exist(10) Then

		'Access Alarm Test Result
		ObjFrame.WebList("lstModifyServiceTestRequired").Click
		Wait 1
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmMyTasks").WebList("lstModifyServiceTestRequired").Select strData
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			
			Exit Function
		End If
		
		'Execution Access Alarm Test Date
		blnResult =  clickFrameImage("imgCalendarAccessSuppliersCommitDeliveryDate")
			If blnResult= False Then
				Environment.Value("Action_Result")=False 
				
				Exit Function
			End If

		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:="&strdate).Click
		

		'Checking whether the calendar got closed or not
		If Browser("brwDateTimePicker").Page("pgDateTimePicker").Exist = "False"Then
			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Todays date is selected succesfully","PASS","")
		Else
			Call ReportLog("AccessAlarmCheckDateSelection","Todays date is to be selected","Not able to select the required date","FAIL","TRUE")
		End If	

	End If
End Function
