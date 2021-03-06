
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

Public Function fn_SQE_ConfigureProduct1(dQuantity,dPlanName,dTGFriendlyName,dTGCACLimit,dTrunkFriendlyName,dTrunkCACLimit,dTrunkCACBandwidthLimit,dProductName)

	'Declaring of variables
	Dim intQuantity

	'Assigning variables
	intQuantity = dQuantity
	strPlanName = dPlanName
      strTGFriendlyName = dTGFriendlyName
	strTGCACLimit = dTGCACLimit
	strTrunkFriendlyName = dTrunkFriendlyName
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACBandwidthLimit = dTrunkCACBandwidthLimit

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'''''''''''	'Check for Configuration Status
	blnResult = objPage.WebTable("webTblItems").Exist
	If blnResult = "True" Then
		strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
		If strConfigured = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
			Exit Function
		End If
	End If
      
'''''''''''''''''''	Select Checkbox
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

''''''''''''''''	Click on Configure Product
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

	For intCounter = 1 to 30
		Wait 5
		blnResult = objPage.WebElement("webElmLoadingAssets").Exist
		If not blnResult Then
			Exit For
		End If
	Next
''
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
	
	For i = 1 to oCol.Count-1
            oCol(i).Click
	
		For intCounter = 1 to 30
				Wait 5
				blnResult = objPage.WebElement("webElmLoadingAssets").Exist
            If not blnResult Then
				Exit For
			End If
		Next


		If bCheck = "True" Then
			For intCounter = 1 to 5
				blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").Exist(10)
				If Not blnResult Then
					Exit For
				End If
			Next
		End If
		Wait 2
		strText = oCol(i).GetROProperty("innertext")
		If strText = "Base Configuration" or  strText = "Rate Plan" or strText = "Rates"   or strText =  "Trunk Group - OCC" Then
			strCols = objPage.WebTable("webTblBaseConfigQty1").GetROProperty("column names")
			If Instr(strCols,"Quantity") >= 1 Then
				wait (8)

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Set ObjDevReplay = CreateObject("mercury.devicereplay")
 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebEdit("txtQuan").Click
wait(1)
 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmQuan").Click

 Set objWebElement = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").ChildItem(2,5,"WebElement",0)
objWebElement.click
Set objWebEdit = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").ChildItem(2,5,"WebEdit",0)
objWebEdit.click
ObjDevReplay.SendString "10"

 strRetrievedText=Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").GetCellData(2,5)

Call ReportLog("Plan Name","User should be able to Enter Quantity","User succesfully Entered" &strRetrievedText,"PASS","TRUE")
Set ObjShell = CreateObject("Wscript.shell")
ObjShell.SendKeys "{TAB}"

Set ObjShell = nothing
Set ObjDevReplay = Nothing

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'			ElseIf Instr(strCols,"Rate Plan") >= 1 Then
'				strQty = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,4)
'					If strQty = "N/A    Rate Plan  " Then
'						Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("Rate Plan").Object.click	
'						wait 5
'						Set oShell = CreateObject("Wscript.Shell")
'								oshell.SendKeys "{DOWN}"
'					End If

