Using Namespace System.Collections.Generic

Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[int][Parameter(Mandatory=$true)][ValidateNotNull()][ValidateRange(1, 7)] $NumberOfPlayers
)

$dealerHand = @()
$playerHands = [List[Card[]]]::new($NumberOfPlayers)
1..$NumberOfPlayers | ForEach-Object { $playerHands.Add(@()) }

ForEach ($deckCount In 1..2) {
	$dealerHand += $Deck.DealCards(1)
	For ($playerIndex = 0; $playerIndex -lt $NumberOfPlayers; $playerIndex++) {
		$playerHands[$playerIndex] += $Deck.DealCards(1)
	}
}

Return @{
	DealerHand = $dealerHand
	PlayerHands = $playerHands.ToArray()
}
