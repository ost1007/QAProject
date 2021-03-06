#Products in the quote
BLOCKER												= "xpath=.//div[@class='blockUI blockMsg blockPage']"
CBOX_ADDITIONAL_PRODUCT								= "xpath=.//tr[3]//input[@id='checks']"
DD_ADDITONAL_PRODUCT_ORDER_TYPE						= "xpath=.//tr[3]/td[3]/div[2]/select[@class='form-control ng-pristine ng-valid']"
BTN_ADD_PRODUCT_TO_QUOTE							= "xpath=.//button[contains(text(),'Add Product to Quote')]"
LINK_ADDITIONAL_PRODUCT_PROVIDE_CONFIGURATION		= "xpath=.//tr[3]//a[contains(text(),'Provide')]"
LINK_ADDITIONAL_PRODUCT_CEASE_CONFIGURATION			= "xpath=.//tr[3]//a[contains(text(),'Cease')]"
LOADING_MESSAGE										= "xpath=.//*[@id='loadingMessage']"
REMOVEMODIFY										= "xpath=.//input[@title='Remove/Modify selected product']"
CREATING_PRODUCT									= "xpath=.//div[@id='creating-product-spinner']"
LINK_BASE_CONFIGURATION								= "xpath=.//li[*]/div/div/span[@title='Base Configuration']"
ASSET_TO_DELETE										= "xpath= //input[@ng-checked='isSelectedAll()']"
STATUS_LOADING										= "xpath=.//*[@id='statusBarModal']"
LINK_QUOTE_OPT_DETAILS								= "xpath=.//*[@id='quoteOption']"
CBOX_LIST_QUOTE_OPT_DETAILS							= "xpath=.//input[@name='listOfQuoteOptionItems']"
BTN_IMPORT_PRODUCT									= "xpath=.//a[@id='importProduct']"
BTN_IMPORT_PRODUCT_BROWSE							= "xpath=.//input[@id='eCRFSheet']"
RFO_INVALID											= "xpath= .//*[@id='orders']/tbody/tr/td[6][contains (text(),'RFO invalid')]"
BTN_OK_RFO											= "xpath=.//div[@role='dialog'][not(contains(@style,'display: none'))]//button"	
UPLOAD_SUCCESSFUL									= "xpath=.//*[text()='Upload Successful']"
STATUS_SUBMITTED									= "xpath=.//*[text()='Submitted']"
NEW_QUANTITY                                        = "xpath= //*[@id='table-row-index-0']/td[5]/div/div[3]/input"
MODIFY_CONFIGURATION                                = "xpath=.//html/body/div/div[1]/section/div/div/div/div/div/div[2]/table/tbody/tr[3]/td[3]/div[1]/a"
ADD_PRODUCT                                         = "xpath=.//*[@id='configurator-container']/div[5]/div[1]/div[1]/button[1]"
MODIFY_PRODUCT_LIST                                 = "//table[@id='siteTable']/tbody/tr"
RFO_IMPORT_ICON                                     = "xpath=.//*[@id='rfoImport']/img"
RFO_EXPORT_ICON                                     = "xpath=.//*[@id='rfoExport']/img"