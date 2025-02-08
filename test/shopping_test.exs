defmodule ShoppingTest do
  use ExUnit.Case, async: true
  doctest Shopping

  test "raises on an invalid basket data type" do
    assert_raise FunctionClauseError, fn ->
      Shopping.check_out(["SR1"])
    end
  end

  test "raises on an invalid product list" do
     assert_raise FunctionClauseError, fn ->
      Shopping.check_out(["SR1oops"])
     end
   end

  test "returns 0 for an empty basket" do
    assert Shopping.check_out("") == 0
  end

  test "gives the right price for a single GR1" do
    assert Shopping.check_out("GR1") == 311
  end

  test "gives the right price for a single SR1" do
    assert Shopping.check_out("SR1") == 500
  end

  test "gives the right price for a single CF1" do
    assert Shopping.check_out("CF1") == 1123
  end

  test "gives the right price for a basket with two green teas" do
    assert Shopping.check_out("GR1,GR1") == 311
  end

  test "gives the right price for a basket with two strawberries" do
    assert Shopping.check_out("SR1,SR1") == 1000
  end

  test "gives the right price for a basket with two coffees" do
    assert Shopping.check_out("CF1,CF1") == 2246
  end

  test "gives the right price for a basket with all three items, no discount" do
    basket = "GR1,SR1,CF1"
    assert Shopping.check_out(basket) == 1934
    assert Shopping.check_out(reorder(basket)) == 1934
  end

  test "gives the right price for a basket with three green teas and other items" do
    basket = "GR1,SR1,GR1,GR1,CF1"
    assert Shopping.check_out(basket) == 2245
    assert Shopping.check_out(reorder(basket)) == 2245
  end

  test "gives the right price for a basket with three strawberries and other items" do
    basket = "SR1,SR1,GR1,SR1"
    assert Shopping.check_out(basket) == 1661
    assert Shopping.check_out(reorder(basket)) == 1661
  end

  test "gives the right price for a basket with four strawberries and other items" do
    basket = "SR1,SR1,GR1,SR1,SR1"
    assert Shopping.check_out(basket) == 2111
    assert Shopping.check_out(reorder(basket)) == 2111
  end

  test "gives the right price for a basket with three coffees and other items" do
    basket = "GR1,CF1,SR1,CF1,CF1"
    assert Shopping.check_out(basket) == 3057
    assert Shopping.check_out(reorder(basket)) == 3057
  end

  test "gives the right price for a basket with four coffees and other items" do
    basket = "GR1,CF1,SR1,CF1,CF1,CF1"
    assert Shopping.check_out(basket) == 3806
    assert Shopping.check_out(reorder(basket)) == 3806
  end

  test "gives the right price for a basket with all three discounts" do
    basket = "SR1,SR1,GR1,SR1,GR1,CF1,CF1,CF1"
    assert Shopping.check_out(basket) == 3907
    assert Shopping.check_out(reorder(basket)) == 3907
  end

  defp reorder(items) when is_binary items do
    String.split(items, ",", trim: true)
              |> Enum.shuffle()
              |> Enum.join(",")
  end
end
