Using Module '..\PSCards.psm1'

Describe 'Deal Card Tests' {
	
	Context 'Script Parameters' {
		It 'Should have the required, not-nullable parameter named Deck.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)

			Get-Command '.\Deal-Card' | Should -HaveParameter 'Deck' -Mandatory -Type $deck.GetType()
			{ & '.\Deal-Card' -Deck $null -Hand $hand } | Should -Throw
		}
	}
	
	Context 'Script Parameters' {
		It 'Should have the required, not-nullable parameter named Hand that allows an empty collection.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)

			Get-Command '.\Deal-Card' | Should -HaveParameter 'Hand' -Mandatory -Type $hand.GetType()
			{ & '.\Deal-Card' -Deck $deck -Hand $null } | Should -Throw
			{ & '.\Deal-Card' -Deck $deck -Hand $hand } | Should -Not -Throw
		}
	}

	Context 'Return Value' {
		It 'Returns a hand (array of cards).' {
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
		It 'Adds 1 card to the hand from the top of the deck.' {
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