from game.deck.card import Card

def strings_to_cards(strings: list[str]) -> list[Card]:
    return [Card.from_str(card) for card in strings]