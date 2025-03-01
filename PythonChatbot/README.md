1.Create venv
    python -m venv venv
    venv\Scripts\activate
2. Install nessesary libraries
    pip install discord 
    pip install rasa
3. Code is integrated with Discord. You need to provide your token (powershell)
    $env:DISCORD_TOKEN="REPLACE_WITH_YOUR_TOKEN"
4. Start app
    python discord_bot.py
    rasa run actions
    rasa run
