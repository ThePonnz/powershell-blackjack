Using Module '..\PSCards.psm1'

Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

$Hand += $Deck.DealCards(1)

Return $Hand
