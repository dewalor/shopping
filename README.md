# shopping
simple cashier application that adds products and displays the total price

# to run the application
`mix deps.get` and `MIX_ENV=dev mix compile` in the project directory
`iex -S mix`
```
  iex(1)> Shopping.check_out("SR1")
  "£5.00"
  iex(2)> Shopping.check_out("SR1,SR1")
  "£10.00"
```
