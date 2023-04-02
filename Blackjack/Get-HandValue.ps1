Using Module '..\PSCards.psm1'

Param (
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

Set-Variable -Option 'Constant' -Name 'ACE_VALUE' -Value 1
Set-Variable -Option 'Constant' -Name 'ACE_SPECIAL_VALUE' -Value 11
Set-Variable -Option 'Constant' -Name 'MAX_HAND_VALUE' -Value 21

Function Get-NonAceScore {
	Set-Variable -Option 'Constant' -Scope 'Private' -Name 'FACE_CARD_VALUE' -Value 10

	$nonAceValues = $Hand | Where-Object { $_.Value -ne $ACE_VALUE } | Select-Object -ExpandProperty Value
	Return (($nonAceValues | ForEach-Object {
		If ($_ -le $FACE_CARD_VALUE) {
			$_
		}
		Else {
			$FACE_CARD_VALUE
		}
	}) | Measure-Object -Sum).Sum
}

Function Add-AcesToScore {
	Param (
		[int] $CountOfAces,
		[int] $NonAceScore
	)

	If ($CountOfAces -gt 0) {
		$score = $NonAceScore + $ACE_SPECIAL_VALUE + ($CountOfAces - 1)
		If ($score -gt $MAX_HAND_VALUE) {
			$score = $NonAceScore + $CountOfAces
		}
		Return $score
	}
	Else {
		Return $NonAceScore
	}
}

$nonAceScore = Get-NonAceScore
$aceCount = ($Hand | Where-Object { $_.Value -eq $ACE_VALUE } | Measure-Object).Count
$score = Add-AcesToScore -CountOfAces $aceCount -NonAceScore $NonAceScore

Return @{
	Value = [int]$score
	IsBlackjack = $score -eq $MAX_HAND_VALUE
	IsBusted = $score -gt $MAX_HAND_VALUE
}