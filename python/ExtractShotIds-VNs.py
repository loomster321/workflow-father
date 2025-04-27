"""
Extract shot IDs from the 'shots_sequence' inside each 'parsed' object of the JSON array
in 'test-data/GenericParse-output.json'.
"""
import json
from pathlib import Path
from typing import List

def extract_shot_ids(json_path: str) -> List[str]:
    """Extract all shot_id values from shots_sequence in each parsed object."""
    shot_ids = []
    try:
        with open(json_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        for item in data:
            parsed = item.get('parsed', {})
            if isinstance(parsed, str):
                try:
                    parsed = json.loads(parsed)
                except json.JSONDecodeError:
                    continue  # skip if not valid JSON string
            if not isinstance(parsed, dict):
                continue
            shots_sequence = parsed.get('shots_sequence', [])
            for shot in shots_sequence:
                shot_id = shot.get('shot_id')
                if shot_id is not None:
                    shot_ids.append(shot_id)
    except (json.JSONDecodeError, OSError) as e:
        print(f"Error reading or parsing JSON: {e}")
    return shot_ids

def main() -> None:
    json_path = Path(__file__).parent.parent / 'test-data' / 'GenericParse-output.json'
    shot_ids = extract_shot_ids(str(json_path))
    print("Extracted shot IDs:")
    for shot_id in shot_ids:
        print(shot_id)

    # Save to file
    output_path = Path(__file__).parent.parent / 'test-data' / 'ExtractedShotIds.txt'
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            for shot_id in shot_ids:
                f.write(f"{shot_id}\n")
        print(f"\nShot IDs saved to {output_path}")
    except OSError as e:
        print(f"Error saving shot IDs: {e}")

if __name__ == "__main__":
    main()