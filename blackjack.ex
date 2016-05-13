defmodule Blackjack do
  def game do
    IO.puts "Hello, welcome to Blackjack. Would you like to start a game?"
    game_start_response = IO.gets "Yes or No "

    if String.rstrip(game_start_response) |> String.capitalize == "Yes" do
      deck = Deck.create_deck |> Deck.shuffle
      [player_hand, deck] = Deck.deal_two(deck)
      [house_hand, deck] = Deck.deal_two(deck)

      Blackjack.dealer_prompt(deck, player_hand, house_hand)
    else
      IO.puts "Goodbye"
    end
  end

  def dealer_prompt(deck, player_hand, house_hand) do
    IO.puts "Your hand is:"
    for card <- player_hand do
      IO.puts "#{elem(card,0)}#{elem(card,1)}"
    end
    if Hand.sum_value(player_hand, 0) > 21 do
      IO.puts "Player busts with #{Hand.sum_value(player_hand, 0)}, YOU LOSE!!"
      Blackjack.play_again
    else
      IO.puts "Your hand total is: #{Hand.sum_value(player_hand, 0)}"
      Blackjack.hit_or_stand(deck, player_hand, house_hand)
    end
  end

  def hit_or_stand(deck, player_hand, house_hand) do
    decision = IO.gets "Would you like to hit or stand? "
    decision = String.rstrip(decision) |> String.capitalize

    case decision do
      "Hit" ->
        Blackjack.player_hit(deck, player_hand, house_hand)
      "Stand" ->
        Blackjack.stand(deck, player_hand, house_hand)
      _ ->
        IO.puts "Please enter hit or stand"
        Blackjack.hit_or_stand(deck, player_hand, house_hand)
    end
  end

  def player_hit(deck, player_hand, house_hand) do
    [new_card, deck] = Deck.deal(deck)
    player_hand = player_hand ++ [new_card]
    Blackjack.dealer_prompt(deck, player_hand, house_hand)
  end

  def house_hit(deck, player_hand, house_hand) do
    [new_card, deck] = Deck.deal(deck)
    house_hand = house_hand ++ [new_card]
    Blackjack.stand(deck, player_hand, house_hand)
  end

  def stand(deck, player_hand, house_hand) do
    IO.puts "Dealer has #{Hand.sum_value(house_hand, 0)}"
    house_hand_sum = Hand.sum_value(house_hand, 0)
    player_hand_sum = Hand.sum_value(player_hand, 0)

    case house_hand_sum do
      house_hand_sum when house_hand_sum > 21 ->
        IO.puts "House busts, you win!"
        Blackjack.play_again
      house_hand_sum when house_hand_sum > player_hand_sum and house_hand_sum > 16 or house_hand_sum == player_hand_sum and house_hand_sum > 16->
        IO.puts "House Wins!"
        Blackjack.play_again
      house_hand_sum when house_hand_sum < player_hand_sum and house_hand_sum > 16 ->
        IO.puts "Player Wins!"
        Blackjack.play_again
      _ ->
        IO.gets "Hit enter for the next house card"
        Blackjack.house_hit(deck, player_hand, house_hand)
    end
  end

  def play_again do
    IO.puts "Would you like to play again?"
    game_start_response = IO.gets "Yes or No "

    if String.rstrip(game_start_response) |> String.capitalize == "Yes" do
      Blackjack.game
    else
      IO.puts "Goodbye"
    end
  end
end

defmodule Deck do
  @suits ["♠", "♥", "♦", "♣"]
  @values ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]

  def create_deck do
    for v <- @values, s <- @suits, do: { v, s }
  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  def deal([card | deck]) do
    [card, deck]
  end

  def deal_two(deck) do
    [card1, deck] = deal(deck)
    [card2, deck] = deal(deck)
    [[card1, card2], deck]
  end
end

defmodule Hand do
  def is_face_card({value, _}), do: String.contains?("JQK", value)

  def sum_value([], acc) do
    acc
  end

  def sum_value([head | tail], acc) do
    face_card = Hand.is_face_card(head)

    case head do
      {"A", _ } when acc > 10 ->
        sum_value(tail, 1 + acc)
      {"A", _ } when acc <= 10 ->
        sum_value(tail, 11 + acc)
      _ when face_card ->
        sum_value(tail, 10 + acc)
      _ ->
        sum_value(tail, String.to_integer(elem(head, 0)) + acc)
    end
  end
end
