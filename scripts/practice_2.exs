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

# Function Arity - When Arguments Matter
# Arity denotes number of arguments for a function. Example: hello/2
# means function hello has arity 2. So function hello has 2 arguments.
# Arity 2 means 2 arguments. Arity 3 means 3 arguments.
defmodule Greeter do
  # Function with arity 1
  def hello(name) do
    "Hello, #{name}!"
  end

  # Function with arity 2 - different function despite same name
  def hello(name, language) do
    case language do
      "English" -> "Hello, #{name}!"
      "Spanish" -> "Hola, #{name}!"
      "French" -> "Bonjour, #{name}!"
      "German" -> "Hallo, #{name}!"  # or "Guten tag, #{name}"
      _ -> "Unsupported language"
    end
  end

  # Function with arity 3
  def hello(name, language, formal) do
    greeting = hello(name, language)
    if formal do
      String.replace(greeting, name, "Mr./Ms. #{name}")
    else
      greeting
    end
  end
end

IO.puts("\n")
IO.puts(Greeter.hello("Alice"))
IO.puts(Greeter.hello("Bob", "Spanish"))
IO.puts(Greeter.hello("Charlie", "French", true))

# ------------------------------------------------------
# Advanced Boolean Checking
# ------------------------------------------------------

IO.puts("\n--- Additional Boolean Examples ---")

# 1. Using 'unless' (the opposite of 'if')
authenticated = false
unless authenticated do
  IO.puts("Access Denied: Please log in.")
end

# 2. Using 'cond' for multiple boolean conditions
age = 20
category = cond do
  age < 13 -> "Child"
  age < 20 -> "Teenager"
  true     -> "Adult" # The 'true' acts as a catch-all (else)
end
IO.puts("Category: #{category}")

# 3. Truthiness: Everything except 'false' and 'nil' is true
defmodule TruthyChecker do
  def check(val) do
    if val, do: "Truthy", else: "Falsy"
  end
end

IO.puts("Is 0 truthy? #{TruthyChecker.check(0)}")      # Truthy (unlike JS/C)
IO.puts("Is \"\" truthy? #{TruthyChecker.check("")}")   # Truthy
IO.puts("Is nil truthy? #{TruthyChecker.check(nil)}")   # Falsy


# Pattern matching on function head
defmodule ShapeCalculator do
  # Pattern matching on tuple structure
  def area({:circle, radius}) do
    3.14159 * radius * radius
  end

  def area({:rectangle, width, height}) do
    width * height
  end

  def area({:triangle, base, height}) do
    0.5 * base * height
  end

  # Pattern matching with guards
  def describe_number(n) when n < 0, do: "negative"                      # no need of end here for do
  def describe_number(0), do: "zero"                                     # no need of end here for do
  def describe_number(n) when n > 0 and n < 10, do: "Single digit"       # no need of end here for do
  def describe_number(n) when n >= 10, do: "Multiple digits"             # no need of end here for do
end

IO.puts("\n")
circle = {:circle, 5}
rectangle = {:rectangle, 4, 6}
triangle = {:triangle, 8, 3}

IO.puts("Area of Circle: #{ShapeCalculator.area(circle)}")
IO.puts("Area of Rectangle: #{ShapeCalculator.area(rectangle)}")
IO.puts("Area of Triangle: #{ShapeCalculator.area(triangle)}")

IO.puts("Number 5 is: #{ShapeCalculator.describe_number(5)}")
IO.puts("Number -3 is: #{ShapeCalculator.describe_number(-3)}")
IO.puts("Number 15 is: #{ShapeCalculator.describe_number(15)}")


# ------------------------------------------------------
# Default Arguments - Flexibility Without Complexity
defmodule Coffeeshop do
  # Function with default arguments
  def make_order(drink, size \\ :medium, milk_type \\ :regular, extra_shots \\ 0) do
    base_price = case size do
      :small -> 3.50
      :medium -> 4.50
      :large -> 5.50
    end

    milk_cost = case milk_type do
      :regular -> 0.00
      :almond -> 0.60
      :oat -> 0.65
      :soy -> 0.55
    end

    shots_cost = extra_shots * 0.75
    total = base_price + milk_cost + shots_cost

    %{
      drink: drink,
      size: size,
      milk: milk_type,
      shots: extra_shots,
      total: total
    }
  end
end

# Using defaults
IO.puts("\n")
simple_order = Coffeeshop.make_order("Latte")
IO.inspect(simple_order, label: "Simple order")

# Overriding some defaults
custom_order = Coffeeshop.make_order("Cappuccino", :large, :oat, 2)
IO.inspect(custom_order, label: "Custom order")

