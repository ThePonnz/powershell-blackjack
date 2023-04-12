<#
	.SYNOPSIS
	Deals the hands before the game starts.
	.OUTPUTS
	A hashtable containing both the dealer and player hands.
#>
Using Module '..\PSCards.psm1'

Param (
	# The deck for the game.
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	# The number of human players in the game. 7 is the max as that's typical at a blackjack table.
	[int][Parameter(Mandatory=$true)][ValidateNotNull()][ValidateRange(1, 7)] $NumberOfPlayers
)

Set-Variable -Option 'Constant' -Name 'HAND_CARD_COUNT' -Value 2

$dealerHand = @()
$playerHands = @(,@() * $NumberOfPlayers)

ForEach ($deckCount In 1..$HAND_CARD_COUNT) {
	$dealerHand = & '.\Deal-Card' -Deck $Deck -Hand $dealerHand
	For ($playerIndex = 0; $playerIndex -lt $NumberOfPlayers; $playerIndex++) {
		$playerHands[$playerIndex] = & '.\Deal-Card' -Deck $Deck -Hand $playerHands[$playerIndex]
	}
}

Return @{
	DealerHand = $dealerHand
	PlayerHands = $playerHands
}
