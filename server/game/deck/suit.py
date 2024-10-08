from enum import Enum

class Suit(Enum):
    SPADES = "S"
    HEARTS = "H"
    CLUBS = "C"
    DIAMONDS = "D"

    def __str__(self):
        return self.value