'			ElseIf Instr(strCols,"Plan Name") >= 1 Then
''''					strQty = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,4)
''''						If strQty = "."Then
''''							Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("webElmBlankQty").Object.click
''''							wait 5
''''							Set oShell = CreateObject("Wscript.Shell")
''''									oshell.SendKeys "{DOWN}"
''''							wait 5
''''						End If

				ElseIf Instr(strCols,"Plan Name") >= 1 Then
				Set oWebElement = description.Create
					oWebElement("micclass").value = "WebElement"
					oWebElement("class").value = "grid_Add_newVal text-content linkContainer"

                    Set oWebElmChild = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").ChildObjects(oWebElement)
							oWebElmChild(0).Click
					Set oShellObj = createobject("Wscript.Shell")
							oShellObj.SendKeys"{DOWN}"
                            oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"
							oWebElmChild(0).Click
							oShellObj.SendKeys"{DOWN}"

							Set oShellObj = nothing
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
			ElseIf Instr(strCols,"Trunk Group Friendly Name") >= 1 Then
				strQty = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,4)
				If strQty = "." Then
					objPage.WebElement("webElmBlankQty").Click
					Set objEdit = objPage.WebTable("webTblBaseConfigQty1").ChildItem(2,4,"WebEdit",0)
					blnResult = objEdit.Exist
                    If blnResult = "True" Then
						objEdit.Set strTGFriendlyName
						bCheck = True
					Else
						bCheck = False
					End If
				End IF
				Wait 4
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		ElseIf Instr(strCols,"Rates Configure All") >= 1 Then
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("webElmConfigure").Click
	wait 10
	
	Set abc = createobject("Wscript.Shell")
	Wait 5
	 abc.SendKeys "{TAB},8"
	 abc.SendKeys "{TAB},8"
	 Wait 5
	 abc.SendKeys "{DOWN},8"
	 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnAdd").Click
	 Wait 3
	 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnOkRateScreen").Click
	
				For intCounter = 1 to 10
						Wait 2
					blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").Exist
                    If not blnResult Then
						Exit For
					End If
				Next
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'				strQty = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,5)
'					If strQty = "." Then
'						objPage.WebElement("webElmBlankQty").Click
'								  Set objEdit = objPage.WebTable("webTblBaseConfigQty").ChildItem(2,5,"WebEdit",0)
'						blnResult = objEdit.Exist
'						If blnResult = "True" Then
'							objEdit.Set strTGCACLimit
'							bCheck = True
'						Else
'							bCheck = False
'						End If
'					End If
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
					ElseIf Instr(strCols,"Trunk Group - OCC") >= 1 Then
					For intCounter = 1 to 30
						Wait 5
					blnResult = objPage.WebElement("webElmLoadingAssets").Exist
					  If not blnResult Then
						Exit For
						End If
				Next

				strQty = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,4)
				If strQty = "N/A    Configure  " Then
					objPage.WebElement("webElmConfigure").Click
		
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("webElmConfigure").Click
	wait 10
	
	Set abc = createobject("Wscript.Shell")
	Wait 5
	 abc.SendKeys "{TAB},8"
	 abc.SendKeys "{TAB},8"
	 Wait 5
	 abc.SendKeys "{DOWN},8"
	 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnAdd").Click
	 Wait 3
	 Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnOkRateScreen").Click
	
				For intCounter = 1 to 30
						Wait 2
					blnResult = objPage.WebElement("webElmLoadingAssets").Exist
            		If not blnResult Then
						Exit For
					End If
				Next
'
				End If
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

				strQty = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,5)
				If strQty = "." Then
					objPage.WebElement("webElmBlankQty").Click
                              Set objEdit = objPage.WebTable("webTblBaseConfigQty1").ChildItem(2,5,"WebEdit",0)
					blnResult = objEdit.Exist
					If blnResult = "True" Then
						objEdit.Set strTrunkCACLimit
						bCheck = True
					Else
						bCheck = False
					End If
				End IF

				strQty = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,6)
				If strQty = "." Then
					objPage.WebElement("webElmBlankQty").Click
					Set objEdit = objPage.WebTable("webTblBaseConfigQty1").ChildItem(2,6,"WebEdit",0)
					blnResult = objEdit.Exist
					If blnResult = "True" Then
						objEdit.Set strTrunkCACBandwidthLimit
						bCheck = True
					Else
						bCheck = False
					End If
				End If
			Else
			End If
	End If	
Next

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmOneCloudCiscoContract").Click
	Wait 1
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmOneCloudCiscoContract").Click
	wait 3
	blnResult = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebCheckBox("chkListOfQuoteOptionItems1").Exist
	If blnResult = "True" Then
		Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	blnResult = objPage.WebButton("btnPrice").Exist
	wait 3
		blnResult = clickbutton("btnPrice")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If


		For intCounter = 1 to 60
			blnResult = objPage.WebTable("webTblBaseConfigQty1").Exist
		If blnResult = "True" Then
			wait 5
			strPricingStatus = objPage.WebTable("webTblBaseConfigQty1").GetCellData(2,6)
			If strPricingStatus = "Not Priced" Then
				Wait 15
			ElseIf strPricingStatus = "Firm" Then
				Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is shown as - "&strPricingStatus,"PASS","False")
				Exit For
			End If
		End If
	Next
	If strPricingStatus = "Not Priced" Then
		Wait 10
		Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is not changed and is shown as - "&strPricingStatus,"FAIL","True")				
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

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
			Wait 5
		End If
	Next

	If Not blnResult Then
                  Call ReportLog("Configure Product Status Check","WebTable should exist with Product Details.","WebTable does not exist with Product Details","FAIL","True")
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
