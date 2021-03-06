
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Aactivity
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_BillofMaterial()

   ''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwExpedioBillofMaterials","pgExpedioBillofMaterials","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

   ''Click on Bill of Material Tab
	blnResult  = clickLink("lnkBillofMaterials")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''Click on Edit Bill of Material  Link
	blnResult  = clickLink("lnkEditBillofMaterials")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''Click on Add Button
	blnResult  = clickLink("lnkAdd")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	End Function