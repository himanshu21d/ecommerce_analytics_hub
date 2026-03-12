import duckdb
import os

# Connect to DuckDB - creates the file if it doesn't exist
conn = duckdb.connect('ecommerce.duckdb')

# Raw CSV files to load
raw_files = {
    'raw_orders': 'data/raw/olist_orders_dataset.csv',
    'raw_customers': 'data/raw/olist_customers_dataset.csv',
    'raw_order_items': 'data/raw/olist_order_items_dataset.csv',
    'raw_products': 'data/raw/olist_products_dataset.csv',
    'raw_sellers': 'data/raw/olist_sellers_dataset.csv',
    'raw_order_reviews': 'data/raw/olist_order_reviews_dataset.csv',
    'raw_order_payments': 'data/raw/olist_order_payments_dataset.csv',
}

for table_name, filepath in raw_files.items():
    if os.path.exists(filepath):
        conn.execute(f"""
            CREATE OR REPLACE TABLE {table_name} AS 
            SELECT * FROM read_csv_auto('{filepath}')
        """)
        count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"✅ Loaded {table_name}: {count:,} rows")
    else:
        print(f"❌ File not found: {filepath}")

conn.close()
print("\n🎉 All data loaded into ecommerce.duckdb!")