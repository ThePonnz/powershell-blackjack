Using Module '..\PSCards.psm1'

Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

Set-Variable -Option 'Constant' -Name 'DEAL_CARD_COUNT' -Value 1

$Hand += $Deck.DealCards($DEAL_CARD_COUNT)

Return $Hand
