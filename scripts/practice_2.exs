# ------------------------------------------------------
# Functions - The heart of Elixir
# ------------------------------------------------------

# Creating an anonymous function
add_numbers = fn a, b -> a + b end

# Calling the anonymous function
result = add_numbers.(5, 3)
IO.puts("The sum is: #{result}")
IO.puts(result) # we can directly print the variable without "#{}". But we need #{} to print the value within a doube quote("").

# A more complex anonymous function
calculate_tip = fn bill, tip_percentage ->
  tip = bill * (tip_percentage / 100)
  total = bill + tip
  {tip, total}
end

{tip_amount, final_bill} = calculate_tip.(28, 15)
IO.puts("Tip: #{tip_amount}, Total: #{final_bill}")


# Named Functions - Building Your Function Library
defmodule RestaurantHelper do
  def calculate_discount(bill, discount_percentage) do
    discount_amount = bill * (discount_percentage/100)
    bill - discount_amount
  end

  def apply_senior_discount(bill) do
    calculate_discount(bill, 15)
  end

  def apply_student_discount(bill) do
    calculate_discount(bill, 10)
  end
end

original_bill = 50.00
senior_price = RestaurantHelper.apply_senior_discount(original_bill)
student_price = RestaurantHelper.apply_student_discount(original_bill)

IO.puts("\n")
IO.puts("Original Bill: #{original_bill}")
IO.puts("Senior price after Discount: #{senior_price}")
IO.puts("Student price after Discount: #{student_price}")

# Nested functions vs functions with pipe operator
defmodule OrderProcessor do
  def add_tax(amount, rate \\ 0.08) do  # In Elixir, the \\ operator is used to define a default value for a function argument.
    amount * (1 + rate)
  end

  def add_tip(amount, tip_percent \\ 15) do
    amount * (1 + tip_percent / 100)
  end

  def round_to_cents(amount) do
    Float.round(amount, 2)
  end
end

# Traditional nested function calls (hard to read)
# Here you have to call functions from bottom to top of the defmodule
IO.puts("\n")
final_amount_nested = OrderProcessor.round_to_cents(
  OrderProcessor.add_tip(
    OrderProcessor.add_tax(25.00, 0.10), 20
  )
)

# Using the pipe operator (much cleaner)
# Pipe operator takes the output of the previous
# function as the first argument for the next function
final_amount_piped = 25.00
|> OrderProcessor.add_tax(0.10)
|> OrderProcessor.add_tip(20)
|> OrderProcessor.round_to_cents()

IO.puts("Final Amount (nested approach): #{final_amount_nested}")
IO.puts("Final Amount (piped approach): #{final_amount_piped}")
