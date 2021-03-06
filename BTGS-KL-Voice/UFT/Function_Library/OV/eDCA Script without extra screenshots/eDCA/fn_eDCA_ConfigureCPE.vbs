'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ConfigureCPE
' Purpose	 	 : Function to enter details in Configure CPEpage
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 03/06/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_ConfigureCPE(dTypeOfOrder,dBaseRouter,dCPETerm,dPowerCord,dIOS,dMaintenanceOption,dWICSlots,dNetworkModules)

	'Variable declaration
	Dim blnResult
	Dim strBaseRouter,strCPETerm,strPowerCord,strIOS,strMaintenanceOption,strWICSlots,strNetworkModules

	'Assignment of values to variables
	strBaseRouter=dBaseRouter
	strCPETerm=dCPETerm
	strPowerCord=dPowerCord
	strIOS=dIOS
	strMaintenanceOption=dMaintenanceOption
	strWICSlots=dWICSlots
	strNetworkModules=dNetworkModules

    If Browser("brweDCAPortal").Dialog("regexpwndtitle:=Message from webpage").Exist Then
		Browser("brweDCAPortal").Dialog("regexpwndtitle:=Message from webpage").WinButton("regexpwndtitle:=OK").Click
	End If
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If  dTypeOfOrder <> "OB_FULLPSTN_MODIFY" Then
		'Selecting BaseRouter from drop down
		If objPage.WebList("lstBaseRouter").Exist(30) Then
			blnResult=selectValueFromPageList("lstBaseRouter",strBaseRouter)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync		
		End if 

		If objPage.WebList("lstCPETerm").Exist(30) Then
			'Selecting CPE term from the drop down list
			blnResult=selectValueFromPageList("lstCPETerm",strCPETerm)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If	

		'Selecting Power Cord from drop down list
		If objPage.WebList("lstPowerCord").Exist(30) Then
			blnResult=selectValueFromPageList("lstPowerCord",strPowerCord)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if 
  
		'Selecting IOS from drop down list
		If objPage.WebList("lstIOS").Exist(30) Then
			blnResult=selectValueFromPageList("lstIOS",strIOS)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if
    
		'Selcting Maintenance Option from drop down list
		If objPage.WebList("lstMaintenanceOption").Exist(30) Then
			blnResult=selectValueFromPageList("lstMaintenanceOption",strMaintenanceOption)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if	

		'Entering NetworkModules value
		If objPage.WebEdit("txtNetworkModules").Exist(30) Then
			blnResult=enterText("txtNetworkModules",strNetworkModules)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if

		'CLicking on Save Button
		If objPage.WebButton("btnSave").Exist(30) Then
			blnResult=clickButton("btnSave")
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if
	
		'Clicking on Next Button
		blnResult=clickButton("btnNext")
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

	Else
		'Click on Next Button
		blnResult = clickButton("btnNext")
		If blnResult = False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	End if
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to Configure WIC/NM/PA Cards page
	Set objMsg = objpage.WebElement("webElmConfigureWIC/NM/PACards")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("ConfigureCPE","Should be navigated to ConfigureCards page on clicking Next Buttton","Not navigated to ConfigureCards page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmConfigureWIC/NM/PACards")
		Call ReportLog("ConfigureCPE","Should be navigated to ConfigureCards page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
