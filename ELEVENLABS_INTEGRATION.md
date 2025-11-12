# ElevenLabs Conversational AI Integration

## Overview
This app now uses ElevenLabs Conversational AI instead of Google Gemini for the chatbot feature.

## Configuration

**Agent ID:** `agent_9801k9j2cznxfc7ae9n3tfn835nd`  
**API Key:** `002beea61b08b362f6304d093a7e40adfb0aa3e9da6f6c482baf4a5e04816025`

## Features

### 1. **Conversation Memory**
- The agent maintains context across messages within the same conversation
- Conversation ID is stored and reused for all messages
- Agent remembers previous messages and can reference them

### 2. **Reset Conversation**
- Users can start a new conversation via the menu (⋮) button
- Resets conversation memory on the ElevenLabs side
- Clears local chat history

### 3. **API Implementation**

**File:** `lib/api/elevenlabs_api.dart`

Key methods:
- `getConversationId()` - Creates or retrieves existing conversation ID
- `sendMessage(String message)` - Sends message and gets response
- `resetConversation()` - Clears conversation memory
- `getConversationHistory()` - Retrieves conversation history (optional)

## How It Works

1. **Initialization:**
   - When chatbot opens, a conversation ID is created via ElevenLabs API
   - This ID is stored in memory for the session

2. **Sending Messages:**
   - User message is sent to ElevenLabs with the conversation ID
   - Agent processes the message with full context of previous messages
   - Response is returned and displayed

3. **Memory Management:**
   - Conversation ID persists during the app session
   - Tapping "New Conversation" resets the ID and clears memory
   - Each new conversation starts fresh

## API Endpoints Used

- **Create Conversation:** `POST /v1/convai/conversation`
- **Send Message:** `POST /v1/convai/conversation/{conversation_id}`
- **Get History:** `GET /v1/convai/conversation/{conversation_id}/history`

## Error Handling

- Network errors show user-friendly messages
- Failed API calls retry with error messages
- Conversation can be reset if issues occur

## Migration from Gemini

**Old:** Used Google Gemini API (`gemini_api.dart`)  
**New:** Uses ElevenLabs Conversational AI (`elevenlabs_api.dart`)

The chatbot UI remains the same, only the backend API changed.
