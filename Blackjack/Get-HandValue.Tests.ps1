Using Module '..\PSCards.psm1'

Describe 'Hand Value Calculation' {

	Context 'Script Parameters' {
		It 'Should have the required, not-nullable parameter named Hand that allows an empty collection.' {
			$hand = [Card[]]::new(0)

			Get-Command '.\Get-HandValue' | Should -HaveParameter 'Hand' -Mandatory -Type $hand.GetType()
			{ & '.\Get-HandValue' -Hand $null } | Should -Throw
			{ & '.\Get-HandValue' -Hand $hand } | Should -Not -Throw
		}
	}

	Context 'Return Value' {
		It 'Returns a hashtable with the keys Value, IsBlackjack, and IsBusted.' {
			$hand = [Card[]]::new(0)

			$hands = & '.\Get-HandValue' -Hand $hand

			$hands | Should -Not -BeNullOrEmpty
			$hands | Should -BeOfType [Hashtable]
			$hands.Keys | Should -Contain 'Value'
			$hands.Value | Should -BeOfType [Int32]
			$hands.Keys | Should -Contain 'IsBlackjack'
			$hands.IsBlackjack | Should -BeOfType [bool]
			$hands.Keys | Should -Contain 'IsBusted'
			$hands.IsBusted | Should -BeOfType [bool]
		}
	}

	Context 'Default Score' {
		It 'Should be 0.' {
			$hand = [Card[]]::new(0)

			$handValue = & '.\Get-HandValue' -Hand $hand

			$handValue.Value | Should -Be 0
		}
	}

	Context 'Evaluating Numbered Cards' {
		It 'Should be equal to the value of the card.' {
			For ($value = 2; $value -le 10; $value++) {
				$hand = @([Card]::new($value, [Suit]::Club))
				
				$handValue = & '.\Get-HandValue' -Hand $hand

				$handValue.Value | Should -Be $value
			}
		}
	}

	Context 'Evaluating Face Cards' {
		It 'Should always evaluate face cards to 10.' {
			For ($value = 11; $value -le 13; $value++) {
				$hand = @([Card]::new($value, [Suit]::Club))

				$handValue = & '.\Get-HandValue' -Hand $hand

				$handValue.Value | Should -Be 10
			}
		}
	}

	Context 'Evaluating Aces' {
		It 'Should use an ace to get to 21.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(1, [Suit]::Club)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 21
		}
	}

	Context 'Evaluating Aces' {
		It 'Should see a combination of 1''s and 11''s.' {
			$hand = @(
				[Card]::new(1, [Suit]::Club),
				[Card]::new(1, [Suit]::Diamond),
				[Card]::new(1, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 13
		}
	}

	Context 'Evaluating Aces' {
		It 'Should all aces evaluated as 1''s.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(11, [Suit]::Diamond),
				[Card]::new(1, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 21
		}
	}

	Context 'Evaluating Blackjack' {
		It 'Should be a blackjack for a score of 21.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(10, [Suit]::Diamond),
				[Card]::new(1, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 21
			$handValue.IsBlackjack | Should -Be $true
		}
	}

	Context 'Evaluating Blackjack' {
		It 'Should not be a blackjack for a score under 21.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(9, [Suit]::Diamond),
				[Card]::new(1, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 20
			$handValue.IsBlackjack | Should -Be $false
		}
	}

	Context 'Evaluating Blackjack' {
		It 'Should not be a blackjack for a score over 21.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(10, [Suit]::Diamond),
				[Card]::new(2, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 22
			$handValue.IsBlackjack | Should -Be $false
		}
	}

	Context 'Evaluating Busted' {
		It 'Should be busted if over 21.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(10, [Suit]::Diamond),
				[Card]::new(2, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 22
			$handValue.IsBusted | Should -Be $true
		}
	}

	Context 'Evaluating Busted' {
		It 'Should not be busted if 21 or under.' {
			$hand = @(
				[Card]::new(10, [Suit]::Club),
				[Card]::new(10, [Suit]::Diamond),
				[Card]::new(1, [Suit]::Spade)
			)

			$handValue = & '.\Get-HandValue.ps1' -Hand $hand

			$handValue.Value | Should -Be 21
			$handValue.IsBusted | Should -Be $false
		}
	}

}