Using Module '..\PSCards.psm1'

Param (
	[Card[]][Parameter(Mandatory=$true)][ValidateNotNull()][AllowEmptyCollection()] $Hand
)

Function Get-NonAceCardValue {
	Param (
		[Card] $Card
	)
	
	If ($Card.Value -le 10) {
		Return $Card.Value
	}
	Else {
		Return 10
	}
}

Function Get-Score {
	Param (
		[int][ValidateRange(1, 4)] $CountOfAces,
		[int] $NonAceScore
	)

	$values = @(1..$CountOfAces | ForEach-Object { 11 })
	$valueIndex = 0
	While ($valueIndex -lt $CountOfAces -and $NonAceScore + ($values | Measure-Object -Sum).Sum -gt 21) {
		$values[$valueIndex] = 1
		$valueIndex++
	}

	Return $NonAceScore + ($values | Measure-Object -Sum).Sum
}

$score = 0
$score += (@($Hand | Where-Object { $_.Value -ne 1 } | ForEach-Object { Get-NonAceCardValue -Card $_ }) | Measure-Object -Sum).Sum
$aceCount = ($Hand | Where-Object { $_.Value -eq 1 } | Measure-Object).Count
If ($aceCount -gt 0) {
	$score = Get-Score -CountOfAces $aceCount -NonAceScore $score
}

Return @{
	Value = [int]$score
	IsBlackjack = $score -eq 21
	IsBusted = $score -gt 21
}