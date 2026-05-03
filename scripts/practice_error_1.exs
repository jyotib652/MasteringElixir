#-----------------------------------
# Error handling in Elixir
#-----------------------------------
# We'll learn
# 1. How to raise exceptions using raise
# 2. How to catch exceptions with try and rescue block
# 3. The difference between errors and throws in Elixir
# 4. When to rescue and when to let process crash

# Very simple example of try and rescue
# Remember try and rescue block returns a value
result = try do
  # simulate a risky calculation
  10 / 0
rescue
  ArithmeticError ->
    "Oops! can't divide by zero."
end

IO.puts(result)


# Another very simple example of try and rescue
result = try do
  # simulate a risky calculation
  10 / 0
rescue
  ArithmeticError ->
    "Oops! can't divide by zero."

  RuntimeError ->
    "Something unexpected happened"
end

IO.puts(result)

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Raising an error which creates an error struct behind the scene
# and then rescuing it(error)
try do
  raise "Wallet is empty"
rescue
  e in RuntimeError ->
    IO.puts("Caught: #{inspect(e.message)}")
end

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another example of Raising an error which creates an error struct behind the scene
# and then rescuing it(error)
try do
  IO.puts("Openning saved game file...")
  raise "save file corrupted"
rescue
  e in RuntimeError ->
    IO.puts("Error: #{e.message}")
after             # here this after block runs no matter what.
  IO.puts("Closing file handle.")
end

# Note:
# Notice there is no timeout for this after block.
# This after block will always run. It doesn't matter if the
# code succeed or it raise an error or it rescued. No matter what
# it always run this after block everytime.



# *** Important
# Errors raised with raise are exceptional, unexpected situations you rescue from.
# Throws using throw and catch are for non-local returns when you need to exit
# deeply nested code.Errors are common.Throws are rare and reserved for control
# flow that has no better alternative.
# Throws are sign that a different design might be worth considering.

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Validation function for fitness application: Rescuing multiple error types
defmodule Validator do
  def check_age(age) do
    try do
      if !is_integer(age) do
        raise ArgumentError, message: "Not a number"
      end

      if age < 0 do
        raise RuntimeError, message: "Age is negative"
      end

      if age > 150 do
        raise RuntimeError, message: "Unrealistic age"
      end

      IO.puts("Valid age: #{age}")
    rescue
      e in ArgumentError ->
        IO.puts("Bad input: #{e.message}")
      e in RuntimeError ->
        IO.puts("Logic error: #{e.message}")
    end
  end
end

Validator.check_age("twenty")
Validator.check_age(-5)
Validator.check_age(25)
Validator.check_age(165)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Shopping cart. Generic errors aren't always descriptive enough. Here we're defining custom exception
# module called insufficient funds using defexception.
defmodule InsufficientFunds do
  defexception message: "Not enough money"
end

try do
  balance = 10
  cost = 25
  if cost > balance do
    raise InsufficientFunds
  end
rescue
  e in InsufficientFunds ->
    IO.puts(e.message)

end

# Overriding the default message of InsufficientFundsTwo exception.
defmodule InsufficientFundsTwo do
  defexception message: "Not enough money"
end

try do
  balance = 10
  cost = 25
  if cost > balance do
    raise InsufficientFundsTwo, message: "Balance too low: need $25."
  end
rescue
  e in InsufficientFundsTwo ->
    IO.puts(e.message)

end


#### Important ###########
# Catching all exceptions with a bare rescue hides bugs.
# Always match on specific error types. In Elixir, the philosophy
# is to let processes crash and let supervisor restart them. Only
# rescue when you have meaningful recovery strategy.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Kitchen temparature converter
defmodule Kitchen do
  def converter_temp(input) do
    try do
      temp = String.to_integer(input)
      fahrenheit = temp * 9 / 5 + 32
      if fahrenheit < -273 do
        raise RuntimeError
      end
      IO.puts("#{temp}C = #{fahrenheit}F")
    rescue
      ArgumentError ->
        IO.puts("Please enter a number")
      RuntimeError ->
        IO.puts("Below absolute zero!!!!")
    end
  end
end

Kitchen.converter_temp("100")
Kitchen.converter_temp("hot")
Kitchen.converter_temp("-274")


# Note:
# In Elixir, the / operator always performs floating-point division

# 1. Use raise with a string for quick RuntimeErrors or specify an error module for precision.
# 2. Wrap risky code in try and rescue block to handle exceptions gracefully, and use after for
# guaranted cleanup.
# 3. Errors use raise and rescue for exceptional situations. Throws use throw and catch for rare
# non-local returns.
# 4. Always rescue specific error types. Let processes crash when you have no meaningful recovery.
# Trust the supervision tree.
