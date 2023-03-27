Using Namespace System.Collections.Generic

Enum Suit {
	Heart = 1
	Diamond = 2
	Club = 3
	Spade = 4
}

Class Card {

	static [Hashtable] $CardValues = @{
		1 = 'A'; 2 = '2'; 3 = '3'; 4 = '4'; 5 = '5'; 6 = '6'; 7 = '7';
		8 = '8'; 9 = '9'; 10 = '10'; 11 = 'J'; 12 = 'Q'; 13 = 'K'
	}

	static [Hashtable] $SuitValues = @{
		[Suit]::Heart = '♥'; [Suit]::Diamond = '♦';
		[Suit]::Club = '♣'; [Suit]::Spade = '♠'
	}

	Card([int] $value, [Suit] $suit) {
		If ($value -lt 1 -or $value -gt 13) {
			Throw "$value is an invalid card value."
		}
		If ($suit -lt 1 -or $suit -gt 4) {
			Throw "$suit is an invalid card suit."
		}
		
		$this.Value = $value
		$this.Suit = $suit
	}

	[int] $Value
	
	[Suit] $Suit

	[string] ToString() {
		[string] $cardValue = [Card]::CardValues[$this.Value]
		[string] $cardSuit = [Card]::SuitValues[$this.Suit]
		Return "$cardValue$cardSuit"
	}
}

Class Deck {

	Hidden [List[Card]] $Cards

	Deck() {
		$this.Reset()
	}

	Reset() {
		$this.Cards = New-Object 'List[Card]'
		For ($suitIndex = 1; $suitIndex -le 4; $suitIndex++) {
			For ($valueIndex = 1; $valueIndex -le 13; $valueIndex++) {
				$card = [Card]::new($valueIndex, $suitIndex)
				$this.Cards.Add($card)
			}
		}
	}

	Shuffle() {
		$randomizedCards = New-Object 'List[Card]' -ArgumentList @(52)
		$random = New-Object 'Random'
	
		ForEach ($card in $this.Cards) {
			$index = $random.Next(0, $randomizedCards.Count + 1)
			$randomizedCards.Insert($index, $card)
		}
	
		$this.Cards = $randomizedCards
	}

	[Card[]] DealCards([int] $cardCount) {
		If ($cardCount -le 0 -or $cardCount -gt ($this.Cards.Count)) {
			Throw "$cardCount is an invalid number of cards to deal."
		}

		$deltCards = $this.Cards | Select-Object -First $cardCount
		$this.Cards.RemoveRange(0, $cardCount)

		Return $deltCards
	}

}
