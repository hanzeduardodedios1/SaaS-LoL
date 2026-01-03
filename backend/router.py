from services import riot_service
from fastapi import APIRouter

router = APIRouter()

@router.get("/player/{game_name}/{tag_line}")
def get_player_data(game_name: str, tag_line: str):

    #get PUUID
    puuid = riot_service.get_puiid(game_name, tag_line)