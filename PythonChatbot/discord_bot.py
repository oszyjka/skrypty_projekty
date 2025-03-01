import requests
import os
import discord
from discord.ext import commands

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
RASA_SERVER_URL = "http://localhost:5005/webhooks/rest/webhook"

intents = discord.Intents.default()
intents.messages = True
intents.message_content = True  

bot = commands.Bot(command_prefix="!", intents=intents)

user_addresses = {}

@bot.event
async def on_ready():
    print(f' {bot.user} is online and ready!')

async def get_rasa_response(message):
    """Send message to Rasa server and get a response."""
    headers = {"Content-Type": "application/json"}
    payload = {"sender": "discord_user", "message": message}

    try:
        response = requests.post(RASA_SERVER_URL, json=payload, headers=headers)
        response.raise_for_status() 
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error sending message to Rasa: {e}")
        return [{"text": "Sorry, I encountered an error while processing your request. Please try again later."}]

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return 

    rasa_response = await get_rasa_response(message.content)

    for response in rasa_response:
        await message.channel.send(response.get("text", "Sorry, I couldn't understand that."))

    if "order_food" in [r.get("text", "").lower() for r in rasa_response]:
        await message.channel.send("Sure! What would you like to order?")

    elif "delivery_address" in [r.get("text", "").lower() for r in rasa_response]:
        await message.channel.send("Please provide your delivery address.")
        
        def check(msg):
            return msg.author == message.author and msg.channel == message.channel
        
        try:
            user_response = await bot.wait_for("message", check=check, timeout=60.0)
            user_addresses[message.author.id] = user_response.content
            await message.channel.send(f"Got it! Your order will be delivered to: {user_response.content}")
        except TimeoutError:
            await message.channel.send("You took too long to respond. Please provide your delivery address again.")

bot.run(DISCORD_TOKEN)