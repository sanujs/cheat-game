from game.action import Action, Play
from game.deck.card import Card
from typing import Optional

from game.deck.rank import Rank
from game.deck.utils import strings_to_cards


class Player:
    def __init__(self, name: str, hand: list[Card] = None) -> None:
        self.name: str = name
        self.hand: list[Card] = hand

    def turn(self, round_rank: Optional[Rank]) -> Action | Play:
        # if round_rank == None, then this is the first turn of the round
        first_turn = not round_rank
        print(f"It is {self.name}'s turn")
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
                print(f"Round rank is {rank.name}")
            else:
                rank: Rank = round_rank
            return Play(self.remove_cards(strings_to_cards(card_list.split(" "))), self.name, rank)

        if action == "cheat":
            return Action.CALL_CHEAT

        return Action.PASS

    def remove_cards(self, cards: list[Card]) -> list[Card]:
        self.hand = [card for card in self.hand if card not in cards]
        return cards
