Param (
	[Deck][Parameter(Mandatory=$true)][ValidateNotNull()] $Deck,
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

$state = [Hashtable]::new()
$handValue = & '.\Get-HandValue' -Hand $Hand

If (-not $handValue.IsBusted) {
	If ($handValue.Value -le 16) {
		$Hand = & '.\Deal-Card' -Deck $Deck -Hand $Hand
		$handValue = & '.\Get-HandValue' -Hand $Hand
		$state['DidHit'] = $true
		$state['DidStand'] = $handValue.Value -gt 16 -and $handValue.Value -le 21
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