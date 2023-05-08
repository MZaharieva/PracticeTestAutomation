'''
Questions: 
- Which aspects of a webpage change most frequently? 
  >> Layout stays rather stable, process flow is more likely to change in terms of action steps or behavior-input contingencies

- Why didn't this approach work?
#Try Click  xpath://iframe[@id="29789"] >> css:img[alt=Alleen]
>> Returns Error: locator.click: Unsupported token "@id" while parsing selector ...
>> See "Try Iframe Injection Approach" below
'''

*** Settings ***
Library  Browser  auto_closing_level=SUITE  # suite shares same browser context, etc.
Library  String  # for RegEx string manipulation

*** Keywords ***
Open Iframe
    [Documentation]  Gets Iframe URL from src and opens it in a new page.
    [Arguments]  ${selector}
      ${iframe}=  Get Attribute  ${selector}  src  # get the URL to the iframe as defined in src
      Log  ${iframe}
      New Page  ${iframe}  # open the URL to the iframe  as new page

*** Test Cases ***
ABN Test Numeric Mortgage Calculation
  Register Keyword To Run On Failure  Take Screenshot  failure-{index}  fullPage=True  # take screenshot upon each failure
  New Browser  firefox  headless=false  # express browser preview for debugging, suppress for production
  New Context  viewport={'width': 1920, 'height': 1080}  # set standard display resolution for the browser
  Set Browser Timeout  0:00:15  # wait time for last script action to unfold  
  # Page 1: Start Mortgage Calculation 
  New Page  https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html  
  Log  Page opened.  
  ${title}=  Get Title  # get title of the page opened
  Should Be Equal  ${title}  Hypotheek berekenen in 2023 - ABN AMRO  # check whether page title matches expected
  Wait For Elements State  //a[@id="aab-cookie-consent-agree"]  visible  timeout=2 s  # wait for cookies element to appear
  Click  //a[@id="aab-cookie-consent-agree"]  # accept cookies
  Open Iframe  selector=//iframe[@id="29789"]  # open the iframe in which the calculator function is embedded
  # Page 2: Wat is uw situatie?
  Click  //button[@data-element-label="Ik heb nog geen hypotheek bij ABN AMRO"]
  # Page 3: Koopt u alleen of samen?
  Click  //img[@alt="Alleen"]
  ${url_page_3}  Get Url  # get current URL to reuse in another test case 
  Set Suite Variable  $url_page_3  # store URL as SUITE variable
  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  txt="30"  delay=200 ms
  Click  //button[@class="base-btn__inner-button"]  
  # Page 5: Wat is uw werksituatie?
  ${url_page_5}  Get Url  # get current URL to reuse in another test case 
  Set Suite Variable  $url_page_5  # store URL as SUITE variable
  Click  //button[@class="base-btn__inner-button"]  # press to continue, skipping the dropdown menu
  # Page 6: Wat is uw bruto inkomen per jaar?
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  # Playwright supports CSS for shadow DOM
  Click  //button[@class="base-btn__inner-button"] 
  # Page 7-9: Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  3  Click  //span[text()="Nee"]/parent::div
  # Page 10: Check whether the outputted mortgage amount is numeric
  ${mortgage_amount}  Get Text  //span[@class="calculation-total__amount"]  # get the text containing the mortgage amount
  Log  ${mortgage_amount}  
  ${mortgage_amount}=  Remove String    ${mortgage_amount}  .  # remove decimal dots from the string
  ${numeric_test_result}=  Convert to Number  ${mortgage_amount}  # convert the string to numeric
  Run Keyword If  ${numeric_test_result} >= 0  Log  Mortgage amount is numeric.  # evaluate whether the mortgage amount is a positive number or zero
  ...  ELSE  Fail  Mortgage amount is not numeric.  # if the string could not be converted to number, the test should fail
  Set Suite Variable    $numeric_test_result_fixed  ${numeric_test_result}  # store mortgage amount to compare to output from another test
  Sleep  1 s  # wait for N seconds before closing browser preview 

