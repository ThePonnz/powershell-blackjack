Using Module '..\PSCards.psm1'
Using Namespace System.Collections.Generic

Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[int][Parameter(Mandatory=$true)][ValidateNotNull()][ValidateRange(1, 7)] $NumberOfPlayers
)

Set-Variable -Option 'Constant' -Name 'HAND_CARD_COUNT' -Value 2

$dealerHand = [Card[]]::new(0)
$playerHands = [List[Card[]]]::new($NumberOfPlayers)
1..$NumberOfPlayers | ForEach-Object { $playerHands.Add([Card[]]::new(0)) }

ForEach ($deckCount In 1..$HAND_CARD_COUNT) {
	$dealerHand = & '.\Deal-Card' -Deck $Deck -Hand $dealerHand
	For ($playerIndex = 0; $playerIndex -lt $NumberOfPlayers; $playerIndex++) {
		$playerHands[$playerIndex] = & '.\Deal-Card' -Deck $Deck -Hand $playerHands[$playerIndex]
	}
}

Return @{
	DealerHand = $dealerHand
	PlayerHands = $playerHands.ToArray()
}
