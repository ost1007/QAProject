#####login#####
timeOutWait				= "300"
seleniumSpeed			= "0.3"
t3_SI_URL				= "http://singlemodela.nat.bt.com/default.aspx"
t3_AIB_URL				= "http://aibwebc-ws.nat.bt.com:61007/aibweb/"
taskList				= ["Handle Automated Test Exception (CN)", "Handle Automated Exception - Provide Service Attributes for Supplier (Amazon) end Activation", "Provide Service Attributes for Customer end Activation (Cloud Connect Direct)", "Confirm Customer end Activation (Cloud Connect Direct)", "Autoclose Wait Task (Service Connection)", "Order Quality Check (Cloud Connect Direct)", "Handover to Maintenance (Cloud Connect Direct)", "Notify Customer Service is Ready (Cloud Connect Direct)", "Confirm Order Closure (Cloud Connect Direct)"]
failedTaskNameList		= ["Handle Automated MRS Failure (CN)"]
local_ie_driver 		= "C://Python27//IEDriverServer.exe"

#added Azry 06072018 - task details waiting time for refresh
maxWaitingTime			= "6h"
refreshTime				= "10s"
#end added Azry 06072018 - task details waiting time for refres