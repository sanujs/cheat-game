import json
from game.action import Action, Play
from game.deck.card import Card
from typing import Optional

from game.deck.rank import Rank
from game.deck.utils import strings_to_cards
from websockets.asyncio.server import ServerConnection


class Player:
    def __init__(self, uuid: str, websocket: ServerConnection) -> None:
        self.uuid: str = uuid
        self.hand: list[Card] = []
        self.connection: ServerConnection = websocket

    def turn(self, round_rank: Optional[Rank]) -> Action | Play:
        # if round_rank == None, then this is the first turn of the round
        first_turn = not round_rank
        print(f"It is {self.uuid}'s turn")
        print(f"Your hand: {self.hand}")

        if not first_turn:
            action: str = input(
                "What would you like to do? (pass/cheat/play):").strip()

        if first_turn or action == "play":
            card_list = input(
                "What cards would you like to play? (space separated list e.g. 8S 8H 8D):")
            print(f"{card_list}")
            print(f"{card_list.split(" ")}")
            if not round_rank:
                rank: Rank = Rank(input(
                    "What rank would you say these cards are? (single character e.g. 8):").strip())
                print(f"Round rank is {rank.uuid}")
            else:
                rank: Rank = round_rank
            return Play(self.remove_cards(strings_to_cards(card_list.split(" "))), self.uuid, rank)

        if action == "cheat":
            return Action.CALL_CHEAT

        return Action.PASS

    def remove_cards(self, cards: list[Card]) -> list[Card]:
        self.hand = [card for card in self.hand if card not in cards]
        return cards

    def hand_to_str(self):
        return [card.to_str() for card in self.hand]
