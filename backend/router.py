from services import riot_service
from fastapi import APIRouter

router = APIRouter()
#This file will handle everything after the user inputs their username and tagline

@router.get("/player/{game_name}/{tag_line}")
def get_player_data(game_name: str, tag_line: str):

    #get PUUID
    puuid = riot_service.get_puuid(game_name, tag_line)
    #get match_history
    match_history = riot_service.get_match_history(puuid)
    
    #Place useful data here
    filtered_analysis = []

    #get match details
    for match_id in match_history:
        raw_data = riot_service.get_match_details(match_id)
        if raw_data:
            #shortcut to 'info'
            info = raw_data.get('info', {})

            #DATA FILTERING: ranked games & no remakes ONLY (no ARAM because this is for professional analysis)
            #queueId = 420 is 5v5 Ranked Solo/Duo
            if info.get('queueId') != 420:
                continue #skipping current iteration onto the next match
            
            #Skip iteration if match is less than 4 minutes (a remake)
            if info.get('gameDuration') < 240:
                continue

            #Find our user within the list of matches
            participants = info.get('participants', []) #Returns empty [] if missing
            target_player = None

            for participant in participants:
                if participant.get('puuid') == puuid:
                    target_player = participant
                    break #Player found, break the loop

            if target_player:
                #add minion kills and jungle kills for total cs
                creep_score = target_player.get('totalMinionsKilled') + target_player.get('neutralMinionsKilled')

                filtered_stats = {
                    'match_id': match_id,
                    'champion': target_player.get('championName'),
                    'win': target_player.get('win'),

                    #Economy
                    'gold_earned': target_player.get('goldEarned'),
                    'gold_spent': target_player.get('goldSpent'),
                    'cs': creep_score,

                    #Player's Items
                    'Items': [
                        target_player.get('item0'),
                        target_player.get('item1'),
                        target_player.get('item2'),
                        target_player.get('item3'),
                        target_player.get('item4'),
                        target_player.get('item5'),
                        target_player.get('item6'), #Ward
                    ]
                }
            filtered_analysis.append(filtered_stats)
    return filtered_analysis



#SHOULD CONTAIN USEFUL DETAILS ONLY
#-----------------------------------------------
# 1. Build & Economy
#   -item0 - item6
#   -goldEarned
#   -goldSpent
#   -totalMinionsKilled + neutralMinionsKilled = CS
#----------------------------------------------- 

#shortcut to participant list
