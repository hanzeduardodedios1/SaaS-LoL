## System Architecture

```mermaid
---
config:
      theme: redux
---
flowchart LR
    %%Frontend
    User((User))-->|User Login|UI
    subgraph Frontend["Frontend (Flutter App)"]
        direction TB
        UI[UI / Screens]
        Auth["User Auth (Firebase)"]     
    end
    UI-->|FastAPI|Backend
    U

    %%Backend
    subgraph Backend["Backend (FastAPI)"]
        direction TB
        
        %%Router and Authentication
        RouterAuth["Router and Auth"]
        RouterAuth-->Services

        %%After authorization, user can now access services
        subgraph Services[Services]
            direction TB
            %%1. Riot Games API -- game stats and information
            RiotGamesAPI["Riot Games API"]

            %%2. RAG -- Information Retrieval Logic
            RAG["RAG Service"]

            %%3. Youtube API and services
            Youtube["Youtube"] 
        end
    end

    %%Database
    subgraph Database["Supabase Cloud"]
        SupabaseDB[(Supabase DB)]
    end
    %%Connect services with database
    RAG-->|FastAPI|SupabaseDB
    Youtube-->|FastAPI|SupabaseDB
    RiotGamesAPI-->|FastAPI|SupabaseDB

