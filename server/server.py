import asyncio
import json
from websockets.asyncio.server import serve, ServerConnection, broadcast
import secrets

from game.game import CheatGame
from game.player import Player

JOIN = {}


async def play(websocket: ServerConnection, game: CheatGame, player: Player):
    hand = player.hand_to_str()
    print(hand)
    event = {"type": "hand", "hand": hand}
    await websocket.send(json.dumps(event))
    async for message in websocket:
        event = json.loads(message)



async def start(websocket: ServerConnection):
    game = CheatGame()
    cur_player = game.create_player(websocket)
    connected = {websocket}
    join_key = secrets.token_urlsafe(4)
    JOIN[join_key] = game, connected

    try:
        # Send the secret access token to the browser of the first player,
        # where it'll be used for building a "join" link.
        event = {
            "type": "init",
            "join": join_key,
            # "uuid": str(cur_player.uuid)
        }
        await websocket.send(json.dumps(event))
        message = await websocket.recv()
        event = json.loads(message)
        assert event["type"] == "start"
        game.start_game()
        start_broadcast = {"type": "start"}
        broadcast(connected, json.dumps(start_broadcast))
        message = await websocket.recv()
        event = json.loads(message)
        assert event["type"] == "start"
        await play(websocket, game, cur_player)
    finally:
        del JOIN[join_key]


async def join(websocket: ServerConnection, join_key):
    try:
        game, connected = JOIN[join_key]
    except KeyError:
        await error(websocket, "Game not found.")
        return

    # Register to receive moves from this game.
    connected.add(websocket)
    cur_player: Player = game.create_player(websocket)
    event = {
        "type": "init",
        # "uuid": str(cur_player.uuid)
    }
    await websocket.send(json.dumps(event))
    try:
        message = await websocket.recv()
        event = json.loads(message)
        assert event["type"] == "start"
        await play(websocket, game, cur_player)
    finally:
        connected.remove(websocket)


async def error(websocket, message):
    event = {
        "type": "error",
        "message": message,
    }
    await websocket.send(json.dumps(event))


async def handler(websocket: ServerConnection):
    # Receive and parse the "init" event from the UI.
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