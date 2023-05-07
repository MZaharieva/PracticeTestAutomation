## General Info
Aim: Practice tutorials to use Robot Framework for browser automation. 

## Test questions & answers: 
1) Primary test: When going through the simplest choice path of the [ABN mortgage calculator](https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html), does the calculator output a numeric calculation for mortgage? 
   1) Yes, see Report for ABN Test Numeric Mortgage Calculation.
2) Additional tests: 
    - Does the calculator correctly assign relative mortgate values given certain modifiers? 
      - TBD.
    - Does the calculator stop if invalid age is inputed? 
      - Yes, see ABN Test Valid Age Input.
    - Etc. 

## To-do:
- [x] Setup python virtual environment with [poetry](https://michaelcurrin.github.io/dev-cheatsheets/cheatsheets/package-managers/python/poetry.html)
- [x] Re-install robotframework-browser & [Playwright](https://playwright.dev/docs/intro)
- [x] Push to Github repository 

## Resources: 
- [Quick Start in RobotFramework](https://github.com/robotframework/QuickStartGuide/blob/master/QuickStart.rst)
- [RobotFramework Documentation](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#installing-using-pip)
- [RobotFramework browser documentation](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [RobotFramework built-in documentation](https://robotframework.org/robotframework/6.0.2/libraries/BuiltIn.html?_ga=2.223392667.1631393726.1683372460-868379529.1683372460#library-documentation-top)
- [Articles on Test Automation](https://testersdock.com/)
- [XPath, CSS, HTML Syntax](https://www.w3schools.com/xml/xpath_syntax.asp#gsc.tab=0)
- [XPath vs. CSS selectors](https://www.scrapingbee.com/blog/xpath-vs-css-selector/)

## Notes & General Tips for Web Test Automation: 
- When installing new packages >> RESTART VS code project 
- Use Mozilla Firefox for webpage automation 
- When test automation projects scale up, keep Test Cases and Keywords apart 
- For browser automation, use Playwright within Robot Framework [stable alternative to Selenium]
- To locate an element within iframes, you need to search the element within the iframe (iframe punch-through)
- Use CSS or XPATH to query XML/HTML (can be also done via the web element inspector)
- CSS - most commonly used, less verbose, but excludes content; # = id 
- XPATH - great for searchiing tag content, hierarchy (parent, child, sibling, etc.)
- Aim to automate with reference to unique and stationary properties of the webpage (e.g., hierarchy can change) 
- XML - user-defined tags; HTML - universal for building webpages

//input[@id = "username"], where input is the tag name, [] defines a set of criteria, and @id = "username" specifies some attribute

- Avoid searching tags in the whole document via / expression
- can combine / and // expressions to allocate tags (but should be avoided) 
- Overview Xpath & CSS selectors: https://www.scrapingbee.com/blog/xpath-vs-css-selector/ 
- Install Robot Framework Language Server plugn for code support 
- Node.js - java script engine for browser automation
- Check out adding roadmaps to projects (the overall project planning/scale-up)


