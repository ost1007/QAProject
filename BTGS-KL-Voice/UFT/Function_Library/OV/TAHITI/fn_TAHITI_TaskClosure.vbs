'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_TaskClosure
'
' Purpose	 	 : Function to complete Task Closures in Tahiti 
'
' Author	 	 :	Linta C.K.
'
' Creation Date  :	25/04/2014
'
' Parameters	 : 	dTahitiURL
'					dTahitiUserID
'					dTahitiPassword
'					dOrderID - Order ID to be searched
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_TAHITI_TaskClosure(dTahitiURL,dTahitiUserID,dTahitiPassword,dOrderID,dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK,dSELECT_SCHEDULE_TESTS_REQUIRED,dCONFIGURE_GMV,dPerformAccessAlarmCheck,dONSITE_CPE_CONNECTIVITY_TEST,dFULL_SERVICE_CPE_TEST,dPERFORM_SERVICE_TEST,dCONFIGURE_MEDIATION,dTRIGGER_CUSTOMER_BILLING,dRecieverMailAddress,dCCMailAddress,dNOTIFY_CUSTOMER_SERVICE_READY,dHANDOVER_INTO_MAINTENANCE,dOrderCPEProvide,dPlanServiceModification)
	Call fn_TAHITI_Login(dTahitiURL,dTahitiUserID,dTahitiPassword)
	If Not Environment.Value("Action_Result") Then
		Exit Function
	End If

	Call fn_TAHITI_OrderSearch(dOrderID)
	If Not Environment.Value("Action_Result") Then
		Exit Function
	End If

	Call fn_TAHITI_TaskSelection_Closure(dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK,dSELECT_SCHEDULE_TESTS_REQUIRED,dCONFIGURE_GMV,dPerformAccessAlarmCheck,dONSITE_CPE_CONNECTIVITY_TEST,dFULL_SERVICE_CPE_TEST,dPERFORM_SERVICE_TEST,dCONFIGURE_MEDIATION,dTRIGGER_CUSTOMER_BILLING,dRecieverMailAddress,dCCMailAddress,dNOTIFY_CUSTOMER_SERVICE_READY,dHANDOVER_INTO_MAINTENANCE,dOrderCPEProvide,dOrderAccessTailProvide,dCONFIRM_SUPPLIER_COMMIT_DATE_REFERENCE_PROVIDE,dCONFIRM_ACCESS_DELIVERY_DATE_REFERENCE_PROVIDE,dPREPARE_BUILD_CPE_BASE_CONFIG,dCONFIRM_ACCESS_INSTALLATION,dPlanServiceModification,dPERFORM_Full_SERVICE_TEST)
	If Not Environment.Value("Action_Result") Then
		Exit Function
	End If

End Function
