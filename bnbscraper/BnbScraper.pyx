import sys
import os
from pathlib import Path
import argparse
import json
from logging import StreamHandler, Formatter, getLogger, INFO, DEBUG
from logging.handlers import TimedRotatingFileHandler
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from webdriver_manager.chrome import ChromeDriverManager
from . import VERSION

_logger = getLogger('bnb_scraper')

# airbnb base url
BNB_URL = 'https://www.airbnb.co.uk/rooms/'


class BnbScraper(object):
    """
    Class implementing Aribnb Scraping
    """

    def __init__(self, input_path=None, destination_path=None):
        _logger.info("Initialize the airbnb sraper %s", VERSION)

        self.destination = destination_path
        if input_path != None:
            self.input = input_path
            self.permitted_listings = self._load_listings()
        self.driver = self._get_driver()

    def _load_listings(self):
        """
        Loads Airbnb listings
        """
        #path = os.path.join(os.getcwd(), "airbnb_listings.json")
        path = self.input

        if not os.path.exists(path):
            with open(path, 'w') as outfile:
                json.dump({"listings_to_scrape": []}, outfile)

        with open(path) as listings_json_file:
            airbnb_listings_data = json.load(listings_json_file)

        airbnb_listings = set(
            airbnb_listings_data.get('listings_to_scrape', {}))
        _logger.info("airbnb listings to scrape: %s", airbnb_listings)

        return airbnb_listings

    def _get_driver(self):
        """
        Loads Chrome driver
        """

        options = Options()
        options.add_argument("--headless")

        # working_directory = os.getcwd()

        # driver_path = working_directory + '\\bnbscraper\chrome_driver\chromedriver.exe'

        # driver = webdriver.Chrome(
        #     executable_path=driver_path, options=options)

        driver = webdriver.Chrome(
            ChromeDriverManager().install(), options=options)

        return driver

    def _get_url(self, url):
        """
        Loads Url
        """
        self.driver.get(url)

    def _get_name(self):
        """
        Read property name
        """
        self.driver.implicitly_wait(11)

        property_name = WebDriverWait(self.driver, 60).until(EC.presence_of_element_located(
            (By.XPATH, """//*[@id="site-content"]/div/div/div[1]/div[1]/div/div/div/div/section/div/div[1]/h1"""))).text

        return property_name

    def _get_type(self):
        """
        Read property type
        """
        self.driver.implicitly_wait(12)

        result = WebDriverWait(self.driver, 60).until(EC.presence_of_element_located(
            (By.XPATH, """//*[@id="site-content"]/div/div/div[3]/div[1]/div/div[1]/div/div/div/div/div/div[1]/div[1]"""))).text

        property_type = result.split('hosted', 1)[0]

        return property_type

    def _get_bedrooms(self):
        """
        Read property number of bedrooms
        """

        self.driver.implicitly_wait(13)

        result = WebDriverWait(self.driver, 60).until(EC.presence_of_element_located(
            (By.XPATH, """//*[@id="site-content"]/div/div/div[3]/div[1]/div/div[1]/div/div/div/div/div/div[1]/div[2]/span[3]"""))).text

        bedrooms = int(result.split()[0])

        return bedrooms

    def _get_bathrooms(self):
        """
        Read property number of bathrooms
        """
        self.driver.implicitly_wait(15)

        result = WebDriverWait(self.driver, 60).until(EC.presence_of_element_located(
            (By.XPATH, """//*[@id="site-content"]/div/div/div[3]/div[1]/div/div[1]/div/div/div/div/div/div[1]/div[2]/span[7]"""))).text

        bathrooms = int(result.split()[0])

        return bathrooms

    def _get_amenities(self):
        """
        Read property amenities list
        """
        self.driver.implicitly_wait(10)
        amenities_list = []
        amenities = self.driver.find_elements_by_class_name('_1nlbjeu')

        for amenity in amenities:

            if 'Unavailable' not in amenity.text:
                amenities_list.append(amenity.text)

        return amenities_list

    def _export_json(self, listing, bathrooms, bedrooms, property_type, property_name, amenities):
        """
        Export data as a json object
        """
        data = {
            'property_id': listing,
            'bathrooms': bathrooms,
            'bedrooms': bedrooms,
            'property_type': property_type,
            'property_name': property_name,
            'amenities': amenities
        }

        with open(self.destination, 'a') as f:
            json.dump(data, f)
            f.write('\n')

        _logger.info('Property details sent to destination')

    def _export_dictionary(self, listing, bathrooms, bedrooms, property_type, property_name, amenities):
        """
        Return data as a python dictionary
        """
        data = {
            'property_id': listing,
            'bathrooms': bathrooms,
            'bedrooms': bedrooms,
            'property_type': property_type,
            'property_name': property_name,
            'amenities': amenities
        }

        return data

    def scrape(self, listing):
        """
        Scrapes a single airbnb listing
        """
        URL = BNB_URL + listing

        self._get_url(URL)

        bathrooms = self._get_bathrooms()
        bedrooms = self._get_bedrooms()
        property_type = self._get_type()
        property_name = self._get_name()
        amenities = self._get_amenities()

        result = self._export_dictionary(listing, bathrooms, bedrooms,
                                         property_type, property_name, amenities)

        return result

    def scrape_list(self, listings):
        """
        Scrapes a list of airbnb listings
        """
        result = []

        for listing in listings:

            listing_dict = self.scrape(listing)

            result.append(listing_dict)

        return result

    def run(self):

        try:
            os.remove(self.destination)
        except OSError:
            pass

        for listing in self.permitted_listings:

            URL = BNB_URL + listing

            _logger.info("scraping %s starts...", URL)

            self._get_url(URL)

            bathrooms = self._get_bathrooms()
            _logger.debug("bathrooms: %s", bathrooms)
            bedrooms = self._get_bedrooms()
            _logger.debug("bedrooms: %s", bedrooms)
            property_type = self._get_type()
            _logger.debug("property type: %s", property_type)
            property_name = self._get_name()
            _logger.debug("property name: %s", property_name)
            amenities = self._get_amenities()
            _logger.debug("amenities: %s", amenities)

            self._export_json(listing, bathrooms, bedrooms,
                              property_type, property_name, amenities)


def main():
    parser = argparse.ArgumentParser(description='Insert engine')

    parser.add_argument('-input', help='Input queue', required=True)
    parser.add_argument(
        '-destination', help='Database for output data', required=True)
    parser.add_argument('-debug', action='store_true')
    parser.add_argument(
        '-uid', help='Unique identifier for process', required=True)

    opts = parser.parse_args()

    # For debugging
    if opts.debug:
        _logger.setLevel(DEBUG)

    Path('logs').mkdir(parents=True, exist_ok=True)

    # UID
    handler = TimedRotatingFileHandler('logs/BnbScraper-{0}.log'.format(opts.uid),
                                       when='midnight',
                                       interval=1,
                                       encoding='utf-8',
                                       backupCount=7)
    fileformatter = Formatter(
        '%(asctime)s %(levelname)s %(message)s', '%H:%M:%S')
    handler.setFormatter(fileformatter)
    _logger.addHandler(handler)

    insert_engine = BnbScraper(opts.input, opts.destination)

    insert_engine.run()
