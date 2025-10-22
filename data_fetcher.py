import yt_dlp
import os
#-- Core Libraries --


YOUTUBE_URL = "https://www.youtube.com/watch?v=jaAldAYENU0" 

TRANSCRIPT_DIR = "transcripts"
os.makedirs(TRANSCRIPT_DIR, exist_ok=True)

def fetch_transcript(video_url: str) -> str:
    """Downloads the raw English transcript for a YouTube video."""
    try:
        # Provides the format of downloading the VOD file, or settings. Downloads without the video file
        # We prioritize English subtitles and request the raw JSON format for easier parsing.
        ydl_opts = {
            'skip_download': True,
            'writesubtitles': True,
            'writeautomaticsub': True,
            'subtitleslangs': ['en'],
            'subtitlesformat': 'json3',
            'quiet': True,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            
            # Get subtitles
            if 'subtitles' in info and 'en' in info['subtitles']:
                sub_url = info['subtitles']['en'][0]['url']
            elif 'automatic_captions' in info and 'en' in info['automatic_captions']:
                sub_url = info['automatic_captions']['en'][0]['url']
            else:
                print("ERROR: No English subtitles found")
                return ""
            
            # Download subtitle content
            import requests
            response = requests.get(sub_url)
            import json
            subtitle_data = json.loads(response.text)
            
            # Extract text from JSON3 format
            text_blocks = []
            for event in subtitle_data.get('events', []):
                # This loop drills down into the nested list of segments within each event/timestamp
                if 'segs' in event:
                    for seg in event['segs']:
                        # The 'utf8' key holds the clean text string for the commentator speech
                        if 'utf8' in seg:
                            text_blocks.append(seg['utf8'])

            # Final Assembly: Convert list of short blocks into a single, clean text
            # This single string is the raw input needed for the RAG chunking process.
            raw_text = " ".join(text_blocks)
            
            # Save the raw text
            # This file is the foundation of the RAG Knowledge Base.
            file_path = os.path.join(TRANSCRIPT_DIR, "raw_match_transcript.txt")
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(raw_text)
                
            print(f"\nSUCCESS: Transcript saved to {file_path}")
            print(f"First 100 characters: {raw_text[:100]}...")
            return file_path

    except Exception as e:
        print(f"\nFATAL ERROR: {e}")
        return ""

if __name__ == "__main__":
    fetch_transcript(YOUTUBE_URL)