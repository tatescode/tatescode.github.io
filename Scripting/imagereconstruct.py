import os # For file/dir operations
from PIL import Image # For image handling
import numpy as np # For numerical operations
from pathlib import Path # For path handling

def load_shreds(directory):
    """Load all jpg images from directory"""
    shreds = [] # Creates an empty list to store image pieces
    # Loops through each file in the directory
    for filename in os.listdir(directory):  
        if filename.endswith('.jpg'): # Only jpg files (added this in case I have a dir full of different file types)
            path = os.path.join(directory, filename) # Create full filepath
            img = Image.open(path) # Opens image and then converts to numpy array and stores
            shreds.append(np.array(img))
    return shreds

def compare_edges(strip1, strip2):
    """Compare right edge of strip1 with left edge of strip2"""
    edge1 = strip1[:, -1]  # right edge
    edge2 = strip2[:, 0]   # left edge
    
    # Calculate difference between edges
    diff = np.sum(np.abs(edge1 - edge2))
    return diff

def reconstruct_image(shreds):
    """Try to reconstruct image by matching edges"""
    used = set()
    result = []
    current = 0  # Start with first shred
    
    while len(used) < len(shreds):
        used.add(current)
        result.append(shreds[current])
        
        if len(used) == len(shreds):
            break
            
        # Find best matching edge among unused pieces
        best_match = None
        best_score = float('inf')
        
        for i in range(len(shreds)):
            if i not in used:
                score = compare_edges(shreds[current], shreds[i])
                if score < best_score:
                    best_score = score
                    best_match = i
        
        current = best_match
    
    # Concatenate all pieces
    return np.concatenate(result, axis=1)

def main():
    # Get directory containing shreds
    directory = input("Enter directory path containing shredded images: ")
    
    # Load all shreds
    print("Loading shreds...")
    shreds = load_shreds(directory)
    
    if not shreds:
        print("No jpg files found in directory!")
        return
        
    print(f"Loaded {len(shreds)} shreds")
    
    # Attempt reconstruction
    print("Attempting reconstruction...")
    reconstructed = reconstruct_image(shreds)
    
    # Save result
    output = Image.fromarray(reconstructed)
    output.save("reconstructed.jpg")
    print("Saved reconstructed image as 'reconstructed.jpg'")

if __name__ == "__main__":
    main()
