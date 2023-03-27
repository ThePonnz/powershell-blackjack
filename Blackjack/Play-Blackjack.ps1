Using Module '..\PSCards.psm1'

Clear-Host
Do {
	$numberOfPlayers = Read-Host -Prompt 'Enter the number of players'
	$isValidNumber = $numberOfPlayers -match '^(1|2|3|4|5|6|7)$'
} While (-not $isValidNumber)
$numberOfPlayers = [Convert]::ToInt32($numberOfPlayers)

Write-Host -NoNewline 'Shuffling the deck... '
$deck = [Deck]::new()
$deck.Shuffle()
Write-Host -ForegroundColor 'DarkCyan' 'Done'

Function Take-PlayerTurn {
	Param (
		[int] $PlayerNumber,
		[Card[]] $Hand
	)

	Write-Host
	Write-Host "Player $PlayerNumber's turn."

	Do {
		$handValue = & '.\Get-HandValue' -Hand $Hand
		Write-Host "Your hand is $Hand with a value of $handValue."

		If ($handValue -lt 21) {
			Do {
				$continueResponse = Read-Host -Prompt 'Would you like to hit'
				$isContinuing = $continueResponse -match '^(Yes|Y)$'
			} While (-not $continueResponse -match '^(Yes|Y|No|N)$')
			If ($isContinuing) {
				$Hand = & '.\Deal-Card' -Deck $deck -Hand $Hand
			}
		}
		ElseIf ($handValue -eq 21) {
			Write-Host -ForegroundColor 'DarkMagenta' 'You got 21!'
			$isContinuing = $false
		}
		Else {
			Write-Host -NoNewline 'Sorry; '
			Write-Host -NoNewline -ForegroundColor 'DarkRed' 'you busted'
			Write-Host '.'
			$isContinuing = $false
		}
	} While ($isContinuing)

	Return $Hand
}

Write-Host -NoNewline 'Dealing the cards... '
$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers $numberOfPlayers
Write-Host -ForegroundColor 'DarkCyan' 'Done'

Write-Host
Write-Host "The dealer has a $($hands.DealerHand[1]) facing up."

For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	$hands.PlayerHands[$playerIndex] = Take-PlayerTurn -Hand $hands.PlayerHands[$playerIndex] -PlayerNumber ($playerIndex + 1)
}

Function Take-DealerTurn {
	Param (
		[Card[]] $Hand
	)

	Write-Host
	Write-Host "Dealer's turn."
	$handValue = & '.\Get-HandValue' -Hand $Hand
	Write-Host "The dealer hand is $Hand with a value of $handValue."

	Do {
		$isContinuing = $false
		If ($handValue -le 21) {
			If ($handValue -le 16) {
				$Hand = & '.\Deal-Card' -Deck $deck -Hand $Hand
				$card = $Hand | Select-Object -Last 1
				Write-Host "Dealer hit and got a $card."
				$handValue = & '.\Get-HandValue' -Hand $Hand
				Write-Host "The dealer hand is $Hand with a value of $handValue."
				$isContinuing = $handValue -le 16
			}
			Else {
				Write-Host 'Dealer stands.'
			}
		}
		
		If ($handValue -eq 21) {
			Write-Host -ForegroundColor 'DarkMagenta' 'Dealer got 21.'
		}
		ElseIf ($handValue -gt 21) {
			Write-Host -ForegroundColor 'DarkRed' 'The dealer busted.'
		}
	} While ($isContinuing)

	Return $Hand
}

$playerScores = @($hands.PlayerHands | ForEach-Object { & '.\Get-HandValue' -Hand $_ })
$shouldDealerTakeTurn = ($playerScores | Where-Object { $_ -le 21 } | Measure-Object).Count -gt 0
If ($shouldDealerTakeTurn) {
	$hands.DealerHand = Take-DealerTurn -Deck $deck -Hand $hands.DealerHand
}
$dealerValue = & '.\Get-HandValue' -Hand $hands.DealerHand

Write-Host
Write-Host "Dealer Score:   $dealerValue"
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	Write-Host "Player $($playerIndex + 1) Score: $($playerScores[$playerIndex])"
}

Write-Host
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	$playerValue = & '.\Get-HandValue' -Hand $hands.PlayerHands[$playerIndex]

	Write-Host -NoNewline "Player $($playerIndex + 1) "
	If ($dealerValue -gt 21 -and $playerValue -le 21) {

	}
	If ($playerValue -gt 21) {
		Write-Host -NoNewline -ForegroundColor 'DarkRed' 'busted'
		Write-Host '.'
	}
	ElseIf ($dealerValue -gt 21 -or $playerValue -gt $dealerValue) {
		Write-Host -NoNewline -ForegroundColor 'DarkGreen' 'wins'
		Write-Host '!'
	}
	ElseIf ($playerValue -eq $dealerValue) {
		Write-Host -NoNewline -ForegroundColor 'DarkBlue' 'pushes'
		Write-Host '.'
	}
	ElseIf ($playerValue -lt $dealerValue) {
		Write-Host -NoNewline -ForegroundColor 'DarkRed' 'loses'
		Write-Host '.'
	}
}
