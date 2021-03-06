'================================================================================================================================
'Description		:	To handle the tasks generated, validate attributes and close the task
'History			:	Name				Date		Changes Implemented
	'Created		:	BT Automation Team	18/05/2016	NA
	'Modified	:	
'Return Values	:	Not Applicable		
'Example			:	fn_SQE_SelectProductFamilyVariantOffering("One Cloud", "One Cloud Cisco-Build Order", "One Cloud Cisco - Site")
'Reference		:	sub_SQE_SelectWebListElement
'================================================================================================================================
Public Function fn_SQE_SelectProductFamilyVariantOffering(ByVal ProductFamily, ByVal ProductVariant, ByVal ProductOffering)
	Set objPage = Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct")
	With Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct")
		'Select Product Family
		blnResult = .WebEdit("txtProductFamily").Exist(60)
		If Not blnResult Then
			Call ReportLog("txtProductFamily", "txtProductFamily should exist", "txtProductFamily doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			.WebEdit("txtProductFamily").Click
			Call sub_SQE_SelectWebListElement(objPage, ProductFamily)
			If Not Environment("Action_Result") Then
				Exit Function
			Else
				blnResult = .WebEdit("txtProductFamily").WaitProperty("value", ProductFamily, 10000)
				If Not blnResult Then
					Call ReportLog("txtProductFamily", "<B>" & ProductFamily & "</B> should be selected",  "<B>" & ProductFamily & "</B> could not be selected", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Call ReportLog("txtProductFamily", "<B>" & ProductFamily & "</B> should be selected",  "<B>" & ProductFamily & "</B> is selected", "PASS", False)
				End If
			End If
		End If
		
		'Wait until Processing is finished
		For intCounter = 1 to 25
			If objPage.WebElement("innertext:=innertext:=Processing\.\.\.", "index:=0").Exist(5) Then
				Wait 5
			Else
				Exit For
			End If
		Next
			
		'Select Product Variant
		blnResult = .WebEdit("txtProductVariant").Exist(60)
		If Not blnResult Then
			Call ReportLog("txtProductVariant", "txtProductVariant should exist", "txtProductVariant doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			.WebEdit("txtProductVariant").Click
			Call sub_SQE_SelectWebListElement(objPage, ProductVariant)
			If Not Environment("Action_Result") Then
				Exit Function
			Else
				blnResult = .WebEdit("txtProductVariant").WaitProperty("value", ProductVariant, 10000)
				If Not blnResult Then
					Call ReportLog("txtProductVariant", "<B>" & ProductVariant & "</B> should be selected",  "<B>" & ProductVariant & "</B> could not be selected", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Call ReportLog("txtProductVariant", "<B>" & ProductVariant & "</B> should be selected",  "<B>" & ProductVariant & "</B> is selected", "PASS", False)
				End If
			End If
		End If
		
		'Wait until Processing is finished
		For intCounter = 1 to 25
			If objPage.WebElement("innertext:=innertext:=Processing\.\.\.", "index:=0").Exist(5) Then
				Wait 5
			Else
				Exit For
			End If
		Next
		
		'Select Product Offering
		blnResult = .WebEdit("txtProductOffering").Exist(60)
		If Not blnResult Then
			Call ReportLog("txtProductOffering", "txtProductOffering should exist", "txtProductOffering doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			.WebEdit("txtProductOffering").Click
			Call sub_SQE_SelectWebListElement(objPage, ProductOffering)
			If Not Environment("Action_Result") Then
				Exit Function
			Else
				blnResult = .WebEdit("txtProductOffering").WaitProperty("value", ProductOffering, 10000)
				If Not blnResult Then
					Call ReportLog("txtProductOffering", "<B>" & ProductOffering & "</B> should be selected",  "<B>" & ProductOffering & "</B> could not be selected", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				Else
					Call ReportLog("txtProductOffering", "<B>" & ProductOffering & "</B> should be selected",  "<B>" & ProductOffering & "</B> is selected", "PASS", False)
				End If
			End If
		End If
		
		'Wait until Processing is finished
		For intCounter = 1 to 25
			If objPage.WebElement("innertext:=innertext:=Processing\.\.\.", "index:=0").Exist(5) Then
				Wait 5
			Else
				Exit For
			End If
		Next
	End With
End Function

'================================================================================================================================
' Description: SQE has custom dropdowns on Clicking WebEdit, WebElements are listed for selection. this procedure selects MenuItem
'================================================================================================================================
Sub sub_SQE_SelectWebListElement(ByVal oPage, ByVal InnerText)
	Dim oDesc
	Set oDesc = Description.Create
	oDesc("class").Value = "ui-menu-item"
	oDesc("innerText").Value = InnerText
	oDesc("index").Value = 0
	
	Set oEleMenuItem = oPage.WebElement(oDesc)
	If Not oEleMenuItem.Exist(30) Then
		Call ReportLog("MenuItem", "MenuItem should contain <B>" & InnerText & "</B>", "MenuItem doesn't contain <B>" & InnerText & "</B>", "FAIL", True)
		Environment("Action_Result") = False : Exit Sub
	Else
		oEleMenuItem.Click
		Environment("Action_Result") = True
	End If
End Sub
