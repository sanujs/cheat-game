from game.deck.rank import Rank
from game.deck.suit import Suit

class Card:
    def __init__(self, rank: Rank, suit: Suit):
        self.rank: Rank = rank
        self.suit: Suit = suit
    
    def __str__(self) -> str:
        return f"{self.rank}{self.suit}"

    def __repr__(self) -> str:
        # return f"Card({self.rank.name} of {self.suit.name})"
        return f"{self.rank}{self.suit}"

    def __eq__(self, other) -> bool:
        return self.rank is other.rank and self.suit is other.suit

    def from_str(string: str):
        if len(string) != 2:
            raise ValueError(f"Invalid string: {string}")
        return Card(Rank(string[0]), Suit(string[1]))

    def to_str(self):
        return f"{self.rank}{self.suit}"
