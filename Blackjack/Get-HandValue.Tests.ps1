Using Module '..\PSCards.psm1'

Describe 'Hand Value Calculation' {

	Context 'Script Parameters' {
		It 'Should have the Hand parameter.' {
			$hand = [Card[]]::new(0)

			Get-Command '.\Deal-Card' | Should -HaveParameter 'Hand' -Mandatory -Type $hand.GetType()
		}
	}

	Context 'Default Score' {
		It 'Should be 0.' {
			$hand = [Card[]]::new(0)

			$handValue = & '.\Get-HandValue' -Hand $hand

			$handValue | Should -Be 0
		}
	}

	Context 'Evaluating Numbered Cards' {
		It 'Should be equal to the value of the card.' {
			For ($value = 2; $value -le 10; $value++) {
				$hand = @([Card]::new($value, [Suit]::Club))
				
				$handValue = & '.\Get-HandValue' -Hand $hand

				$handValue | Should -Be $value
			}
		}
	}

	Context 'Evaluating Face Cards' {
		It 'Should always evaluate face cards to 10.' {
			For ($value = 11; $value -le 13; $value++) {
				$hand = @([Card]::new($value, [Suit]::Club))

				$handValue = & '.\Get-HandValue' -Hand $hand

				$handValue | Should -Be 10
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

			$handValue | Should -Be 21
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

			$handValue | Should -Be 13
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

			$handValue | Should -Be 21
		}
	}

}