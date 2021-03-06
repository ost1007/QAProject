'=============================================================================================================
'Description: Function to Create a Cease Proof Doc
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			13/08/2015 				NA
'Return Values : strFileName - File Name
'Example: fn_TAHITI_CreateCeaseProofDoc
'=============================================================================================================
Public Function fn_TAHITI_CreateCeaseProofDoc(ByVal OrderID)
	'Variable Declaration
	Dim objWord, objSelection
	Dim strFileName

	Set objWord = CreateObject("Word.Application")
	objWord.Caption = "Test Caption"
	objWord.Visible = False
	
	Set objDoc = objWord.Documents.Add()
	Set objSelection = objWord.Selection
	
	objSelection.Font.Name = "Calibri (Body)"
	objSelection.Font.Size = "11"
	objSelection.TypeText "no"
	objSelection.TypeParagraph()

	strFileName = Left(Environment("TestDataPath"), InStrRev(Environment("TestDataPath"), "\")) & "CeaseProof_" & OrderID & ".docx"
	
	objDoc.SaveAs strFileName
	objDoc.Close(True)
	objWord.Quit
	Set objWord = Nothing

	fn_TAHITI_CreateCeaseProofDoc = strFileName
End Function