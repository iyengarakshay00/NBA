"""
run via e.g. `python fga_by_player.py`

stores data as csv in your current directory
"""

import time

import pandas as pd
from nba_api.stats import endpoints


def clean_src_fga_df(df: pd.DataFrame) -> pd.Series:
    df = df.set_index("PLAYER_ID")
    data = df.FGA
    return data


if __name__ == "__main__":
    seasons = ["2017-18", "2018-19", "2019-20", "2020-21", "2021-22"]

    player_seasonal_fga = []
    for season in seasons:
        reg_season = endpoints.LeagueDashPlayerPtShot(
            per_mode_simple="Totals",
            season=season,
            season_type_all_star="Regular Season",
        ).get_data_frames()[0]
        reg_season = clean_src_fga_df(reg_season)
        time.sleep(1)  # avoid getting blocked by NBA

        playoffs = endpoints.LeagueDashPlayerPtShot(
            per_mode_simple="Totals", season=season, season_type_all_star="Playoffs"
        ).get_data_frames()[0]
        playoffs = clean_src_fga_df(playoffs)
        time.sleep(1)  # avoid getting blocked by NBA

        full = reg_season.add(playoffs, fill_value=0)
        full = full.to_frame().reset_index().assign(season=season)
        player_seasonal_fga.append(full)

    player_seasonal_fga = pd.concat(player_seasonal_fga, ignore_index=True)
    player_seasonal_fga.to_csv("fga_by_player_2017-22.csv", index=False)
