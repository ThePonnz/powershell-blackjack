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
		Write-Host "Your hand is $Hand with a value of $($handValue.Value)."

		If ($handValue.IsBlackjack) {
			Write-Host -ForegroundColor 'DarkMagenta' 'You got 21!'
			$isContinuing = $false
		}
		ElseIf (-not $handValue.IsBusted) {
			Do {
				$continueResponse = Read-Host -Prompt 'Would you like to hit'
				$isContinuing = $continueResponse -match '^(Yes|Y)$'
			} While ($continueResponse -notmatch '^(Yes|Y|No|N)$')
			If ($isContinuing) {
				$Hand = & '.\Deal-Card' -Deck $deck -Hand $Hand
			}
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
$playerScores = @($hands.PlayerHands | ForEach-Object { & '.\Get-HandValue' -Hand $_ })
$shouldDealerTakeTurn = ($playerScores | Where-Object { $_.Value -le 21 } | Measure-Object).Count -gt 0

If ($shouldDealerTakeTurn) {
	Write-Host
	Write-Host "Dealer's turn."
	$dealerValue = & '.\Get-HandValue' -Hand $hands.DealerHand

	Do {
		Write-Host "The dealer hand is $($hands.DealerHand) with a value of $($dealerValue.Value)."
		$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hands.DealerHand
		$hands.DealerHand = $state.Hand
		$dealerValue = $state.Score
		If ($state.DidHit) {
			$card = $hands.DealerHand | Select-Object -Last 1
			Write-Host "Dealer hit and got a $card."
		}
		If ($state.Score.IsBlackjack) {
			Write-Host -ForegroundColor 'DarkMagenta' 'Dealer got blackjack.'
		}
		ElseIf ($state.DidStand) {
			Write-Host 'Dealer stands.'
		}
		If ($state.Score.IsBusted) {
			Write-Host -ForegroundColor 'DarkRed' 'The dealer busted.'
		}
	} While ((-not $state.DidStand) -and (-not $state.Score.IsBusted))
}

Write-Host
Write-Host "Dealer Score:   $($dealerValue.Value)"
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	Write-Host "Player $($playerIndex + 1) Score: $($playerScores[$playerIndex].Value)"
}

Write-Host
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	$playerValue = & '.\Get-HandValue' -Hand $hands.PlayerHands[$playerIndex]

	Write-Host -NoNewline "Player $($playerIndex + 1) "
	If ($dealerValue.Score.IsBusted -and -not $playerValue.Score.IsBusted) {
		Write-Host -NoNewline -ForegroundColor 'DarkGreen' 'wins'
		Write-Host '!'
	}
	ElseIf ($playerValue.Score.IsBusted) {
		Write-Host -NoNewline -ForegroundColor 'DarkRed' 'busted'
		Write-Host '.'
	}
	ElseIf ($dealerValue.Score.IsBusted -or $playerValue.Value -gt $dealerValue.Value) {
		Write-Host -NoNewline -ForegroundColor 'DarkGreen' 'wins'
		Write-Host '!'
	}
	ElseIf ($playerValue.Value -eq $dealerValue.Value) {
		Write-Host -NoNewline -ForegroundColor 'DarkBlue' 'pushes'
		Write-Host '.'
	}
	ElseIf ($playerValue.Value -lt $dealerValue.Value) {
		Write-Host -NoNewline -ForegroundColor 'DarkRed' 'loses'
		Write-Host '.'
	}
}
