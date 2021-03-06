LINK_MAIN_WORKFLOW		= "ctl00_siMenu_HeaderHyperLink3"
TXT_ID					= "ctl00_ctl00_contentPlaceHolder_QuickSearch1_tbSearchText"
GO_SEARCH_ORDER			= "ctl00_ctl00_contentPlaceHolder_QuickSearch1_btnGo"
TAB_ORDER_CONTACT_DETAILS	= "xpath=.//*[@onclick='OrderContactDetails()']"

#----------------Change Installation Coordinator----------------------------------------
IMG_EDIT_COORDINATOR	= "xpath=.//*[@title='Installation Coordinator']/..//input[@type='image']"
IMG_RED_CROSS			= "xpath=.//img[contains(@src,'RedCross')]"
IMG_SEARCH				= "xpath=.//*[@id='spanTextBox']/img"
TXT_REASON_FOR_CHANGE	= "xpath=.//*[@title='Installation Coordinator']/..//input[@name='ReasonForChange']"
IMG_SAVE				= "xpath=.//*[@title='Installation Coordinator']/..//input[@title='Save']"
#----------------------------------------------------------------------------------------

TAB_TASK_DETAILS	= "xpath=.//*[@onclick='LoadTaskGrid()']"
BTN_REFRESH_TASK	= "xpath=.//*[@id='psg4']//*[@title='Reload Grid']/div"
BLOCK_LOADING		= "xpath=.//*[@id='load_TaskGrid'][contains(@style,'block')]"
BLOCK_LOADING2		= "xpath=.//*[text()='Loading...'][not(contains(@style,'none'))]"
OPEN_TASK			= "xpath=.//td[@title='Open']"
TAB_ORDER_ITEM_LIST	= "xpath=.//*[@onclick='OrderItemList();']"
ONE_TREE			= "xpath=.//div[@id='tree1']/ul/li/div/span"
DD_ACTION_REQUIRED	= "1830"
#LAST_TASK			= "Confirm Order Closure (Cloud Connect Direct)"
RED_CROSS			= "xpath=.//img[@src='RedCross2.png']/../../span[1]"
MANDATORY_FIELDS	= "xpath=(.//span[@class='mandatoryclass']/../*[1])"
IMG_LOADING			= "xpath=.//div[@class='blockUI blockMsg blockPage']"
AIB_COMPLETE		= "xpath=.//*[@id='orderStatus']/div[text()='Complete']"
ORDER_ITEM_LIST		= "xpath=.//span[@class='jqtree-title jqtree_Header']"