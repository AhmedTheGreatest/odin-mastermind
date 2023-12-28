# Mastermind
A simple Mastermind game made implemented in Ruby for TheOdinProject.
  
## Usage

[![Run on Repl.it](https://replit.com/badge/github/AhmedTheGreatest/mastermind)](https://replit.com/new/github/AhmedTheGreatest/mastermind)

To play the game, run `$ ruby mastermind.rb` in your terminal

For info on how to play the game visit [Wikipedia](https://en.wikipedia.org/wiki/Mastermind)

## Code Overview

The game contains the following classes:

- `Player`: Represents a base player, with a name.
- - `CodeMaker`: Represents the base CodeMaker player (The player who will make the secret code).
- - - `CodeMakerAI`: Represents the CodeMaker AI.
- - - `CodeMakerHuman`: Represents the CodeMaker Human player.
- - `CodeBreaker`: Represents the base CodeBreaker player (The player who will guess the code).
- - - `CodeBreakerAI`: Represents the CodeBreaker AI.
- - - `CodeBreakerHuman`: Represents the CodeBreaker Human player.
- `Game`: Manages the overall game flow and logic.

- The `Mastermind` module contains and ties together the other classes.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.