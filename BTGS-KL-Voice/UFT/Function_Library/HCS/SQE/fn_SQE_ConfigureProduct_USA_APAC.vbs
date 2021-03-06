
'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct
'
' Purpose				: 		Function to configure Products added to the Quote
'
' Author				:		 Linta C.K.
'Modified by		  : 			
' Creation Date  		 : 		  07/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_ConfigureProduct_USA_APAC(dQuantity,dPlanName,dTGFriendlyName,dTGCACLimit,dTrunkFriendlyName,dTrunkCACLimit,dTrunkCACBandwidthLimit,dProductName)

	'Declaring of variables
	Dim intQuantity

	'Assigning variables
	strQuantity = dQuantity
	strPlanName = dPlanName
      strTGFriendlyName = dTGFriendlyName
	strTGCACLimit = dTGCACLimit
	strTrunkFriendlyName = dTrunkFriendlyName
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACBandwidthLimit = dTrunkCACBandwidthLimit

''''	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'''''''''	'Check for Configuration Status
	blnResult = objPage.WebTable("webTblItems").Exist
	If blnResult = "True" Then
		strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
		If strConfigured = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
			Exit Function
		End If
	End If
      
'''''''''''''''''	Select Checkbox
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

''''''''''''''	Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult = "True" Then
		blnResult = clickLink("lnkConfigureProduct")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If


	For intCounter = 1 to 10
		blnResult = objPage.WebElement("webElmLoadingAssets").WaitProperty("Visible",False,50)
		If not blnResult Then
			Exit for
		End If
	Next

	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'''''''''''	'Check if navigated to Bulk Configuration Page
	blnResult = objPage.WebElement("webElmBulkConfiguration").Exist
	If blnResult = "True" Then
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link and navigated to Bulk configuration page","User succesfully navigated to Bulk Configuration page after clicking on Configure Product link","PASS","False")
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link and navigated to Bulk configuration page","User not navigated to Bulk Configuration page after clicking on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	oDesc("class").value = "label ng-scope ng-binding.*"
    Set oCol = objPage.ChildObjects(oDesc)
    	For i = 4 to 6
          oCol(i).Click
'		Wait(5)
			For intCounter = 1 to 10
			blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").WaitProperty("Visible",False,100)
				If not blnResult Then
					Exit for
				End If
	Next
		strText = oCol(i).GetROProperty("innertext")
		If strText = "Base Configuration" or  strText = "Rate Plan" or strText = "Rates"   or strText =  "Trunk Group - OCC" Then
			strCols = objPage.WebTable("webTblBaseConfigQty").GetROProperty("column names")
			If Instr(strCols,"Quantity") >= 1 Then
			For intCounter = 1 to 10
				blnResult = objPage.WebElement("webElmLoadingAssets").WaitProperty("Visible",False,100)
				If not blnResult Then
					Exit for
				End	If
			Next
			For intCounter = 1 to 10
				blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").WaitProperty("Visible",False,100)
				If not blnResult Then
					Exit for
				End	If
			Next

		strRowCnt = ObjPage.WebTable("webTblBaseConfigQty").RowCount
		Set abc = CreateObject("mercury.devicereplay")
        On Error Resume Next
        For intRownCnt = 2 to strRowCnt
            stritemvalue = ObjPage.WebTable("webTblBaseConfigQty").GetCellData(intRownCnt,5)
              Set ObjItem = ObjPage.WebTable("webTblBaseConfigQty").ChildItem(intRownCnt, 5, "WebElement",1)
              ObjItem.Click
              abc.SendString 1
              Wait(1)
              intRownCnt = intRownCnt+1
        Next
	Set ObjShell = nothing
	Set ObjDevReplay = Nothing
	Wait(4)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	ElseIf Instr(strCols,"Plan Name") >= 1 Then
		index = -1
		Set oWebElement = description.Create
			oWebElement("micclass").value = "WebElement"
			oWebElement("class").value = "grid_Add_newVal text-content linkContainer"
			Set oWebElmChild = objPage.ChildObjects(oWebElement)
					oWebElmChild(0).Click
					stritemcount = split(objPage.WebList("lstselect").GetROProperty("all items"),";")
					For intcounter = 0 to ubound(stritemcount)
						If  stritemcount(intcounter) = dPlanName Then
							index = intcounter
						End If
					Next
					blnResult = objPage.WebList("lstselect").Exist
					If blnResult = "True" Then
						objPage.WebList("lstselect").HighLight
								objPage.WebList("lstselect").Click
								Set ObjShell = createobject("Wscript.Shell")
								index = index+1
								For iCounter = 1 to index
										ObjShell.SendKeys "{DOWN}"
										Set objWebTable = objPage.WebTable("webTblBaseConfigQty").ChildItem(2,4,"WebElement",0)
												objWebTable.Click
										Wait 1
								Next
								Wait 3
								Set ObjShell = Nothing
								Call ReportLog("Select Plan Name","User should be able to select Plan Name","User is able to select value for Plan Name","PASS",False)
						Else
							Call ReportLog("Select Plan Name","User should be able to select Plan Name","User is not able to select value for Plan Name","FAIL","True")
							Environment.Value("Action_Result") = False  
							Call EndReport()
							Exit Function
						End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		ElseIf Instr(strCols,"Rates Configure All") >= 1 Then
		Wait(5)

			For intCounter = 1 to 10
				blnResult = objPage.WebElement("webElmLoadingAssets").WaitProperty("Visible",False,100)
				If not blnResult Then
					Exit for
				End	If
			Next

		objPage.WebElement("webElmConfigure").Click
		wait(5)
		Call fn_SQE_Productselection(dProductName)
		Set abc = createobject("Wscript.Shell")
		If objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		 objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Highlight
		 objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Click
		End If
		
		If objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		 objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Highlight
		 objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Click
		End If

	For intCounter = 1 to 10
		blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").WaitProperty("Visible",False,100)
				If not blnResult Then
					Exit for
				End If
	Next
	End If
	End If	
Next
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	oCol(0).Click
	wait(1)
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	blnResult = objPage.WebButton("btnPrice").Exist
	wait(3)
		blnResult = clickbutton("btnPrice")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

	For intcount= 1 to 10
		blnResult = Objpage.WebElement("WebElmPerformingprice").WaitProperty("Visible",False,1000)
		If not blnResult  Then
			Exit For
		 Else
		 Wait(4)
		End If
	Next
	Wait(3)	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*******************************************************************************************************************************
	Set ObjShell = CreateObject("Wscript.Shell")
		ObjShell.SendKeys"{F5}"
	Set ObjShell = Nothing
	Wait(2)
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	End if

	blnResult = objPage.WebButton("btnPrice").Exist
	wait(3)
		blnResult = clickbutton("btnPrice")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
		Wait(10)	
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*******************************************************************************************************************************
	blnResult = objPage.WebElement("webElmQuoteDetails").Exist
	If blnResult = "True" Then
		blnResult = clickWebElement("webElmQuoteDetails")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 End Function
 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
