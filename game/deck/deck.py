from deck.card import Card
from deck.rank import Rank
from deck.suit import Suit
import random

class Deck:
    all_cards: list[Card] = []
    for s in Suit:
        for r in Rank:
            all_cards.append(Card(r, s))

    def __init__(self) -> None:
        self.cards: list[Card] = self.all_cards
        self.dealt_cards = []

    def shuffle(self) -> None:
        random.shuffle(self.cards)

    def deal_one(self) -> Card:
        top_card = self.cards.pop()
        self.dealt_cards.append(top_card)
        return top_card

    def deal(self, num_cards: int) -> list[Card]:
        result = []
        for _ in range(min(num_cards, len(self.cards))):
            result.append(self.deal_one())
        return result
