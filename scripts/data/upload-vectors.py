#!/usr/bin/env python3
"""
MediSafe-MAS v3 - Qdrant Vector Store Initialization Script
Uploads clinical guidelines and case data to Qdrant collections with embeddings from Ollama
"""

import json
import requests
import time
import sys
from typing import List, Dict, Any

# Configuration
OLLAMA_URL = "http://localhost:11434/api/embeddings"
QDRANT_URL = "http://localhost:6333"
EMBEDDING_MODEL = "nomic-embed-text:latest"

def check_services():
    """Verify Ollama and Qdrant are accessible"""
    print("🔍 Checking service availability...")
    
    # Check Ollama
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=5)
        if response.status_code == 200:
            print("✅ Ollama is running")
        else:
            print(f"⚠️  Ollama returned status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Ollama is not accessible: {e}")
        print("   Run: docker compose --profile cpu up -d")
        return False
    
    # Check Qdrant
    try:
        response = requests.get(f"{QDRANT_URL}/collections", timeout=5)
        if response.status_code == 200:
            print("✅ Qdrant is running")
        else:
            print(f"⚠️  Qdrant returned status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Qdrant is not accessible: {e}")
        print("   Run: docker compose up -d qdrant")
        return False
    
    return True

def get_embedding(text: str) -> List[float]:
    """Get embedding vector from Ollama for given text"""
    try:
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": EMBEDDING_MODEL,
                "prompt": text
            },
            timeout=30
        )
        response.raise_for_status()
        return response.json()["embedding"]
    except requests.exceptions.RequestException as e:
        print(f"❌ Error getting embedding: {e}")
        raise

def create_collection(collection_name: str, vector_size: int = 768):
    """Create Qdrant collection if it doesn't exist"""
    try:
        # Check if collection exists
        response = requests.get(f"{QDRANT_URL}/collections/{collection_name}")
        if response.status_code == 200:
            print(f"ℹ️  Collection '{collection_name}' already exists")
            return True
        
        # Create collection
        response = requests.put(
            f"{QDRANT_URL}/collections/{collection_name}",
            json={
                "vectors": {
                    "size": vector_size,
                    "distance": "Cosine"
                }
            }
        )
        response.raise_for_status()
        print(f"✅ Created collection '{collection_name}'")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Error creating collection '{collection_name}': {e}")
        return False

def upload_guidelines():
    """Upload clinical guidelines to Qdrant"""
    print("\n📚 Uploading clinical guidelines...")
    
    try:
        with open('data/guidelines/sample-guidelines.json', 'r', encoding='utf-8') as f:
            guidelines = json.load(f)
    except FileNotFoundError:
        print("❌ sample-guidelines.json not found")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing sample-guidelines.json: {e}")
        return False
    
    # Create collection
    if not create_collection("clinical_guidelines"):
        return False
    
    # Process each guideline
    points = []
    for idx, item in enumerate(guidelines, start=1):
        print(f"   Processing guideline {idx}/{len(guidelines)}: {item.get('guideline_id', 'N/A')}")
        
        try:
            embedding = get_embedding(item["text"])
            points.append({
                "id": idx,
                "vector": embedding,
                "payload": item
            })
            time.sleep(0.1)  # Rate limiting
        except Exception as e:
            print(f"   ⚠️  Failed to process guideline {idx}: {e}")
            continue
    
    # Upload to Qdrant
    if not points:
        print("❌ No guidelines to upload")
        return False
    
    try:
        response = requests.put(
            f"{QDRANT_URL}/collections/clinical_guidelines/points",
            json={"points": points}
        )
        response.raise_for_status()
        print(f"✅ Uploaded {len(points)} guidelines to Qdrant")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Error uploading guidelines: {e}")
        return False

