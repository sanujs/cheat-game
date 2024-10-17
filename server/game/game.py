from itertools import cycle, islice
from game.action import Action, Play
from game.deck.deck import Deck, Card
from game.deck.rank import Rank
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
        if remaining_cards := len(self.deck.cards) > 0:
            self.discard_pile = self.deck.deal(remaining_cards)

        self.last_play: Play = None
        self.starting_player: Player = None
        self.current_turn_player: Player = None

    def start_game(self) -> None:
        num_players = len(self.players)
        self.starting_player = choice(list(self.players.values()))
        for player in self.players.values():
            player.hand = self.deck.deal(52//num_players)
        self.player_iterable = islice(cycle(self.players.values()), list(self.players.values()).index(self.starting_player), None)

    def create_player(self, connection: ServerConnection) -> Player:
        uuid: str = str(uuid4())
        self.players[uuid] = Player(uuid, connection)
        if self.current_turn_player is None:
            self.current_turn_player = self.players[uuid]
        return self.players[uuid]

    def next_turn(self) -> Player:
        self.current_turn_player = next(self.player_iterable)
        return self.current_turn_player

    def play_game(self) -> None:
        while not self.play_round():
            pass
        
    def all_players_pass(self) -> None:
        self.out_pile.append(self.active_pile)
        self.active_pile = []

    def call_cheat(self, accuser: Player) -> bool:
        accused: Player = self.players[self.last_play.player_name]
        if self.last_play.cheat:
            # The accuser correctly identified the cheating play
            self.starting_player = accuser
            accused.hand.extend(self.active_pile)
            self.active_pile = []
            self.last_play = None
            return True
        else:
            # The accused was not cheating
            self.starting_player = accused
            accuser.hand.extend(self.active_pile)
            self.active_pile = []
            self.last_play = None
            return False

    # Returns True if game is over
    def play_round(self) -> bool:
        players_cycle = islice(cycle(self.players.values()),
                               list(self.players.values()).index(self.starting_player), None)
        pass_count: int = 0
        start: bool = True
        round_rank: Rank = None
        for player in players_cycle:
            action: Action | Play = player.turn(round_rank)
            print(f"Type {type(action) is Action}")
            if type(action) is Action:
                match action:
                    case Action.PASS:
                        pass_count += 1
                        if pass_count == len(self.players):
                            self.all_players_pass()
                            return False
                    case Action.CALL_CHEAT:
                        print("somebody called cheat")
                        self.call_cheat(player)
                        return False
            elif type(action) is Play:
                pass_count = 0
                self.last_play = action
                self.active_pile.extend(action.cards)
                if start:
                    round_rank = action.claimed_rank
                    start = False
                if len(player.hand) == 0:
                    player = next(players_cycle)
                    action = player.turn(round_rank)
                    if action is Action.CALL_CHEAT:
                        return not self.call_cheat(player)
                    return True


    def play_turn(self, player: str, cards: list[str], round_rank: Rank) -> None:
        played_cards: list[Card] = [Card.from_str(card) for card in cards]
        play: Play = Play(played_cards, player, round_rank)
        self.last_play = play
        self.active_pile.extend(played_cards)
