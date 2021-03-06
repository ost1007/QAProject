
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

'Public Function fn_SQE_ConfigureProduct(dQuantity,dPlanName,dTGFriendlyName,dTGCACLimit,dTrunkFriendlyName,dTrunkCACLimit,dTrunkCACBandwidthLimit,dProductName)
Public Function fn_SQE_ConfigureProduct(dPlanName, dProductName, dProductQuantity)

	'Declaring of variables
	Dim intQuantity, intQuantityIndex
	Dim arrColumnNames
	Dim strColumn

	'Assigning variables
	strQuantity = dProductQuantity
	strPlanName = dPlanName
	strProductName = dProductName
    'strTGFriendlyName = dTGFriendlyName
	'strTGCACLimit = dTGCACLimit
	'strTrunkFriendlyName = dTrunkFriendlyName
	'strTrunkCACLimit = dTrunkCACLimit
	'strTrunkCACBandwidthLimit = dTrunkCACBandwidthLimit

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	''Check for Configuration Status
	blnResult = objPage.WebTable("webTblItems").Exist
	If blnResult = "True" Then
		strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
		If strConfigured = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
			Exit Function
		End If
	End If
      
	'Select Checkbox
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	'Click on Configure Product
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

	intInitWaitTime = 90
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
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
	blnErrorRefresh = False
	For i = 4 to oCol.Count-5
		oCol(i).Click
		Wait(10)
		strText = oCol(i).GetROProperty("innertext")
		If strText = "Base Configuration" or  strText = "Rate Plan" or strText = "Rates"   or strText =  "Trunk Group - OCC" Then
			strCols = objPage.WebTable("webTblBaseConfigQty").GetROProperty("column names")

			If Instr(strCols,"Quantity") >= 1 Then
					For intCounter = 1 to 10
						blnResult = objPage.WebElement("webElmLoadingAssets").WaitProperty("Visible",False,10)
						If not blnResult Then
							Exit for
						End	If
					Next
		
					For intCounter = 1 to 10
						blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").WaitProperty("Visible",False,10)
						If not blnResult Then
							Exit for
						End	If
					Next
		
					intProductIndex = 0
					intProduct = Split(strQuantity, "|")
		
					strRowCnt = ObjPage.WebTable("webTblBaseConfigQty").RowCount

					intQuantityIndex = 0
					arrColumnNames = Split(ObjPage.WebTable("webTblBaseConfigQty").GetROProperty("column names"), ";")
					For Each strColumn in arrColumnNames
						If strColumn = "Quantity" Then
							intQuantityIndex = intQuantityIndex + 1
							Exit For
						Else
							intQuantityIndex = intQuantityIndex + 1
						End If
					Next
					
					Set abc = CreateObject("mercury.devicereplay")
		
					On Error Resume Next
					For intRownCnt = 2 to strRowCnt
						strCheckColumnVal = LCase(ObjPage.WebTable("webTblBaseConfigQty").GetCellData(intRownCnt,3))
						If Instr(strCheckColumnVal, "error") = 0  Then
							stritemvalue = ObjPage.WebTable("webTblBaseConfigQty").GetCellData(intRownCnt,intQuantityIndex)
		
							'Code to Clear the populated quantity
							intLenthQuantity = Len(stritemvalue)
							Set ObjItem = ObjPage.WebTable("webTblBaseConfigQty").ChildItem(intRownCnt, intQuantityIndex, "WebElement",1)
		
							For iDelCounter = 1 to intLenthQuantity + 1
								ObjItem.Click
								CreateObject("WScript.Shell").SendKeys "{DELETE}"
							Next
		
							ObjItem.Click
							abc.SendString Cstr(intProduct(intProductIndex)) : intProductIndex = intProductIndex + 1
							Wait(1)
							intRownCnt = intRownCnt+1
						End If
					Next
			
					Set ObjShell = nothing
					Set ObjDevReplay = Nothing
					Wait(4)

			ElseIf Instr(strCols,"Plan Name") >= 1 Then

					index = -1
					Set oWebElement = description.Create
					oWebElement("micclass").value = "WebElement"
					oWebElement("class").value = "grid_Add_newVal text-content linkContainer"

					Set oWebElmChild = objPage.ChildObjects(oWebElement)
							oWebElmChild(1).Click
							stritemcount = split(objPage.WebList("lstselect").GetROProperty("all items"),";")
							For intcounter = 0 to ubound(stritemcount)
								If  stritemcount(intcounter) = dPlanName Then
									index = intcounter
								End If
							Next

							blnResult = objPage.WebList("lstselect").Exist
							If blnResult Then									
									'objPage.WebList("lstselect").HighLight
									'objPage.WebList("lstselect").Click
									oWebElmChild(1).Click
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

			ElseIf Instr(strCols,"Rates Configure All") >= 1 Then

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
						blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").WaitProperty("visible",False,100)
						If not blnResult Then
							Wait 10
							Exit for
						End If
					Next

					'To Check if Pricing Error has occurred or not
					If objPage.WebElement("elmErrorDialog").WebElement("elmPricingError").Exist Then
						If objPage.WebElement("elmErrorDialog").WebElement("elmPricingError").GetROProperty("height") > 0 Then
							strText = objPage.WebElement("elmErrorDialog").WebElement("elmPricingError").GetROProperty("innertext")
							objPage.WebElement("elmErrorDialog").WebButton("btnDetailsHideDetails").Click
							Call ReportLog("Pricing Error", "Pricing Error Encountered", strText, "Warnings", True)
							objPage.HighLight
							CreateObject("WScript.Shell").SendKeys "{F5}"
							Wait 10
							If Not blnErrorRefresh Then
								For intCounter = 4 to i
									oCol(i).Click : Wait 5
								Next
								blnErrorRefresh = True
							End If
						End If
					End If

					If blnErrorRefresh Then
						If objPage.WebElement("elmErrorDialog").WebElement("elmPricingError").Exist Then
							If objPage.WebElement("elmErrorDialog").WebElement("elmPricingError").GetROProperty("height") > 0 Then
								Call ReportLog("Pricing Error", "Pricing Error Encountered", strText, "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							End If
						End If
					End If

			End If
		End If	
	Next

	oCol(0).Click

	Wait 5

	For intCounter = 1 to 30
		blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").Exist(5)
		If blnResult Then
			If objPage.WebElement("webElmNumberOfOutstandingSaves").GetROProperty("height") > 0 Then
				Wait 10
			Else
				Exit For
			End If
		Else
			Exit For
		End If
	Next

	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	blnResult = objPage.WebButton("btnPrice").Exist
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

	Wait 10

	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next

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

	For intCounter = 1 to 60
		blnResult = objPage.WebTable("webTblBaseConfigQty1").Exist
		If blnResult = "True" Then
			wait(5)
			strPricingStatus = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,6)
			If strPricingStatus = "Not Priced" Then
					blnResult = clickbutton("btnPrice")
					Wait(15)
			ElseIf strPricingStatus = "Firm" Then
				Wait 5
				Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is shown as - "&strPricingStatus,"PASS","False")
				Exit For
			End If
		End If
	Next

	If strPricingStatus = "Not Priced" Then
		Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is not changed and is shown as - "&strPricingStatus,"FAIL","True")				
		Environment.Value("Action_Result") = False
		Exit Function
	End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*******************************************************************************************************************************
	blnResult = objPage.WebElement("webElmQuoteDetails").Exist
	If blnResult = "True" Then
		blnResult = clickWebElement("webElmQuoteDetails")
			If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	End If

	'Check for existence of Product Line Items Table on clicking Quote Details and validate Configuration Status
	For intCounter = 1 to 20
		blnResult = objPage.WebTable("webTblItems").Exist
		If blnResult = "True" Then
				strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
				If strConfigured = "VALID" Then
						Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
						Exit For
				Else
						Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is not shown as 'VALID' after bulk configuration","FAIL","True")
						Exit Function
				End If
		Else
				Wait(5)
		End If
	Next

	If Not blnResult Then
			Call ReportLog("Configure Product Status Check","WebTable should exist with Product Details.","WebTable does not exist with Product Details","FAIL","True")
			Environment.Value("Action_Result") = False  
			Exit Function
	End If

 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
