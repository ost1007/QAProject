'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_TaskSelection_Closure
' Purpose	 	 : Function to select task in sequence by Task ID
' Author	 	 : Vamshi Krishna G
' Modified By	 : Linta C.K.
' Creation Date  : 18/12/2013
' Modification Date: 25/04/2014
' Parameters	 :                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public gTrigger_rPACS_Request
Public arrEndDate, arrEndTime

Public function fn_TAHITI_TaskSelection_Closure(dAIBURL, dAIBUserName, dAIBPassword, dVLPURL, dVLPUserName, dVLPPassword, diVServeURL, diVServeUserName, diVServePassword,_
				dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK, dSELECT_SCHEDULE_TESTS_REQUIRED,dCONFIGURE_GMV, dPerformAccessAlarmCheck, dONSITE_CPE_CONNECTIVITY_TEST,_
				dFULL_SERVICE_CPE_TEST, dPERFORM_SERVICE_TEST, dCONFIGURE_MEDIATION, dRecieverMailAddress, dCCMailAddress, dHANDOVER_INTO_MAINTENANCE,_
				dOrderAccessTailProvide, dCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE, dPREPARE_BUILD_CPE_BASE_CONFIG, dCONFIRM_ACCESS_INSTALLATION,_
				dPlanServiceModification, dPERFORM_Full_SERVICE_TEST, dUpdateMNUMProvide)
	'Declaration of variables
	Dim strTaskStatus,arrResultMessage,NoOfTasks
	Dim intRowCnt
	Dim iRow
	Dim blnClosed
	Dim MNUMToBeUsed
	
	
	'Loading AIB Application Resources
	pORName = "AIB"
	Call fLoadOR()
	Call fLoadFunctionLib(pORName)
	gTrigger_rPACS_Request = GetAttributeValue("drPACSInvolved")

	'Building Web Reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Taking No of Tasks
	If Not objFrame.WebElement("webElmNoOfTasks").Exist(5) Then
		objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
		objBrowser.Sync : objPage.Sync
	End If
	
	strRetrivedText = objFrame.WebElement("webElmNoOfTasks").GetROProperty("innerhtml")
	arrResultMessage = SPlit(strRetrivedText," ")
	NoOfTasks = arrResultMessage(0)

	strOrderID = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(4, 9)
	Call fn_TAHITI_SortRecords()

	intRowCnt =  objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
	strRetrivedText = objFrame.WebElement("webElmNoOfTasks").GetROProperty("innerhtml")
	arrResultMessage = SPlit(strRetrivedText," ")
	NoOfTasksUpdated = arrResultMessage(0)

	'=========================== Nagaraj Added ==========================	
	intNext = Ceil(NoOfTasksUpdated/10)
	blnFlag = False
	
	For iNext = 1 To intNext
		objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RefreshObject
		RowsInPage = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
	
		For iRow = 4 To RowsInPage
			strCurrentTaskName = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 3)
			strTaskStatus = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 4)
			If strTaskStatus = "Execution" Then
				blnFlag = True
				Exit for '#iRow
			ElseIf (strCurrentTaskName = "Set Elements to Installed (Provide)" OR strCurrentTaskName = "Set Elements to Installed (Change)" OR strCurrentTaskName = "Set Elements to Ceased (Cease)" AND strTaskStatus = "Ended") Then
				arrEndDate = Split(objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 8), Space(1))
				If UBound(arrEndDate) = 1 Then
					arrEndTime = Split(arrEndDate(1), ":")
				End If
			End If
		Next
		
		If blnFlag Then
			Exit For '#iNext
		ElseIf intNext > iNext Then
			blnResult = clickFrameImage("imgNext")
				If Not BlnResult Then fn_TAHITI_CheckForTasks = False : Exit Function
			Wait 10
		End If
	Next '#iNext
	
	'Check for Tasks generation
	If Not blnFlag Then
		blnTasks = fn_TAHITI_CheckForTasks(strCurrentTaskName)
			If Not blnTasks Then Exit Function
	End If

	'Initalize task status as Execution
	Do until(strTaskStatus = "Ended")
		
		objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RefreshObject
		RowsInPage = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
	
		For iRow = 4 To RowsInPage
			strTaskStatus = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 4)
			If strTaskStatus = "Execution" Then
				strCurrentTaskName = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 3)
				strTaskId = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 2)
				objFrame.WebRadioGroup("IdNumber").Select strTaskId
				Exit for '#iRow
			End If
		Next

		Call ReportLog("CurrentTaskName","Task name for execution should be retrived","Task under execution is <B>" & strCurrentTaskName & "</B>","PASS",True)
	
		Select Case (Trim(strCurrentTaskName))

			Case "Automatic Port Allocation"
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						blnResult = fn_TAHITI_CheckAutoClosure(strTaskId, 25)
						If blnResult Then
							Call ReportLog("Auto Closure Tasks", "Automatic Port Allocation Task should be AutoClosed in 25 mins", "Automatic Port Allocation Task is AutoClosed", "PASS", True)
						Else
							Call ReportLog("Auto Closure Tasks", "Automatic Port Allocation Task should be AutoClosed in 25 mins", "Automatic Port Allocation Task is not closed after 25 mins", "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
					Else
						Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
						Call fn_TAHITI_EndTask()
					End if
	
			Case "Automatic Service Activation", "Automatic order CPE (Provide)"
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						blnResult = fn_TAHITI_CheckAutoClosure(strTaskId, 60)
						If blnResult Then
							Call ReportLog("Auto Closure Tasks", strCurrentTaskName & " Task should be AutoClosed in 60 mins", strCurrentTaskName & " Task is AutoClosed", "PASS", True)
						Else
							Call ReportLog("Auto Closure Tasks", strCurrentTaskName & " Task should be AutoClosed in 60 mins", strCurrentTaskName & " Task is not closed after 60 mins", "FAIL", True)
							Environment("Action_Result") = False
							Exit Function
						End If
	
						If Trim(strCurrentTaskName) = "Automatic Service Activation" Then
							fn_TAHITI_AutomaticServiceActivationCheckPointVerification "Automatic Service Activation", "Successful Response Received from rPACS for Automatic Service Activation"
								If Not Environment("Action_Result") Then Exit Function
						End If
					Else
						Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
						Call fn_TAHITI_EndTask()
					End If

			Case "Wait for acknowledgement of CPE ord"
					blnResult = fn_TAHITI_CheckAutoClosure(strTaskId, 10)
					If blnResult Then
						Call ReportLog("Auto Closure Tasks", strCurrentTaskName & " Task should be AutoClosed in 10 mins", strCurrentTaskName & " Task is AutoClosed", "PASS", True)
					Else
						Call ReportLog("Auto Closure Tasks", strCurrentTaskName & " Task should be AutoClosed in 10 mins", strCurrentTaskName & " Task is not closed after 10 mins", "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If					
	
			Case "Plan & Assign Primary Global Networ"
					Wait 90
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PlanAssignPrimaryGlobalNetwork(dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK)
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()

			Case "Plan & Assign Secondary Global Netw"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						blnEndTask = fn_TAHITI_PlanAssignSecondaryGlobalNetwork(dAIBURL, dAIBUserName, dAIBPassword)
						If Not blnEndTask Then 
							Environment("Action_Result") = False
							Exit Function
						End If
					End If
					Call fn_TAHITI_EndTask()

			Case "Plan & Assign in-country Network Re"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PlanAndAssignInCountryNetworkResource
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()					
					
			Case "Perform Number Management", "Perform Number Management (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PerformNumberManagement()
					Call fn_TAHITI_EndTask()
		
			Case "Order Access Tail (Provide)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_OrderAccessTailProvide(dOrderAccessTailProvide)
					'Call fncOrderAccessTail(AccessDeliveryStatus,AccessDeliveryType,AccessSupplierContractTerm)
					Call fn_TAHITI_EndTask()  

			Case "Confirm Access Delivery Date & refe"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfirmAccessDeliveryDateAndReferenceProvide(dCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE)
					'Call fncConfirmAccessDeliveryDateRefNum(AccessSupplierOrderRefNo,AccessDeliveryStatus,CurrencyType,OneTimeCost,RecurringCost,AccessOrderAccepted)
					Call fn_TAHITI_EndTask()		

			Case "Confirm Access installation (Provid"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfirmAccessInstallation(dCONFIRM_ACCESS_INSTALLATION)
					Call fn_TAHITI_EndTask()		
		
			Case "Select & schedule tests required (P"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_SelectandScheduletestsrequired(dSELECT_SCHEDULE_TESTS_REQUIRED)
					Call fn_TAHITI_EndTask()	
		
			Case "Configure GMV (Provide)", "Configure GMV (Change)", "De-configure Mediation"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfigureGMV(dCONFIGURE_GMV)
					Call fn_TAHITI_EndTask()
		
			Case "Hand over into maintenance (Provide", "Hand over into maintenance (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_HandOverIntoMaintenance(dHANDOVER_INTO_MAINTENANCE)
					Call fn_TAHITI_EndTask()

			Case "Co-ordinate Cutover activities (Cha"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_CoordinateCutoverActivities()
					Call fn_TAHITI_EndTask()	
	
			Case "Full Service / CPE Test (Provide)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_FullServiceCPETest(dFULL_SERVICE_CPE_TEST)
					Call fn_TAHITI_EndTask()
		
			Case "Perform Access Alarm Check (Provide", "Perform Alarm Check (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PerformAccessAlarmCheck(dPerformAccessAlarmCheck)
					Call fn_TAHITI_EndTask()
		
			Case "On-Site / CPE Connectivity Test (Pr"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_OnSiteCPEConnectivityTest(dONSITE_CPE_CONNECTIVITY_TEST)
					Call fn_TAHITI_EndTask()
		
			Case "Perform Service Test (Provide)", "Perform Service Test (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PerformServiceTest(dPERFORM_SERVICE_TEST)
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()
                  
			Case  "Perform Full Service / CPE Test (Ch"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PerformFullServiceTest(dPERFORM_Full_SERVICE_TEST)
					Call fn_TAHITI_EndTask()
	
			'Case "Set Elements to Installed (Provide)", "Set Elements to Installed (Change)"
			'		Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
			'		'This task is to be completed in classic Hence we are sending a mail to them
			'		Call ReportLog("Manual Intervention", "Please handle the task " & strTaskId & "_" & strCurrentTaskName, "Please take necessary action in classic", "Warnings", True)
			'		Call  fn_TAHITI_MailAlertForSetElementsToInstalled(dRecieverMailAddress,dCCMailAddress)

			Case "Set Elements to Installed (Provide)", "Set Elements to Installed (Change)", "Set Elements to Ceased (Cease)"
					Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strTaskId & " Order has encountered with Task " & strCurrentTaskName, strTaskId & " Order has encountered  with Task " & strCurrentTaskName & ". Please take necessary actions in Classic", "")
					Call ReportLog("Manual Intervention", "Please handle the task " & strTaskId & "_" & strCurrentTaskName, "Please take necessary action in classic", "Warnings", True)
					Environment("Action_Result") = False : Exit Function

			Case "Notify Customer Service is Ready (P", "Notify Customer Service is Ready (C"
					'If DateDiff("d", arrEndDate(0), Date) = 0 Then
						Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
						Call fn_TAHITI_NotifyCustomerServiceReady(Trim(arrEndDate(0)), Trim(arrEndTime(0)), Trim(arrEndTime(1)), Trim(arrEndTime(2)))
						Call fn_TAHITI_EndTask()
					'Else
					'	Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strTaskId & " Order has encountered with Task " & strCurrentTaskName, strTaskId & " Order has encountered  with Task " & strCurrentTaskName & ". Please end the task manually.", "")
					'	Call ReportLog("Manual Intervention", "Requires Manual Intervention for task " & strTaskId & "_" & strCurrentTaskName, "Please take necessary action in Tahiti by closing it manually", "Warnings", True)
					'	Environment("Action_Result") = False : Exit Function
					'End If
					
			Case "Notify Customer Service is Ready (C"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_NotifyCustomerServiceReady()
'					Call fncNotifyCustomerServiceReady(NotifyCustSvcReadyDate)
					Call fn_TAHITI_EndTask()
	
			Case "Configure Mediation"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfigureMediation(dCONFIGURE_MEDIATION)
					'Call fncConfigureMediation(ServiceLocationID)
					Call fn_TAHITI_EndTask()
                   
			Case "Configure Mediation (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfigureMediation(dCONFIGURE_MEDIATION)
					'Call fncConfigureMediation(ServiceLocationID)
					Call fn_TAHITI_EndTask()

			Case "Order CPE (Provide)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_OrderCPEProvide()
					Call fn_TAHITI_EndTask()

			Case "Confirm supplier commit date & refe"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_ConfirmSupplierCommitDateAndReferenceProvide()
					Call fn_TAHITI_EndTask()

			Case "Prepare & build CPE base config (Pr"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					blnResult = fn_TAHITI_PrepareAndBuildCPEBaseConfig(dPREPARE_BUILD_CPE_BASE_CONFIG, dAIBURL,dAIBUserName,dAIBPassword)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Call fn_TAHITI_EndTask()

			Case "Plan Service Modification (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					'Call fn_TAHITI_PerformAccessAlarmCheckforPlanandModification(dPlanServiceModification)
					Call fn_TAHITI_PlanServiceModification_Change(dPlanServiceModification)
					Call fn_TAHITI_EndTask()

			Case "Gather & Confirm Service Configurat"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					blnResult = fn_TAHITI_GatherAndConfirmServiceConfig()
						If Not blnResult Then Exit Function
					Call fn_TAHITI_EndTask()

			Case "Port in/out and test service with c"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					blnResult = fn_TAHITI_PortInOutAndTestServiceWithCustomer()
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Call fn_TAHITI_EndTask()

			Case "Notify Billing of Cease (Cease)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_NotifyBillingOfCease()
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()
					
			Case "Customer Activation Support (Provid"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_CustomerActivationSupport()
					Call fn_TAHITI_EndTask()

			Case "Recover Primary Global Network Reso" 'Handling Dependency
					'Check whether Task "Deactivate Service / Feature (Cease" is Ended or not if not pick for the execution
					Call ReportLog("Check Dependent Task", "[[Deactivate Service / Feature (Cease]] Task should be closed first", "Checking the Status", "Information", True)
						blnClosed = fn_TAHITI_CheckDeactivateServiceClosure(strCurrentTaskName)
							If Not Environment("Action_Result") Then Exit Function

					If blnClosed Then
							objFrame.WebRadioGroup("IdNumber").Select strTaskId
							Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
							If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then ' Need to check the impact
								Call fn_TAHITI_RecoverPrimaryGlobalNetworkResources()
									If Not Environment("Action_Result") Then Exit Function
							End if
					Else
							Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
							Call ReportLog("Check Dependent Task", "[[Deactivate Service / Feature (Cease]] Task should be closed first", "Task is not closed and handling the task", "Information", True)
							Call fn_TAHITI_DeactivateServiceORFeature()
								If Not Environment("Action_Result") Then Exit Function
					End If

					Call fn_TAHITI_EndTask()

			Case "Deactivate Service / Feature (Cease"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_DeactivateServiceORFeature()
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()
					
			Case "Prepare & build CPE customer config"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						blnResult = fn_TAHITI_PrepareAndBuildCPECustomerConfig(dAIBURL,dAIBUserName,dAIBPassword)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End If
					Call fn_TAHITI_EndTask()
			
			Rem 12-Oct-2015 - R40
			Case "Order / Modify Fibre (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_OrderOrModifyFibreChange()
					Call fn_TAHITI_EndTask()
			
			Rem 24-Aug-2016 - R45
			Case "Cutover and test service with custo"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_CutoverAndTestServiceWithCustomer()
					Call fn_TAHITI_EndTask()
			
			Rem 24-Aug-2016 - R45
			Case "Set scheduled cutover date(Modify)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_SetScheduledCutoverDate()
					Call fn_TAHITI_EndTask()

			Rem 16-Oct-2015 - R40 - Needs to be completed as credentials dont have the access to upload Cease Proof Document
			'Case "Confirm Access Dates (Cease)"
			'		Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
			'		'Call fn_TAHITI_ConfirmAccessDatesCease()
			'		Call fn_TAHITI_EndTask()
							
			Case "Configure Incountry Voice Platform(", "Confirm CCD with Customer (Provide)", "Configure CBR", "Trigger Customer Billing (Provide)",_
					"Set scheduled port in or out date(M", "Reconfigure incountry voice platfor", "Confirm CCD with customer (Change)", "Configure Voice PoP (Change)",_
					"Configure CBR (Change)", "Trigger Customer Billing (Change)", "Deactivate Service / Feature (Cease", "Deconfigure Voice PoP",_
					"De-Configure GMV (Cease)", "Deconfigure incountry voice platfor", "Trigger Customer Billing (Cease)","Re-Configure Local Transmission Pat", "Receive Notification of Access (Cha",_
					"Inform Customer Access Installed (P", "Set up Customer Reporting (Provide)", "Resolve Customer Activation Support", "Trigger B-End billing (Provide)",_
					"Deliver / Modify Fibre (Change)", "Confirm Own Access Delivered (Chang", "Resolve Full Service / CPE Test Fai", "Order Access Cease (Cease)",_
					"Schedule Site Visit to Recover CPE", "Confirm CPE Recovered (Cease)", "De-configure core Transmission path", "Trigger Deactivate Customer Reporti",_
					"Recover Secondary Global Network Re", "Recover In-Country Network Resource", "Set scheduled port in date (Provide", "Configure Ribbit(Provide)", "Plan Local Transmission Path Re-Con", _
					"Resolve On-Site / CPE Connectivity", "Trigger B-end billing (Change)", "Resolve handover issues (Provide)", "Confirm CCD with customer (Provide)",_
					"Resolve Service Test Failure (Provi"

					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_EndTask()

			'Scripted in Rel39
			Case "Update MNUM(Provide)", "Update MNUM(Modify)", "Update MNUM(Cease)"
					strServiceDetails = objPage.Frame("name:=content").WebTable("column names:=All Tasks For Service.*").GetROProperty("column names")
					strServiceID = fRegExpReplaceText(strServiceDetails, "(All Tasks For Service\s*\()(GONEV.*)(\))", "$2")
					
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						strFileName = fn_TAHITI_UpdateMNUMProvide()
							If Not Environment("Action_Result") Then Exit Function
						strValues = dUpdateMNUMProvide
						arrValues = Split(strValues, ",")
						
						arrVal1 = Split(arrValues(0), ":")
						strCountry = arrVal1(1)
						
						arrVal2 = Split(arrValues(1), ":")
						strProduct = arrVal2(1)
						
						arrVal3 = Split(arrValues(2), ":")
						strCustomerID = arrVal3(1)
						
						'Upload the file in VLP
						Call fn_TAHITI_VLP_UploadCSVFile(dVLPURL, dVLPUserName, dVLPPassword, strFileName, strCountry, strProduct, strCustomerID)
							If Not Environment("Action_Result") Then Exit Function
							
						'Mail Verification for Attchement contains success, fail status or not					
						Call fn_TAHITI_CheckNumberBlockStatus(strServiceID, "Manage Number Operations")
							If Not Environment("Action_Result") Then Exit Function

					End If
					Call fn_TAHITI_EndTask()

			Case "Update Number Management"
					strServiceDetails = objPage.Frame("name:=content").WebTable("column names:=All Tasks For Service.*").GetROProperty("column names")
					strServiceID = fRegExpReplaceText(strServiceDetails, "(All Tasks For Service\s*\()(GONEV.*)(\))", "$2")
			
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_UpdateNumberManagement(MNUMToBeUsed)
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()
					
					If MNUMToBeUsed = "Yes" Then
						'Perform Operation for Update MNUM ceasing the Number Blocks that are added
						Call fn_TAHITI_NavigateToUpdateMNUMCease()
						If Not Environment("Action_Result") Then 
								Exit Function
						Else
								Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
								strFileName = fn_TAHITI_UpdateMNUMProvide()
									If Not Environment("Action_Result") Then Exit Function
		
								strValues = dUpdateMNUMProvide
								arrValues = Split(strValues, ",")
								arrVal1 = Split(arrValues(0), ":")
								strCountry = arrVal1(1)
								arrVal2 = Split(arrValues(1), ":")
								strProduct = arrVal2(1)
								'Upload the file in VLP
		
								Call fn_TAHITI_VLP_UploadCSVFile(dVLPURL, dVLPUserName, dVLPPassword, strFileName, strCountry, strProduct)
									If Not Environment("Action_Result") Then Exit Function
	
								'Mail Verification for Attchement contains success, fail status or not
								Call fn_TAHITI_CheckNumberBlockStatus(strServiceID, "Manage Number Operations")
									If Not Environment("Action_Result") Then Exit Function
	
								'Click on Tasks In Service Link
								objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
						End If
					End If

			Case "Verify CPE is ready for Installatio"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_VerifyCPEIsReadyForInstallation()
					Call fn_TAHITI_EndTask()

			Case "In Service Notification (Provide)", "In Service Notification (Change)"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_InServiceNotificationProvide
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()
					

			'Case "Plan Configuration of Core Transmis"			
			'		Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strOrderID & " Order has encountered  with Task " & strCurrentTaskName, strOrderID & " Order has encountered with Task " & strCurrentTaskName & ". Please take necessary actions at rPACS for creating VLANS", "")
			'		Call ReportLog("Manual Intervention", strCurrentTaskName & " requires manual intervention", strOrderID & " Order has encountered with Task " & strCurrentTaskName & ". Please take necessary actions at rPACS by creating VLANS", "Warnings", True)
			'		Environment("Action_Result") = False : Exit Function
	
			'Needs to Completed as R39 New Requirement
			Case "Confirm Subproject Closure (Cease)", "Confirm Access Dates (Cease)"
					Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strTaskId & " Order has encountered  with Task " & strCurrentTaskName, strTaskId & " Order has encountered with Task " & strCurrentTaskName & ". Please take necessary actions" & _
						"</BR> Inform Automation Team once access has been provided to upload Cease Proof Document", "")
					Call ReportLog("Manual Intervention", strCurrentTaskName & " requires manual intervention", strOrderID & " Order has encountered with Task " & strCurrentTaskName & ". Please take necessary actions.", "Warnings", False)
					Environment("Action_Result") = True : Exit Function
					'Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					'Call fn_TAHITI_ConfirmSubProjectClosure()
					'	If Not Environment("Action_Result") Then Exit Function
					'Call fn_TAHITI_ConfirmSubProjectClosure()
			
			'Should include interaction details page
			Case "Plan Configuration of Core Transmis"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_PlanConfigurationOfCoreTransmissionPath()
						If Not Environment("Action_Result") Then Exit Function
					Call fn_TAHITI_EndTask()

			Case "Activate Service for Test & Turnup", "Automatic Wait for the CRD Date"
					Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strTaskId & " Order has encountered  with Task " & strCurrentTaskName, strTaskId & " Order has encountered  with Task " & strCurrentTaskName & ". Please take necessary actions", "")
					Call ReportLog("Manual Intervention", "Please handle the task " & strTaskId & "_" & strCurrentTaskName, "Please take necessary action", "Warnings", True)
					Environment("Action_Result") = False : Exit Function

			Case "Activate Service for Test and Turnu"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						blnResult = fn_TAHITI_UpdaterPACSAndVerifyMessage()
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End If
					Call fn_TAHITI_EndTask()
					
			Case "Automatic wait for Port in/out Date", "Automatic Wait for the Hard Cease D", "Automatic Order CPE (Cease)"
					Call fCreateAndSendMail(dRecieverMailAddress,dCCMailAddress, "", strTaskId & " Order has encountered  with Task " & strCurrentTaskName, strTaskId & " Order has encountered  with Task " & strCurrentTaskName & ". Drop mail to Classic Team and get task closed", "")
					Call ReportLog("Manual Intervention", "Please handle the task " & strTaskId & "_" & strCurrentTaskName, "Please take necessary action", "Warnings", True)
					Environment("Action_Result") = False : Exit Function

			Case "Confirm sub-project completion (Pro", "Confirm sub-project completion (Cha"
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_EndTask()
					Call fn_TAHITI_Logout()
					Call ReportLog("Task Closure Completion", "All Tasks has been closed", strCurrentTaskName & " has been triggered", "PASS", True)
					Environment("Action_Result") = True
					Exit Function
					
			Case "Configure Voice PoP"
					
					If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
						Call fn_TAHITI_iVServeLogin(diVServeURL, diVServeUserName, diVServePassword)
						Call fn_TAHITI_iVServeCheckLBM("RoW Generic / 1.0", RandomNumber(111, 999) , LoopBackMode)
						If Not Environment("Action_Result") And LoopBackMode = "NO" Then
							Call ReportLog("Check LBM", "Encountered error while checking LBM", "Please contact Automation Team", "Warnings", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						If LoopBackMode = "NO" Then
							Call fCreateAndSendMail(dRecieverMailAddress, "" , "", "Loopback mode is NO", "Loopback mode is NO. Please take necessary actions", "")
							Call ReportLog("Check LBM", "LBM should be <B>YES</B>", "Loopback mode is found to be <B>NO</B>", "Warnings", False)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog("Check LBM", "LBM should be <B>YES</B> in IVServe", "Loopback mode is found to be <B>" & LoopBackMode & "</B> in IVServe", "Information", False)
						End If
					End If
					
					Call fn_TAHITI_TaskNavigation(strCurrentTaskName)
					Call fn_TAHITI_EndTask()

			Case Else
					Call ReportLog("New Task has been Triggered", strCurrentTaskName & " has been triggered", "Contact Automation Team", "FAIL", True)
					Environment("Action_Result") = False
					Exit Function

			End Select

			blnTasks = fn_TAHITI_CheckForTasks(strCurrentTaskName)
			If Not blnTasks Then
				Call ReportLog("Tasks Generation", "Task should be generated", "Tasks are not getting gererated and its been more than 25mins", "Warnings", False)
				Environment("Action_Result") = False : Exit Function
			End If
		Loop

End function

'***************************************************************************************************************************************************************************************
' Description: Checks whether tasks are generated or not for 25+ mins
'***************************************************************************************************************************************************************************************
Public Function fn_TAHITI_CheckForTasks(strCurrentTaskName)
	Dim iNext, intNext, intCounter, iRow
	
	Reporter.ReportNote "In Function [[ fn_TAHITI_CheckForTasks ]]"
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

		For intCounter = 1 to 60
				'To check if new tasks are added
				If Not objFrame.WebElement("webElmNoOfTasks").Exist(5) Then
					objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
					objBrowser.Sync : objPage.Sync
				End If
				
				objFrame.WebElement("webElmNoOfTasks").RefreshObject
				strRetrivedText = objFrame.WebElement("webElmNoOfTasks").GetROProperty("innerhtml")
				arrResultMessage = SPlit(strRetrivedText," ")
				NoOfTasksUpdated = arrResultMessage(0)
	
				Call fn_TAHITI_SortRecords()

				'To calculate number of times next to be clicked to reach last task
				intNext = Ceil(NoOfTasksUpdated/10)
	
				For iNext = 1 To intNext
						'To see if already generated tasks are there which are not closed
						RowsInPage = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
						blnFlag = False
						For iRow = 4 to RowsInPage
								strTaskStatus = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 4)
								strTaskName = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 3)
								If strTaskStatus = "Execution" Then
										fn_TAHITI_CheckForTasks = True
										Exit Function
								End If

								If Instr(strTaskName, "Confirm sub-project completion") > 0 And strTaskStatus = "Ended" Then
									Call ReportLog("Task Closure Completion", "All Tasks has been closed", "Confirm sub-project completion has been triggered", "PASS", True)
									Environment("Action_Result") = True : Exit Function
								ElseIf (strTaskName = "Set Elements to Installed (Provide)" OR strTaskName = "Set Elements to Installed (Change)" OR strTaskName = "Set Elements to Ceased (Cease)" AND strTaskStatus = "Ended") Then
									arrEndDate = Split(objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 8), Space(1))
									If UBound(arrEndDate) = 1 Then
										arrEndTime = Split(arrEndDate(1), ":")
									End If								
								End If
						Next '#iRow
		
						If intNext > iNext Then
								blnResult = clickFrameImage("imgNext")
									If Not BlnResult Then fn_TAHITI_CheckForTasks = False : Exit Function
								Wait 10
						End If
				Next 'Next
	
				Wait 60
				Browser("brwTahitiPortal").Page("pgTahitiPortal").Frame("frmThahitiFrame").Link("lnkTasksInService").Click
				Wait 5
			Next

	fn_TAHITI_CheckForTasks = False
