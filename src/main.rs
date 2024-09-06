
// use actix_web::{post, web, App, HttpServer};
use deckofcards::*;

const NUM_PLAYERS: usize = 3;

fn read_string() -> String {
    let mut input = String::new();
    std::io::stdin()
        .read_line(&mut input)
        .expect("can not read user input");
    input
}

struct Player {
    name: String,
    hand: Hand,
}

// struct Play {
//     cards: Vec<Card>,
//     rank: Rank,
//     valid: bool,
// }

fn game() {
    // Start of Game
    let mut deck = Deck::new();
    deck.shuffle();
    let mut players: Vec<Player> = Vec::with_capacity(NUM_PLAYERS);
    let mut active_pile = Hand::new();
    // let mut out_pile = Hand::new();
    for i in 0..NUM_PLAYERS {
        players.push(Player {
            name: format!("Player {}", i + 1),
            hand: Hand::new(),
        });
        deck.deal_to_hand(&mut players[i].hand, 52 / NUM_PLAYERS);
        println!("{}: {}", players[i].name, players[i].hand);
    }
    let undealt = deck.undealt_count();
    deck.deal_to_hand(&mut active_pile, undealt);
    println!("Active Pile: {} cards", active_pile.len());
    // Start of a round
    let mut round_rank: Option<Rank> = None;
    let mut next_cards: Vec<Card>;
    for mut player in players {
        println!();
        println!("---------{}'s turn-----------", player.name);
        println!("Your hand: {}", player.hand);
        println!("What cards would you like to play? (comma separated list):");
        // TODO: Verify text input or catch incorrect string
        next_cards = read_string()
            .trim()
            .split(",")
            .map(|card_name| Card::from_str(card_name).unwrap())
            .collect();
        // TODO: Verify cards are in hand
        active_pile.push_cards(&next_cards);
        player.hand.remove_cards(&next_cards);
        if round_rank == None {
            println!("What rank do you claim this hand is? (e.g. 2,5,T,A,etc)");
            round_rank = Some(Rank::from_char(read_string().remove(0)).unwrap());
        }
        let truthful = next_cards.iter().all(|card| card.rank == round_rank.unwrap());
        if truthful {
            println!("{} is telling the truth", player.name);
        } else {
            println!("{} is cheating", player.name);
        }
        println!("Active Pile: {} cards", active_pile.len());
        // let mut cheat: Option<bool> = None;
        // while cheat == None {
        // println!("Would you like to lie or tell the truth? (L/T):");
        //     match read_string().as_str().trim() {
        //         "L" => cheat = Some(true),
        //         "T" => cheat = Some(false),
        //         _  => {
        //             // println!("You said {}", input);
        //             println!("Could not determine choice. Please type L for lie and T for truth.");
        //         }
        //     }
        // }
        // // println!("Cheat is {:?}", cheat);
        // if let Some(cheating) = cheat {
        //     println!("")
        // }
    }
}

// #[actix_web::main]
// async fn run_server() -> std::io::Result<()> {
//     HttpServer::new(|| {
//         let cors = Cors::permissive();
//         App::new().wrap(cors).service(index)
//     })
//     .bind(("127.0.0.1", 8080))?
//     .run()
//     .await
// }

fn main() {
    // match run_server() {
    //     Ok(_) => println!("Running!"),
    //     Err(_) => println!("Error :("),
    // }
    game()
}
