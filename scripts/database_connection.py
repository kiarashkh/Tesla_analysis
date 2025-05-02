from sqlalchemy import create_engine, text

def create_db_connection():
    DB_USER = "root"        
    DB_PASSWORD = "6R.~7x}Vr-Kll*I(" 
    DB_HOST = "localhost"    
    DB_PORT = "3306"         
    DB_NAME = "tesla_stock_analysis"
    
    connection_string = (
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
        "?charset=utf8mb4"
    )
    
    try:
        engine = create_engine(connection_string)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1")) 
        print("✅ Database connection established successfully")
        return engine
    except Exception as e:
        print(f"❌ Error connecting to database: {e}")
        raise

if __name__ == "__main__":
    engine = create_db_connection()
    if engine:
        engine.dispose()