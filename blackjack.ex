defmodule Blackjack do
  def sit_at_table do
    chip_count = 50

    IO.puts "Why hello there, I see that you have #{chip_count} chips. Would you like to play a game of Blackjack?"
    game_start_response = IO.gets "Yes or No "
    response = String.rstrip(game_start_response) |> String.capitalize
    case response do
      "Yes" ->
        deck = Deck.create_deck |> Deck.shuffle
        game(deck, chip_count)
      "Y" ->
        deck = Deck.create_deck |> Deck.shuffle
        game(deck, chip_count)
      "No" ->
        IO.puts "\nGoodbye"
      "N" ->
        IO.puts "\nGoodbye"
      _ ->
        IO.puts "\nLets try this again..."
        Blackjack.sit_at_table
    end
  end

  def game(deck, chip_count) do
    response = IO.gets "\nWhat would you like to bet on this game? "
    bet = String.rstrip(response) |> Integer.parse
    number =
      case bet do
        :error ->
          :error
        _ ->
          elem(bet,0)
      end

    case number do
      :error ->
        IO.puts "\nPlease enter a number greater than zero"
        Blackjack.game(deck, chip_count)
      { _ , ""} when number > chip_count and number > 0 ->
        IO.puts "\nYour total chip count is #{chip_count}, please make a bet equal or less to that value"
        Blackjack.game(deck, chip_count)
      { _ , ""} when number > 0 ->
        [player_hand, deck] = Deck.deal_two(deck)
        [house_hand, deck] = Deck.deal_two(deck)

        Blackjack.dealer_prompt(deck, player_hand, house_hand, number, chip_count)
      _ ->
        IO.puts "\nPlease enter a number greater than zero"
        Blackjack.game(deck, chip_count)
    end
  end

  def dealer_prompt(deck, player_hand, house_hand, bet, chip_count) do
    IO.puts "\nYour hand is:"
    for card <- player_hand do
      IO.puts "#{elem(card,0)}#{elem(card,1)}"
    end
    if Hand.sum_value(player_hand, 0) > 21 do
      IO.puts "\nPlayer busts with #{Hand.sum_value(player_hand, 0)}, YOU LOSE!!"
      chip_count = chip_count - bet
      Blackjack.play_again(deck, chip_count)
    else
      IO.puts "\nYour hand total is: #{Hand.sum_value(player_hand, 0)}"
      Blackjack.hit_or_stand(deck, player_hand, house_hand, bet, chip_count)
    end
  end

  def hit_or_stand(deck, player_hand, house_hand, bet, chip_count) do
    decision = IO.gets "\nWould you like to hit or stand? "
    decision = String.rstrip(decision) |> String.capitalize

    case decision do
      "Hit" ->
        Blackjack.player_hit(deck, player_hand, house_hand, bet, chip_count)
      "Stand" ->
        Blackjack.stand(deck, player_hand, house_hand, bet, chip_count)
      _ ->
        IO.puts "\nPlease enter hit or stand"
        Blackjack.hit_or_stand(deck, player_hand, house_hand, bet, chip_count)
    end
  end

  def player_hit(deck, player_hand, house_hand, bet, chip_count) do
    [new_card, deck] = Deck.deal(deck)
    player_hand = player_hand ++ [new_card]
    Blackjack.dealer_prompt(deck, player_hand, house_hand, bet, chip_count)
  end

  def house_hit(deck, player_hand, house_hand, bet, chip_count) do
    [new_card, deck] = Deck.deal(deck)
    house_hand = house_hand ++ [new_card]
    Blackjack.stand(deck, player_hand, house_hand, bet, chip_count)
  end

  def stand(deck, player_hand, house_hand, bet, chip_count) do
    IO.puts "\nThe Dealer's hand is:"
    for card <- house_hand do
      IO.puts "#{elem(card,0)}#{elem(card,1)}"
    end
    IO.puts "Totalling #{Hand.sum_value(house_hand, 0)}"

    house_hand_sum = Hand.sum_value(house_hand, 0)
    player_hand_sum = Hand.sum_value(player_hand, 0)

    case house_hand_sum do
      house_hand_sum when house_hand_sum > 21 ->
        IO.puts "\nHouse busts, you win!"
        chip_count = chip_count + bet
        Blackjack.play_again(deck, chip_count)
      house_hand_sum when house_hand_sum > player_hand_sum and house_hand_sum > 16 or house_hand_sum == player_hand_sum and house_hand_sum > 16->
        IO.puts "\nHouse Wins!"
        chip_count = chip_count - bet
        Blackjack.play_again(deck, chip_count)
      house_hand_sum when house_hand_sum < player_hand_sum and house_hand_sum > 16 ->
        IO.puts "\nPlayer Wins!"
        chip_count = chip_count + bet
        Blackjack.play_again(deck, chip_count)
      _ ->
        IO.gets "\nHit enter to see the next house card"
        Blackjack.house_hit(deck, player_hand, house_hand, bet, chip_count)
    end
  end

  def play_again(deck, chip_count) do
    IO.puts "\nYou now have #{chip_count} chips"
    if chip_count > 0 do
      IO.puts "Would you like to play again?"
      game_start_response = IO.gets "Yes or No "
      response = String.rstrip(game_start_response) |> String.capitalize
      case response do
        "Yes" ->
          game(deck, chip_count)
        "Y" ->
          game(deck, chip_count)
        "No" ->
          IO.puts "\nThanks for playing, you left the table with #{chip_count} chips!"
        "N" ->
          IO.puts "\nThanks for playing, you left the table with #{chip_count} chips!"
        _ ->
          IO.puts "\nLets try this again..."
          Blackjack.sit_at_table
      end
    else
      "You're out of chips! Come back with more to play again."
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
