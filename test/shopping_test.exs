defmodule ShoppingTest do
  use ExUnit.Case, async: true
  doctest Shopping

  test "raises on an invalid basket data type at checkout" do
    assert_raise FunctionClauseError, fn ->
      Shopping.check_out(["SR1"])
    end
  end

  test "raises on an invalid product list at checkout" do
     assert_raise ArgumentError, fn ->
      Shopping.check_out("SR1oops")
     end
  end

  test "returns 0 for an empty basket" do
    assert Shopping.check_out("") == "0"
  end

  test "gives the right price for a single GR1" do
    assert Shopping.check_out("GR1") == "£3.11"
  end

  test "gives the right price for a single SR1" do
    assert Shopping.check_out("SR1") == "£5.00"
  end

  test "gives the right price for a single CF1" do
    assert Shopping.check_out("CF1") == "£11.23"
  end

  test "gives the right price for a basket with two green teas" do
    assert Shopping.check_out("GR1,GR1") == "£3.11"
  end

  test "gives the right price for a basket with two strawberries" do
    assert Shopping.check_out("SR1,SR1") == "£10.00"
  end

  test "gives the right price for a basket with two coffees" do
    assert Shopping.check_out("CF1,CF1") == "£22.46"
  end

  test "gives the right price for a basket with all three items, no discount" do
    basket = "GR1,SR1,CF1"
    assert Shopping.check_out(basket) == "£19.34"
    assert Shopping.check_out(reorder(basket)) == "£19.34"
  end

  test "gives the right price for a basket with three green teas and other items" do
    basket = "GR1,SR1,GR1,GR1,CF1"
    assert Shopping.check_out(basket) == "£22.45"
    assert Shopping.check_out(reorder(basket)) == "£22.45"
  end

  test "gives the right price for a basket with three strawberries and other items" do
    basket = "SR1,SR1,GR1,SR1"
    assert Shopping.check_out(basket) == "£16.61"
    assert Shopping.check_out(reorder(basket)) == "£16.61"
  end

  test "gives the right price for a basket with four strawberries and other items" do
    basket = "SR1,SR1,GR1,SR1,SR1"
    assert Shopping.check_out(basket) == "£21.11"
    assert Shopping.check_out(reorder(basket)) == "£21.11"
  end

  test "gives the right price for a basket with three coffees and other items" do
    basket = "GR1,CF1,SR1,CF1,CF1"
    assert Shopping.check_out(basket) == "£30.57"
    assert Shopping.check_out(reorder(basket)) == "£30.57"
  end

  test "gives the right price for a basket with four coffees and other items" do
    basket = "GR1,CF1,SR1,CF1,CF1,CF1"
    assert Shopping.check_out(basket) == "£38.06"
    assert Shopping.check_out(reorder(basket)) == "£38.06"
  end

  test "gives the right price for a basket with all three discounts" do
    basket = "SR1,SR1,GR1,SR1,GR1,CF1,CF1,CF1"
    assert Shopping.check_out(basket) == "£39.07"
    assert Shopping.check_out(reorder(basket)) == "£39.07"
  end

  test "gives the right total price in GBP pennies when adding the second coffee" do
    assert Shopping.calculate_total_price(:CF1, 2, 1123) == 2246
  end

  test "gives the right total price in GBP pennies when adding the third coffee" do
    assert Shopping.calculate_total_price(:CF1, 3, 2246) == 2246
  end

  test "gives the right total price in GBP pennies when adding the fourth coffee" do
    assert Shopping.calculate_total_price(:CF1, 4, 2246) == 2995
  end

  test "gives the right total price in GBP pennies when adding the third green tea" do
    assert Shopping.calculate_total_price(:GR1, 3, 311) == 622
  end

  test "gives the right total price in GBP pennies when adding the fourth green tea" do
    assert Shopping.calculate_total_price(:GR1, 4, 622) == 622
  end

  test "gives the right total price in GBP pennies when adding the third strawberry" do
    assert Shopping.calculate_total_price(:SR1, 3, 1000) == 1350
  end

  test "gives the right total price in GBP pennies when adding the fourth strawberry" do
    assert Shopping.calculate_total_price(:SR1, 4, 1350) == 1800
  end

  defp reorder(items) when is_binary items do
    String.split(items, ",", trim: true)
              |> Enum.shuffle()
              |> Enum.join(",")
  end
end
