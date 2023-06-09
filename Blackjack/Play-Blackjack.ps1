Using Module '..\PSCards.psm1'

Clear-Host

# Prompt for how many humans are playing.
Do {
	$numberOfPlayers = Read-Host -Prompt 'Enter the number of players'
	$isValidNumber = $numberOfPlayers -match '^(1|2|3|4|5|6|7)$'
} While (-not $isValidNumber)
$numberOfPlayers = [Convert]::ToInt32($numberOfPlayers)

# Shuffle the deck.
Write-Host -NoNewline 'Shuffling the deck... '
$deck = [Deck]::new()
$deck.Shuffle()
Write-Host -ForegroundColor 'DarkCyan' 'Done'

# Deal the hands to the players.
Write-Host -NoNewline 'Dealing the cards... '
$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers $numberOfPlayers
Write-Host -ForegroundColor 'DarkCyan' 'Done'

Write-Host
Write-Host "The dealer has a $($hands.DealerHand[1]) facing up."

Function Take-PlayerTurn {
	<#
		.SYNOPSIS
		Prompts a human player to hit or stand and shows the value of their hand.
		.OUTPUTS
		The hand of the player after they've taken their turn.
	#>
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
			Write-Host -ForegroundColor 'DarkMagenta' 'You got blackjack!'
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

# Let each human take their turn.
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	$hands.PlayerHands[$playerIndex] = Take-PlayerTurn -Hand $hands.PlayerHands[$playerIndex] -PlayerNumber ($playerIndex + 1)
}
$playerScores = @($hands.PlayerHands | ForEach-Object { & '.\Get-HandValue' -Hand $_ })

$shouldDealerTakeTurn = ($playerScores | Where-Object { $_.Value -le 21 } | Measure-Object).Count -gt 0
$dealerValue = & '.\Get-HandValue' -Hand $hands.DealerHand

# Let the dealer take their turn.
Write-Host
If ($shouldDealerTakeTurn) {
	Write-Host "Dealer's turn."

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
Else {
	Write-Host "Dealer stands because all players busted."
}
Write-Host "The dealer hand is $($hands.DealerHand) with a value of $($dealerValue.Value)."

Write-Host
Write-Host "Dealer Score:   $($dealerValue.Value)"
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	Write-Host "Player $($playerIndex + 1) Score: $($playerScores[$playerIndex].Value)"
}

# Indicate who wins, loses, and pushes.
Write-Host
For ($playerIndex = 0; $playerIndex -lt $numberOfPlayers; $playerIndex++) {
	$playerValue = $playerScores[$playerIndex]

	Write-Host -NoNewline "Player $($playerIndex + 1) "
	If ($dealerValue.IsBusted -and -not $playerValue.IsBusted) {
		Write-Host -NoNewline -ForegroundColor 'DarkGreen' 'wins'
		Write-Host '!'
	}
	ElseIf ($playerValue.IsBusted) {
		Write-Host -NoNewline -ForegroundColor 'DarkRed' 'busted'
		Write-Host '.'
	}
	ElseIf ($dealerValue.IsBusted -or $playerValue.Value -gt $dealerValue.Value) {
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
