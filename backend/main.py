from fastapi import FastAPI
from router import router #imports router.py
from fastapi.middleware.cors import CORSMiddleware #Allows browser connection between frontend and backend ports 

app = FastAPI()

#Connects logic within router.py onto the server
app.include_router(router)

#Enables browser to explicitly allow requests going between frontend and backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins (good for development)
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Server is running! Go to /docs to test."}

