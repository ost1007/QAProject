'****************************************************************************************************************************
' Function Name 		:		fn_SQE_CreateOrder
'
' Purpose				: 		Function to Create Order
'
' Author				:		 Linta C.K.
'Modified by		  : 			
' Creation Date  		 : 		  08/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_CreateOrder_ModifySoftChanges(dOrderName,dActualConfigureProduct)

	'Declaring of variables
	Dim blnResult
	Dim strOrderName

	'Assigning variables
	strOrderName = dOrderName

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'''''''''	'Check if order is created
'''''''	blnResult = objPage.Link("lnkOrders").Exist(10)
'''''''	If blnResult = "True" Then
'''''''		Call ReportLog("Order creation","Check if order is created","Order is created and Orders tab is visible","PASS","False")
'''''''		Exit Function
'''''''	Else
'''''''		Wait 5
'''''''	End If	

'	'Select Checkbox
''''	StrRowCount = objPage.WebTable("webTblBaseConfigQty1").RowCount
'''''	strColCount = objPage.WebTable("webTblItems").ColumnCount(StrRowCount)
''''
''''	For Intcounter = 2 to StrRowCount
''''			strProductName = objPage.WebTable("webTblBaseConfigQty1").GetCellData(Intcounter,2)
''''			If  strProductName = dActualConfigureProduct Then
''''				Set ObjWebchkBox = objPage.WebTable("webTblBaseConfigQty1").childitem(Intcounter,1,"WebCheckBox",0)
''''						ObjWebchkBox.Set "ON"
''''						Exit For
''''			End If
''''
''''	Next


	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'	'Click on Create Order
	blnResult = objPage.Link("lnkCreateOrder").Exist
	objPage.Link("lnkCreateOrder").Highlight
	If blnResult = "True" Then
		blnResult = clickLink("lnkCreateOrder")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Click on Create Order","User should be able to click on Create Order link","User could not click on Create Order link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'
'	'Enetr Order Name
	blnResult = objPage.WebEdit("txtOrderName").Exist
	If blnResult = "True" Then
		blnResult = enterText("txtOrderName",strOrderName)
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If

'	'Click on Save
	blnResult = objPage.WebButton("btnSave").Exist
	If blnResult = "True" Then
		blnResult = clickButton("btnSave")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If

	'Check if navigated to Orders Link
	For intCounter = 1 to 10
		blnResult = Browser("brwSQE").Page("pgSQE").Link("lnkOrders").Exist
		If blnresult = "False" Then
			Call ReportLog("Save Order Details","User should be able to save Order details and navigate to Orders link","User is able to save Order details and navigate to Orders link","FAIL","False")
		Else
			Call ReportLog("Save Order Details","User should be able to save Order details and navigate to Orders link","User is able to save Order details and navigate to Orders link","PASS","False")
			Exit For
		End If	
	Next

	If Not blnResult Then
		Call ReportLog("Save Order Details","User should be able to save Order details and navigate to Orders link","User is able to save Order details and navigate to Orders link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************


