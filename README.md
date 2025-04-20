 
# Scraping Kabum + SQL Server

Automatiza a coleta de dados de marcas e preços de teclados e mouses do Kabum.com.br e insere os resultados em uma tabela no SQL Server.

---

## 🎯 Funcionalidades

- Navegação headless com Selenium + ChromeDriver  
- Parsing de HTML com BeautifulSoup  
- Normalização de preços (R$, pontos e vírgulas)  
- Armazenamento temporário em pandas DataFrame  
- Criação dinâmica da tabela `ST_MARCA_PRECO_KBM` no SQL Server  
- Inserção de registros via pyodbc  
- Scripts separados para Python e SQL  

---

## 🛠 Tecnologias

- Python 3.x  
- Selenium  
- BeautifulSoup4  
- pandas  
- webdriver-manager  
- pyodbc  
- SQL Server  

---

## 🚀 Pré-requisitos

1. **Python 3.8+** instalado  
2. **SQL Server** acessível (local ou remoto)  
3. Permissões de criação e gravação no banco de dados  
4. Credenciais salvas em arquivo JSON (ex.: `credencial_banco_st.json`)  

---

## 🔧 Intalação

1. Clone este repositório:
   ```bash
   git clone https://github.com/MichaelCSPF/Web-Scrappy
