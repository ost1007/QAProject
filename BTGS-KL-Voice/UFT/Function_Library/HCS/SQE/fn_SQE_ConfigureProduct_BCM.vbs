
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

Public Function fn_SQE_ConfigureProduct_BCM(dQuantity,dPlanName,dProductName)

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

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'''''''''''	'Check for Configuration Status
''''	blnResult = objPage.WebTable("webTblItems").Exist
''''	If blnResult = "True" Then
''''		strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
''''		If strConfigured = "VALID" Then
''''			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
''''			Exit Function
''''		End If
''''	End If
      
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

'''Synching with the progress bar message
	For intCounter = 1 to 10
			blnResult = Objpage.WebElement("webElmLoadingAssets").Exist
			If blnResult Then
				Wait(5)
''				Objpage.WebElement("webElmLoadingAssets").Highlight
			Else
			Exit For
			End If
	Next

''''''Setting the Build Reference
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

'''Click on the Base Configuartion Link for the Rates
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	oDesc("class").value = "label ng-scope ng-binding.*"

'''Create Objects for Shell and Device Replay 
	Set ObjShell = CreateObject("Wscript.Shell")
	Set ObjDevReplay = CreateObject("mercury.devicereplay")
	
	Set oCol = objPage.ChildObjects(oDesc)
	On Error Resume Next
        oCol(6).Click

'''Synching with the progress bar message
	For intCounter = 1 to 5
			blnResult =  Objpage.WebElement("webElmLoadingAssets").Exist
			If  blnResult Then
				Wait(5)
''				Objpage.WebElement("webElmLoadingAssets").Highlight
             Else
			 Exit For
			End If
	Next


''''Updating the value for No. of Concurrent Sessions and No. of Registrations 

''''''''''Team can comment the code from Line No. 132 to 157
	On Error Resume Next
	Set ObjShell = CreateObject("Wscript.Shell")
	Set ObjDevReplay = CreateObject("MerCury.DeviceReplay")
	If objPage.WebTable("webTblBaseConfigQty").Exist Then
		StrRowCount = objPage.WebTable("webTblBaseConfigQty").RowCount
		For IntCounter = 0 to StrRowCount step 2
				Set ObjWebElm = objPage.WebTable("webTblBaseConfigQty").ChildItem(IntCounter,5,"WebElement",0)
				ObjWebElm.Click
				Set ObjWebEdt = objPage.WebTable("webTblBaseConfigQty").ChildItem(IntCounter,5,"WebEdit",0)
				If ObjWebEdt.GetROProperty("Value") = "1" Then
					ObjShell.SendKeys "{DEL}"
					ObjDevReplay.SendString "0"
					Call ReportLog("No. of Concurrent Sessions and No. of Registrations ","No. of Concurrent Sessions and No. of Registrations should be Zero","No. of Concurrent Sessions and No. of Registrations changed to Zero  ","PASS","False")
				Else
					Call ReportLog("No. of Concurrent Sessions and No. of Registrations ","No. of Concurrent Sessions and No. of Registrations should be Zero","No. of Concurrent Sessions and No. of Registrations is Zero  ","PASS","False")
				End If
				Set ObjWebElm = objPage.WebTable("webTblBaseConfigQty").ChildItem(IntCounter,8,"WebElement",0)
						ObjWebElm.Click
				Set ObjWebEdt = objPage.WebTable("webTblBaseConfigQty").ChildItem(IntCounter,8,"WebEdit",0)
				If ObjWebEdt.GetROProperty("Value") = "1" Then
					 ObjShell.SendKeys "{DEL}"
					ObjDevReplay.SendString "0"
				End If
		Next
		ObjShell.SendKeys "{TAB}"
	End if
	Set ObjShell = Nothing
	Set ObjDevReplay = Nothing


'''Click on First Base Configuration link
		oCol(0).Click
		Wait(2)

'''Synching with the progress bar message
		For intCounter = 1 to 145
			blnResult =  Objpage.WebElement("webElmLoadingAssets").Exist
			If  blnResult Then
				Wait(10)
''				Objpage.WebElement("webElmLoadingAssets").Highlight
             Else
			 Exit For
			End If
	Next


'''Synching with the progress bar message
'''		For intCounter = 1 to 150
'''			blnResult =  Objpage.WebElement("webElmNumberOfOutstandingSaves").Exist
'''			If  blnResult Then
'''				Wait(5)
'''''				Objpage.WebElement("webElmNumberOfOutstandingSaves").Highlight
'''             Else
'''			 Exit For
'''			End If
'''	Next


	wait(1)
''Selecing the Check box after updation of values
	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
	If blnResult = "True" Then
		objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'Clicking on Price button
	blnResult = objPage.WebButton("btnPrice").Exist
	If  blnResult Then
		blnResult = clickbutton("btnPrice")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If

'''Synching with the progress bar message
    For intCounter = 1 to 150
			blnResult =  Objpage.WebElement("WebelmPerformingdelete").Exist
			If  blnResult Then
				Wait(5)
''				Objpage.WebElement("WebelmPerformingdelete").Highlight
             Else
			 Exit For
			End If
	Next

'''For Refreshing the Page
	Set ObjShell = CreateObject("Wscript.Shell")
			ObjShell.SendKeys"{F5}"
	Set ObjShell = Nothing

	Wait(2)

'''Validating the Firm Status
		For intCounter = 1 to 60
			blnResult = objPage.WebTable("webTblBaseConfigQty").Exist
		If blnResult = "True" Then
			wait(5)
			strPricingStatus = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,6)
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
		Wait(10)
		Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is not changed and is shown as - "&strPricingStatus,"FAIL","True")				
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

'''Navigating back to Quote Details page
	blnResult = objPage.WebElement("webElmQuoteDetails").Exist
	If blnResult = "True" Then
		blnResult = clickWebElement("webElmQuoteDetails")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If

	'Check for existence of Product Line Items Table on clicking Quote Details and validate Configuration Status
	For intCounter = 1 to 40
		blnResult = objPage.WebTable("webTblItems").Exist
		If blnResult = "True" Then
			strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
			If strConfigured = "VALID" Then
                        Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
						Exit For
			Else
					Wait(5)
            End If
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