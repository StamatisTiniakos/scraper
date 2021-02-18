Python library for scraping Airbnb listings using the property listing id. 

The following data is extracted: 

*Number of bathrooms

*number of bedrooms

*Property type

*Property name

*List of amenities.



Clone and Install: 

1) Clone the project
2) Open powershell as admin and --> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
3) Navigate to the scraper directory and run ./setup.ps1 on PowerShell



To use as a tool:

1) Add the required listing ids on airbnb_listings.json e.g. for https://www.airbnb.co.uk/rooms/43523332  add "43523332"

2) py -m bnbscraper.engine -input ./airbnb_listings.json -destination ./data.json -uid 1 -debug



To use as a library:

1) Import the module:                      from bnbscraper.BnbScraper import BnbScraper

2) Create an instance of the class:        scraper = BnbScraper()

3) Scrape single listing:                                 result = scraper.scrape("43523332")   #result is a dictionary

4) Scrape a list of listings:                            result = scraper.scrape_list(["33571268","33090114","40558945"]) #result is a list that contains dictionaries



Future Work: 

*Unit Testing

*Error Handling

*Explore whether the use of scrapy vs selenium could improve performance.