End Function
'================================================================================================================================================================================================
' Description: Check for AutoClosure of Automatic Tasks
'================================================================================================================================================================================================
Public Function fn_TAHITI_CheckAutoClosure(ByVal TaskID, ByVal intWaitCounter)
	Dim iRow, iWaitCounter, iNextCounter, intRow
	Dim strTaskID, strTaskStatus
	Dim blnFound
	
	Reporter.ReportNote "In Function [[ fn_TAHITI_CheckAutoClosure ]]"
	
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then Environment.Value("Action_Result")=False : Exit Function

		For iWaitCounter = 1 To intWaitCounter
			For iNextCounter = 1 To 3
					objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RefreshObject
					intRow = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
					blnFound = False
					For iRow = 4 To intRow
							strTaskID = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 2)
							If strTaskID = TaskID Then
								blnFound = True
								strTaskStatus  = Trim(objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 4))
								If strTaskStatus = "Ended" Then
									fn_TAHITI_CheckAutoClosure = True
									Exit Function
								End If
							End If
					Next '#iRow
	
					If Not blnFound Then
						objFrame.Image("imgNext").Click
						Wait 5
					Else
						Exit For '#iNextCounter
					End If
			Next '#iNextCounter 

			Wait 60
			objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
			Wait 5
	Next '#iWaitCounter

	fn_TAHITI_CheckAutoClosure = False
