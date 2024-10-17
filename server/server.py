import asyncio
import json
from websockets.asyncio.server import serve, ServerConnection, broadcast
import secrets

from game.deck.rank import Rank
from game.game import CheatGame
from game.player import Player

JOIN = {}


async def play(websocket: ServerConnection, game: CheatGame, player: Player, connected: set[ServerConnection]):
    hand = player.hand_to_str()
    print(hand)
    event = {"type": "hand", "hand": hand}
    await websocket.send(json.dumps(event))
    print(game.current_turn_player.uuid)
    print(player.uuid)
    if game.current_turn_player.uuid == player.uuid:
        event = {"type": "turn", "player": str(game.current_turn_player.uuid), "round_start": True}
        await websocket.send(json.dumps(event))
    async for message in websocket:
        event = json.loads(message)
        match event["type"]:
            case "play":
                game.play_turn(player.uuid, event["cards"], Rank(event["round_rank"]))
                # TODO: broadcast to all players how many cards this player played
                #   and possibly the current round rank
                next_player: Player = game.next_turn()
                event = {"type": "turn", "player": str(next_player.uuid), "round_start": False, "round_rank": event["round_rank"]}
                broadcast(connected, json.dumps(event))

async def start(websocket: ServerConnection):
    game = CheatGame()
    cur_player = game.create_player(websocket)
    connected: set[ServerConnection] = {websocket}
    join_key = secrets.token_urlsafe(2)
    JOIN[join_key] = game, connected
    try:
        await initialize_connection(websocket, join_key, cur_player, game, connected)

        # Initialize game and deal cards
        game.start_game()

        # Broadcast the game is starting to all players
        start_broadcast = {"type": "start"}
        broadcast(connected, json.dumps(start_broadcast))

        # Wait for client to acknowledge
        message = await websocket.recv()
        event = json.loads(message)
        assert event["type"] == "start"
        await play(websocket, game, cur_player, connected)
    finally:
        del JOIN[join_key]


async def join(websocket: ServerConnection, join_key: str):
    try:
        game, connected = JOIN[join_key]
    except KeyError:
        await error(websocket, "Game not found.")
        return

    # Register to receive moves from this game.
    connected.add(websocket)
    cur_player: Player = game.create_player(websocket)

    try:
        await initialize_connection(websocket, join_key, cur_player, game, connected)
        await play(websocket, game, cur_player, connected)
    finally:
        connected.remove(websocket)


async def initialize_connection(
    websocket: ServerConnection,
    join_key: str,
    player: Player,
    game: CheatGame,
    connected: set[ServerConnection],
):
    event = {
        "type": "init",
        "join": join_key,
        "uuid": str(player.uuid),
    }
    await websocket.send(json.dumps(event))
    new_player_broadcast = {"type": "players", "players": list(game.players.keys())}
    broadcast(connected, json.dumps(new_player_broadcast))

    # Wait for host to start game
    message = await websocket.recv()
    event = json.loads(message)
    assert event["type"] == "start"


async def error(websocket, message):
    event = {
        "type": "error",
        "message": message,
    }
    await websocket.send(json.dumps(event))


async def handler(websocket: ServerConnection):
    # Receive and parse the "init" event from the UI.
    print("connected")
    message = await websocket.recv()
    print(message)
    event = json.loads(message)
    assert event["type"] == "init"

    if "join" in event:
        # Second player joins an existing game.
        await join(websocket, event["join"])
    else:
        # First player starts a new game.
        await start(websocket)


async def main():
    async with serve(handler, "", 8001):
        await asyncio.get_running_loop().create_future()  # run forever


if __name__ == "__main__":
    asyncio.run(main())
