from game.deck.card import Card

def strings_to_cards(strings: list[str]) -> list[Card]:
    cards: list[Card] = []
    for string in strings:
        cards.append(Card.from_str(string))
    return cards