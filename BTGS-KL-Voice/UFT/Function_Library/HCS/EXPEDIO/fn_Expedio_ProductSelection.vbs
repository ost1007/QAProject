
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Aactivity
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_ProductSelection(dProducttype,dProp,dSubProp,dQuantity,dProductName)

   Dim strProductName,strProducttype,strProp,strSubProp,intCounter
		
		strProducttype = dProducttype
		strProp = dProp
		strSubProp = dSubProp
		strProductName = dProductName
        strQuantity=dQuantity
		arrProductName = split(dProductName, "|")


   ''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwProductSelection","pgProductSelection","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If


	''''''''''''''''''''''''''''''''''
 'Select Product type
                blnResult = objPage.WebEdit("txtproducttype").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("imgproducttype").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("imgproducttype")
                                                If blnResult = "False" Then                                                           
                                                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                                                Call EndReport()
                                                                Exit Function
                                                End If
                                                blnResult = objPage.WebTable("class:=MenuTable").Exist
                                                If blnResult = "True" Then
                                                                Set objDesc = Description.Create
                                                                objDesc("micClass").Value = "WebElement"
                                                                objDesc("class").value = "MenuEntryName.*"

                                                                Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
                                                                If objElm.Count >= 1 Then
																	For intCounter = 0 to objElm.Count -1
																					If strProducttype =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onmouseover"
																					Wait 1
																					objElm(intCounter).Click
																					Exit For
																					End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If
'''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''
 'Select Prop
                blnResult = objPage.WebEdit("txtprop").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("imgMenuforProp").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("imgMenuforProp")
                                                If blnResult = "False" Then                                                           
                                                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                                                Call EndReport()
                                                                Exit Function
                                                End If
                                                blnResult = objPage.WebTable("class:=MenuTable").Exist
                                                If blnResult = "True" Then
                                                                Set objDesc = Description.Create
                                                                objDesc("micClass").Value = "WebElement"
                                                                objDesc("class").value = "MenuEntryName.*"

                                                                Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
                                                                If objElm.Count >= 1 Then
																	For intCounter = 0 to objElm.Count -1
																					If strSubProp =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onmouseover"
																					Wait 1
																					objElm(intCounter).Click
																					Exit For
																					End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If
'''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''
 'Select  subProp
                blnResult = objPage.WebEdit("txtprop").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("imgMenuforProp").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("imgMenuforProp")
                                                If blnResult = "False" Then                                                           
                                                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                                                Call EndReport()
                                                                Exit Function
                                                End If
                                                blnResult = objPage.WebTable("class:=MenuTable").Exist
                                                If blnResult = "True" Then
                                                                Set objDesc = Description.Create
                                                                objDesc("micClass").Value = "WebElement"
                                                                objDesc("class").value = "MenuEntryName.*"

                                                                Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
                                                                If objElm.Count >= 1 Then
																	For intCounter = 0 to objElm.Count -1
																					If strProp =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onmouseover"
																					Wait 1
																					objElm(intCounter).Click
																					Exit For
																					End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If
'''''''''''''''''''''''''''''

'Add Product 
For intCounter = 0 to ubound(dProductName)

	'''''Enter  Product Name
    blnResult = enterText("txtproductname",arrProductName(intCounter))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''Click on Search Button
	blnResult  = clickLink("lnkSearch")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''''''''''Add Sites
 blnResult = objPage.WebTable("tblselectProducts").Exist
	strRow = objPage.WebTable("tblselectProducts").RowCount
	strCol = objPage.WebTable("tblselectProducts").ColumnCount(strRow)
	 If blnResult Then
'		 Set ObjWebelement = objPage.WebTable("tblCustomername").ChildItem(1,1,"WebElement",0)
'                ObjWebelement.Click
	objPage.WebTable("tblCustomername").object.rows(strRow).cells(strCol-1).click

	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
        Call EndReport()
        Exit Function
	 End If

''''''Enter  Quantity
    blnResult = enterText("txtquantity",strQuantity)
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

Next

blnResult  = clickLink("lnkContinue")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

End Function