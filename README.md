# Tesla_analysis

A data pipeline for reading Tesla stock data with database integration and visualization.

## Features

- Automated data loading from MySQL
- Technical indicator calculations
- Candlestick visualization
- Daily/weekly aggregation

## Usage

all the necessary data_preprocess and feature_exteraction is already done in the phase of data_gathering
-you can look at the steps in the data_presentaion and final_data folders
-the data is vissible in the final_data_Data

you can run pipline by running the command "python3 ./pipline.py" or if it doesn't work "python ./pipeline.py"

the data gathered through the database is in folder data and its filtered by tables and also whole data joined