End Function
'==============================================================================================================================================
' Description: To Check whether required message is getting populated or not
'==============================================================================================================================================
Public Sub fn_TAHITI_AutomaticServiceActivationCheckPointVerification(ByVal TaskName, ByVal Message)
		Reporter.ReportNote "In Function [[ fn_TAHITI_AutomaticServiceActivationCheckPointVerification ]]"
		Dim intRow, iRow
		Dim strTaskID, strTaskName
			
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Sub
	
		intRows = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RowCount
	
		blnFound = False
		For iRow = 4 To intRows
			strTaskName = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow, 3)
			If strTaskName = TaskName Then
				blnFound = True
				Exit For
			End If
		Next
	
		If Not blnFound  Then
			Call ReportLog("Task Search", "Tasks Should be available", "Task is not available", "FAIL", True)
			Environment("Action_Result") = False
			Exit Sub
		End If
		
		strTaskID = objPage.Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(iRow,2)
		objFrame.WebRadioGroup("IdNumber").Select strTaskID
	
		blnResult = clickFrameButton("btnTaskDetail")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Sub
	
		If Not objFrame.WebButton("btnEndTask").WaitProperty("height", micGreaterThan(0), 60000) Then
			Call ReportLog("Navigation", "Should be Navigated to Task Details Page", "Navigated to Task Details Page", "FAIL", True)
			Environment("Action_Result") = False
			Exit Sub
		End If
	
		strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
		strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
		If Instr(strText, Message) > 0 Then
			Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
			Environment("Action_Result") = True
		Else
			Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message doesnt exist</BR>" & strInnerHTML, "FAIL", True)
			Environment("Action_Result") = False
		End If
	
		objPage.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
		Wait 10

