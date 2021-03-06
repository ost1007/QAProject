'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CaptureAndClickOrderItemNumber
'
' Purpose					: 			Function to capture and click on Order Item Number
'
' Author					:		  	Linta CK
'Modified by			  : 		
' Creation Date   		: 			18/06/2014
'Modified Date   			:				
' Parameters	 		 :			objTbl,OrderNumber,ByRef MainOrderItemTable,ByRef objOrderItemNumber
'                  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************

Public function fn_AIB_CaptureAndClickOrderItemNumber(objTbl,OrderNumber,ByRef MainOrderItemTable,ByRef objOrderItemNumber)

       	'Declaration of variable
	Dim objTable,strOrderNumber

	'Assigning of variables
	Set objTable = objTbl
	strOrderNumber = OrderNumber

	MainOrderItemTable= GetWebTableIndex (objTable)
						
	Set objDesc = Description.Create
	objDesc("micClass").value = "WebElement"
	objDesc("innertext").value = strOrderNumber
	
	
	Set objTable = objPage.WebTable("tblFulfilmentOrderNumber")
	Set objOrderItemNumber = objTable.ChildObjects(objDesc)
	If objOrderItemNumber.Count >= 1 Then
		objOrderItemNumber(0).Click
		Call ReportLog("Order Item Number","Order Item Number should be captured and  clicked" , "Order Item Number is captured and  clicked - <B>"&strOrderNumber& "</B>","PASS","")
		Wait 3
	End If
End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************
