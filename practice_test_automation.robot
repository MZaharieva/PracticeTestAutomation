'''
Questions: 
- Which aspects of a webpage change most frequently? 
- How to deal with cookies? 
- Why didn't this approach work?
#Click   //iframe[@id="29789"] >> img[alt=Alleen] 
- How to deal with shadow DOM >> using CSS rather than XPath in Playwright
'''

*** Settings ***
Library  Browser  auto_closing_level=SUITE  # shares same browser context, etc.
Library    String

*** Keywords ***
Open Iframe
    [Documentation]  Opens an Iframe in a new page.
    [Arguments]  ${selector}
      ${iframe}=  Get Attribute  ${selector}  src  # get the link to the iframe as defined in src
      Log  ${iframe}
      New Page  ${iframe}  # open the link to the iframe  

*** Test Cases ***
ABN Test Numeric Mortgage Calculation
  Register Keyword To Run On Failure  Take Screenshot  failure-{index}  fullPage=True  # take screenshot upon each failure
  New Browser  firefox  headless=false  # express browser preview for debugging, suppress for production
  New Context  viewport={'width': 1920, 'height': 1080}  # set standard display resolution for the browser
  Set Browser Timeout  0:00:30  # wait time for last script action to unfold  
  # Page 1: Start Mortgage Calculation 
  New Page  https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html  
  Log  Page opened.  
  ${title}=  Get Title  
  Should Be Equal  ${title}  Hypotheek berekenen in 2023 - ABN AMRO
  Open Iframe  selector=//iframe[@id="29789"]  # open the iframe in which the calculator function is embedded
  # Page 2: Wat is uw situatie?
  Click  //button[@data-element-label="Ik heb nog geen hypotheek bij ABN AMRO"]
  # Page 3: Koopt u alleen of samen?
  Click  //img[@alt="Alleen"]
  ${url_page_3}  Get Url  # get current URL for later reuse
  Set Suite Variable  $url_page_3  # store URL as SUITE variable
  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  txt="30"  delay=200 ms
  Click  //button[@class="base-btn__inner-button"]  
  # Page 5: Wat is uw werksituatie?
  Click  //button[@class="base-btn__inner-button"]  # press to continue, skipping the dropdown menu
  # Page 6: Wat is uw bruto inkomen per jaar?
  Type Text  css=input#inputId  txt="55.555"  delay=200 ms  # for shadow DOM, use css (bc Playwright)
  Click  //button[@class="base-btn__inner-button"] 
  # Page 7: Heeft u een studieschuld?
  Click  //span[text()="Nee"]/parent::div
  # Page 8: Heeft u leningen?
  Click  //span[text()="Nee"]/parent::div
  # Page 9: Betaalt u alimentatie?
  Click  //span[text()="Nee"]/parent::div
  # Page 10: Check whether the outputted mortgage amount is numeric
  ${mortgage_amount}  Get Text  //span[@class="calculation-total__amount"]  # get the text containing the mortgage amount
  Log  ${mortgage_amount}  
  ${mortgage_amount}=  Remove String    ${mortgage_amount}  .  # remove decimal dots from the string
  ${numeric_test_result}=  Convert to Number  ${mortgage_amount}  # convert the string to numeric
  Run Keyword If  ${numeric_test_result} >= 0  Log  Mortgage amount is numeric.  # evaluate whether the mortgage amount is a positive number or zero
  ...  ELSE  Fail  Mortgage amount is not numeric.  # if the string could not be converted to number, the test should fail
  Sleep  5 s  # wait for 5 seconds before closing browser preview 

ABN Test Valid Age Input
# Test whether a user can move on with the calculation with invalid age input. 
# Alternative approach is to test whether the button is deactivated after inputing invalid age value: <button disabled type="button" data-v-655a9b73="" class=…>…</button>
  New Page  ${url_page_3}  # the variable is not stored in memory, only works when running the suite.
  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  txt="1000"  delay=200 ms  # input invalid age
  Run Keyword And Expect Error  TimeoutError: locator.click:*  Click  //button[@class="base-btn__inner-button"]  # Will fail if user moved on with invalid age input.  

#ABN Test Ordinal Income Calculation Given Employment Contract 

# Check whether dropdown menu is in visible state //span[@class="arrow arrow--flipped"]  

# Approach to circumvent shadow DOM using Xpath
#Click  //aab-select[@class="dropdown-input__dropdown"]  # open dropdown menu.
#Click  text=Flexibel  # select another opion; 