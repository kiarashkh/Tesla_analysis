USE tesla_stock_analysis;

SELECT * FROM datetime_dimension LIMIT 5;


-- Get the first 5 trading hours with price and volume
SELECT 
    d.datetime,
    p.open,
    p.high,
    p.low,
    p.close,
    v.volume
FROM 
    price_ohlc p
JOIN 
    datetime_dimension d ON p.datetime = d.datetime
JOIN 
    volume_metrics v ON p.datetime = v.datetime
ORDER BY 
    d.datetime ASC
LIMIT 5;


-- Find top 10 highest trading volume hours with RSI > 70 (overbought)
SELECT 
    d.datetime,
    d.day_name,
    p.close,
    v.volume,
    o.rsi
FROM 
    price_ohlc p
JOIN 
    datetime_dimension d ON p.datetime = d.datetime
JOIN 
    volume_metrics v ON p.datetime = v.datetime
JOIN 
    oscillators o ON p.datetime = o.datetime
WHERE 
    o.rsi > 70
ORDER BY 
    v.volume DESC
LIMIT 10;



-- Calculate average daily trading volume and price range
SELECT 
    DATE(d.datetime) AS trading_date,
    d.day_name,
    COUNT(*) AS hours_traded,
    AVG(v.volume) AS avg_hourly_volume,
    MAX(p.high) - MIN(p.low) AS daily_price_range,
    AVG(o.rsi) AS avg_rsi
FROM 
    price_ohlc p
JOIN 
    datetime_dimension d ON p.datetime = d.datetime
JOIN 
    volume_metrics v ON p.datetime = v.datetime
JOIN 
    oscillators o ON p.datetime = o.datetime
GROUP BY 
    trading_date, d.day_name
ORDER BY 
    trading_date DESC
LIMIT 5;



-- Find Bollinger Band breakouts with volume confirmation
SELECT 
    d.datetime,
    p.close,
    o.bollinger_upper,
    o.bollinger_lower,
    v.volume,
    CASE 
        WHEN p.close > o.bollinger_upper THEN 'Upper Breakout'
        WHEN p.close < o.bollinger_lower THEN 'Lower Breakout'
        ELSE 'Within Bands'
    END AS bollinger_status
FROM 
    price_ohlc p
JOIN 
    datetime_dimension d ON p.datetime = d.datetime
JOIN 
    oscillators o ON p.datetime = o.datetime
JOIN 
    volume_metrics v ON p.datetime = v.datetime
WHERE 
    (p.close > o.bollinger_upper OR p.close < o.bollinger_lower)
    AND v.volume > (SELECT AVG(volume) FROM volume_metrics)
ORDER BY 
    v.volume DESC;
    
    
    

-- Compare morning vs afternoon trading sessions
SELECT 
    CASE 
        WHEN HOUR(d.datetime) BETWEEN 9 AND 12 THEN 'Morning (9AM-12PM)'
        WHEN HOUR(d.datetime) BETWEEN 13 AND 16 THEN 'Afternoon (1PM-4PM)'
        ELSE 'Other Hours'
    END AS session,
    COUNT(*) AS observations,
    AVG(p.close - p.open) AS avg_price_change,
    AVG(v.volume) AS avg_volume,
    AVG(o.rsi) AS avg_rsi
FROM 
    price_ohlc p
JOIN 
    datetime_dimension d ON p.datetime = d.datetime
JOIN 
    volume_metrics v ON p.datetime = v.datetime
JOIN 
    oscillators o ON p.datetime = o.datetime
WHERE 
    d.is_weekend = FALSE
GROUP BY 
    session
ORDER BY 
    avg_volume DESC;
    


-- Find golden crosses (50MA crossing above 200MA)
WITH ma_data AS (
    SELECT 
        d.datetime,
        m.sma_50,
        m.sma_200,
        LAG(m.sma_50) OVER (ORDER BY d.datetime) AS prev_sma_50,
        LAG(m.sma_200) OVER (ORDER BY d.datetime) AS prev_sma_200
    FROM 
        moving_averages m
    JOIN 
        datetime_dimension d ON m.datetime = d.datetime
)
SELECT 
    datetime,
    sma_50,
    sma_200,
    'Golden Cross' AS signal_type
FROM 
    ma_data
WHERE 
    prev_sma_50 < prev_sma_200 AND sma_50 > sma_200;
    