Using Module '..\PSCards.psm1'

Describe 'Take-DealerTurn' {

	Context 'Script Parameters' {
		It 'Should have the required, not-nullable parameter named Deck.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)

			Get-Command '.\Take-DealerTurn' | Should -HaveParameter 'Deck' -Mandatory -Type $deck.GetType()
			{ & '.\Take-DealerTurn' -Deck $null -Hand $hand } | Should -Throw
		}
	}
	
	Context 'Script Parameters' {
		It 'Should have the required, not-nullable parameter named Hand that allows an empty collection.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)

			Get-Command '.\Take-DealerTurn' | Should -HaveParameter 'Hand' -Mandatory -Type $hand.GetType()
			{ & '.\Take-DealerTurn' -Deck $deck -Hand $null } | Should -Throw
			{ & '.\Take-DealerTurn' -Deck $deck -Hand $hand } | Should -Not -Throw
		}
	}

	Context 'Return Value' {
		It 'Returns a hashtable with the keys DidHit, DidStand, Score, and Hand.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)
			$cardType = [Card]::new(2, [Suit]::Heart).GetType()

			$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hand

			$state | Should -Not -BeNullOrEmpty
			$state | Should -BeOfType [Hashtable]
			$state.Keys | Should -Contain 'DidHit'
			$state.DidHit | Should -BeOfType [bool]
			$state.Keys | Should -Contain 'DidStand'
			$state.DidStand | Should -BeOfType [bool]
			$state.Keys | Should -Contain 'Score'
			$state.Score | Should -BeOfType [Hashtable]
			$state.Keys | Should -Contain 'Hand'
			$state.Hand | Should -HaveCount 1
			$state.Hand[0] | Should -BeOfType $cardType
		}
	}

	Context 'Dealer Logic' {
		It 'Already over 21 should return the busted, non-hit state.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)
			$hand += [Card]::new(10, [Suit]::Heart)
			$hand += [Card]::new(10, [Suit]::Diamond)
			$hand += [Card]::new(10, [Suit]::Club)
			$originalHand = [Card[]]::new(3)
			[Array]::Copy($hand, $originalHand, 3)

			$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hand

			$state.DidHit | Should -Be $false
			$state.DidStand | Should -Be $false
			$state.Score.IsBusted | Should -Be $true
			$originalHand | Should -Be $state.Hand
		}
	}

	Context 'Dealer Logic' {
		It 'Already over 16 should return a stood, not busted state.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)
			$hand += [Card]::new(10, [Suit]::Heart)
			$hand += [Card]::new(7, [Suit]::Diamond)
			$originalHand = [Card[]]::new(2)
			[Array]::Copy($hand, $originalHand, 2)

			$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hand

			$state.DidHit | Should -Be $false
			$state.DidStand | Should -Be $true
			$state.Score.IsBusted | Should -Be $false
			$originalHand | Should -Be $state.Hand
		}
	}

	Context 'Dealer Logic' {
		It '16 or under should hit.' {
			$deck = [Deck]::new()
			$hand = [Card[]]::new(0)
			$hand += [Card]::new(2, [Suit]::Heart)
			$hand += [Card]::new(2, [Suit]::Diamond)

			$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hand

			$state.DidHit | Should -Be $true
			$state.DidStand | Should -Be $false
			$state.Hand | Should -HaveCount 3
			$state.Score.IsBusted | Should -Be $false
			$originalHand | Should -Not -Be $state.Hand
		}
	}

	Context 'Dealer Logic' {
		It '17 or over should stand.' {
			$deck = [Deck]::new()
			$deck.Cards.Insert(2, [Card]::new(2, [Suit]::Heart))
			$hand = [Card[]]::new(0)
			$hand += [Card]::new(10, [Suit]::Heart)
			$hand += [Card]::new(7, [Suit]::Diamond)

			$state = & '.\Take-DealerTurn' -Deck $deck -Hand $hand

			$state.DidHit | Should -Be $false
			$state.DidStand | Should -Be $true
		}
	}

}