from itertools import cycle, islice
from typing import Optional
from game.action import Play
from game.deck.deck import Deck, Card
from game.deck.rank import Rank
from game.deck.utils import strings_to_cards
from game.player import Player
from websockets.asyncio.server import ServerConnection
from uuid import uuid4
from random import choice


class CheatGame:
    def __init__(self):
        self.deck = Deck()
        self.deck.shuffle()
        self.players: dict[str, Player] = {}

        self.active_pile: list[Card] = []
        self.out_pile: list[Card] = []
        self.discard_pile: list[Card] = []

        self.last_play: Optional[Play] = None
        self.starting_player: Optional[Player] = None
        self.current_turn_player: Optional[Player] = None
        self.pass_count: int = 0
        self.player_iterable = []

        self.almost_winner: Optional[str] = None

    def start_game(self) -> None:
        num_players = len(self.players)
        self.starting_player = choice(list(self.players.values()))
        for player in self.players.values():
            player.hand = self.deck.deal(52 // num_players)
        if remaining_cards := len(self.deck.cards) > 0:
            self.discard_pile = self.deck.deal(remaining_cards)
        self.player_iterable = islice(
            cycle(self.players.values()),
            list(self.players.values()).index(self.starting_player),
            None,
        )
        self.next_turn()

    def create_player(self, connection: ServerConnection) -> str:
        uuid: str = str(uuid4())
        self.players[uuid] = Player(uuid, connection)
        return uuid

    def next_turn(self) -> Player:
        self.current_turn_player = next(self.player_iterable)
        return self.current_turn_player

    def call_cheat(self, accuser_uuid: str) -> Player:
        accuser: Player = self.players[accuser_uuid]
        accused: Player = self.players[self.last_play.player_uuid]
        if self.last_play.cheat:
            # The accuser correctly identified the cheating play
            self.starting_player = accuser
            accused.hand.extend(self.active_pile)
            self.active_pile = []
            self.end_round()
            return accused
        else:
            # The accused was not cheating
            self.starting_player = accused
            accuser.hand.extend(self.active_pile)
            self.active_pile = []
            self.end_round()
            return accuser

    def play_turn(self, uuid: str, cards: list[str], round_rank: Rank) -> None:
        played_cards: list[Card] = self.players[uuid].remove_cards(
            strings_to_cards(cards)
        )
        if len(self.players[uuid].hand) == 0:
            self.almost_winner = uuid
        play: Play = Play(played_cards, uuid, round_rank)
        self.last_play = play
        self.active_pile.extend(played_cards)
        self.pass_count = 0

    def pass_turn(self) -> bool:
        self.pass_count += 1
        if self.pass_count == len(self.players) - 1:
            self.out_pile.extend(self.active_pile)
            self.active_pile = []
            self.end_round()
            return True
        return False

    def end_round(self) -> None:
        print(f"new starting player is {self.starting_player.uuid}")
        self.last_play = None
        self.pass_count = 0
        self.player_iterable = islice(
            cycle(self.players.values()),
            list(self.players.values()).index(self.starting_player),
            None,
        )
