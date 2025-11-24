#!/usr/bin/env node
/**
 * Test ElevenLabs WebSocket Connection
 * This script tests the WebSocket connection to ElevenLabs Conversational AI
 */

const https = require('https');
const WebSocket = require('ws');

// ElevenLabs credentials
const AGENT_ID = "agent_9801k9j2cznxfc7ae9n3tfn835nd";
const API_KEY = "40254a8a0e10d078cd46eb2749eb5f9ec0ec43f14c1ba1e4854e529b24911dd6";

function getSignedUrl() {
    return new Promise((resolve, reject) => {
        console.log("Getting signed WebSocket URL...");
        
        const url = `https://api.elevenlabs.io/v1/convai/conversation/get_signed_url?agent_id=${AGENT_ID}`;
        
        const options = {
            method: 'GET',
            headers: {
                'xi-api-key': API_KEY
            }
        };
        
        https.get(url, options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                console.log(`Status: ${res.statusCode}`);
                
                if (res.statusCode === 200) {
                    const response = JSON.parse(data);
                    const signed_url = response.signed_url;
                    console.log(`✅ Got signed URL: ${signed_url.substring(0, 80)}...`);
                    resolve(signed_url);
                } else {
                    console.log(`❌ Error: ${data}`);
                    reject(new Error(data));
                }
            });
        }).on('error', reject);
    });
}

async function testWebSocket(signedUrl) {
    console.log("\n📡 Connecting to WebSocket...");
    
    return new Promise((resolve) => {
        const ws = new WebSocket(signedUrl);
        let messageCount = 0;
        
        ws.on('open', () => {
            console.log("✅ WebSocket connected!");
            
            // Send a test message
            const testMessage = {
                type: "user_message",
                text: "Hi"
            };
            
            console.log(`\n📤 Sending: ${JSON.stringify(testMessage)}`);
            ws.send(JSON.stringify(testMessage));
            
            console.log("\n📥 Waiting for responses...\n");
        });
        
        ws.on('message', (data) => {
            messageCount++;
            console.log(`--- Message ${messageCount} ---`);
            
            // Try to parse as JSON
            try {
                const parsed = JSON.parse(data.toString());
                console.log(`Type: ${typeof parsed}`);
                console.log(`Content: ${JSON.stringify(parsed, null, 2)}`);
                
                // Check for text response
                if (typeof parsed === 'object' && parsed !== null) {
                    if ('text' in parsed) {
                        console.log(`\n🎯 TEXT FOUND: ${parsed.text}`);
                    }
                    if ('type' in parsed) {
                        console.log(`📋 Message Type: ${parsed.type}`);
                    }
                }
            } catch (e) {
                // Not JSON, maybe binary audio data
                const buffer = Buffer.isBuffer(data) ? data : Buffer.from(data);
                console.log(`Binary data (length: ${buffer.length} bytes)`);
                console.log(`First 100 bytes: ${buffer.toString('utf-8', 0, Math.min(100, buffer.length))}`);
            }
            
            console.log();
            
            // Stop after receiving 10 messages
            if (messageCount >= 10) {
                console.log("Received 10 messages, closing connection...");
                ws.close();
            }
        });
        
        ws.on('error', (error) => {
            console.log(`❌ WebSocket error: ${error.message}`);
            ws.close();
        });
        
        ws.on('close', () => {
            console.log("\n✅ WebSocket closed!");
            console.log(`Total messages received: ${messageCount}`);
            resolve();
        });
        
        // Timeout after 15 seconds
        setTimeout(() => {
            if (ws.readyState === WebSocket.OPEN) {
                console.log("\n⏱️  Timeout - closing connection");
                ws.close();
            }
        }, 15000);
    });
}

async function main() {
    console.log("=".repeat(60));
    console.log("ElevenLabs WebSocket Test");
    console.log("=".repeat(60));
    
    try {
        // Step 1: Get signed URL
        const signedUrl = await getSignedUrl();
        
        // Step 2: Test WebSocket
        await testWebSocket(signedUrl);
        
    } catch (error) {
        console.error("❌ Test failed:", error.message);
    }
    
    console.log("\n" + "=".repeat(60));
    console.log("Test finished!");
    console.log("=".repeat(60));
}

main();
