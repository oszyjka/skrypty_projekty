import json
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

class ActionCheckHours(Action):
    def name(self):
        return "action_check_hours"

    def run(self, dispatcher, tracker, domain):
        with open("opening_hours.json", "r") as f:
            hours = json.load(f)["items"]

        dispatcher.utter_message("Our opening hours are:")
        for day, times in hours.items():
            dispatcher.utter_message(f"{day}: {times['open']} AM - {times['close']} PM")

        return []

class ActionListMenu(Action):
    def name(self):
        return "action_list_menu"

    def run(self, dispatcher, tracker, domain):
        with open("menu.json", "r") as f:
            menu = json.load(f)["items"]

        menu_items = ", ".join(item["name"] for item in menu)
        dispatcher.utter_message(f"We have {menu_items}. What would you like to order?")
        return []

class ActionConfirmAddress(Action):
    def name(self):
        return "action_confirm_address"

    def run(self, dispatcher, tracker, domain):
        user_address = tracker.get_slot("address")
        if user_address:
            dispatcher.utter_message(f"Thank you! Your order will be delivered to {user_address}.")
        else:
            dispatcher.utter_message("I need your delivery address to confirm the order.")
        return []
