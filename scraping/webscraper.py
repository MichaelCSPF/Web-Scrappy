# %%
import time
import json
import math
import re
import logging 
import pandas as pd
import pyodbc
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup

# %%
# --- config base ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

BASE_URL = r'https://www.kabum.com.br/perifericos/teclado-mouse'
PAGE_SIZE = 20 
CREDENTIAL_PATH = r'C:\Users\Michael\DW\DATA_MART_VENDAS\ETL_PYTHON\credencial_banco_st.json'

# --- adjustes selenium ---
options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--window-size=1920x1080')
options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36') # Add a common user agent

try:
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    wait = WebDriverWait(driver, 30) 
except Exception as e:
    logging.error(f"Failed to initialize WebDriver: {e}")
    exit()

# --- DB credencial ---
try:
    with open(CREDENTIAL_PATH, 'r') as file:
        cred = json.load(file)
    server = cred['server']
    database = cred['database']
    driver_sql = cred.get('driver', '{ODBC Driver 17 for SQL Server}') # Use default if not specified
    conn_str = f'DRIVER={driver_sql};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
except FileNotFoundError:
    logging.error(f"Credential file not found at {CREDENTIAL_PATH}")
    driver.quit()
    exit()
except KeyError as e:
    logging.error(f"Missing key in credential file: {e}")
    driver.quit()
    exit()
except Exception as e:
    logging.error(f"Error reading credentials: {e}")
    driver.quit()
    exit()



all_product_data = []
total_pages = 1

try:
    # 1. Get Total Product Count and Calculate Pages
    logging.info(f"Accessing base URL to get product count: {BASE_URL}")
    driver.get(BASE_URL)
    # Wait for the count element to be present
    count_element = wait.until(EC.presence_of_element_located((By.ID, 'listingCount')))
    bsp_count = BeautifulSoup(driver.page_source, 'html.parser')
    div_count = bsp_count.find('div', id='listingCount')

    if div_count and div_count.b:
        quantidade_texto = div_count.b.get_text().strip()
        logging.info(f"Raw quantity text found: '{quantidade_texto}'")
        # Extract only the number part reliably
        match = re.search(r'(\d+)', quantidade_texto.replace('.', '')) # Remove thousands separators if any
        if match:
            qtd_total = int(match.group(1))
            logging.info(f"Total products found: {qtd_total}")
            total_pages = math.ceil(qtd_total / PAGE_SIZE)
            logging.info(f"Calculated total pages: {total_pages} (page size: {PAGE_SIZE})")
        else:
            logging.error("Could not extract number from quantity text.")
            raise ValueError("Could not parse product quantity.")
    else:
        logging.error("Element 'listingCount' or its '<b>' tag not found.")
        raise ValueError("Could not find product quantity element.")

    # 2. Scrape data page by page
    logging.info(f"Starting scraping process for {total_pages} pages...")
    for i in range(1, total_pages + 1):
        # Construct URL WITHOUT the problematic facet_filters, using the correct page size
        page_url = f'{BASE_URL}?page_number={i}&page_size={PAGE_SIZE}&sort=most_searched'
        logging.info(f"Scraping page {i}/{total_pages}: {page_url}")

        try:
            driver.get(page_url)
            logging.info("Waiting for the first 'a.productLink' element...")
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "a.productLink")))
            logging.info("First 'a.productLink' located.")
            # Opcional: Pequena pausa para garantir renderização completa após a espera
            time.sleep(1)

            soup = BeautifulSoup(driver.page_source, 'html.parser')

            # 2. MODIFY O FIND_ALL (BeautifulSoup):
            #    SEARCH ALL  TAGS 'a'  IN CLASS 'productLink'
            logging.info("Finding all 'a.productLink' elements...")
            # A regex re.compile(r'\bproductLink\b') é uma forma mais segura de garantir
            # que estamos pegando a classe exata, mesmo que haja outras classes no elemento.
            product_cards = soup.find_all('a', class_=re.compile(r'\bproductLink\b'))
            logging.info(f"Found {len(product_cards)} product links on page {i}.")

            if not product_cards:
                 logging.warning(f"No 'a.productLink' elements found on page {i}. Skipping.")
                 # re-check 
                 continue # Skip to next page
             
            page_data = []
            
            for card in product_cards:
                marca_text = None
                preco_text = None
                preco_float = None
                try:
                    # SEARCH nameCard IN CARD (tag 'a.productLink')
                    marca_span = card.find('span', class_=re.compile('nameCard'))
                    if marca_span:
                        marca_text = marca_span.get_text(strip=True)
                    else:
                        logging.warning(f"Brand ('nameCard') not found within a 'a.productLink' on page {i}.")

                    # SEARCH priceCard IN CARD(tag 'a.productLink')
                    preco_span = card.find('span', class_=re.compile('priceCard'))
                    if preco_span:
                        preco_text = preco_span.get_text(strip=True)
                        preco_cleaned = preco_text.replace('R$', '').replace('.', '').replace(',', '.').strip()
                        preco_float = float(preco_cleaned)
                    else:
                        logging.warning(f"Price ('priceCard') not found within product link '{marca_text}' on page {i}.")

                    if marca_text and preco_float is not None:
                         page_data.append({'marca': marca_text, 'preco': preco_float})


                except AttributeError as e:
                    logging.error(f"AttributeError while parsing a product card on page {i}: {e}. Card HTML might be incomplete or different.")
                except ValueError as e:
                    logging.error(f"ValueError converting price '{preco_text}' to float for product '{marca_text}' on page {i}: {e}")
                except Exception as e:
                    logging.error(f"Unexpected error processing a product card on page {i} for product '{marca_text}': {e}", exc_info=True) # Log traceback

            all_product_data.extend(page_data)
            logging.info(f"Finished page {i}. Total products collected so far: {len(all_product_data)}")

            # Be polite to the server - add a small delay between page requests
            time.sleep(1) # Adjust as needed

        except Exception as e:
            logging.error(f"Failed to process page {i}: {e}", exc_info=True) # Log traceback for page-level errors
            # Consider adding retry logic here for page loads if needed
        

