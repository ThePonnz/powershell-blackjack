Using Module '.\PSCards.psm1'
# Remove-Module -Name 'PSCards'

Describe 'PS Cards Tests' {

	# Cards should have a Suit and Value property. Suits are defined as an enumeration and value is an int from 1 to 13.
	Context 'Creating New Card' {
		It 'Ensure the card has the correct suit and value.' {
			$card = [Card]::new(12, [Suit]::Spade)

			$card.Suit | Should -Be 'Spade'
			$card.Value | Should -Be 12
		}
	}

	# Creating a new Card object with an invlaid value should throw an exception.
	Context 'Creating New Card' {
		It 'Ensure the card value must be valid.' {
			{ [Card]::new(0, [Suit]::Spade) } | Should -Throw
			{ [Card]::new(14, [Suit]::Spade) } | Should -Throw
		}
	}

	# Creating a new Card object with an invlaid suit should throw an exception.
	Context 'Creating New Card' {
		It 'Ensure the card suit must be valid.' {
			{ [Card]::new(1, 0) } | Should -Throw
			{ [Card]::new(1, 5) } | Should -Throw
		}
	}

	# When outputting the value of a card, ToString() should follow the pattern <card_value><card_suit>. i.e. A♠, 3♣, 10♦, Q♥
	Context 'Outputting Card' {
		It 'Ensure the ToString() method property displays suit.' {
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

	# When outputting the value of a card, ToString() will display the values of 1..13 as A, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K.
	Context 'Outputting Card' {
		It 'Ensure the ToString() method property displays value.' {
			$cards = [Card]::new(1, [Suit]::Club), [Card]::new(2, [Suit]::Club), [Card]::new(3, [Suit]::Club), [Card]::new(4, [Suit]::Club), [Card]::new(5, [Suit]::Club), [Card]::new(6, [Suit]::Club), [Card]::new(7, [Suit]::Club), [Card]::new(8, [Suit]::Club), [Card]::new(9, [Suit]::Club), [Card]::new(10, [Suit]::Club), [Card]::new(11, [Suit]::Club), [Card]::new(12, [Suit]::Club), [Card]::new(13, [Suit]::Club)

			# Get all bug the last character that ToString() produces for each card.
			$actualValues = @($cards | ForEach-Object { $_.ToString().Substring(0, $_.ToString().Length - 1) }) -join ''

			$expectedValues = 'A2345678910JQK'
			$actualValues | Should -BeExactly $expectedValues
		}
	}

	# A deck should start with 52 unique cards comparised of 4 suits each with 13 cards and no jokers.
	Context 'New Deck' {
		It 'Ensure that there are 52 cards in the deck.' {
			$deck = [Deck]::new()

			$cards = $deck.DealCards(52)
			$cards | Should -HaveCount 52
		}
	}

	# The deck should start with 52 cards and throw an exception when attempting to deal more cards than are in the deck.
	Context 'New Deck' {
		It 'Ensure that an exception is thrown when dealing more than the number of cards in the deck.' {
			$deck = [Deck]::new()

			{ $deck.DealCards(53) } | Should -Throw
			$deck.DealCards(52)
			{ $deck.DealCards(1) } | Should -Throw
		}
	}

	# A new deck should have 4 suits: heart, diamond, club, and spade.
	Context 'New Deck' {
		It 'Ensure that there are 4 correct suits in the deck.' {
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

	# A new deck will have 4 suits each with 13 distinct values from A..K.
	Context 'New Deck' {
		It 'Ensure that there are 13 unique cards of each suit in the deck.' {
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

	# Resetting the deck will place the the cards in suit order heart, diamond, club, spade and value order from A..K.
	Context 'Resetting Deck' {
		It 'Resets the deck back to an unshuffled state.' {
			$deck = [Deck]::new()

			$deck.Shuffle()
			$deck.Reset()
			$actualValues = @($deck.Cards | ForEach-Object { $_.ToString() }) -join ''			
			
			$expectedValues = 'A♥2♥3♥4♥5♥6♥7♥8♥9♥10♥J♥Q♥K♥A♦2♦3♦4♦5♦6♦7♦8♦9♦10♦J♦Q♦K♦A♣2♣3♣4♣5♣6♣7♣8♣9♣10♣J♣Q♣K♣A♠2♠3♠4♠5♠6♠7♠8♠9♠10♠J♠Q♠K♠'
			$expectedValues | Should -BeExactly $actualValues
		}
	}

	# Shuffling the deck will change the order of the cards.
	Context 'Shuffling Deck' {
		It 'Ensure that the card order changes.' {
			$deck = [Deck]::new()

			$cards = $deck.Cards
			$deck.Shuffle()

			$cards | Should -Not -Be ($deck.Cards)
		}
	}

}
