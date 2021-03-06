Public Function fn_Classic_EnterBillingAccountDetails(ByVal Currncy, ByVal InfoCurrency, ByVal CreditClass)
	
	Const BACINVENTORIED = "The Billing Account has been inventoried."
	
	Wait 30
	
	Set oWndControl = Window("AmdocsCRM").Window("BillingAccountInfo").WinComboBox("cmbLanguage")
	blnResult = waitForWindowControl(oWndControl, 60)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Build Amdocs Reference
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "BillingAccountInfo")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Language
	blnResult = selectFromChildWindowComboBox("cmbLanguage", "English")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Currency
	blnResult = selectFromChildWindowComboBox("cmbCurrency", Currncy)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Select Info Currency
	blnResult = selectFromChildWindowComboBox("cmbInfoCurrency", InfoCurrency)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Select Credit Class
	blnResult = selectFromChildWindowComboBox("cmbCreditClass", CreditClass)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Click on Add Button
	blnResult = clickChildWindowButton("btnActivationDate")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Set the Date
	Call fn_Classic_SetDialogDate(Date)
		If Not Environment("Action_Result") Then Exit Function
	
	'Click on Add Button
	blnResult = clickChildWindowButton("btnAdd")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check whether BAC has been Inventoried or not
	If oParentWindow.Dialog("WindowDialogs").Static("msgBACInventoried").Exist(120) Then
		Call ReportLog("BAC Inventoried", BACINVENTORIED & "</BR>Message should exist", BACINVENTORIED & "</BR>Message exists", "PASS", True)
		oParentWindow.Dialog("WindowDialogs").WinButton("btnOK").Click
		Environment("Action_Result") = True
	Else
		Call ReportLog("BAC Inventoried", BACINVENTORIED & "</BR>Message should exist", BACINVENTORIED & "</BR>Message doesn't exists", "FAIL", True)
		Environment("Action_Result") = False
	End If
	
	'Click on Done Button
	blnResult = clickChildWindowButton("btnDone")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
End Function
