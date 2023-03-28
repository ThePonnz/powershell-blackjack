Using Module '.\PSCards.psm1'

Describe 'PSCards' {

	Context 'Creating New Card' {
		It 'Creates a Card object with Suit and Value properties.' {
			$properties = [Card]::new(12, [Suit]::Spade).GetType().GetProperties()

			$suitProperty = $properties | Where-Object { $_.Name -eq 'Suit' }
			$valueProperty = $properties | Where-Object { $_.Name -eq 'Value' }

			$suitProperty | Should -Not -BeNullOrEmpty
			$valueProperty | Should -Not -BeNullOrEmpty
		}
	}

	Context 'Creating New Card' {
		It 'The values passed to the constructor are transferred to the properties.' {
			$card = [Card]::new(12, [Suit]::Spade)

			$card.Suit | Should -Be 'Spade'
			$card.Value | Should -Be 12
		}
	}

	Context 'Creating New Card' {
		It 'The card value must be between 1 to 13 representing A, 1 - 10, J, Q, K.' {
			{ [Card]::new(0, [Suit]::Spade) } | Should -Throw
			{ [Card]::new(1, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(2, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(3, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(4, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(5, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(6, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(7, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(8, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(9, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(10, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(11, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(12, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(13, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(14, [Suit]::Spade) } | Should -Throw
		}
	}

	Context 'Creating New Card' {
		It 'The card suit must be valid.' {
			{ [Card]::new(1, 0) } | Should -Throw
			{ [Card]::new(1, [Suit]::Heart) } | Should -Not -Throw
			{ [Card]::new(1, [Suit]::Diamond) } | Should -Not -Throw
			{ [Card]::new(1, [Suit]::Club) } | Should -Not -Throw
			{ [Card]::new(1, [Suit]::Spade) } | Should -Not -Throw
			{ [Card]::new(1, 5) } | Should -Throw
		}
	}

	# When outputting the value of a card, ToString() should follow the pattern <card_value><card_suit>. i.e. A♠, 3♣, 10♦, Q♥.
	Context 'Outputting Card' {
		It 'The ToString() method property displays suit.' {
			$heartCard = [Card]::new(1, [Suit]::Heart)
			$diamondCard = [Card]::new(1, [Suit]::Diamond)
			$clubCard = [Card]::new(1, [Suit]::Club)
			$spadeCard = [Card]::new(1, [Suit]::Spade)

			# Get the last character that ToString() produces for each card.
			$actualValues = @($heartCard, $diamondCard, $clubCard, $spadeCard | ForEach-Object { $_.ToString().Substring($_.ToString().Length - 1, 1) }) -join ''
			
			$expectedValues = '♥♦♣♠'
			$actualValues | Should -Be $expectedValues
		}
	}

	# When outputting the value of a card, ToString() should follow the pattern <card_value><card_suit>. i.e. A♠, 3♣, 10♦, Q♥.
	Context 'Outputting Card' {
		It 'The ToString() method property displays value.' {
			$cards = [Card]::new(1, [Suit]::Club), [Card]::new(2, [Suit]::Club), [Card]::new(3, [Suit]::Club), [Card]::new(4, [Suit]::Club), [Card]::new(5, [Suit]::Club), [Card]::new(6, [Suit]::Club), [Card]::new(7, [Suit]::Club), [Card]::new(8, [Suit]::Club), [Card]::new(9, [Suit]::Club), [Card]::new(10, [Suit]::Club), [Card]::new(11, [Suit]::Club), [Card]::new(12, [Suit]::Club), [Card]::new(13, [Suit]::Club)

			# Get all bug the last character that ToString() produces for each card.
			$actualValues = @($cards | ForEach-Object { $_.ToString().Substring(0, $_.ToString().Length - 1) }) -join ''

			$expectedValues = 'A2345678910JQK'
			$actualValues | Should -BeExactly $expectedValues
		}
	}

	Context 'New Deck' {
		It 'There are 52 cards in the deck.' {
			$deck = [Deck]::new()

			$cards = $deck.DealCards(52)
			$cards | Should -HaveCount 52
		}
	}

	Context 'New Deck' {
		It 'An exception is thrown when dealing more than the number of cards in the deck.' {
			$deck = [Deck]::new()

			{ $deck.DealCards(53) } | Should -Throw
			{ $deck.DealCards(52) } | Should -Not -Throw
			{ $deck.DealCards(1) } | Should -Throw
		}
	}

	Context 'New Deck' {
		It 'There are 4 correct suits in the deck.' {
			$deck = [Deck]::new()

			$cards = $deck.DealCards(52)
			$suitGroups = $cards | Group-Object -Property Suit

			$suitGroups | Should -HaveCount 4
			$values = $suitGroups | Select-Object -ExpandProperty Name
			$values | Should -Contain 'Heart'
			$values | Should -Contain 'Diamond'
			$values | Should -Contain 'Club'
			$values | Should -Contain 'Spade'
		}
	}

	Context 'New Deck' {
		It 'There are 13 unique cards of each suit in the deck.' {
			$deck = [Deck]::new()

			$cards = $deck.DealCards(52)
			$suitGroups = $cards | Group-Object -Property Suit

			$suitGroups | Should -HaveCount 4
			$expectedValues = 1..13
			For ($index = 0; $index -lt 4; $index++) {
				$actualValues = $suitGroups[0].Group | Select-Object -Unique -ExpandProperty Value | Sort-Object
				$actualValues | Should -Be $expectedValues
			}
		}
	}

	Context 'New Deck' {
		It 'Starts in an unshuffled state.' {
			$deck = [Deck]::new()

			$actualValues = @($deck.Cards | ForEach-Object { $_.ToString() }) -join ''						
			$expectedValues = 'A♥2♥3♥4♥5♥6♥7♥8♥9♥10♥J♥Q♥K♥A♦2♦3♦4♦5♦6♦7♦8♦9♦10♦J♦Q♦K♦A♣2♣3♣4♣5♣6♣7♣8♣9♣10♣J♣Q♣K♣A♠2♠3♠4♠5♠6♠7♠8♠9♠10♠J♠Q♠K♠'
			$expectedValues | Should -BeExactly $actualValues
		}
	}

	Context 'Shuffling Deck' {
		It 'Ensure that the card order changes.' {
			$deck = [Deck]::new()

			$cards = $deck.Cards
			$deck.Shuffle()

			$cards | Should -Not -Be ($deck.Cards)
		}
	}

}
