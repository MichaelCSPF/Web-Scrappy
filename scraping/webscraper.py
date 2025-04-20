 
#%%
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import re
import time
import json
import math
import pandas as pd
import pyodbc

#%%
# Configurações do navegador
options = Options()
options.add_argument('--headless') 
options.add_argument('--disable-gpu')
options.add_argument('--window-size=1920x1080')

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# Caminho do JSON com credenciais
credencial_db = r'C:\Users\Michael\DW\DATA_MART_VENDAS\ETL_PYTHON\credencial_banco_st.json'

# Lê o arquivo JSON com credenciais
with open(credencial_db, 'r') as file:
    cred = json.load(file)

server = cred['server']
database = cred['database']
driver_sql = cred.get('driver', '{ODBC Driver 17 for SQL Server}')  # valor padrão

#%%
# Captura da quantidade de produtos
URL = r'https://www.kabum.com.br/perifericos/teclado-mouse'
driver.get(URL)
time.sleep(3)

bsp = BeautifulSoup(driver.page_source, 'html.parser')

div = bsp.find('div', id='listingCount')
if div:
    quantidade = div.b.get_text().strip()
    print(f"Quantidade de produtos: {quantidade}")
else:
    print("Elemento 'listingCount' não encontrado.")
    driver.quit()
    exit()

idx = quantidade.find(' ')
qtd = quantidade[:idx]
ultima_pag =  math.ceil(int(qtd)/100)

#%%
# Scraping dos produtos
dados = []

for i in range(1, ultima_pag + 1):
    url_pag = f'https://www.kabum.com.br/perifericos/teclado-mouse?page_number={i}&page_size=100&facet_filters=eyJjYXRlZ29yeSI6WyJQZXJpZsOpcmljb3MiXSwiaGlnaGxpZ2h0ZWRfZnJlZV9zaGlwcGluZyI6WyJ0cnVlIl19&sort='
    
    driver.get(url_pag)
    time.sleep(5)

    soup = BeautifulSoup(driver.page_source, 'html.parser')
    produtos = soup.find_all('div', class_=re.compile('p-\[2px\] rounded-4 group bg-white'))

    for produto in produtos:
        try:
            marca = produto.find('span', class_=re.compile('nameCard')).get_text().strip()
            preco = produto.find('span', class_=re.compile('priceCard')).get_text().strip()

            # Remove R$ e . dos preços, troca vírgula por ponto
            preco = preco.replace('R$', '').replace('.', '').replace(',', '.').strip()

            dados.append({'marca': marca, 'preco': float(preco)})

        except Exception as e:
            continue

driver.quit()

#%%
# Cria DataFrame
df = pd.DataFrame(dados)

#%%
# Conecta ao SQL Server
conn_str = f'DRIVER={driver_sql};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Cria tabela no banco
cursor.execute("""
IF OBJECT_ID('ST_MARCA_PRECO_KBM', 'U') IS NOT NULL
    DROP TABLE ST_MARCA_PRECO_KBM;

CREATE TABLE ST_MARCA_PRECO_KBM (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MARCA VARCHAR(255),
    PRECO DECIMAL(10,2)
);
""")
conn.commit()

# Insere os dados
for _, row in df.iterrows():
    cursor.execute("INSERT INTO ST_MARCA_PRECO_KBM (MARCA, PRECO) VALUES (?, ?)", row['marca'], row['preco'])

conn.commit()
cursor.close()
conn.close()
