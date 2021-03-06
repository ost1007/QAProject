'=============================================================================================================
'Description: Function to handle PlanServiceModification Change
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			08/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PlanServiceModification_Change PlanServiceModification
'=============================================================================================================
Public Function fn_TAHITI_PlanServiceModification_Change(ByVal PlanServiceModification)
		'Variable Declaration
		Dim oDictPlanServiceModification
		Dim arrPlanServiceModification
		Dim strPlanServiceModificationVal
		Dim arrPlanServiceModVal
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
	
		Set oDictPlanServiceModification = CreateObject("Scripting.Dictionary")
	
		arrPlanServiceModification = Split(PlanServiceModification, ",")
		For Each strPlanServiceModificationVal In arrPlanServiceModification
				arrPlanServiceModVal = Split(Trim(strPlanServiceModificationVal), ":")
				oDictPlanServiceModification(Trim(arrPlanServiceModVal(0))) = Trim(arrPlanServiceModVal(1))
		Next
	
		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		'Access Alarm Test Required
		If objFrame.WebList("lstAccessAlarmTestRequired").Exist(10) Then
				blnResult = fn_TAHITI_SelectValue("lstAccessAlarmTestRequired", oDictPlanServiceModification("AccessAlarmTest"))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
				If UCase(oDictPlanServiceModification("AccessAlarmTest")) = "YES" Then
					blnResult =  clickFrameImage("imgCalAccessAlarmTestRequired")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Wait 2
		
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
					
				End If
		End If
	
		'Access Alarm Test Required
		If objFrame.WebList("lstFullservice/CPETestRequired").Exist(10) Then
				blnResult = fn_TAHITI_SelectValue("lstFullservice/CPETestRequired", oDictPlanServiceModification("FullserviceCPEtestRequired"))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
				If UCase(oDictPlanServiceModification("FullserviceCPEtestRequired")) = "YES" Then
					blnResult =  clickFrameImage("imgCalFullservice/CPETestRequired")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Wait 2
		
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
					
				End If
		End If
	
		'Update all the Modify Activity Table Attributes
		Set objModifyActivities = objFrame.WebTable("tblModifyActivities")
		With objModifyActivities
	
				strCellValue = "Allocate New Network Resources: (*)"
				strSelectValue = oDictPlanServiceModification("AllocateNewNetworkResources")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Billing Only: (*)"
				strSelectValue = oDictPlanServiceModification("BillingOnly")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Cease Existing CPE: (*)"
				strSelectValue = oDictPlanServiceModification("CeaseExistingCPE")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Change CPE: (*)"
				strSelectValue = oDictPlanServiceModification("ChangeCPE")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Change OLO/DSL: (*)"
				strSelectValue = oDictPlanServiceModification("ChangeOLODSL")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Change Transmission Path: (*)"
				strSelectValue = oDictPlanServiceModification("ChangeTransmissionPath")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Network Reconfiguration Required: (*)"
				strSelectValue = oDictPlanServiceModification("NetworkReconfigurationRequired")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Own access Modification: (*)"
				strSelectValue = oDictPlanServiceModification("OwnaccessModification")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Service Outage required: (*)"
				strSelectValue = oDictPlanServiceModification("ServiceOutageRequired")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
		End With
	
		'On site CPE Test Required
		If objFrame.WebList("lstOnSiteCPETestReq").Exist(10) Then
				blnResult = fn_TAHITI_SelectValue("lstOnSiteCPETestReq", oDictPlanServiceModification("OnsiteCPETestRequired"))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
				If UCase(oDictPlanServiceModification("OnsiteCPETestRequired")) = "YES" Then
					blnResult =  clickFrameImage("imgCalOnSiteCPETestReq")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Wait 2
		
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
					
				End If
		End If
	
		'Customer Keeping CPE: (*)
		If objFrame.WebList("lstCustomerKeepingCPE").Exist(10) Then
				blnResult = fn_TAHITI_SelectValue("lstCustomerKeepingCPE", oDictPlanServiceModification("CustomerKeepingCPE"))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
	
		'Update all the Recover Activity Table Attributes
		Set objRecoveryActivities = objFrame.WebTable("tblRecoveryActivities")
		With objRecoveryActivities
	
				strCellValue = "Cease Access Tail: (*)"
				strSelectValue = oDictPlanServiceModification("CeaseAccessTail")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Recover Own Access: (*)"
				strSelectValue = oDictPlanServiceModification("RecoverOwnAccess")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
	
				strCellValue = "Recover Port: (*)"
				strSelectValue = oDictPlanServiceModification("RecoverPort")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
		End With '#objRecoveryActivities
	
		'Scheduled Service test Date
		If objFrame.WebList("lstServiceTestReq").Exist(10) Then
				blnResult = fn_TAHITI_SelectValue("lstServiceTestReq", oDictPlanServiceModification("Servicetestrequired"))
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
				If UCase(oDictPlanServiceModification("Servicetestrequired")) = "YES" Then
					blnResult =  clickFrameImage("imgCalServiceTest")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Wait 2
		
					Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
					Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
					Wait 2
					
				End If
		End If
End Function