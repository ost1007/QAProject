'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CaptureAndClickProductLink
'
' Purpose					: 			Function to capture and click on Product Link
'
' Author					:		  	Linta CK
'Modified by			  : 		
' Creation Date   		: 			18/06/2014
'Modified Date   			:				
' Parameters	 		 :			dataTableIndex,TaskName,ByRef objProduct
'                  					     
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_AIB_CaptureAndClickProductLink(dataTableIndex,TaskName,ByRef objProduct)

	'Declaration of variables
	Dim strTaskName

	'Assigning of variables
	strTaskName = TaskName

	'Setting WebTable
	If objPage.WebTable("index:=" & dataTableIndex).Exist Then
		Set objTable = objPage.WebTable("index:=" & dataTableIndex)
	End If
	
	Set objDesc = Description.Create
	objDesc("micClass").value = "WebElement"
	objDesc("innertext").value = strTaskName
	
	Set objProduct = objTable.ChildObjects(objDesc)
	If objProduct.Count >= 1 Then
		objProduct(0).Click
		Call ReportLog("Product Name","Product Name should be captured and  clicked" , "Product Name is captured and  clicked - <B>"&strTaskName& "</B>","PASS","")
		Wait 3
	End If
End Function

'****************************************************************************************************************************
'															END OF FUNCTION
'****************************************************************************************************************************
