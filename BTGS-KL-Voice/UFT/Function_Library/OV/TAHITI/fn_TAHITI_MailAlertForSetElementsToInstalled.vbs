'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_MailAlertForSetElementsToInstalled
'
' Purpose	 	 : Function to write a mail when set elements to be installed task is appeared
'
' Author	 	 : Vamshi Krishna G
'Modified by		 : Linta CK
'
' Creation Date  	 : 18/12/2013
'
' Parameters	 : 
'                                      					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_TAHITI_MailAlertForSetElementsToInstalled(dRecieverMailAddress,dCCMailAddress)
   'fncMailAlertForSetElementsToInstalled(RecieverMailAddress,CCMailAddress)

'Declaration of variables
Dim strRecieverMailAddress,strCCMailAddress

'Assignment of variables
strRecieverMailAddress = dRecieverMailAddress
strCCMailAddress = dCCMailAddress

'Create an object of type Outlook
Set objOutlook = CreateObject("Outlook.Application")
Set myMail = objOutlook.CreateItem(0)

'Set the email properties
myMail.To = strRecieverMailAddress
myMail.CC = strCCMailAddress 'Sending mails to multiple ids
myMail.Subject = "Mail Alert for the task Set elements to be installed"
myMail.Body= "Script execution is reached to Set Elements to be installed task.Please complete the task in classic and run the script for remaining tasks"

'myMail.Attachments.Add("D:\Attachment.txt") 'Path of the file to be attached

'Call ReportLog("Mail Alert","","Set elements to be installed task is under execution.Please close the task in Classic","PASS","")
 
'Send the mail
myMail.Send
Wait(3)
 
'Clear object reference
Set myMail = Nothing
Set objOutlook = Nothing

exitaction(0)
 
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

