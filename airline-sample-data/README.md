# Airline Sample Data

This folder contains reference lookup tables, a download script, and a simple verification script for working with U.S. airline **On-Time Performance** data from the Bureau of Transportation Statistics (BTS).

## What’s in this folder

- **`data/`** – Static lookup/reference CSVs (`l_*.csv`) used to decode fields in the raw BTS On‑Time datasets. Examples include airline IDs, airport info, cancellation reasons, delay groups, months, weekdays, quarters, state/country codes, etc.
- **`download.sh`** – Bash script that downloads **2018** on‑time performance CSVs (all months) from BTS, unzips them, and moves them into `data/`.
- **`verify.py`** – Python script that verifies the integrity of the downloaded data against the `l_*.csv` lookup tables (e.g., checking that coded fields map to valid reference values).

## Folder structure

```
airline-sample-data/
├── data/
│   ├── l_airline_id.csv
│   ├── l_airport.csv
│   ├── l_airport_id.csv
│   ├── l_airport_seq_id.csv
│   ├── l_cancellation.csv
│   ├── l_carrier_history.csv
│   ├── l_city_market_id.csv
│   ├── l_deparrblk.csv
│   ├── l_distance_group_250.csv
│   ├── l_diversions.csv
│   ├── l_months.csv
│   ├── l_ontime_delay_groups.csv
│   ├── l_quarters.csv
│   ├── l_state_abr_aviation.csv
│   ├── l_state_fips.csv
│   ├── l_unique_carriers.csv
│   ├── l_weekdays.csv
│   ├── l_world_area_codes.csv
│   └── l_yesno_resp.csv
├── download.sh
└── verify.py
```

## Quick start


### 1) Download the 2018 on‑time data
```bash
./download.sh
```
**Important:** The current script is hard‑coded to 2018. If you pass any arguments, it will exit with a message saying only 2018 is verified. (Year/month parameters are not supported yet.)

Downloaded files are saved as:
```
data/On_Time_Reporting_Carrier_On_Time_Performance_2018_<month>.csv
# e.g., data/On_Time_Reporting_Carrier_On_Time_Performance_2018_1.csv
```

Data folder structure after running `download.sh`

```
data/
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_1.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_2.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_3.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_4.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_5.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_6.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_7.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_8.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_9.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_10.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_11.csv
├── On_Time_Reporting_Carrier_On_Time_Performance_2018_12.csv
├── l_airline_id.csv
├── l_airport.csv
├── l_airport_id.csv
├── l_airport_seq_id.csv
├── l_cancellation.csv
├── l_carrier_history.csv
├── l_city_market_id.csv
├── l_deparrblk.csv
├── l_distance_group_250.csv
├── l_diversions.csv
├── l_months.csv
├── l_ontime_delay_groups.csv
├── l_quarters.csv
├── l_state_abr_aviation.csv
├── l_state_fips.csv
├── l_unique_carriers.csv
├── l_weekdays.csv
├── l_world_area_codes.csv
└── l_yesno_resp.csv
```

### 2) Verify the downloads against lookup tables
```bash
python3 verify.py
```
This checks that coded fields in the downloaded CSVs correspond to values in the `l_*.csv` reference files.  
If all data matches the lookup references, you should see **all green** output.

## Requirements

- **Bash**, **wget**, **unzip** (for `download.sh`)
- **Python 3.x** (for `verify.py`)
  - requirements: `pandas`, `pathlib`.

## Data source & licensing

- Source: U.S. DOT **Bureau of Transportation Statistics (BTS)** – On‑Time Performance data.  
  See: https://transtats.bts.gov/
- U.S. Government data is generally public domain. Scripts in this repository are covered by the repo’s main license.

## Notes

- The verification workflow currently targets the 2018 files produced by `download.sh`.
- If BTS changes filenames/paths, you may need to update the pattern inside `download.sh`.
- The lookup tables in `data/` are intended to be relatively stable; treat them as authoritative for decoding fields.
