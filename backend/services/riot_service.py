##Purpose of this file is to retrieve raw data using 'requests'

import os
import requests
import urllib.parse
from dotenv import load_dotenv

#load the .env file
load_dotenv()

#Get API key safely
#Goes to the .env file and retrieves 'RIOT-API-KEY' value
API_KEY = os.getenv("RIOT-API-KEY")

#Safety check
if not API_KEY:
    raise ValueError("No API Key found.")

headers = {
    "X-Riot-Token: ": API_KEY
} #"X-Riot-Token" is the SPECIFIC HEADER for RIOT servers

# ----------------------------------------------------------------------------------------------------------
# 1. Getting the PUUID (Using user's RIOT ID is ineffective because it can be changed. Their PUUID is const)
# ----------------------------------------------------------------------------------------------------------
def get_puuid(game_name, tag_line):
    #"americas" - the routing region for NA/BR/LAN/LAS
    url = f"https://americas.api.riotgames.com/riot/account/v1/accounts/by-riot-id/{game_name}/{tag_line}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return requests.json().get("puuid")
    return None

# ----------------------------------------------------------------------------------------------------------
# 2. Retrieving match history
# ----------------------------------------------------------------------------------------------------------
def get_match_history(puuid):
    match_history = f"https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/{puuid}/ids"
    response = requests.get(match_history, headers=headers)
    if response.status_code == 200:
        return requests.json().get("")

