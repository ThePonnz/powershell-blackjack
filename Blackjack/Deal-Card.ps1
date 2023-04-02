<#
	.SYNOPSIS
	Deals a card to a player.
	.OUTPUTS
	The hand of the player that has been delt to.
#>
Using Module '..\PSCards.psm1'

Param (
	# The deck for the game.
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	# The hand of the player being delt to.
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

Set-Variable -Option 'Constant' -Name 'DEAL_CARD_COUNT' -Value 1

$Hand += $Deck.DealCards($DEAL_CARD_COUNT)

Return $Hand
