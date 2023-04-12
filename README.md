# powershell-blackjack
Just what it sounds like - a PowerShell port of the card game, Blackjack. This game isn't meant to be played - though it is fun; it's really for teaching PowerShell students one way to break down your scripts into operations that can be property unit tested with Pester. This project has full code coverage except for the console output.

## Playing the Game
To run the game, execute the following commands from the root of the repo:
```
Cd .\Blackjack\
.\Play-Blackjack.ps1
```

## Running Tests
The tests are meant to be run from the .\Blackjack\ directory, not the root of the repo.  If you run the tests while you're current directory is the root of the repo, they will fail.  You must change you directory to the .\Blackjack\ directory and then run the tests.
