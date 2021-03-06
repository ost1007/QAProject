'****************************************************************************************************************************
' Function Name 		:		fn_SQE_CalculatePrice
'
' Purpose				: 		Function to calculate price for Products added to the Quote
'
' Author				:		 Linta C.K.
'Modified by		  : 			
' Creation Date  		 : 		  08/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_CalculatePrice()

	'Declaring of variables
	Dim blnResult
	Dim strPricingStatus

	'Assigning variables

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

''''''''''''	'Check Pricing Status
''	blnResult = objPage.WebTable("webTblItems").Exist
'	blnResult = objPage.WebTable("webTblBaseConfigQty").Exist
'	If blnResult = "True" Then
'''		strPricingStatus = objPage.WebTable("webTblItems").GetCellData(2,10)
'		strPricingStatus = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,5)
'		If strPricingStatus <> "Not Priced" Then
'			Call ReportLog("Calculate Price","Pricing Status should be changed from not Priced","Pricing Status is shown as - "&strPricingStatus,"PASS","False")
'			Exit Function
'		End If
'	End If
''
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmOneCloudCiscoContract").Click
	Wait 1
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("WebElmOneCloudCiscoContract").Click
	wait 3


'''''''''''	'Select Checkbox
	blnResult = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebCheckBox("chkListOfQuoteOptionItems1").Exist

	If blnResult = "True" Then
		Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'
'	'Click on Calculate Price
''	blnResult = objPage.Link("lnkCalculatePrice").Exist
	blnResult = objPage.WebButton("btnPrice").Exist
	If blnResult = "True" Then
''		blnResult = clickLink("lnkCalculatePrice")
		wait 3
		blnResult = clickbutton("btnPrice")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Click on Calculate Price","User should be able to click on Calculate Price Button","User could not click on Calculate Price Button","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'
	For intCounter = 1 to 60
		'Check Pricing Status
''		blnResult = objPage.WebTable("webTblItems").Exist
		blnResult = objPage.WebTable("webTblBaseConfigQty").Exist
		If blnResult = "True" Then
			wait 10
''			strPricingStatus = objPage.WebTable("webTblItems").GetCellData(2,10)
			strPricingStatus = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,6)
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

End Function
'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************

