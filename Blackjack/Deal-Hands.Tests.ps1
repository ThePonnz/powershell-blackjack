Using Module '..\PSCards.psm1'

Describe 'Blackjack Deal Cards Tests' {

	Context 'Script Parameters' {
		It 'Should have the Deck parameter' {
			$deck = [Deck]::new()

			Get-Command '.\Deal-Hands' | Should -HaveParameter 'Deck' -Mandatory -Type $deck.GetType()
		}
	}
	
	Context 'Script Parameters' {
		It 'Should have the NumberOfPlayers parameter' {
			Get-Command '.\Deal-Hands' | Should -HaveParameter 'NumberOfPlayers' -Mandatory -Type [Int32]
		}
	}

	Context 'Script Parameters' {
		It 'Should require NumberOfPlayers to be between 1 and 7.' {
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers -1
			} | Should -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 0
			} | Should -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 1
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 2
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 3
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 4
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 5
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 6
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 7
			} | Should -Not -Throw
			{
				$deck = [Deck]::new()
				& '.\Deal-Hands' -Deck $deck -NumberOfPlayers 8
			} | Should -Throw
		}
	}

	Context 'Dealing Hands' {
		It 'Should return a hashtable with a DealerHand and PlayerHands keyvalue pair.' {
			$deck = [Deck]::new()

			$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers 1

			$hands | Should -Not -BeNullOrEmpty
			$hands | Should -BeOfType Hashtable
			$hands.Keys | Should -Contain 'DealerHand'
			$hands.Keys | Should -Contain 'PlayerHands'
		}
	}

	Context 'Dealer Hand' {
		It 'Should return an array with 2 cards.' {
			$deck = [Deck]::new()
			$card = [Card]::new(1, [Suit]::Heart)

			$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers 1
			
			$dealerHand = $hands['DealerHand']
			$dealerHand | Should -HaveCount 2
			$dealerHand[0] | Should -BeOfType $card.GetType()
			$dealerHand[1] | Should -BeOfType $card.GetType()
		}
	}

	Context 'Player Hands' {
		It 'Returned count should match number of players.' {
			For ($numberOfPlayers = 1; $numberOfPlayers -le 7; $numberOfPlayers++) {
				$deck = [Deck]::new()
				$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers $numberOfPlayers

				$hands['PlayerHands'] | Should -HaveCount $numberOfPlayers
			}
		}
	}

	Context 'Player Hands' {
		It 'Should return an array with 2 cards per player.' {
			$deck = [Deck]::new()
			$card = [Card]::new(1, [Suit]::Heart)

			$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers 2

			$player1Hand = $hands['PlayerHands'][0]
			$player1Hand | Should -HaveCount 2
			$player1Hand[0] | Should -BeOfType $card.GetType()
			$player1Hand[1] | Should -BeOfType $card.GetType()

			$player2Hand = $hands['PlayerHands'][1]
			$player2Hand | Should -HaveCount 2
			$player2Hand[0] | Should -BeOfType $card.GetType()
			$player2Hand[1] | Should -BeOfType $card.GetType()
		}
	}

	Context 'Deal Order' {
		It 'Should deal starting with dealer and then iterating through players.' {
			$deck = [Deck]::new()

			$hands = & '.\Deal-Hands' -Deck $deck -NumberOfPlayers 3
			$actual = "$($hands['DealerHand']) $($hands['PlayerHands'][0]) $($hands['PlayerHands'][1]) $($hands['PlayerHands'][2])"

			$actual | Should -BeExactly 'A♥ 5♥ 2♥ 6♥ 3♥ 7♥ 4♥ 8♥'
		}
	}

}
