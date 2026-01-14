##Purpose of this file is to retrieve raw data using 'requests'

import os
import requests
import urllib.parse
from dotenv import load_dotenv
from pathlib import Path

#_________________________________________
#Find the API key
# 1. find this file
current_file = Path(__file__).resolve()

# 2. find 'backend' folder then look for .env
env_path = current_file.parent.parent/'.env'

# 3. Now we can open the file we're looking for
load_dotenv(dotenv_path=env_path)
#_________________________________________

#Get API key safely
#Goes to the .env file and retrieves 'RIOT-API-KEY' value
API_KEY = os.getenv("RIOT_API_KEY")

#Safety check
if not API_KEY:
    raise ValueError("No API Key found.")

headers = {
    "X-Riot-Token": API_KEY
} #"X-Riot-Token" is the SPECIFIC HEADER for RIOT servers

# ----------------------------------------------------------------------------------------------------------
# 1. Getting the PUUID (Using user's RIOT ID is ineffective because it can be changed. Their PUUID is const)
# ----------------------------------------------------------------------------------------------------------
def get_puuid(game_name, tag_line):
    #"americas" - the routing region for NA/BR/LAN/LAS
    url = f"https://americas.api.riotgames.com/riot/account/v1/accounts/by-riot-id/{game_name}/{tag_line}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json().get("puuid")
    return None

# ----------------------------------------------------------------------------------------------------------
# 2. Retrieving match history
# ----------------------------------------------------------------------------------------------------------
def get_match_history(puuid, count=5):
    ##retrieving 5 match_ids
    url = f"https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/{puuid}/ids?start=0&count={count}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    return []

# ----------------------------------------------------------------------------------------------------------
# 3. Retrieving match details
# ----------------------------------------------------------------------------------------------------------
def get_match_details(match_id):
    url = f"https://americas.api.riotgames.com/lol/match/v5/matches/{match_id}"
    response = requests.get(url, headers=headers)
    match_details = []
    if response.status_code == 200:
        return response.json()
    else:
        #DEBUGGING
        print("Error in finding details.")
        print(response)
        return None

# ----------------------------------------------------------------------------------------------------------
# 4. Retrieve latest game version
# ----------------------------------------------------------------------------------------------------------
def get_latest_version():
    url = 'https://ddragon.leagueoflegends.com/api/versions.json'
    response = response.get(url)
    if response.status_code == 200:
        return response.json()[0]
    return "14.1.1" #fallback