def upload_cases():
    """Upload clinical cases to Qdrant"""
    print("\n🏥 Uploading clinical cases...")
    
    try:
        with open('data/cases/sample-cases.json', 'r', encoding='utf-8') as f:
            cases = json.load(f)
    except FileNotFoundError:
        print("❌ sample-cases.json not found")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing sample-cases.json: {e}")
        return False
    
    # Create collection
    if not create_collection("clinical_cases"):
        return False
    
    # Process each case
    points = []
    for idx, item in enumerate(cases, start=1):
        print(f"   Processing case {idx}/{len(cases)}: {item.get('diagnosis', 'N/A')}")
        
        try:
            embedding = get_embedding(item["text"])
            points.append({
                "id": idx,
                "vector": embedding,
                "payload": item
            })
            time.sleep(0.1)  # Rate limiting
        except Exception as e:
            print(f"   ⚠️  Failed to process case {idx}: {e}")
            continue
    
    # Upload to Qdrant
    if not points:
        print("❌ No cases to upload")
        return False
    
    try:
        response = requests.put(
            f"{QDRANT_URL}/collections/clinical_cases/points",
            json={"points": points}
        )
        response.raise_for_status()
        print(f"✅ Uploaded {len(points)} cases to Qdrant")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Error uploading cases: {e}")
        return False

def verify_collections():
    """Verify collections were created and populated"""
    print("\n🔍 Verifying collections...")
    
    collections = ["clinical_guidelines", "clinical_cases"]
    all_ok = True
    
    for collection_name in collections:
        try:
            response = requests.get(f"{QDRANT_URL}/collections/{collection_name}")
            response.raise_for_status()
            data = response.json()
            
            points_count = data.get("result", {}).get("points_count", 0)
            vectors_count = data.get("result", {}).get("vectors_count", 0)
            
            if points_count > 0:
                print(f"✅ {collection_name}: {points_count} points, {vectors_count} vectors")
            else:
                print(f"⚠️  {collection_name}: No data found")
                all_ok = False
        except requests.exceptions.RequestException as e:
            print(f"❌ Error verifying {collection_name}: {e}")
            all_ok = False
    
    return all_ok

def test_search():
    """Test vector search functionality"""
    print("\n🧪 Testing vector search...")
    
    test_query = "chest pain with elevated troponin"
    print(f"   Query: '{test_query}'")
    
    try:
        # Get embedding for query
        embedding = get_embedding(test_query)
        
        # Search clinical_guidelines
        response = requests.post(
            f"{QDRANT_URL}/collections/clinical_guidelines/points/search",
            json={
                "vector": embedding,
                "limit": 3,
                "with_payload": True
            }
        )
        response.raise_for_status()
        results = response.json().get("result", [])
        
        if results:
            print(f"✅ Found {len(results)} relevant guidelines:")
            for i, result in enumerate(results, 1):
                score = result.get("score", 0)
                guideline_id = result.get("payload", {}).get("guideline_id", "N/A")
                category = result.get("payload", {}).get("category", "N/A")
                print(f"   {i}. {guideline_id} ({category}) - Score: {score:.3f}")
        else:
            print("⚠️  No results found")
            return False
        
        return True
    except Exception as e:
        print(f"❌ Search test failed: {e}")
        return False

def main():
    """Main execution flow"""
    print("=" * 60)
    print("MediSafe-MAS v3 - Vector Store Initialization")
    print("=" * 60)
    
    # Check services
    if not check_services():
        print("\n❌ Service check failed. Please ensure Docker services are running.")
        sys.exit(1)
    
    # Upload data
    guidelines_ok = upload_guidelines()
    cases_ok = upload_cases()
    
    if not (guidelines_ok and cases_ok):
        print("\n⚠️  Some uploads failed. Check errors above.")
        sys.exit(1)
    
    # Verify
    if not verify_collections():
        print("\n⚠️  Collection verification failed.")
        sys.exit(1)
    
    # Test search
    if not test_search():
        print("\n⚠️  Search test failed.")
        sys.exit(1)
    
    print("\n" + "=" * 60)
    print("✅ Vector store initialization complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Open N8N at http://localhost:5678")
    print("2. Configure Qdrant credentials (URL: http://qdrant:6333)")
    print("3. Import MediSafe-MAS v3 workflow")
    print("4. Test the workflow with sample clinical input")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1)