End Sub
'==========================================================================================================================
' Description: Sort the Records
'==========================================================================================================================
Public Function fn_TAHITI_SortRecords()
	Dim strTaskID1, strTaskID2, strFrameText
	Dim intRows
	Reporter.ReportNote "In Function [[ fn_TAHITI_SortRecords ]]"
	With Browser("brwTahitiPortal").Page("pgTahitiPortal")
		'Click on Tasks In Service Link
		.Frame("frmThahitiFrame").Link("lnkTasksInService").Click
		Wait 5
		'Click on Sorting Icon on Tasks ID
		.Frame("frmMyTasks").WebElement("webElmTaskTab").Click
		strFrameText = .Frame("html id:=content").Object.DocumentElement.innertext
		If Instr(strFrameText, "Web Server Temporarily Unavailable") > 0 Then
			Browser("brwTahitiPortal").Back : Wait 2
			.Frame("frmMyTasks").WebElement("webElmTaskTab").Click
		End If
		
		Wait 2
		.Frame("frmMyTasks").WebTable("tblAllTaskDetails").RefreshObject

		If intRows > 4 Then
				strTaskID1 = .Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(4, 2)
				strTaskID2 = .Frame("frmMyTasks").WebTable("tblAllTaskDetails").GetCellData(5, 2)
				If (Mid(strTaskId, InstrRev(strTaskID1, "-") + 1, 1) + 1) <> CInt(Mid(strTaskID1, InstrRev(strTaskID2, "-") + 1, 1)) Then
						blnResult = objFrame.WebElement("webElmTaskTab").click
						blnResult = objFrame.WebElement("webElmTaskTab").click
						Wait  3
				End If
		End If
	End With