ABN Test Valid Age Input
# Test whether a user can move on with the calculation with invalid age input. 
# Alternative approach is to test whether the button is deactivated after inputing invalid age value: <button disabled type="button" data-v-655a9b73="" class=…>…</button>
  New Page  ${url_page_3}  # the variable is not stored in memory, only works when running the suite.
  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  txt="1000"  delay=200 ms  # input invalid age
  Run Keyword And Expect Error  TimeoutError: locator.click:*  Click  //button[@class="base-btn__inner-button"]  # will fail if user moved on with invalid age input  

ABN Test Ordinal Mortgage Calculation: Fixed Employment Contract 
# Does the mortgage amount of Flexible contract (<2 years work experience) < Fixed?
  New Page  ${url_page_5}  # the variable is not stored in memory, only works when running the suite.
  # Page 5: Wat is uw werksituatie?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using Xpath to open dropdown menu
  Click  text=Flexibel  
  Click  //button[@class="base-btn__inner-button"]  
  # Page 6-7: Werkt u al langer dan 2 jaar? Had u in de afgelopen 3 jaar ook inkomsten bij andere werkgevers?
  Repeat Keyword  2  Click  //span[text()="Nee"]/parent::div  
  # Page 8: Vul het geschatte bruto jaarinkomen in
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  Click  //button[@class="base-btn__inner-button"] 
  # Page 9-11: Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  3  Click  //span[text()="Nee"]/parent::div
  # Page 11: Check whether the outputted mortgage amount is numeric
  ${mortgage_amount}  Get Text  //span[@class="calculation-total__amount"]  # get the text containing the mortgage amount
  Log  ${mortgage_amount}  
  ${mortgage_amount}=  Remove String    ${mortgage_amount}  .  # remove decimal dots from the string
  ${numeric_test_result}=  Convert to Number  ${mortgage_amount}  # convert the string to numeric
  Run Keyword If  ${numeric_test_result} >= 0  Log  Mortgage amount is numeric.  # evaluate whether the mortgage amount is a positive number or zero
  ...  ELSE  Fail  Mortgage amount is not numeric.  # if the string could not be converted to number, the test should fail
  Set Suite Variable  $numeric_test_result_flex  ${numeric_test_result}  # store mortgage amount to compare to output from another test
  Log  ${numeric_test_result_fixed}  # Log mortgage estimate for "Fixed" contract
  Run Keyword If  $numeric_test_result_fixed >= $numeric_test_result_flex  Log  Test PASSED - greater or equal mortgage estimate for "Fixed" than for "Flex" contract.  
  ...  ELSE  Fail  Test FAILED - lower mortgage estimate for "Fixed" than for "Flex" contract.  # test fails whenever Fixed contract (keeping the rest fixed) doesn't yield higher or equal mortgage estimate.
  Sleep  1 s  # wait for N seconds before closing browser preview  


ABN Test Ordinal Mortgage Calculation: Flexible Employment Contract 
# Does the mortgage amount of Flexible contract (<2 years work experience) < Fixed?
  New Page  ${url_page_5}  # the variable is not stored in memory, only works when running the suite.
  # Page 5: Wat is uw werksituatie?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using Xpath to open dropdown menu
  Click  text=Flexibel  
  Click  //button[@class="base-btn__inner-button"]  
  # Page 6-7: Werkt u al langer dan 2 jaar? Had u in de afgelopen 3 jaar ook inkomsten bij andere werkgevers?
  Repeat Keyword  2  Click  //span[text()="Nee"]/parent::div  
  # Page 8: Vul het geschatte bruto jaarinkomen in euro
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  Click  //button[@class="base-btn__inner-button"] 
  # Page 9-11: Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  3  Click  //span[text()="Nee"]/parent::div
  # Page 12: Check whether the outputted mortgage amount is numeric
  ${mortgage_amount}  Get Text  //span[@class="calculation-total__amount"]  # get the text containing the mortgage amount
  Log  ${mortgage_amount}  
  ${mortgage_amount}=  Remove String    ${mortgage_amount}  .  # remove decimal dots from the string
  ${numeric_test_result}=  Convert to Number  ${mortgage_amount}  # convert the string to numeric
  Run Keyword If  ${numeric_test_result} >= 0  Log  Mortgage amount is numeric.  # evaluate whether the mortgage amount is a positive number or zero
  ...  ELSE  Fail  Mortgage amount is not numeric.  # if the string could not be converted to number, the test should fail
  Set Suite Variable  $numeric_test_result_flex  ${numeric_test_result}  # store mortgage amount to compare to output from another test
  Log  ${numeric_test_result_fixed}  # Log mortgage estimate for "Fixed" contract
  Run Keyword If  $numeric_test_result_fixed >= $numeric_test_result_flex  Log  Test PASSED - greater or equal mortgage estimate for "Fixed" than for "Flex" contract.  
  ...  ELSE  Fail  Test FAILED - lower mortgage estimate for "Fixed" than for "Flex" contract.  # test fails whenever Fixed contract (keeping the rest fixed) doesn't yield higher or equal mortgage estimate.
  Sleep  1 s  # wait for N seconds before closing browser preview  


