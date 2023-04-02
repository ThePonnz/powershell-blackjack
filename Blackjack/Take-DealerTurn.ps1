Using Module '..\PSCards.psm1'

Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

Set-Variable -Option 'Constant' -Name 'DEALER_HIT_SCORE' -Value 16
Set-Variable -Option 'Constant' -Name 'MAX_HAND_VALUE' -Value 21

$state = [Hashtable]::new()
$handValue = & '.\Get-HandValue' -Hand $Hand

If (-not $handValue.IsBusted) {
	If ($handValue.Value -le $DEALER_HIT_SCORE) {
		$Hand = & '.\Deal-Card' -Deck $Deck -Hand $Hand
		$handValue = & '.\Get-HandValue' -Hand $Hand
		$state['DidHit'] = $true
		$state['DidStand'] = $handValue.Value -gt $DEALER_HIT_SCORE -and $handValue.Value -le $MAX_HAND_VALUE
	}
	Else {
		$state['DidHit'] = $false
		$state['DidStand'] = $true
	}
	$state['Score'] = $handValue
	$state['Hand'] = $Hand
}
Else {
	$state['DidHit'] = $false
	$state['DidStand'] = $false
	$state['Score'] = $handValue
	$state['Hand'] = $Hand
}

Return $state