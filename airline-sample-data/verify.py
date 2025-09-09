import pandas as pd
from pathlib import Path
import sys

AIRLINES_FILE         = Path("data/l_airline_id.csv")
AIRPORTS_FILE         = Path("data/l_airport.csv")
AIRPORT_IDS_FILE      = Path("data/l_airport_id.csv")
AIRPORT_SEQ_IDS_FILE  = Path("data/l_airport_seq_id.csv")
CANCELLATION_FILE     = Path("data/l_cancellation.csv")
CARRIER_HIST_FILE     = Path("data/l_carrier_history.csv")
CITY_MARKET_FILE      = Path("data/l_city_market_id.csv")
DEPART_ARR_BLK_FILE   = Path("data/l_deparrblk.csv")
DIST_GROUP_FILE       = Path("data/l_distance_group_250.csv")
DIVERSIONS_FILE       = Path("data/l_diversions.csv")
MONTHS_FILE           = Path("data/l_months.csv")
ONTIME_GROUPS_FILE    = Path("data/l_ontime_delay_groups.csv")
QUARTERS_FILE         = Path("data/l_quarters.csv")
STATE_ABR_FILE        = Path("data/l_state_abr_aviation.csv")
STATE_FIPS_FILE       = Path("data/l_state_fips.csv")
UNIQUE_CARRIERS_FILE  = Path("data/l_unique_carriers.csv")
WEEKDAYS_FILE         = Path("data/l_weekdays.csv")
WAC_FILE              = Path("data/l_world_area_codes.csv")
YESNO_FILE            = Path("data/l_yesno_resp.csv")