ABN Test Ordinal Mortgage Calculation: Self-Employment Employment Contract 
# Does the mortgage amount of Self-Employment contract (<2 years work experience) < Fixed?
  New Page  ${url_page_5}  # the variable is not stored in memory, only works when running the suite.
  # Page 5: Wat is uw werksituatie?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using Xpath to open dropdown menu
  Click  text=Zelfstandig  
  Click  //button[@class="base-btn__inner-button"]  
  # Page 6: Hoe lang bent u al zelfstandig ondernemer?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using Xpath to open dropdown menu
  Click  text=Tussen 1 en 2 jaar
  Click  //button[@class="base-btn__inner-button"]  
  # Page 7: Werkt u al langer dan 2 jaar? 
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  Click  //button[@class="base-btn__inner-button"] 
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  Click  //button[@class="base-btn__inner-button"] 
  # Page 8-11: Had u in de afgelopen 3 jaar ook inkomsten bij andere werkgevers? >> Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  4  Click  //span[text()="Nee"]/parent::div
  # Page 12: Check whether the outputted mortgage amount is numeric
  ${mortgage_amount}  Get Text  //span[@class="calculation-total__amount"]  # get the text containing the mortgage amount
  Log  ${mortgage_amount}  
  ${mortgage_amount}=  Remove String    ${mortgage_amount}  .  # remove decimal dots from the string
  ${numeric_test_result}=  Convert to Number  ${mortgage_amount}  # convert the string to numeric
  Run Keyword If  ${numeric_test_result} >= 0  Log  Mortgage amount is numeric.  # evaluate whether the mortgage amount is a positive number or zero
  ...  ELSE  Fail  Mortgage amount is not numeric.  # if the string could not be converted to number, the test should fail
  Set Suite Variable  $numeric_test_result_self  ${numeric_test_result}  # store mortgage amount to compare to output from another test
  Log Many  ${numeric_test_result_fixed}  ${numeric_test_result_self}  ${numeric_test_result_flex}  # Log mortgage estimate for "Fixed" and "Flex" contract
  Run Keyword If  $numeric_test_result_fixed >= $numeric_test_result_self >= $numeric_test_result_flex  Log  Test PASSED - greater or equal mortgage estimate for "Fixed" than for "Flex" contract.  
  ...  ELSE  Fail  Test FAILED - lower mortgage estimate for "Fixed" than for "Flex" contract.  # test fails whenever Fixed contract (keeping the rest fixed) doesn't yield higher or equal mortgage estimate.
  Sleep  1 s  # wait for N seconds before closing browser preview  

#Try Iframe Injection Approach
#  Register Keyword To Run On Failure  Take Screenshot  failure-{index}  fullPage=True  # take screenshot upon each failure
#  # Page 1: Start Mortgage Calculation 
#  New Page  https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html
#  Log  Page opened.  
#  ${title}=  Get Title  
#  Should Be Equal  ${title}  Hypotheek berekenen in 2023 - ABN AMRO
#  Wait For Elements State  //a[@id="aab-cookie-consent-agree"]  visible  timeout=2 s  # wait for cookies element to appear
#  Click  //a[@id="aab-cookie-consent-agree"]  # accept cookies
#  # Page 2: Wat is uw situatie?
#  Click  xpath://iframe[@id="29789"] >> css:img[alt=Have no mortgage]  #Try Click  xpath://iframe[@id="29789"] >> css:img[alt=Alleen]
#  # Returns Error: locator.click: Unsupported token "@id" while parsing selector "xpath://iframe[@id="29789"]"
#  Sleep  5 s