# Partial override
medium_order = Coffeeshop.make_order("Americano", :medium, :almond)
IO.inspect(medium_order, label: "Medium with almond milk")

# ------------------------------------------------------
#
# Higher Order Functions - Functions That Work With Functions
defmodule DataProcessor do
  # A higher order function takes a function as argument
  def transform_list(list, transformer_func) do
    Enum.map(list, transformer_func)
  end

  # Function that can be passed to higher order functions
  def double(x), do: x * 2
  def square(x), do: x * x
  def add_exclamation(text), do: text <> "!"    # <> is used for concatenation in elixir
end

numbers = [1, 2, 3, 4, 5]
words = ["hello", "world", "elixir"]
IO.puts("\n")

# Using named functions
doubled = DataProcessor.transform_list(numbers, &DataProcessor.double/1)  # double/1 means function double with arity 1. So function double has 1 argument
squared = DataProcessor.transform_list(numbers, &DataProcessor.square/1)  # square/1 means function square with arity 1. So function square has 1 argument

# Using anonymous function
incremented = DataProcessor.transform_list(numbers, fn x -> x + 10 end)
excited_words = DataProcessor.transform_list(words, &DataProcessor.add_exclamation/1) # & is the capture operator. It captures a function(with arity) reference  from a module.

IO.inspect(doubled, label: "Doubled")
IO.inspect(squared, label: "Squared")
IO.inspect(incremented, label: "Incremented")
IO.inspect(excited_words, label: "Excited Words")

# Note:
# & capture operator. It captures a function reference from a
# module. While using & operator you must mention the function arity.
# Example: &DataProcessor.square/1
# Here, & captures the square function with arity 1 from DataProcessor module.
# "&DataProcessor.square/1" in this form we can treat the function as data and
# pass it to a higher order function like an argument.

#--------------------------------------------------
# Map
#--------------------------------------------------
# In Elixir, a Map is the "go-to" data structure for key-value stores. They are incredibly flexible because keys can be any data type (though atoms and strings are the most common).
# Here is a breakdown of the syntax and how to use them.
# 1. Basic Syntax
# Maps are defined using the %{} syntax.
#
# Atom Keys (Most Common)
# When your keys are atoms, Elixir provides a "shorthand" syntax that looks similar to JSON or Ruby.
# # Shorthand syntax
# user = %{name: "Alice", age: 30}
#
# # Standard syntax (equivalent to the above)
# user = %{:name => "Alice", :age => 30}
#
# Generic Keys (The "Arrow" Syntax)
# If you want to use strings, integers, or even other maps as keys, you must use the => (fat arrow) syntax.
# # String keys
# settings = %{"theme" => "dark", "notifications" => true}
#
# # Mixed keys
# mixed = %{"first_name" => "Bob", :id => 1, 100 => "Score"}
#
# 2. Accessing ValuesThere are two primary ways to get data out of a map:
# Dot Notation: Only works for atom keys.
# If the key doesn't exist, it raises an error.
# user.name extracts the value "Alice". So user.name --> "Alice"
#
# Bracket Syntax: Works for any key type. If the key doesn't exist, it returns nil.
# settings["theme"] extracts the value "dark". So settings["theme"] --> "dark"
# user[:age] extracts the value 30. So user[:age] --> 30
#
# 3. Updating Maps
# Maps in Elixir are immutable. When you "update" a map, you are actually creating a new map with the changes.
# The Update Operator (|)
# This is a high-performance way to update a value, but it only works if the key already exists in the map.
# user = %{name: "Alice", age: 30}
# updated_user = %{user | age: 31}
# # Result: %{name: "Alice", age: 31}
#
# Map Module
# For adding new keys or working with dynamic keys, use the Map module:
# Map.put(user, :location, "London")
# Result: %{name: "Alice", age: 30, location: "London"}
#
# 4. Pattern Matching
# This is one of Elixir's most powerful features. You can "destructure" a map to extract values into variables.
# %{name: user_name} = %{name: "Alice", age: 30}
# user_name is now "Alice"
# Note: When pattern matching, the map on the left only needs to match a subset of the map on the right.
# This makes it perfect for function arguments where you only care about specific fields.
# Syntax Examples:
# Empty Map	--> %{}
# Map Creation -->	%{key: value} (Atoms) or %{"key" => value} (Others)
# Access (Strict)	--> map.key
# Access (Safe)	--> map[:key] or Map.get(map, :key)
# Insert/Update	--> Map.put(map, :new_key, value)


