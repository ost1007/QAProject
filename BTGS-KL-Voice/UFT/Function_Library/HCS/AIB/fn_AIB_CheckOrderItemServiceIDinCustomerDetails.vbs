'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CheckOrderItemServiceIDinCustomerDetails
'
' Purpose					: 			Function to Check Order Item Service ID in CustomerDetails
'
' Author					:		  	Linta CK
'Modified by			  : 		
' Creation Date   		: 			22/06/2014
'Modified Date   			:				
' Parameters	 		 :			TaskName,InnerOrderItemName
'                  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************
Public function fn_AIB_CheckOrderItemServiceIDinCustomerDetails(TaskName,InnerOrderItemName)

	'Declaration
	Dim strTaskName,strInnerOrderItemName

	'Assigning
	strTaskName = TaskName
	strInnerOrderItemName = InnerOrderItemName

	'Build  web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	'Click on Customer Order Details tab
	If objPage.Link("lnkCustomerOrderDetails").exist Then
		blnResult = clickLink("lnkCustomerOrderDetails")
		If blnResult = "False" Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
		objPage.Sync
	End If
							
	'To Capture Index on Main Order Item Table
	Set objTable = objPage.WebTable("tblOrderItem")
	MainOrderItemTable= GetWebTableIndex (objTable)

	Set objTable = objPage.WebTable("tblOrderItem")
	strOrderItemNumber = objTable.GetCellData(2,1)
	Set objDesc = Description.Create
	objDesc("micClass").value = "WebElement"
	objDesc("innertext").value = strOrderItemNumber

	Set objOrderItemNumber = objTable.ChildObjects(objDesc)
	If objOrderItemNumber.Count >= 1 Then
		objOrderItemNumber(0).Click
		Wait 3
	End If

	dataTableIndex=MainOrderItemTable+1
	Set objTable = objPage.WebTable("index:=" & dataTableIndex)	

	'Capture the valus inside that inner table.
	intRow = objTable.GetRowWithCellText(strInnerOrderItemName,2)
	strServiceId = objTable.GetCellData(intRow,4)								                                            		
	Call ReportLog(strInnerOrderItemName& " - Service ID","Service ID should be populated for the product - "&strInnerOrderItemName , "Service ID <B>"&strServiceId&"</B> is populated for the product - <B> " &strInnerOrderItemName,"PASS","")

End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************

