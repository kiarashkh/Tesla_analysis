import pandas as pd
from database_connection import create_db_connection
import os
from datetime import datetime

def load_individual_tables(engine):
    tables = {
        "datetime": "datetime_dimension",
        "prices": "price_ohlc", 
        "volume": "volume_metrics",
        "moving_avgs": "moving_averages",
        "indicators": "oscillators"
    }
    
    data = {}
    try:
        with engine.connect() as conn:
            for key, table in tables.items():
                query = f"SELECT * FROM {table}"
                data[key] = pd.read_sql(query, conn)
                print(f"{datetime.now().strftime('%H:%M:%S')} - Loaded {len(data[key]):,} rows from {table}")
        return data
    except Exception as e:
        print(f"Error loading individual tables: {e}")
        raise

def load_joined_data(engine):
    with engine.connect() as conn:
        price_cols = pd.read_sql("SHOW COLUMNS FROM price_ohlc", conn)['Field'].tolist()
        volume_cols = pd.read_sql("SHOW COLUMNS FROM volume_metrics", conn)['Field'].tolist()
        ma_cols = pd.read_sql("SHOW COLUMNS FROM moving_averages", conn)['Field'].tolist()
        osc_cols = pd.read_sql("SHOW COLUMNS FROM oscillators", conn)['Field'].tolist()
    
    select_parts = [
        "d.*",
        ", ".join(f"p.{col}" for col in price_cols if col != "datetime"),
        ", ".join(f"v.{col}" for col in volume_cols if col != "datetime"), 
        ", ".join(f"m.{col}" for col in ma_cols if col != "datetime"),
        ", ".join(f"o.{col}" for col in osc_cols if col != "datetime")
    ]
    
    join_query = f"""
    SELECT 
        {', '.join(select_parts)}
    FROM 
        datetime_dimension d
    JOIN price_ohlc p ON d.datetime = p.datetime
    JOIN volume_metrics v ON d.datetime = v.datetime
    JOIN moving_averages m ON d.datetime = m.datetime
    JOIN oscillators o ON d.datetime = o.datetime
    ORDER BY d.datetime
    """
    
    try:
        with engine.connect() as conn:
            start_time = datetime.now()
            df = pd.read_sql(join_query, conn)
            duration = (datetime.now() - start_time).total_seconds()
            print(f"{datetime.now().strftime('%H:%M:%S')} - Loaded joined data ({len(df):,} rows, {duration:.2f}s)")
            return df
    except Exception as e:
        print(f"Error loading joined data: {e}")
        raise

def save_data(data, output_dir="data"):
    os.makedirs(output_dir, exist_ok=True)
    
    if isinstance(data, dict):
        # Save individual tables
        for name, df in data.items():
            filepath = f"{output_dir}/individual/{name}_data.csv"
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            df.to_csv(filepath, index=False)
            print(f"Saved {filepath}")
    else:
        # Save joined dataframe
        filepath = f"{output_dir}/joined/full_dataset.csv"
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        data.to_csv(filepath, index=False)
        print(f"Saved comprehensive dataset to {filepath}")

def main():
    engine = create_db_connection()
    
    if not engine:
        return
    
    try:
        individual_data = load_individual_tables(engine)
        save_data(individual_data)
        
        joined_data = load_joined_data(engine)
        save_data(joined_data)
        
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")
    finally:
        engine.dispose()

if __name__ == "__main__":
    main()