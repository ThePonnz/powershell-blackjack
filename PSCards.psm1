Using Namespace System.Collections.Generic

Enum Suit {
	<#
		.SYNOPSIS
		The values suits used for a deck of cards.	
	#>
	Heart = 1
	Diamond = 2
	Club = 3
	Spade = 4
}

Class Card {
	<#
		.SYNOPSIS
		The Card class is an abstraction representing a playing card. The Value property is a 1 - 13 representing aces with a 1, 2 - 10 as their face value, and J - K and 11 - 13 respectively.
	#>

	# All of the values, and their text representation, that can be assigned to a card.
	Static Hidden [Hashtable] $CardValues = @{
		1 = 'A'; 2 = '2'; 3 = '3'; 4 = '4'; 5 = '5'; 6 = '6'; 7 = '7';
		8 = '8'; 9 = '9'; 10 = '10'; 11 = 'J'; 12 = 'Q'; 13 = 'K'
	}

	# All of the suits, and their text representation, that can be assigned to a card.
	Static Hidden [Hashtable] $SuitValues = @{
		[Suit]::Heart = '♥'; [Suit]::Diamond = '♦';
		[Suit]::Club = '♣'; [Suit]::Spade = '♠'
	}

	Card([int] $value, [Suit] $suit) {
		If ($value -notin [Card]::CardValues.Keys) {
			Throw "$value is an invalid card value."
		}
		If ($suit -notin [Card]::SuitValues.Keys) {
			Throw "$suit is an invalid card suit."
		}

		$this.Value = $value
		$this.Suit = $suit
	}

	# The value of the card from 1 to 13.
	[int] $Value
	
	# The suite of the card.
	[Suit] $Suit

	# Returns a string that represents the current object.
	[string] ToString() {
		[string] $cardValue = [Card]::CardValues[$this.Value]
		[string] $cardSuit = [Card]::SuitValues[$this.Suit]
		Return "$cardValue$cardSuit"
	}
}

Class Deck {
	<#
		.SYNOPSIS
		The Deck class is an abstraction representing a deck of 52 cards that doens't include jokers.
	#>

	# The number of suits that are in a single deck.
	Static [int] $SUITS_PER_DECK = 4

	# The number of cards that are in a suit.
	Static [int] $CARDS_PER_SUIT = 13

	# The deck of cards.
	Hidden [List[Card]] $Cards

	Deck() {
		$this.Cards = [List[Card]]::new([Deck]::CARDS_PER_SUIT * [Deck]::SUITS_PER_DECK)
		For ($suitIndex = 1; $suitIndex -le [Deck]::SUITS_PER_DECK; $suitIndex++) {
			For ($valueIndex = 1; $valueIndex -le [Deck]::CARDS_PER_SUIT; $valueIndex++) {
				$card = [Card]::new($valueIndex, $suitIndex)
				$this.Cards.Add($card)
			}
		}
	}

	# Shuffles the cards into a random order.
	Shuffle() {
		$randomizedCards = [List[Card]]::new([Deck]::CARDS_PER_SUIT * [Deck]::SUITS_PER_DECK)
		$random = [Random]::new()
	
		ForEach ($card in $this.Cards) {
			$index = $random.Next(0, $randomizedCards.Count + 1)
			$randomizedCards.Insert($index, $card)
		}
	
		$this.Cards = $randomizedCards
	}

	# Deals a specific number of cards from the deck.
	[Card[]] DealCards([int] $cardCount) {
		If ($cardCount -le 0 -or $cardCount -gt ($this.Cards.Count)) {
			Throw "$cardCount is an invalid number of cards to deal."
		}

		$deltCards = $this.Cards | Select-Object -First $cardCount
		$this.Cards.RemoveRange(0, $cardCount)

		Return $deltCards
	}

}
