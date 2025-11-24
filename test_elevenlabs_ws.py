#!/usr/bin/env python3
"""
Test ElevenLabs WebSocket Connection
This script tests the WebSocket connection to ElevenLabs Conversational AI
"""

import asyncio
import json
import requests
import websockets

# ElevenLabs credentials
AGENT_ID = "agent_9801k9j2cznxfc7ae9n3tfn835nd"
API_KEY = "40254a8a0e10d078cd46eb2749eb5f9ec0ec43f14c1ba1e4854e529b24911dd6"

def get_signed_url():
    """Get signed WebSocket URL from ElevenLabs"""
    print("Getting signed WebSocket URL...")
    url = f"https://api.elevenlabs.io/v1/convai/conversation/get_signed_url?agent_id={AGENT_ID}"
    headers = {"xi-api-key": API_KEY}
    
    response = requests.get(url, headers=headers)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        signed_url = data.get("signed_url")
        print(f"✅ Got signed URL: {signed_url[:80]}...")
        return signed_url
    else:
        print(f"❌ Error: {response.text}")
        return None

async def test_websocket(signed_url):
    """Test WebSocket connection and message exchange"""
    print("\n📡 Connecting to WebSocket...")
    
    try:
        async with websockets.connect(signed_url) as websocket:
            print("✅ WebSocket connected!")
            
            # Send a test message
            test_message = {
                "type": "user_message",
                "text": "Hi"
            }
            print(f"\n📤 Sending: {json.dumps(test_message)}")
            await websocket.send(json.dumps(test_message))
            
            print("\n📥 Waiting for responses...\n")
            
            # Listen for responses (timeout after 10 seconds)
            try:
                async with asyncio.timeout(10):
                    message_count = 0
                    async for message in websocket:
                        message_count += 1
                        print(f"--- Message {message_count} ---")
                        
                        # Try to parse as JSON
                        try:
                            data = json.loads(message)
                            print(f"Type: {type(data)}")
                            print(f"Content: {json.dumps(data, indent=2)}")
                            
                            # Check for text response
                            if isinstance(data, dict):
                                if 'text' in data:
                                    print(f"\n🎯 TEXT FOUND: {data['text']}")
                                if 'type' in data:
                                    print(f"📋 Message Type: {data['type']}")
                                    
                        except json.JSONDecodeError:
                            # Not JSON, maybe binary audio data
                            print(f"Binary data (length: {len(message)} bytes)")
                            print(f"First 100 chars: {str(message[:100])}")
                        
                        print()
                        
                        # Stop after receiving 5 messages
                        if message_count >= 5:
                            print("Received 5 messages, stopping...")
                            break
                            
            except TimeoutError:
                print("⏱️  Timeout - no more messages received")
            
            print("\n✅ Test complete!")
            
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
        import traceback
        traceback.print_exc()

async def main():
    print("=" * 60)
    print("ElevenLabs WebSocket Test")
    print("=" * 60)
    
    # Step 1: Get signed URL
    signed_url = get_signed_url()
    
    if not signed_url:
        print("❌ Failed to get signed URL")
        return
    
    # Step 2: Test WebSocket
    await test_websocket(signed_url)
    
    print("\n" + "=" * 60)
    print("Test finished!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(main())