finally:
    logging.info("Closing WebDriver.")
    driver.quit()

# --- Data Processing and Storage ---
if not all_product_data:
    logging.warning("No product data was collected. Exiting.")
    exit()

logging.info(f"Successfully collected data for {len(all_product_data)} products.")

# Create DataFrame
df = pd.DataFrame(all_product_data)
logging.info("DataFrame created:")
logging.info(df.head())
logging.info(f"DataFrame shape: {df.shape}")

# Connect to SQL Server and Insert Data
logging.info(f"Connecting to database '{database}' on server '{server}'...")
conn = None
cursor = None
try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    logging.info("Database connection successful.")

    # Drop and Create table (as per original logic)
    logging.info("Dropping existing table ST_MARCA_PRECO_KBM if it exists...")
    cursor.execute("""
    IF OBJECT_ID('ST_MARCA_PRECO_KBM', 'U') IS NOT NULL
        DROP TABLE ST_MARCA_PRECO_KBM;
    """)
    logging.info("Creating table ST_MARCA_PRECO_KBM...")
    cursor.execute("""
    CREATE TABLE ST_MARCA_PRECO_KBM (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        MARCA VARCHAR(255),
        PRECO DECIMAL(10,2)
    );
    """)
    conn.commit()
    logging.info("Table created successfully.")

    # Prepare data for executemany (list of tuples)
    data_to_insert = [tuple(row) for row in df[['marca', 'preco']].itertuples(index=False)]

    if data_to_insert:
        logging.info(f"Inserting {len(data_to_insert)} rows into the database...")
        sql_insert = "INSERT INTO ST_MARCA_PRECO_KBM (MARCA, PRECO) VALUES (?, ?)"
        cursor.executemany(sql_insert, data_to_insert)
        conn.commit()
        logging.info("Data insertion completed successfully.")
    else:
        logging.warning("No data available to insert into the database.")

except pyodbc.Error as ex:
    sqlstate = ex.args[0]
    logging.error(f"Database error (SQLSTATE: {sqlstate}): {ex}")
except Exception as e:
    logging.error(f"An error occurred during database operations: {e}", exc_info=True)
finally:
    if cursor:
        cursor.close()
        logging.info("Database cursor closed.")
    if conn:
        conn.close()
        logging.info("Database connection closed.")

logging.info("Script finished.")
# %%
