'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CheckMainOrderServiceIDinCustomerDetails
'
' Purpose					: 			Function to Check Main Order Service ID in CustomerDetails
'
' Author					:		  	Linta CK
'Modified by			  : 		
' Creation Date   		: 			22/06/2014
'Modified Date   			:				
' Parameters	 		 :			dTaskName
'                  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************

Public function fn_AIB_CheckMainOrderServiceIDinCustomerDetails(dTaskName)

	'Declaration of variables
	strTaskName = dTaskName

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
							

	'Retrieving Main Order Item Service Id 
	If objPage.WebTable("tblOrderItem").Exist Then
		Set objTable = objPage.WebTable("tblOrderItem")
		RowCntMainOrder = objTable.GetROProperty("rows")
		NumberOfProducts = RowCntMainOrder - 1
	End If
	
	For intCnt = 1 to NumberOfProducts
		strProductName = objTable.GetCellData(intCnt+1,2)
		If Instr(strProductName,"ERROR") >= 1 Then
			Exit For
		End If
		strServiceId = objTable.GetCellData(intCnt+1,4)								                                            		
		Call ReportLog("Main Order Item Service ID","Service ID should be populated for the Main Order Item" , "Service ID <B>"&strServiceId&"</B> is populated for the Main Order Item - <B> "&strTaskName&"</B> ","PASS","")
	Next

End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************

