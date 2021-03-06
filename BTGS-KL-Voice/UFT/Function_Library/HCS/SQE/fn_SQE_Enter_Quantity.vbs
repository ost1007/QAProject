'''''''''****************************************************************************************************************************
' Function Name 		:		fn_SQE_Select_Product
'
' Purpose				: 		Function to configure Products added to the Quote
'
' Author				:		 Anil.
'Modified by		  : 			
' Creation Date  		 : 		  28/8/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_Enter_Quantity(dProductQuantity)

   strQuantity = split(dProductQuantity, "|")

 blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

''''''''	If ObjPage.WebTable("webTblBaseConfigQty").Exist Then
''''''''		StrRowCount = ObjPage.WebTable("webTblBaseConfigQty").RowCount
''''''''		For iterator = 1 to 2
''''''''			Set objWebElement = objPage.WebTable("webTblBaseConfigQty").ChildItem(iterator+3,6,"WebElement",0)
''''''''			Set objEdit = objPage.WebTable("webTblBaseConfigQty").ChildItem(iterator+3,6,"WebEdit",0)
''''''''				blnResult = objEdit.Exist
''''''''				If blnResult = "True" Then
''''''''					objEdit.Set strQuantity(iterator-1)
''''''''				End if
''''''''		Next
''''''''	End If




Set ObjDevReplay = CreateObject("mercury.devicereplay")
 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebEdit("txtQuan").Click
wait(1)
 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmQuan").Click

 Set objWebElement = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty").ChildItem(2,5,"WebElement",0)
objWebElement.click
Set objWebEdit = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty").ChildItem(2,5,"WebEdit",0)
objWebEdit.click
ObjDevReplay.SendString "10"

 strRetrievedText=Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty").GetCellData(2,5)

Call ReportLog("Plan Name","User should be able to Enter Quantity","User succesfully Entered" &strRetrievedText,"PASS","TRUE")

'' Set objWebElement = Browser("brwSQE").Page("pgSQE").WebTable("webTblBaseConfigQty").ChildItem(4,6,"WebElement",0)
''objWebElement.click
''Set objWebEdit = Browser("brwSQE").Page("pgSQE").WebTable("webTblBaseConfigQty").ChildItem(4,6,"WebEdit",0)
''objWebEdit.click
''ObjDevReplay.SendString "10"
''
'' strRetrievedText=Browser("brwSQE").Page("pgSQE").WebTable("webTblBaseConfigQty").GetCellData(4,6)
''
''Call ReportLog("Plan Name","User should be able to Enter Quantity","User succesfully Entered" &strRetrievedText,"PASS","TRUE")

Set ObjShell = CreateObject("Wscript.shell")
ObjShell.SendKeys "{TAB}"

Set ObjShell = nothing
Set ObjDevReplay = Nothing




End Function
