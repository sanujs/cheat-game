from enum import Enum

class Rank(Enum):
    ACE = "A"
    TWO = "2"
    THREE = "3"
    FOUR = "4"
    FIVE = "5"
    SIX = "6"
    SEVEN = "7"
    EIGHT = "8"
    NINE = "9"
    TEN = "T"
    JACK = "J"
    QUEEN = "Q"
    KING = "K"

    def __str__(self):
        return self.value

# def from_string(string: str) -> Rank:
#     match ch:
#         case 'A':
#             return Rank.ACE
#         case '2':
#             return Rank.TWO
#         case '3':
#             return Rank.THREE
#         case '4':
#             return Rank.FOUR
#         case '5':
#             return Rank.FIVE
#         case '6':
#             return Rank.SIX
#         case '7':
#             return Rank.SEVEN
#         case '8':
#             return Rank.EIGHT
#         case '9':
#             return Rank.NINE
#         case 'T':
#             return Rank.TEN
#         case 'J':
#             return Rank.JACK
#         case 'Q':
#             return Rank.QUEEN
#         case 'K':
#             return Rank.KING
#         case _:
#             raise ValueError(f"{ch} does not represent a valid Card Rank")

# def to_string(rank: Rank) -> str:
#     """Converts a Rank to its single-character representation using match-case."""
#     match rank:
#         case Rank.ACE:
#             return 'A'
#         case Rank.TWO:
#             return '2'
#         case Rank.THREE:
#             return '3'
#         case Rank.FOUR:
#             return '4'
#         case Rank.FIVE:
#             return '5'
#         case Rank.SIX:
#             return '6'
#         case Rank.SEVEN:
#             return '7'
#         case Rank.EIGHT:
#             return '8'
#         case Rank.NINE:
#             return '9'
#         case Rank.TEN:
#             return '10'
#         case Rank.JACK:
#             return 'J'
#         case Rank.QUEEN:
#             return 'Q'
#         case Rank.KING:
#             return 'K'
#         case _:
#             raise ValueError(f"Unknown rank: {rank}")