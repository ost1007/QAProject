'=============================================================================================================
' Description	: Function to Configure Particulars of Central Site Product
' History	  	 : Name				Date			Changes Implemented
' Created By	   :  Nagaraj			06/04/2015 				NA
' Return Values : Not Applicable
' Example: fn_SQE_ConfigureCentralSiteProduct "Internet Service Access", "20", "50", "5", "5"
'=============================================================================================================
Public Function fn_SQE_ConfigureCentralSiteProduct(ByVal ProductOffering, ByVal ConcurrentSessions, ByVal Registrations, ByVal AutoAttendantExtension, ByVal Quantity)

	'Variable Declaration
	Dim strConfigured
	Dim objElmBaseConfig
	Dim arrColumnNames
	Dim intConcurrentSessionColumn, intRegistrationsColumn, intSessionValueLength, intRegistrationValueLength, intCounter, intInitWaitTime
	Dim intQuantityColumn, intQuantityValueLength, intPricingStatusCol, intRelatedToSIPTrunkServiceCol

	'Check whether the table has been populated or not
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").Exist
		If blnResult Then
			If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Configure Product","Should be navigated to Showing Quote Option page","Configuration Table is not loaded still","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
		
	For intCounter = 1 To 5
		blnResult = objPage.WebTable("tblProductTableHeader").Exist(60)
		If blnResult Then Exit For
	Next
	
	If Not blnResult Then
		Call ReportLog("Product Table Header", "Table should exist", "Table doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingStatusCol = intCounter + 1
		End If
	Next
	
	intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
	If intProdRow <= 0 Then
		Call ReportLog("Showing Quote Option", ProductOffering & " - should be visible under Line Items Table", ProductOffering & " - line item is not populated in Line Items table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 To 30
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol)
		If strConfigured = "" Then
			Wait 5
		ElseIf strConfigured = "VALID" OR  strConfigured = "INVALID" Then
			blnResult = True
			Exit For
		End If
	Next

	'Check for Configuration Status
	If blnResult Then
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow,intConfiguredCol)
		If strConfigured = "VALID" And ( ProductOffering = "Internet Service Access" OR ProductOffering = "Auto Attendant Starter Pack" )Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS", True)
		ElseIf strConfigured = "INVALID" And ( ProductOffering = "Operator Console" OR ProductOffering = "Voice Lync Integration" ) Then
			Call ReportLog("Configure Product","Configuration Status should be shown as <B>INVALID</B> before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","PASS", True)
		Else
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Select Checkbox
	objPage.WebTable("tblProductLineItems").ChildItem(intProdRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	'Wait for Page to be Navigated to Bulk Configuration
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").Exist Then Exit For
	Next
	
	'Build Web Reference
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

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

	'Click on Base Config
	Set objElmBaseConfig = objPage.WebElement("class:=label ng-scope ng-binding.*","innertext:=Base Configuration", "index:=0")
	If objElmBaseConfig.Exist(10) Then
		objElmBaseConfig.Click
	Else
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check if Base Config Table is present or not
	If Not objPage.WebTable("tblBaseConfig").Exist(10) Then
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	arrColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")

	'Execute If Product Offering is Internet Service Access
	If ProductOffering = "Internet Service Access" Then
			intConcurrentSessionColumn = 0 : intRegistrationsColumn = 0
		
			'Get the index of Column number
			For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
				strColumn = arrColumnNames(intCounter)
				If Trim(strColumn) = "No of Concurrent Sessions" Then
					intConcurrentSessionColumn = intCounter + 1
				ElseIf Trim(strColumn) = "No of Registrations" Then
					intRegistrationsColumn = intCounter + 1
				End If		
			Next
		
			'Set the Concurrent Session value
			Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(2, intConcurrentSessionColumn, "WebElement", 0)
			intSessionValueLength = objPage.WebTable("tblBaseConfig").GetCellData(2, intConcurrentSessionColumn)
			For intCounter = 1 to intSessionValueLength + 1
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys "{DELETE}", True
			Next
		
			For intSetCounter = 1 to 5
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys ConcurrentSessions, True
				CreateObject("WScript.Shell").SendKeys "{TAB}"
				Wait 2
				strCellData = objPage.WebTable("tblBaseConfig").GetCellData(2, intConcurrentSessionColumn)
				If Cstr(strCellData) = CStr(ConcurrentSessions) Then
					Call ReportLog("Concurrent Session", "Concurrent value <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "PASS", False)
					Exit For
				End If
			Next
		
			Wait 2
		
			'Set the Registrations Count value
			Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(2, intRegistrationsColumn, "WebElement", 0)
			intRegistrationValueLength = objPage.WebTable("tblBaseConfig").GetCellData(2, intRegistrationsColumn)
			For intCounter = 1 to intRegistrationValueLength + 1
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys "{DELETE}"
			Next
		
			For intSetCounter = 1 to 5
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys Registrations, True
				CreateObject("WScript.Shell").SendKeys "{TAB}"
				Wait 2
				strCellData = objPage.WebTable("tblBaseConfig").GetCellData(2, intRegistrationsColumn)
				If Cstr(strCellData) = CStr(Registrations) Then
					Call ReportLog("Number of Registrations", "Registrations value <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "PASS", False)
					Exit For
				End If
			Next
	'Execute if Product Offering is Operator Console
	ElseIf ProductOffering = "Operator Console" Then
			intQuantityColumn = 0

			'Get the index of Column number
			For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
				strColumn = arrColumnNames(intCounter)
				If Trim(strColumn) = "Quantity" Then
					intQuantityColumn = intCounter + 1
					Exit For '#intCounter
				End If
			Next '#intCounter
			
			If intQuantityColumn = 0 Then
				Call ReportLog("Bulk Configuration", "Quantity Column should be present", "Quantity column is not present on Bulk Configuration Page", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If

			'Set the Quantity
			Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(2, intQuantityColumn, "WebElement", 0)
			intQuantityValueLength = objPage.WebTable("tblBaseConfig").GetCellData(2, intQuantityColumn)
				If intQuantityValueLength = "." Then intQuantityValueLength = 0

			For intCounter = 1 to intQuantityValueLength + 1
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys "{DELETE}"
			Next '#intCounter

			For intSetCounter = 1 to 5
				objElm.Click
				x = objElm.GetROProperty("abs_x")
				y = objElm.GetROProperty("abs_y")
				CreateObject("Mercury.DeviceReplay").MouseMove x, y
				CreateObject("WScript.Shell").SendKeys Quantity, True
				CreateObject("WScript.Shell").SendKeys "{TAB}"
				Wait 2
				strCellData = objPage.WebTable("tblBaseConfig").GetCellData(2, intQuantityColumn)
				If Cstr(strCellData) = CStr(Quantity) Then
					Call ReportLog("Concurrent Session", "Concurrent value <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "PASS", False)
					Exit For '#intSetCounter
				End If
			Next '#intSetCounter

	'Execute if Product Offering is Auto Attendant
	ElseIf ProductOffering = "Auto Attendant Starter Pack" Then
			arrAutoAttendantExtension = Split(AutoAttendantExtension, "|")
			For Each strAutoExtension in arrAutoAttendantExtension

					If strAutoExtension = "Auto-Attendant Extn +5 Concurrent Calls" Then
						Set objElmConcurrentCalls = objPage.WebElement("innertext:=Auto-Attendant Extn \+5 Concurrent Calls","index:=0")
						If objElmConcurrentCalls.Exist(10) Then
							objElmConcurrentCalls.Click
							Wait 5
							Call ReportLog("Auto Extension", strAutoExtension & " should be visible & to be clivked", strAutoExtension & " is clicked", "INFORMATION", False)
						Else
							Call ReportLog("Auto Extension", strAutoExtension & " should be visible", strAutoExtension & " is not displayed", "FAIL", True)
							objBrowser.Close : Environment("Action_Result") = False : Exit Function
						End If
	
						'Function Call to Click on Configure Link
						blnResult = fn_SQE_ClickConfigure(objPage)
							If Not blnResult Then	Environment("Action_Result") = False : Exit Function
	
					ElseIf strAutoExtension = "Service Change-Auto Attendant" Then
						Set objElmServiceChange = objPage.WebElement("innertext:=Service Change-Auto Attendant","index:=0")
						If objElmServiceChange.Exist(10) Then
							objElmServiceChange.Click
							Wait 5
							Call ReportLog("Auto Extension", strAutoExtension & " should be visible & to be clivked", strAutoExtension & " is clicked", "INFORMATION", False)
						Else
							Call ReportLog("Auto Extension", strAutoExtension & " should be visible", strAutoExtension & " is not displayed", "FAIL", True)
							objBrowser.Close : Environment("Action_Result") = False : Exit Function
						End If
	
						'Function Call to Click on Configure Link
						blnResult = fn_SQE_ClickConfigure(objPage)
							If Not blnResult Then	Environment("Action_Result") = False : Exit Function
	
					End If
	
					blnLoaded = objPage.WebList("Link2New").WaitProperty("items count", micGreaterThan(0), 1000*60*2)
					If Not blnLoaded Then
						Call ReportLog("Configure", "LKist should be populated with items to selected", "No items are populated", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					blnResult = selectValueFromPageList("Link2New", Trim(strAutoExtension))
					If Not blnResult Then
						Environment("Action_Result") = False : Exit Function
					Else
						blnResult = clickButton("btnAdd")
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
						
						Wait 2
						
						blnResult = clickButton("btnOk")
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
							
						Wait 30
					End If

					If strAutoExtension = "Auto-Attendant Extn +5 Concurrent Calls" Then
							Dim oDesc
							Set oDesc = Description.Create
							oDesc("micclass").Value = "WebElement"
							oDesc("innertext").Value = "Base Configuration"
							
							Set objElmChildBaseConfig = objPage.WebElement("innertext:=Auto-Attendant Extn \+5 Concurrent CallsBase Configuration","index:=0").ChildObjects(oDesc)
							If objElmChildBaseConfig.Count >= 1 Then
								objElmChildBaseConfig(objElmChildBaseConfig.Count - 1).Click
								Wait 5
							Else
								Call ReportLog("Base Configuration", strAutoExtension & " - should contain Base Configuration", strAutoExtension & " - doesn't contain Base Configuration under that", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							End If

							Wait 2
							objPage.WebTable("tblBaseConfig").RefreshObject

							arrAutoAttnColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")

							intQuantityColumn = 0
							'Get the index of Column number
							For intCounter = LBound(arrAutoAttnColumnNames) to UBound(arrAutoAttnColumnNames)
								strColumn = arrAutoAttnColumnNames(intCounter)
								If Trim(strColumn) = "Quantity" Then
									intQuantityColumn = intCounter + 1
									Exit For
								End If
							Next
				
							'Set the Quantity
							Set objElm = objPage.WebTable("tblBaseConfig").ChildItem(2, intQuantityColumn, "WebElement", 0)
							intQuantityValueLength = objPage.WebTable("tblBaseConfig").GetCellData(2, intQuantityColumn)
								If intQuantityValueLength = "." Then intQuantityValueLength = 0
				
							For intCounter = 1 to intQuantityValueLength + 1
								objElm.Click
								x = objElm.GetROProperty("abs_x")
								y = objElm.GetROProperty("abs_y")
								CreateObject("Mercury.DeviceReplay").MouseMove x, y
								CreateObject("WScript.Shell").SendKeys "{DELETE}"
							Next

							blnSet = False
							For intSetCounter = 1 to 5
								objElm.Click
								x = objElm.GetROProperty("abs_x")
								y = objElm.GetROProperty("abs_y")
								CreateObject("Mercury.DeviceReplay").MouseMove x, y
								CreateObject("WScript.Shell").SendKeys Quantity, True
								CreateObject("WScript.Shell").SendKeys "{TAB}"
								Wait 2
								strCellData = objPage.WebTable("tblBaseConfig").GetCellData(2, intQuantityColumn)
								If Cstr(strCellData) = CStr(Quantity) Then
									Call ReportLog("Auto-Attendant Extn +5 Concurrent Calls", "Auto-Attendant Extn +5 Concurrent Calls <B>[" & strCellData &"]</B> value should be set", strCellData & " - value is set", "PASS", True)
									blnSet = True
									Exit For									
								End If
							Next

					End If
			Next 'For Each
			
			If Not blnSet Then
				Call ReportLog("Quantity Update", "Quantity should be updated against " & strAutoExtension, "Quantity could not be updated against " & strAutoExtension, "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If

			'Click on Base Configuration
			Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").WebElement("elmModifyBaseConfiguration").Click

			'Check for Loading Grid Status Status
			For intCounter = 1 to 50
				If objPage.WebElement("class:=status-bar","innertext:=Loading.*","visible:=True", "index:=0").Exist(2) Then
					Wait 3
				Else
					Exit For '#intCounter
				End If
			Next '#intCounter
			
	ElseIf ProductOffering = "Voice Lync Integration" Then
			Set DeviceReplay = CreateObject("Mercury.DeviceReplay")
			intQuantityColumn = 0

			'Get the index of Column number
			For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
				strColumn = arrColumnNames(intCounter)
				If Trim(strColumn) = "Quantity" Then
					intQuantityColumn = intCounter + 1
					Exit For '#intCounter
				End If
			Next '#intCounter
			
			If intQuantityColumn = 0 Then
				Call ReportLog("Bulk Configuration", "Quantity Column should be present", "Quantity column is not present on Bulk Configuration Page", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Set the Quantity
			With objPage.WebTable("tblBaseConfig") '#VLIConfig Quantity
					intRow = .GetRowWithCellText("Not Priced")
					If intRow <= 0 Then
						Call ReportLog("Bulk Config Table", "Table should contain Not Priced Text to enter the Quantity",  "Table doesn't contain any configurable attribute", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					'Get The Quanity already entered in Cell
					strQuantity = .GetCellData(intRow, intQuantityColumn)
					intQuantityValueLength = Len(strQuantity)
					Set objQuantityCell = .ChildItem(intRow, intQuantityColumn, "WebElement", 0)
					objQuantityCell.HighLight					
					'Function to get Coordinates of application
					Call fn_SQE_GetCoordinatesOfElementAddNew("Quantity", objQuantityCell, x, y)
						If Not Environment("Action_Result") Then Exit Function
						
					DeviceReplay.MouseMove x, y
					DeviceReplay.MouseClick x, y, LEFT_MOUSE_BUTTON
					DeviceReplay.PressKey 199 'Press HOME
					DeviceReplay.PressNKeys 211, Len(intQuantityValueLength) 'Press DELETE with N times
					Wait 2
					DeviceReplay.SendString CStr(Trim(Quantity)) ' Set the Quantity
					DeviceReplay.PressKey 15 'Press Tab
					.RefreshObject
					'Verify the quantity entered
					strSavedQuantity = .ChildItem(intRow, intQuantityColumn, "WebElement", 0).GetROProperty("innertext")
					If Trim(strSavedQuantity) = Trim(Quantity) Then
						Call ReportLog("Base Config", "Should be updated with quantity <B>" & Quantity & "</B>", "Updated with quantity <B>" & strSavedQuantity & "</B>", "PASS", True)
					Else
						Call ReportLog("Base Config", "Should be updated with quantity <B>" & Quantity & "</B>", "Updated with quantity <B>" & strSavedQuantity & "</B>", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
			End With '#VLIConfig Quantity
			
			'Click on SIP Trunk Service
			blnResult = clickWebElement("elmSIPTrunkServiceVLI")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
			'Check for Loading Grid Status Status
			For intCounter = 1 to 50
				If objPage.WebElement("class:=status-bar","innertext:=Loading.*","visible:=True", "index:=0").Exist(2) Then
					Wait 3
				Else
					Exit For '#intCounter
				End If
			Next '#intCounter
			
			intRelatedToSIPTrunkServiceCol = -1
			objPage.WebTable("tblBaseConfig").RefreshObject
			arrColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")
			For intCounter = LBound(arrColumnNames) To UBound(arrColumnNames)
				If Instr(arrColumnNames(intCounter), "Related To SIP Trunk Service") > 0 Then
					intRelatedToSIPTrunkServiceCol = intCounter + 1
					Exit For '#intCounter
				End If
			Next '#intCounter
			
			'Check whether Column Related To SIP Trunk Service
			If intRelatedToSIPTrunkServiceCol = -1 Then
				Call ReportLog("SIP Trunk Service", "'Related To SIP Trunk Service' Column should present on Bulk Config Table", "'Related To SIP Trunk Service' Column doesn't exist in Bulk Config Table", "FAIL", True)
				Environment("Action_Result") = False : Exit Function				
			End If
			
			Set lnkSIPTService = objPage.WebTable("tblBaseConfig").WebElement("html tag:=A","innertext:=SIP Trunk Service","visible:=True","index:=0")
			If lnkSIPTService.Exist(60) Then
					Call ReportLog("Configure SIP Trunk Service", "Configure Link should be present on Bulk Config Table", "SIP Trunk Service is already configured", "PASS", True)
			Else
					intRow = objPage.WebTable("tblBaseConfig").GetRowWithCellText("Configure")
					Set lnkConfigure = objPage.WebTable("tblBaseConfig").WebElement("html tag:=A","innertext:=Configure","visible:=True","index:=0")
					If Not lnkConfigure.Exist(10) Then
						Call ReportLog("Configure SIP Trunk Service", "Configure Link should be present on Bulk Config Table", "Configure Link does not exist", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					Else
						lnkConfigure.Click
					End If
					
					blnResult = objPage.WebList("Link2Existing").Exist(60*3)
					If blnResult Then
						blnResult = objPage.WebList("Link2Existing").WaitProperty("items count", micGreaterThan(0), 1000*60*5)
						If Not blnResult Then
							Call ReportLog("Link Existing Service", "Link Existing Service List should be visible", "Link Existing Service List is not visible", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						End If
					End If
					
					intItemsCount = objPage.WebList("Link2Existing").GetROProperty("items count")
					If intItemsCount = 0 Then
						Call ReportLog("Link Existing Service", "List should be populated with atleast one value", "Items are not populated", "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					End If
					
					'Select the last Item in List of Existing Services
					objPage.WebList("Link2Existing").Select ("#" & (intItemsCount - 1))
					Wait 2
					If objPage.WebList("Link2Existing").GetROProperty("value") = "SIP Trunk Service" Then
						Call ReportLog("Link2Existing", "<B>SIP Trunk Service</B> should be selected", "<B>SIP Trunk Service</B> is selected", "PASS", True)
					Else
						blnResult = selectValueFromPageList("Link2Existing", "SIP Trunk Service")
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End If
					
					'Click on Add
					blnResult = clickButton("btnAdd")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
					'Click on Ok
					blnResult = clickButton("btnOk")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
						
					'Check for Number of outstanding saves Status
					For intCounter = 1 to 50
						If objPage.WebElement("class:=status-bar","innertext:=Number of outstanding saves.*","visible:=True", "index:=0").Exist(2) Then
							Wait 3
						Else
							Exit For
						End If
					Next
			End If
	End If '#lnkSIPTService.Exist(60)

	'Check whether it is configured or not
	Set objElmProduct = objPage.WebElement("innertext:=" & ProductOffering &".*", "index:=0")
	If Instr(objElmProduct.GetROProperty("innerHTML"), "Not Configured") > 0 Then
		Call ReportLog("Product Configuration", "Product should be configured", "Product is not configured", "FAIL", True)
		objBrowser.Close
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Product Configuration", "Product should be configured", "Product is configured", "PASS", True)
	End If

	'Click on Base Configuration
	objPage.WebElement("elmModifyBaseConfiguration").Click

	Wait 2
	
	'R39 Functionality Changes
	''Select Checkbox for Pricing
	'Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").WebTable("tblBaseConfig").RefreshObject
	'Set oWebElmChild = 	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("tblBaseConfig1").ChildItem(1,1,"WebCheckBox",0)
	'oWebElmChild.Click
	'
	'blnResult = clickbutton("btnPrice")
	'	If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	'
	''Check for Number of outstanding saves Status
	'For intCounter = 1 to 50
	'	If objPage.WebElement("class:=status-bar","innertext:=Number of outstanding saves.*","visible:=True", "index:=0").Exist(2) Then
	'		Wait 3
	'	Else
	'		Exit For
	'	End If
	'Next
	'
	''Check for Performing Pricing Status
	'For intCounter = 1 to 50
	'	If objPage.WebElement("class:=status-bar","innertext:=Performing pricing","visible:=True", "index:=0").Exist(2) Then
	'		Wait 3
	'	Else
	'		Exit For
	'	End If
	'Next
	'
	''Build Web Reference
	'blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	'
	''Check whether Pricing is FIrmed or not
	'If objPage.WebTable("tblBaseConfig1").GetRowWithCellText("Firm") < 0 Then
	'	Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done", "FAIL", True)
	'	Environment("Action_Result") = False
	'	Exit Function
	'End If
	'
	''Build Web Reference
	'blnResult = BuildWebReference("brwBulkConfiguration","pgBulkConfiguration","")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click Quote Details Link Present on Right Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then	Environment("Action_Result") = False : Exit Function
	
	'Wait for the Page to be Navigated
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Exist(60) Then Exit For
	Next

	blnResult = BuildWebReference("brwSalesQuoteEngine", "pgShowingQuoteOption", "")
		If Not blnResult Then	Environment("Action_Result") = False : Exit Function

	index = -1
	arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	For intCounter = 0 to UBound(arrColumns)
		If arrColumns(intCounter) = "Configured" Then
			index = intCounter + 1
			Exit For
		End If
	Next
	
	If index = -1 Then
		Call ReportLog("Get Configured Column Index", "Should be able to Fetch Configured Column index using Table Header", "Unable to Get the index - check for Object Prop", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Wait 10
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
	 	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	 	Wait 5
	Else
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnValid = False
	For intCounter = 1 to 20
		strCellData = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, index)
		If strCellData = "VALID" Then
			blnValid = True
			Exit For
		Else
			Wait 10
		End If
	Next

	If blnValid Then
		Call ReportLog("Configure Product", "Product should be Configured after calculating Pricing", "Product is Configured and Status is <B>" & strCellData & "</B>", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Environment("Action_Result") = False
	End If
	
	blnPriced = False	
	For intCounter = 1 to 20
		objPage.WebTable("tblProductLineItems").RefreshObject
		blnResult = objPage.WebTable("tblProductLineItems").Exist(60)
		If blnResult Then
       		iProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
			strPricing = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iProdRow, intPricingStatusCol))
			If strPricing = "Firm" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","PASS", True)
				blnPriced = True
				Exit For
			ElseIf strPricing = "ERROR" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL","True")
				Environment("Action_Result") = False : Exit Function
			ElseIf strPricing = "" Then
				Wait 20
			End If
		Else
			Wait 5
		End If
	Next '#intCounter
	
	If Not blnPriced Then
		Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If
End Function

'===========================================================================================================================
'===========================================================================================================================
Private Function fn_SQE_ClickConfigure(ByVal objPage)
	Dim oDesc, objConfigure
	Set oDesc = Description.Create
	oDesc("micclass").Value = "WebElement"
	oDesc("innertext").Value = "Configure"
	oDesc("html tag").Value = "A"
	Set objConfigure = objPage.ChildObjects(oDesc)
	For iCounter = 0 to objConfigure.Count - 1
		If objConfigure(iCounter).GetROProperty("height") > 0  Then
			objConfigure(iCounter).Click
			fn_SQE_ClickConfigure = True
			Call ReportLog("Configure", "Should be able to click on configure link", "Clicked on Configure link", "PASS", False)
			Exit Function
		End If
	Next
	Call ReportLog("Configure", "Should be able to click on configure link", "Unable to click on Configure link", "FAIL", True)
	fn_SQE_ClickConfigure = False
End Function
