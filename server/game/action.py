from enum import Enum, auto

from game.deck.card import Card
from game.deck.rank import Rank

class Play:
    def __init__(self, cards: list[Card], player_uuid: str, rank: Rank) -> None:
        self.cards: list[Card] = cards
        self.player_uuid: str = player_uuid
        self.cheat: bool = not self.valid_play(rank)
        self.claimed_rank: Rank = rank
        print(f"{self.player_uuid} played {self.cards} while rank is {self.claimed_rank.name}. Cheating is {self.cheat}")
        print(f"{rank.name} is the round rank")


    def valid_play(self, rank: Rank) -> bool:
        return all(card.rank is rank for card in self.cards)

class Action(Enum):
    PASS = auto()
    CALL_CHEAT = auto()
    PLAY = auto()