def check_airline(flights: pd.DataFrame) -> set[int]:
    airlines_df = pd.read_csv(AIRLINES_FILE, usecols=["Code"], dtype={"Code": int})
    flight_codes = set(flights["DOT_ID_Reporting_Airline"].dropna().astype(int).unique())
    valid_codes  = set(airlines_df["Code"].astype(int).unique())
    missing = flight_codes - valid_codes
    print("✅ All DOT_ID_Reporting_Airline codes are present in l_airline_id.csv." if not missing
          else "❌ Missing DOT_ID_Reporting_Airline in l_airline_id.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_airport(flights: pd.DataFrame) -> set[str]:
    airports = pd.read_csv(AIRPORTS_FILE, usecols=["Code"], dtype={"Code": "string"})
    airports["Code"] = airports["Code"].str.strip().str.upper()
    origin = flights["Origin"].astype("string").str.strip().str.upper()
    dest   = flights["Dest"].astype("string").str.strip().str.upper()
    flight_airports = set(pd.concat([origin, dest]).dropna().unique())
    valid_airports  = set(airports["Code"].dropna().unique())
    missing = flight_airports - valid_airports
    print("✅ All Origin/Dest airport codes are present in l_airport.csv." if not missing
          else "❌ Missing airport codes (Origin/Dest) in l_airport.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_airport_id(flights: pd.DataFrame) -> set[int]:
    ids = pd.read_csv(AIRPORT_IDS_FILE, usecols=["Code"])
    ids["Code"] = pd.to_numeric(ids["Code"], errors="coerce").dropna().astype(int)
    o_ids = flights["OriginAirportID"].dropna().astype(int)
    d_ids = flights["DestAirportID"].dropna().astype(int)
    flight_ids = set(pd.concat([o_ids, d_ids]).unique())
    valid_ids  = set(ids["Code"].unique())
    missing = flight_ids - valid_ids
    print("✅ All Origin/Dest airport IDs are present in l_airport_id.csv." if not missing
          else "❌ Missing airport IDs (OriginAirportID/DestAirportID) in l_airport_id.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_airport_seq_id(flights: pd.DataFrame) -> set[int]:
    seq = pd.read_csv(AIRPORT_SEQ_IDS_FILE, usecols=["Code"])
    seq["Code"] = pd.to_numeric(seq["Code"], errors="coerce").dropna().astype(int)
    o_seq = flights["OriginAirportSeqID"].dropna().astype(int)
    d_seq = flights["DestAirportSeqID"].dropna().astype(int)
    flight_seq = set(pd.concat([o_seq, d_seq]).unique())
    valid_seq  = set(seq["Code"].unique())
    missing = flight_seq - valid_seq
    print("✅ All Origin/Dest airport sequence IDs are present in l_airport_seq_id.csv." if not missing
          else "❌ Missing airport sequence IDs in l_airport_seq_id.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_cancellation_codes(flights: pd.DataFrame) -> set[str]:
    canc = pd.read_csv(CANCELLATION_FILE, usecols=["Code"], dtype={"Code": "string"})
    valid = set(canc["Code"].dropna().str.strip().str.upper().unique())
    used  = set(flights.loc[flights["Cancelled"] == 1, "CancellationCode"]
                .dropna().astype("string").str.strip().str.upper().unique())
    missing = used - valid
    print("✅ All used cancellation codes exist in l_cancellation.csv (or no cancellations)." if not missing
          else "❌ Missing cancellation codes in l_cancellation.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_carrier_history(flights: pd.DataFrame) -> set[str]:
    ch = pd.read_csv(CARRIER_HIST_FILE)
    ch_codes = set(ch["Code"].astype("string").str.strip().str.upper().dropna().unique())

    flight_codes = set()
    for col in [c for c in ["Reporting_Airline", "IATA_CODE_Reporting_Airline", "UniqueCarrier",
                            "Operating_Airline", "Marketing_Airline_Network"] if c in flights.columns]:
        flight_codes |= set(flights[col].astype("string").str.strip().str.upper().dropna().unique())

    overlap = flight_codes & ch_codes
    if not overlap:
        print("ℹ️  No overlap between flight carrier codes and l_carrier_history codes (expected).")
        return set()

    missing = (flight_codes - ch_codes)
    print("✅ All used flight carrier codes are present in l_carrier_history.csv." if not missing
          else "❌ Carrier codes used in flights but missing in l_carrier_history.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_city_market_id(flights: pd.DataFrame) -> set[int]:
    cm = pd.read_csv(CITY_MARKET_FILE, usecols=["Code"])
    cm["Code"] = pd.to_numeric(cm["Code"], errors="coerce").dropna().astype(int)
    o_cm = flights["OriginCityMarketID"].dropna().astype(int)
    d_cm = flights["DestCityMarketID"].dropna().astype(int)
    flight_cm = set(pd.concat([o_cm, d_cm]).unique())
    valid_cm  = set(cm["Code"].unique())
    missing = flight_cm - valid_cm
    print("✅ All Origin/Dest CityMarketIDs are present in l_city_market_id.csv." if not missing
          else "❌ Missing city market IDs in l_city_market_id.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_deparrblk(flights: pd.DataFrame) -> set[str]:
    blk = pd.read_csv(DEPART_ARR_BLK_FILE, usecols=["Code"], dtype={"Code": "string"})
    valid = set(blk["Code"].dropna().str.strip().str.upper().unique())
    used  = set(pd.concat([
                flights.get("DepTimeBlk", pd.Series(dtype="string")),
                flights.get("ArrTimeBlk", pd.Series(dtype="string"))
            ]).dropna().astype("string").str.strip().str.upper().unique())
    missing = used - valid
    print("✅ All Dep/Arr time blocks exist in l_deparrblk.csv." if not missing
          else "❌ Missing Dep/Arr time blocks in l_deparrblk.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_distance_group(flights: pd.DataFrame) -> set[int]:
    dg = pd.read_csv(DIST_GROUP_FILE, usecols=["Code"])
    dg["Code"] = pd.to_numeric(dg["Code"], errors="coerce").dropna().astype(int)
    used = set(pd.to_numeric(flights.get("DistanceGroup", pd.Series(dtype="Int64")),
                             errors="coerce").dropna().astype(int).unique())
    valid = set(dg["Code"].unique())
    missing = used - valid
    print("✅ All DistanceGroup values exist in l_distance_group_250.csv." if not missing
          else "❌ Missing DistanceGroup values in l_distance_group_250.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_diversions(flights: pd.DataFrame) -> set[int]:
    dv = pd.read_csv(DIVERSIONS_FILE, usecols=["Code"])
    dv["Code"] = pd.to_numeric(dv["Code"], errors="coerce").dropna().astype(int)
    used = set(pd.to_numeric(flights.get("DivAirportLandings", pd.Series(dtype="Int64")),
                             errors="coerce").dropna().astype(int).unique())
    valid = set(dv["Code"].unique())
    missing = used - valid
    print("✅ All DivAirportLandings values exist in l_diversions.csv." if not missing
          else "❌ Missing DivAirportLandings values in l_diversions.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_months(flights: pd.DataFrame) -> set[int]:
    mo = pd.read_csv(MONTHS_FILE, usecols=["Code"])
    mo["Code"] = pd.to_numeric(mo["Code"], errors="coerce").dropna().astype(int)
    used = set(pd.to_numeric(flights.get("Month", pd.Series(dtype="Int64")),
                             errors="coerce").dropna().astype(int).unique())
    valid = set(mo["Code"].unique())
    missing = used - valid
    print("✅ All Month values exist in l_months.csv." if not missing
          else "❌ Missing Month values in l_months.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_ontime_groups(flights: pd.DataFrame) -> set[int]:
    og = pd.read_csv(ONTIME_GROUPS_FILE, usecols=["Code"])
    og["Code"] = pd.to_numeric(og["Code"], errors="coerce").dropna().astype(int)
    used = set(pd.concat([
                pd.to_numeric(flights.get("DepartureDelayGroups", pd.Series(dtype="Int64")), errors="coerce"),
                pd.to_numeric(flights.get("ArrivalDelayGroups",   pd.Series(dtype="Int64")), errors="coerce")
            ]).dropna().astype(int).unique())
    valid = set(og["Code"].unique())
    missing = used - valid
    print("✅ All Departure/ArrivalDelayGroups exist in l_ontime_delay_groups.csv." if not missing
          else "❌ Missing values for Departure/ArrivalDelayGroups in l_ontime_delay_groups.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_quarters(flights: pd.DataFrame) -> set[int]:
    qu = pd.read_csv(QUARTERS_FILE, usecols=["Code"])
    qu["Code"] = pd.to_numeric(qu["Code"], errors="coerce").dropna().astype(int)
    used = set(pd.to_numeric(flights.get("Quarter", pd.Series(dtype="Int64")),
                             errors="coerce").dropna().astype(int).unique())
    valid = set(qu["Code"].unique())
    missing = used - valid
    print("✅ All Quarter values exist in l_quarters.csv." if not missing
          else "❌ Missing Quarter values in l_quarters.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_state_abbrev(flights: pd.DataFrame) -> set[str]:
    st = pd.read_csv(STATE_ABR_FILE, usecols=["Code"], dtype={"Code": "string"})
    valid = set(st["Code"].dropna().str.strip().str.upper().unique())
    used = set(pd.concat([
        flights.get("OriginState", pd.Series(dtype="string")),
        flights.get("DestState",   pd.Series(dtype="string")),
    ]).dropna().str.strip().str.upper().unique())
    missing = used - valid
    print("✅ All Origin/Dest state abbreviations exist in l_state_abr_aviation.csv." if not missing
          else "❌ Missing state abbreviations in l_state_abr_aviation.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_state_fips(flights: pd.DataFrame) -> set[str]:
    # Keep leading zeros by reading as string
    sf = pd.read_csv(STATE_FIPS_FILE, usecols=["Code"], dtype={"Code": "string"})
    valid = set(sf["Code"].dropna().str.strip().unique())
    used = set(pd.concat([
        flights.get("OriginStateFips", pd.Series(dtype="string")),
        flights.get("DestStateFips",   pd.Series(dtype="string")),
    ]).dropna().astype(str).str.strip().unique())
    missing = used - valid
    print("✅ All Origin/Dest StateFIPS exist in l_state_fips.csv." if not missing
          else "❌ Missing StateFIPS in l_state_fips.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_unique_carriers(flights: pd.DataFrame) -> set[str]:
    uc = pd.read_csv(UNIQUE_CARRIERS_FILE)
    uc_codes = set(uc["Code"].astype("string").str.strip().str.upper().dropna().unique())

    # Try several possible flight columns that might contain these codes
    candidate_cols = [c for c in [
        "UniqueCarrier", "Operating_Airline", "Marketing_Airline_Network",
        "Reporting_Airline", "IATA_CODE_Reporting_Airline"
    ] if c in flights.columns]

    if not candidate_cols:
        print("ℹ️  No carrier code columns to compare with l_unique_carriers.csv; skipping.")
        return set()

    used = set()
    for col in candidate_cols:
        used |= set(flights[col].astype("string").str.strip().str.upper().dropna().unique())

    overlap = used & uc_codes
    if not overlap:
        print("ℹ️  No overlap between flight carrier codes and l_unique_carriers codes (often expected).")
        return set()

    missing = used - uc_codes
    print("✅ All used flight carrier codes are present in l_unique_carriers.csv." if not missing
          else "❌ Carrier codes used in flights but missing in l_unique_carriers.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_weekdays(flights: pd.DataFrame) -> set[int]:
    wd = pd.read_csv(WEEKDAYS_FILE)
    if "Code" not in wd.columns and "ode" in wd.columns:
        wd = wd.rename(columns={"ode": "Code"})
    wd["Code"] = pd.to_numeric(wd["Code"], errors="coerce").dropna().astype(int)
    valid = set(wd["Code"].unique())
    used = set(pd.to_numeric(flights.get("DayOfWeek", pd.Series(dtype="Int64")),
                             errors="coerce").dropna().astype(int).unique())
    missing = used - valid
    print("✅ All DayOfWeek values exist in l_weekdays.csv." if not missing
          else "❌ Missing DayOfWeek values in l_weekdays.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_wac(flights: pd.DataFrame) -> set[int]:
    wac = pd.read_csv(WAC_FILE, usecols=["Code"])
    wac["Code"] = pd.to_numeric(wac["Code"], errors="coerce").dropna().astype(int)
    valid = set(wac["Code"].unique())
    used = set(pd.concat([
        pd.to_numeric(flights.get("OriginWac", pd.Series(dtype="Int64")), errors="coerce"),
        pd.to_numeric(flights.get("DestWac",   pd.Series(dtype="Int64")), errors="coerce"),
    ]).dropna().astype(int).unique())
    missing = used - valid
    print("✅ All Origin/Dest WAC values exist in l_world_area_codes.csv." if not missing
          else "❌ Missing WAC values in l_world_area_codes.csv:")
    for v in sorted(missing): print(v)
    return missing

def check_yesno(flights: pd.DataFrame) -> set[int]:
    yn = pd.read_csv(YESNO_FILE, usecols=["Code"])
    yn["Code"] = pd.to_numeric(yn["Code"], errors="coerce").dropna().astype(int)
    valid = set(yn["Code"].unique())

    boolish_cols = [c for c in ["Cancelled","Diverted","DepDel15","ArrDel15"] if c in flights.columns]
    if not boolish_cols:
        print("ℹ️  No yes/no style columns found to validate; skipping.")
        return set()

    used_vals = set()
    for col in boolish_cols:
        used_vals |= set(pd.to_numeric(flights[col], errors="coerce").dropna().astype(int).unique())

    missing = used_vals - valid
    print("✅ All yes/no fields use values defined in l_yesno_resp.csv." if not missing
          else "❌ Unexpected values in yes/no fields (not in l_yesno_resp.csv):")
    for v in sorted(missing): print(v)
    return missing

def check():
    overall = {
        "airlines": set(), "airports": set(), "airport_ids": set(), "airport_seq_ids": set(),
        "cancellation": set(), "carrier_history": set(), "city_market": set(),
        "deparrblk": set(), "distance_group": set(), "diversions": set(),
        "months": set(), "ontime_groups": set(), "quarters": set(),
        "state_abbrev": set(), "state_fips": set(), "unique_carriers": set(),
        "weekdays": set(), "wac": set(), "yesno": set(),
    }

    for month in range(1, 13):  # 01..12
        flights_file = Path(f"data/On_Time_Reporting_Carrier_On_Time_Performance_2018_{month}.csv")
        if not flights_file.exists():
            print(f"⚠️  Skipping missing file: {flights_file}")
            continue

        print(f"\n=== Checking {flights_file.name} ===")
        usecols = [
            # calendar
            "Year","Quarter","Month","DayOfWeek",
            # airline
            "DOT_ID_Reporting_Airline","Reporting_Airline","IATA_CODE_Reporting_Airline",
            # airports + geo
            "Origin","Dest","OriginAirportID","DestAirportID",
            "OriginAirportSeqID","DestAirportSeqID","OriginCityMarketID","DestCityMarketID",
            "OriginState","DestState","OriginStateFips","DestStateFips","OriginWac","DestWac",
            # cancellations/diversions
            "Cancelled","CancellationCode","Diverted","DivAirportLandings","DepDel15","ArrDel15",
            # groups/blocks
            "DepTimeBlk","ArrTimeBlk","DistanceGroup",
            "DepartureDelayGroups","ArrivalDelayGroups",
        ]

        try:
            flights = pd.read_csv(
                flights_file,
                usecols=usecols,
                dtype={
                    "Year":"Int64","Quarter":"Int64","Month":"Int64","DayOfWeek":"Int64",
                    "DOT_ID_Reporting_Airline":"Int64",
                    "Reporting_Airline":"string","IATA_CODE_Reporting_Airline":"string",
                    "Origin":"string","Dest":"string",
                    "OriginAirportID":"Int64","DestAirportID":"Int64",
                    "OriginAirportSeqID":"Int64","DestAirportSeqID":"Int64",
                    "OriginCityMarketID":"Int64","DestCityMarketID":"Int64",
                    "OriginState":"string","DestState":"string",
                    "OriginStateFips":"string","DestStateFips":"string",
                    "OriginWac":"Int64","DestWac":"Int64",
                    "Cancelled":"Int64","CancellationCode":"string","Diverted":"Int64",
                    "DivAirportLandings":"Int64","DepDel15":"Int64","ArrDel15":"Int64",
                    "DepTimeBlk":"string","ArrTimeBlk":"string","DistanceGroup":"Int64",
                    "DepartureDelayGroups":"Int64","ArrivalDelayGroups":"Int64",
                },
                low_memory=False,
            )
        except ValueError:
            flights = pd.read_csv(flights_file, low_memory=False)
            for c in usecols:
                if c not in flights.columns:
                    flights[c] = pd.Series([pd.NA]*len(flights))
            flights = flights[usecols]

        overall["airlines"]        |= check_airline(flights)
        overall["airports"]        |= check_airport(flights)
        overall["airport_ids"]     |= check_airport_id(flights)
        overall["airport_seq_ids"] |= check_airport_seq_id(flights)
        overall["cancellation"]    |= check_cancellation_codes(flights)
        overall["carrier_history"] |= check_carrier_history(flights)
        overall["city_market"]     |= check_city_market_id(flights)
        overall["deparrblk"]       |= check_deparrblk(flights)
        overall["distance_group"]  |= check_distance_group(flights)
        overall["diversions"]      |= check_diversions(flights)
        overall["months"]          |= check_months(flights)
        overall["ontime_groups"]   |= check_ontime_groups(flights)
        overall["quarters"]        |= check_quarters(flights)
        overall["state_abbrev"]    |= check_state_abbrev(flights)
        overall["state_fips"]      |= check_state_fips(flights)
        overall["unique_carriers"] |= check_unique_carriers(flights)
        overall["weekdays"]        |= check_weekdays(flights)
        overall["wac"]             |= check_wac(flights)
        overall["yesno"]           |= check_yesno(flights)

    print("\n=== Overall Summary (2018) ===")
    any_missing = False
    for key, label in [
        ("airlines","Airline DOT IDs"),
        ("airports","Airport IATA codes"),
        ("airport_ids","Airport numeric IDs"),
        ("airport_seq_ids","Airport sequence IDs"),
        ("cancellation","Cancellation codes"),
        ("carrier_history","Carrier history codes"),
        ("city_market","CityMarketIDs"),
        ("deparrblk","Dep/Arr time blocks"),
        ("distance_group","DistanceGroup values"),
        ("diversions","DivAirportLandings values"),
        ("months","Month values"),
        ("ontime_groups","DelayGroups values"),
        ("quarters","Quarter values"),
        ("state_abbrev","State abbreviations"),
        ("state_fips","State FIPS"),
        ("unique_carriers","Unique carrier codes"),
        ("weekdays","DayOfWeek values"),
        ("wac","World Area Codes (WAC)"),
        ("yesno","Yes/No fields"),
    ]:
        missing = overall[key]
        if missing:
            any_missing = True
            print(f"❌ Missing {label}:")
            for v in sorted(missing): print(v)
        else:
            print(f"✅ No missing {label} across processed months.")

    # Uncomment to fail CI if anything missing
    # sys.exit(1 if any_missing else 0)

if __name__ == "__main__":
    check()
