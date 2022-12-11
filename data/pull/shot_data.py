"""
run via e.g. `python shot_data.py`

stores data as csv in your current directory
"""

import time

import pandas as pd
from nba_api.stats import endpoints


def get_top_players(season: str) -> pd.DataFrame:
    all_players = endpoints.CommonAllPlayers(
        is_only_current_season=0, season=season
    ).get_data_frames()[0][["PERSON_ID", "TEAM_CITY", "TEAM_NAME"]]
    time.sleep(1)  # avoid getting blocked by NBA

    player_stats = endpoints.LeagueDashPlayerPtShot(
        per_mode_simple="Totals", season=season, season_type_all_star="Regular Season"
    ).get_data_frames()[0]
    time.sleep(1)  # avoid getting blocked by NBA

    player_stats = player_stats.merge(
        all_players, how="left", left_on="PLAYER_ID", right_on="PERSON_ID"
    )
    players_by_fga = player_stats.sort_values(by="FGA", ascending=False)

    players_by_fga["team_name"] = (
        players_by_fga.TEAM_CITY + " " + players_by_fga.TEAM_NAME
    )
    players_by_fga = players_by_fga[
        ["PLAYER_ID", "PLAYER_NAME", "PLAYER_LAST_TEAM_ID", "FGA", "team_name"]
    ]
    players_by_fga = players_by_fga.rename(columns={"PLAYER_LAST_TEAM_ID": "team_id"})
    players_by_fga.columns = [c.lower() for c in players_by_fga.columns]
    return players_by_fga


def get_player_shots(
    player_id: int, team_id: int, season: str, retry: int = 3
) -> pd.DataFrame:
    try:
        regular_season = endpoints.ShotChartDetail(
            player_id=player_id,
            team_id=team_id,
            season_nullable=season,
            context_measure_simple="FGA",
            season_type_all_star="Regular Season",
        ).get_data_frames()[0]
        time.sleep(1)  # avoid getting blocked by NBA
        regular_season["season_part"] = "regular"

        playoffs = endpoints.ShotChartDetail(
            player_id=player_id,
            team_id=team_id,
            season_nullable=season,
            context_measure_simple="FGA",
            season_type_all_star="Playoffs",
        ).get_data_frames()[0]
        time.sleep(1)  # avoid getting blocked by NBA
        playoffs["season_part"] = "playoffs"

        shots = pd.concat([regular_season, playoffs], ignore_index=True)
        shots["season"] = season
        return shots
    except Exception as e:
        if retry > 0:  # allow retries to resolve transient http errors
            time.sleep(5)
            return get_player_shots(player_id, team_id, season, retry - 1)
        else:
            print(f"Out of retries for {player_id}/{team_id}/{season}")
            return pd.DataFrame()  # else skip to avoid breaking entire script


def clean_shots_df(shots: pd.DataFrame) -> pd.DataFrame:
    shots = shots.copy()
    shots = shots[
        [
            "player_name",
            "PLAYER_ID",
            "team_name",
            "TEAM_ID",
            "PERIOD",
            "SHOT_TYPE",
            "SHOT_ZONE_RANGE",
            "SHOT_DISTANCE",
            "LOC_X",
            "LOC_Y",
            "SHOT_MADE_FLAG",
            "GAME_DATE",
            "season_part",
            "season",
        ]
    ]
    shots.SHOT_MADE_FLAG = shots.SHOT_MADE_FLAG.astype(bool)
    shots.GAME_DATE = pd.to_datetime(shots.GAME_DATE).dt.strftime("%Y-%m-%d")
    shots.columns = [c.lower() for c in shots.columns]
    return shots


if __name__ == "__main__":
    seasons = ["2017-18", "2018-19", "2019-20", "2020-21", "2021-22"]
    all_shots = []
    for season in seasons:
        season_players = get_top_players(season).iloc[:100].reset_index(drop=True)
        season_shots = []
        for idx, row in season_players.iterrows():
            if idx % 20 == 0:
                print(f"At player {idx}")
            season_shots.append(get_player_shots(row.player_id, row.team_id, season))
        season_shots = pd.concat(season_shots, ignore_index=True)
        season_shots = season_shots.merge(
            season_players[["player_id", "player_name", "team_name"]],
            left_on="PLAYER_ID",
            right_on="player_id",
        )
        all_shots.append(season_shots)
        print(f"Finished season {season}")

    all_shots = pd.concat(all_shots, ignore_index=True)
    all_shots = clean_shots_df(all_shots)
    all_shots.to_csv("shot_data_2017-2022.csv", index=False)
