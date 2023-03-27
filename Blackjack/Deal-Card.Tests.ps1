Using Module '..\PSCards.psm1'

Describe 'Deal Card Tests' {
	
	Context 'Script Parameters' {
		It 'Should have the Deck parameter.' {
			$deck = [Deck]::new()

			Get-Command '.\Deal-Card' | Should -HaveParameter 'Deck' -Mandatory -Type $deck.GetType()
		}
	}
	
	Context 'Script Parameters' {
		It 'Should have the Hand parameter.' {
			$hand = [Card[]]::new(0)

			Get-Command '.\Deal-Card' | Should -HaveParameter 'Hand' -Mandatory -Type $hand.GetType()
		}
	}

	Context 'Return Value' {
		It 'Should return a hand (array of cards).' {
			$deck = [Deck]::new()
			$hand = @()

			$hand | Should -HaveCount 0
			$hand = & '.\Deal-Card' -Deck $deck -Hand $hand
			$hand | Should -HaveCount 1
			$hand = & '.\Deal-Card' -Deck $deck -Hand $hand
			$hand | Should -HaveCount 2

			$cardType = [Card]::new(1, [Suit]::Diamond).GetType()
			$card = $hand[0]
			$card | Should -BeOfType $cardType
			$card = $hand[1]
			$card | Should -BeOfType $cardType
		}
	}
	
	Context 'Hitting the Player or Dealer' {
		It 'Should add 1 card to the hand from the top of the deck.' {
			$deck = [Deck]::new()
			$hand = @()

			$hand = & '.\Deal-Card' -Deck $deck -Hand $hand

			$hand | Should -HaveCount 1
			"$hand" | Should -BeExactly 'A♥'

			$hand = & '.\Deal-Card' -Deck $deck -Hand $hand

			$hand | Should -HaveCount 2
			"$hand" | Should -BeExactly 'A♥ 2♥'
		}
	}

}