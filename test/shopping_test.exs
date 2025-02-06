defmodule ShoppingTest do
  use ExUnit.Case
  doctest Shopping

  test "gives the right price for a single GR1" do
    assert Shopping.check_out("GR1") == 311
  end

  test "gives the right price for a single SR1" do
    assert Shopping.check_out("SR1") == 500
  end

  test "gives the right price for a single CF1" do
    assert Shopping.check_out("CF1") == 1123
  end

  test "returns 0 for an empty basket" do
    assert Shopping.check_out("") == 0
  end

  test "gives the right price for a basket with all three items, no discount" do
    assert Shopping.check_out("GR1,SR1,CF1") == 1934
  end

  test "gives the right price for a basket with an odd number of green teas" do
    assert Shopping.check_out("GR1,SR1,GR1,GR1,CF1") == 2245
  end

  test "gives the right price for a basket with two green teas" do
    assert Shopping.check_out("GR1,GR1") == 311
  end

  test "gives the right price for a basket with three strawberries" do
    assert Shopping.check_out("SR1,SR1,GR1,SR1") == 1661
  end

  test "gives the right price for a basket with four strawberries" do
    assert Shopping.check_out("SR1,SR1,GR1,SR1,SR1") == 2111
  end

  test "gives the right price for a basket with three coffees" do
    assert Shopping.check_out("GR1,CF1,SR1,CF1,CF1") == 3057
  end

  test "gives the right price for a basket with four coffees" do
    assert Shopping.check_out("GR1,CF1,SR1,CF1,CF1,CF1") == 3806
  end

  # 3 SR1 2 GR1 3 CF1   
  # test "gives the right price for a basket with all three discounts" do
  #   assert Shopping.check_out("SR1,SR1,GR1,SR1,GR1,CF1,CF1,CF1") ==
  # end
end
