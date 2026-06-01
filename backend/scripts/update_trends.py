from datetime import datetime

import pandas as pd
from pytrends.request import TrendReq

from app.db.mongodb import db


def main() -> None:
    pytrends = TrendReq(hl="en-US", tz=420)
    kw_list = ["burnout", "depression", "anxiety"]

    pytrends.build_payload(kw_list, timeframe="today 3-m", geo="ID")
    trend_data = pytrends.interest_over_time()

    trend_data = trend_data.drop(labels=["isPartial"], axis="columns")
    trend_data = trend_data.reset_index()
    trend_data.columns = ["date", "burnout", "depression", "anxiety"]
    trend_data["api_updated_at"] = datetime.now()

    collection = db["weekly_trend"]
    records = trend_data.to_dict("records")

    collection.delete_many({})
    if records:
        collection.insert_many(records)

    print("Weekly trend berhasil diupdate")


if __name__ == "__main__":
    main()