End Function
'==========================================================================================================================
' Description: Check Whether task has been generated or not and check whether DeactiveServiceClosure has been closed or not
'==========================================================================================================================
Public Function fn_TAHITI_CheckDeactivateServiceClosure(ByVal CurrentTaskName)
		'Variable Declaration
		Dim blnTasks
		Dim iRow, intRowsInPage
		Dim strTaskName, strTaskStatus, strTaskID
		
		Reporter.ReportNote "In Function [[ fn_TAHITI_CheckDeactivateServiceClosure ]]"
		'Build Reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnTasks = fn_TAHITI_CheckForTasks(CurrentTaskName)
			If Not blnTasks Then Environment("Action_Result") = False : Exit Function

		intRowsInPage = objFrame.WebTable("tblAllTaskDetails").RowCount

		For iRow = 4 To intRowsInPage
			strTaskName = Trim(objFrame.WebTable("tblAllTaskDetails").GetCellData(iRow, 3))
			strTaskStatus = Trim(objFrame.WebTable("tblAllTaskDetails").GetCellData(iRow, 4))
			If strTaskName = "Deactivate Service / Feature (Cease" Then
				If strTaskStatus = "Ended"  Then
					fn_TAHITI_CheckDeactivateServiceClosure = True
					Environment("Action_Result") = True
					Exit Function
				Else
					strTaskID = Trim(objFrame.WebTable("tblAllTaskDetails").GetCellData(iRow, 2))
					objFrame.WebRadioGroup("IdNumber").Select strTaskID : Wait 2
					fn_TAHITI_CheckDeactivateServiceClosure = False
					Environment("Action_Result") = True
					Exit Function
				End If
			End If
		Next
				
End Function
