CREATE DATABASE tesla_stock_analysis;
USE tesla_stock_analysis;

CREATE TABLE datetime_dimension (
    datetime DATETIME PRIMARY KEY,
    day_of_week TINYINT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    month TINYINT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    month_abbr CHAR(3) NOT NULL,
    season VARCHAR(10) NOT NULL,
    day_sin FLOAT NOT NULL,
    day_cos FLOAT NOT NULL,
    INDEX (day_of_week),
    INDEX (month),
    INDEX (season)
);

CREATE TABLE price_ohlc (
    datetime DATETIME PRIMARY KEY,
    open DECIMAL(12,6) NOT NULL,
    high DECIMAL(12,6) NOT NULL,
    low DECIMAL(12,6) NOT NULL,
    close DECIMAL(12,6) NOT NULL,
    FOREIGN KEY (datetime) REFERENCES datetime_dimension(datetime),
    INDEX (close)
);

CREATE TABLE volume_metrics (
    datetime DATETIME PRIMARY KEY,
    volume BIGINT NOT NULL,
    vwap DECIMAL(12,6) NOT NULL,
    obv BIGINT NOT NULL,
    cumulative_return DECIMAL(12,6) NOT NULL,
    FOREIGN KEY (datetime) REFERENCES datetime_dimension(datetime),
    INDEX (volume)
);

CREATE TABLE moving_averages (
    datetime DATETIME PRIMARY KEY,
    sma_5 DECIMAL(12,6) NOT NULL,
    sma_20 DECIMAL(12,6) NOT NULL,
    sma_50 DECIMAL(12,6) NOT NULL,
    sma_200 DECIMAL(12,6) NOT NULL,
    ema_5 DECIMAL(12,6) NOT NULL,
    ema_20 DECIMAL(12,6) NOT NULL,
    ema_50 DECIMAL(12,6) NOT NULL,
    ema_200 DECIMAL(12,6) NOT NULL,
    FOREIGN KEY (datetime) REFERENCES datetime_dimension(datetime)
);

CREATE TABLE oscillators (
    datetime DATETIME PRIMARY KEY,
    rsi DECIMAL(12,6) NOT NULL,
    atr DECIMAL(12,6) NOT NULL,
    macd DECIMAL(12,6) NOT NULL,
    macd_signal DECIMAL(12,6) NOT NULL,
    bollinger_upper DECIMAL(12,6) NOT NULL,
    bollinger_mid DECIMAL(12,6) NOT NULL,
    bollinger_lower DECIMAL(12,6) NOT NULL,
    FOREIGN KEY (datetime) REFERENCES datetime_dimension(datetime)
);