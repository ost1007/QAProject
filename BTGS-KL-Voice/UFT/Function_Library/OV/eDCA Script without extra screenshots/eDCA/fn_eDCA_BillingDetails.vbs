'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_BillingDetails
' Purpose	 	 :  Collecting Billing Details for the order
' Author	 	 : Vamshi Krishna G
' Creation Date    : 11/06/2013
' Return values :	Nil
'**************************************************************************************************************************************	
Public Function fn_eDCA_BillingDetails(dOrderType, deDCAOrderId, dBillingSiteId, dContractMSANo, dTariffOption, dTariffDetailFileLocation, dUsageReportDeliveryMethod,_
			dCompanyName, dAddressLine1, dCityBillingDetails, dRegionState, dPostZIPCode, dBillingContactName, dBillingContactPhoneNumber, dBillingContactEmailAddress,_
			dServiceDescription, dProductDescription, dInvoicePeriod, dItemisedBillRequired)

	'Decalration of variables
	Dim blnResult,objMsg,strMessage,streDCAOrderId
	Dim strBillingSiteId,strContractMSANo,strTariffOption,strTariffDetailFileLocation,strUsageReportDeliveryMethod
	Dim strCompanyName,strAddressLine1,strCityBillingDetails,strRegionState,strPostZIPCode,strBillingContactName,strBillingContactPhoneNumber,strBillingContactEmailAddress
	Dim strServiceDescription,strProductDescription,strInvoicePeriod

	'Assignment of variables
	streDCAOrderId = deDCAOrderId
	strBillingSiteId = dBillingSiteId
	strContractMSANo = dContractMSANo
	strTariffOption = dTariffOption
	strTariffDetailFileLocation = dTariffDetailFileLocation
	strUsageReportDeliveryMethod = dUsageReportDeliveryMethod
	strCompanyName = dCompanyName
	strAddressLine1 = dAddressLine1
	strCityBillingDetails = dCityBillingDetails
	strRegionState = dRegionState
	strPostZIPCode = dPostZIPCode
	strBillingContactName = dBillingContactName
	strBillingContactPhoneNumber = dBillingContactPhoneNumber
	strBillingContactEmailAddress = dBillingContactEmailAddress
	strServiceDescription = dServiceDescription
	strProductDescription = dProductDescription
	strInvoicePeriod = dInvoicePeriod
	strItemisedBillRequired = dItemisedBillRequired

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter BillingSite ID
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtBillingSiteId").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtBillingSiteId").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Billing Site Id is displayed ","Value of Billing Site Id is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Billing Site Id should display ","Field Billing Site Id is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		if objPage.WebEdit("txtBillingSiteId").Exist(10) then 
			strBillingSiteId = streDCAOrderId&strBillingSiteId
			blnResult = enterText("txtBillingSiteId",strBillingSiteId)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End If

	'Enter Contract/MSANo
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtContractMSANo").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtContractMSANo").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Billing Contract MSA No is displayed ","Value of Contract MSA No is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Billing Contract MSA No should display ","Field Billing Contract MSA Nois not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		if objPage.WebEdit("txtBillingSiteId").Exist(10) then 
          	strContractMSANo = streDCAOrderId&strContractMSANo
			blnResult = enterText("txtContractMSANo",strContractMSANo)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End If

	'Select Tarrff  Option from drop down list
	If dOrderType = "MODIFY"  Then
		If objPage.WebList("lstTariffOption").Exist(10) Then
			strRetrievedText = objPage.WebList("lstTariffOption").GetROProperty("Value")
			If strRetrievedText = "Please Select" Then
				strTariffOption = objPage.WebList("lstTariffOption").GetROProperty("all items")
				arrTariffOption = Split(strTariffOption,";")
				stRretr = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTariffOption").Select (arrTariffOption(0))
			Else
				Call ReportLog("Billing Details page","Field Tariff Option is displayed ","Value of Tariff Option is  - "&strRetrievedText,"PASS","")
			End If
		 Else
		 	Call ReportLog("Billing Details page","Field Tariff Option should display ","Field Tariff Option is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebList("lstTariffOption").Exist(10) Then
			strTariffOption = objPage.WebList("lstTariffOption").GetROProperty("all items")
			arrTariffOption = Split(strTariffOption,";")
			stRretr = Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTariffOption").Select (arrTariffOption(0))
		End If
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Tariff Detail File Location
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtTariffDetailFileLocation").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtTariffDetailFileLocation").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Tariff Detail File Location is displayed ","Value of Tariff Detail File Location  is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Tariff Detail File Location should display ","Field Tariff Detail File Location is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if	
	Else
		If objPage.WebEdit("txtTariffDetailFileLocation").Exist(10) Then
			blnResult = enterText("txtTariffDetailFileLocation",strTariffDetailFileLocation)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End If

	'Choose Usage Report Delivery Method from drop down
	If dOrderType = "MODIFY"  Then
		If objPage.WebList("lstUsageReportDeliveryMethod").Exist(10) Then
			strRetrievedText = objPage.WebList("lstUsageReportDeliveryMethod").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Usage Report Delivery Method is displayed ","Value of  Usage Report Delivery Method is  - "&strRetrievedText,"PASS","")
		 Else
			Call ReportLog("Billing Details page","Field Usage Report Delivery Method  should display ","Field Usage Report Delivery Method  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		 End if
	Else
		If objPage.WebList("lstUsageReportDeliveryMethod").Exist(10) Then
			blnResult = selectValueFromPageList("lstUsageReportDeliveryMethod",strUsageReportDeliveryMethod)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter Company Name
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtCompanyName").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtCompanyName").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Company Name is displayed ","Value of  Company Name is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Company Name  should display ","Field Company Name  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	 ELSE
		If objPage.WebEdit("txtCompanyName").Exist(10) Then
			blnResult = enterText("txtCompanyName",strCompanyName)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter AddressLine1
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtAddressLine1").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtAddressLine1").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Address Line1 is displayed ","Value of  Address Line1 is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Address Line1   should display ","Field Address Line1   is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebEdit("txtAddressLine1").Exist(10) Then
			blnResult = enterText("txtAddressLine1",strAddressLine1)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter City
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtCityBillingDetails").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtCityBillingDetails").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field City Billing Details is displayed ","Value of  City Billing Details is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field City Billing Details  should display ","Field City Billing Details   is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebEdit("txtCityBillingDetails").Exist(10) Then
			blnResult = enterText("txtCityBillingDetails",strCityBillingDetails)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter Region/State
	If dOrderType = "MODIFY"  Then
        If objPage.WebEdit("txtRegionState").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtRegionState").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Region State is displayed ","Value of  Region State is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Region State  should display ","Field Region State   is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebEdit("txtRegionState").Exist(10) Then
			blnResult = enterText("txtRegionState",strRegionState)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter Post/zip code
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtPostZIPCode").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtPostZIPCode").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Post ZIP Code is displayed ","Value of  Post ZIP Code is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Post ZIP Codeshould display ","Field Post ZIP Code  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebEdit("txtPostZIPCode").Exist(10) Then
			blnResult = enterText("txtPostZIPCode",strPostZIPCode)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter Billing Contact Name
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtBillingContactName").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtBillingContactName").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Billing Contact Name is displayed ","Value of  Billing Contact Name is  - "&strRetrievedText,"PASS","")
		 Else
			Call ReportLog("Billing Details page","Field  Billing Contact Name should display ","Field Billing Contact Name  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if
	Else
		If objPage.WebEdit("txtBillingContactName").Exist(10) Then
			blnResult = enterText("txtBillingContactName",strBillingContactName)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter Billing contact Phone number 
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtBillingContactPhoneNumber").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtBillingContactPhoneNumber").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Billing Contact Phone Number is displayed ","Value of  Billing Contact Phone Number is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field  Billing Contact Phone Number should display ","Field Billing Contact Phone Number  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if	
	Else
		If objPage.WebEdit("txtBillingContactPhoneNumber").Exist(10) Then
			blnResult = enterText("txtBillingContactPhoneNumber",strBillingContactPhoneNumber)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if

	'Enter billing contact e-mail address
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtBillingContactEmailAddress").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtBillingContactEmailAddress").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Billing Contact Email Address is displayed ","Value of  Billing Contact Email Address is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field  Billing Contact Email Address should display ","Field Billing Contact Email Address  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if	
	Else
		If objPage.WebEdit("txtBillingContactEmailAddress").Exist(10) Then
			blnResult = enterText("txtBillingContactEmailAddress",strBillingContactEmailAddress)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End IF
	End if

	'Enter Service Description
	If dOrderType = "MODIFY"  Then
		If objPage.WebEdit("txtServiceDescription").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtServiceDescription").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Service Description is displayed ","Value of  Service Description is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field  Service Description should display ","Field Service Description  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if	
	Else
		If objPage.WebEdit("txtServiceDescription").Exist(10) Then
			blnResult = enterText("txtServiceDescription",strServiceDescription)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End IF
	End if

	If dOrderType = "MODIFY"  Then
		'Enter Product description
		If objPage.WebEdit("txtProductDescription").Exist(10) Then
			strRetrievedText = objPage.WebEdit("txtProductDescription").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Product Description is displayed ","Value of  Product Description is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Product Description should display ","Field Product Description  is not displayed","Warnings", True)
		End if	
	Else
		If objPage.WebEdit("txtProductDescription").Exist(10) Then
			blnResult = enterText("txtProductDescription",strProductDescription)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End If
	End if


	'Choose Invoice period from drop down
	If dOrderType = "MODIFY"  Then
		If objPage.WebList("lstInvoicePeriod").Exist(10) Then
			strRetrievedText = objPage.WebList("lstInvoicePeriod").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Invoice Period is displayed ","Value of  Invoice Period is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Invoice Period should display ","Field Invoice Period  is not displayed","FAIL","")
			Environment("Action_Result") = False : Exit Function
		End if	
	Else
		If objPage.WebList("lstInvoicePeriod").Exist(10) Then
			blnResult = selectValueFromPageList("lstInvoicePeriod",strInvoicePeriod)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End if
	End If

	'Checking the existence of Itemised Bill Required drop down box

	If dOrderType = "MODIFY"  Then
		If objPage.WebList("lstItemisedBillRequired").Exist(10) then
			strRetrievedText = objPage.WebList("lstItemisedBillRequired").GetROProperty("Value")	
			Call ReportLog("Billing Details page","Field Itemised Bill Required is displayed ","Value of  Itemised Bill Required is  - "&strRetrievedText,"PASS","")
		Else
			Call ReportLog("Billing Details page","Field Itemised Bill Requiredshould display ","Field Itemised Bill Required is not displayed","Warnings","")
		End if	
	Else
		'Selecting ItemisedBillRequired from drop down list
		If objPage.WebList("lstItemisedBillRequired").Exist(0) then
			blnResult = selectValueFromPageList("lstItemisedBillRequired",strItemisedBillRequired)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		End if
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If objPage.WebList("lstNationalCallRateCard").Exist(5) Then
		blnResult = selectValueFromPageList("lstNationalCallRateCard","Timed")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If objPage.WebList("lstNumberValidationRequired").Exist(5) Then
		blnResult = selectValueFromPageList("lstNumberValidationRequired","Yes")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	If objPage.Webbutton("btnNext").Exist(10) Then
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to PricingDetails Page
	Set objMsg = objpage.WebElement("webElmPricingDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Billing Details","Should be navigated to PricingDetails page on clicking Next Buttton","Not navigated to PricingDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmPricingDetails")
		Call ReportLog("Billing Details","Should be navigated to PricingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