# Putting It All Together - A Complete Function Pipeline
defmodule OrderSystem do
  # Multiple function definitions with pattern matching
  def validate_order(%{items: items, customer: customer}) when length(items) > 0 do
    {:ok, %{items: items, customer: customer, status: :validated}}
  end

  def validate_order(_), do: {:error, "Invalid order"} # here _ is Catch all scenario. It would catch all those validate_order function that doesn't match all those previous validate_order functions signature.

  def calculate_subtotal(%{items: items} = order) do
    subtotal = items
    |> Enum.map(fn %{price: price, quantity: quantity} -> price * quantity end)
    |> Enum.sum

    Map.put(order, :subtotal, subtotal)
  end

  def apply_tax(%{subtotal: subtotal} = order, rate \\ 0.08) do
    tax = Float.round(subtotal * rate, 2)
    order
    |> Map.put(:tax, tax)
    |> Map.put(:total, subtotal + tax)
  end

  def process_order(raw_order) do
    with {:ok, validate_order} <- validate_order(raw_order) do
      validate_order
      |> calculate_subtotal()
      |> apply_tax()
      |> Map.put(:status, :processed)
    else
      {:error, reason} -> {:error, reason}
    end
  end
end

# This code snippet demonstrates a classic Elixir pattern called a "Happy Path" pipeline. It uses the with construct to handle potential errors gracefully while keeping the main logic readable.

# Here is the breakdown of how it works:

# 1. The with Special Form
# The with statement is used to chain together operations that might fail.

# The Match: {:ok, validate_order} <- validate_order(raw_order)
# This says: "Call validate_order. If it returns a tuple starting with :ok, extract the second value and name it validate_order. Then, proceed to the do block."

# The Failure: If validate_order returns something that doesn't match (like {:error, reason}), the code skips the do block entirely and jumps to the else block.

# 2. The else Block (Error Handling)
# This section catches anything that didn't match the <- arrow in the with statement.

# 1. Breaking down {:error, reason} -> {:error, reason}
# This specific line is a Pattern Match instruction:

# Left side ({:error, reason}): This is the pattern the code is looking for. It says: "If the result is a 2-element tuple where the first element is the atom :error, then take whatever is in the second position and assign it to a variable named reason."

# The Arrow (->): This means "if the above matches, then do this..."

# Right side ({:error, reason}): This is the result the function actually returns. In this case, it’s just passing the error along exactly as it found it.
# One small tip:
# You don't always have to include the else block in a with statement. If you leave it out, and the match fails, Elixir will simply return the failed value (the error tuple) automatically.

# However, explicitly writing {:error, reason} -> {:error, reason} is common when you want to be very clear about what your function returns, or if you want to log the error before returning it.

# Why use with instead of if/else?
# If you used nested if statements, your code would look like a "Pyramid of Doom." The with macro keeps everything flat and readable. If you had 5 more steps (checking inventory, charging credit cards, etc.), you could just add more <- lines to the with block without nesting deeper.
#
#1. The Left Arrow <- (The "Success" Gate)
# Think of <- as a conditional filter. It is almost exclusively used in with and for (Comprehensions).

# Used inside a with or for block
# Context: with or for.

# Behavior: It tries to match the right side against the left side. If it matches, the variable is bound and the code moves to the next line. If it fails to match, it stops the whole chain and returns the value that failed.
# Example:
# with {:ok, user} <- find_user(id),      # MUST be {:ok, user} to continue
#      {:ok, card} <- get_credit_card(user) # MUST be {:ok, card} to continue
# do
#   charge(card)
# end

# 2. The Right Arrow -> (The "Choice" Branch)
# Think of -> as a switch or a map. It maps a pattern to a consequence.

# Used in case, cond, else, or fn
# Context: case, receive, cond, else blocks, and anonymous functions.

# Behavior: It defines a branch. It says "If the data looks like the left side, execute the block on the right side."

# Example:
# case validate_order(order) do
#   {:ok, valid_data} ->  # IF it looks like this...
#     process(valid_data) # THEN do this.

#   {:error, reason} ->   # IF it looks like this...
#     handle_error(reason) # THEN do this.
# end

# Test order
order = %{
  customer: "Alice",
  items: [
    %{name: "coffee", price: 4.50, quantity: 2},
    %{name: "muffin", price: 3.25, quantity: 1}
  ]
}

result = OrderSystem.process_order(order)
IO.puts("\n")
IO.inspect(result, label: "Processed order")

# Test invalid order
invalid_result = OrderSystem.process_order(%{customer: "Bob", items: []})
IO.inspect(invalid_result, label: "Invalid order result")
