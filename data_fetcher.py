# data_fetcher.py

from pytube import YouTube
import os

# --- 1. Define the VOD Source (Example: A long match VOD URL) ---
# Replace this with an actual LoL Worlds VOD URL for a good match
YOUTUBE_URL = "https://www.youtube.com/watch?v=jaAldAYENU0" 

# Define the folder to save the raw text
TRANSCRIPT_DIR = "transcripts"
os.makedirs(TRANSCRIPT_DIR, exist_ok=True)

def fetch_transcript(video_url: str) -> str:
    """Downloads the raw English transcript for a YouTube video."""
    try:
        yt = YouTube(video_url)
        
        # Access the caption tracks
        captions = yt.caption_tracks
        
        # Find the English transcript (often 'en', 'a.en', or 'en-US')
        # We search keys like 'en', 'a.en', or just use the first available English track
        en_caption = None
        for track in captions:
            if 'en' in track.name.lower():
                en_caption = track
                break
        
        if not en_caption:
            print("ERROR: English transcript not found. Check VOD settings.")
            return ""

        # Fetch the transcript content (raw XML format)
        transcript_xml = en_caption.xml_captions

        # Simple cleaning: we only want the raw text blocks, not the XML tags/timestamps.
        # This cleaning step will be imperfect but provides the core raw text data.
        import re
        text_blocks = re.findall(r'">([^<]+)</text>', transcript_xml)
        
        # Join into a single block of text
        raw_text = " ".join(text_blocks)
        
        # Save the raw text
        file_path = os.path.join(TRANSCRIPT_DIR, "raw_match_transcript.txt")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(raw_text)
            
        print(f"\nSUCCESS: Transcript saved to {file_path}")
        print(f"First 100 characters: {raw_text[:100]}...")
        return file_path

    except Exception as e:
        print(f"\nFATAL ERROR during Pytube execution: {e}")
        return ""

if __name__ == "__main__":
    fetch_transcript(YOUTUBE_URL)