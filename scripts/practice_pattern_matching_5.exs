#----------------------------------------
# Pattern Matching: Pin Operator
#----------------------------------------

# The main use of Pin (^) operator is:
# to match against existing variable values and
# preventing accidental variable rebinding.

x = 42
{x, y} = {100, 200}
IO.inspect(x)  # What do you think this prints?
IO.inspect(y)

# Here the x rebiands with the new value 100 and the previous value 42 is gone.

IO.puts("")
#----------------------------------------------------------------------------------------------------

x = 42
{^x, y} = {42, 200}  # Here, we're telling to match the current value of x not rebind to a new value. So it will try to match 42 with the current existing value of x.
IO.inspect(x)
IO.inspect(y)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Here, we want to fetch the orders with user_id 123 but it's going to fail as user_id is going to rebind to  new values in the for loop.
user_id = 123
orders = [
  {123, "Coffee", 4.50},
  {456, "Tea", 3.25},
  {123, "Muffin", 2.75}
]

# Without pinning - accidentally rebinds user_id!
for {user_id, item, price} <- orders do
  IO.puts("Item: #{item}, Price: #{price}")
end

IO.inspect(user_id)  # Oops! user_id is now 123, not what we wanted


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Here, we want to fetch the orders with user_id 123 but it's going to succeed as user_id is going to match with the value stored in it.
# This time we're using pin operator in the for loop which prevents the rebinding of new vallues with the variable user_id
user_id = 123
orders = [
  {123, "Coffee", 4.50},
  {456, "Tea", 3.25},
  {123, "Muffin", 2.75}
]

# With pinning - only matches orders for our specific user
for {^user_id, item, price} <- orders do
  IO.puts("#{item}: $#{price}")
end

IO.inspect(user_id)  # Still 123, as expected


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Pining in Function Definition
# Here, we're calculating points for a very specific player and to achieve that
# We're using pin operator in for loop.
defmodule GameStats do
  def calculate_score(player_name, events) do
    target_player = player_name

    total_score = for {^target_player, _action, points} <- events, reduce: 0 do
      acc -> acc + points
    end

    {player_name, total_score}
  end
end

events = [
  {"Alice", "kill", 10},
  {"Bob", "death", -5},
  {"Alice", "assist", 3},
  {"Charlie", "kill", 10}
]

result = GameStats.calculate_score("Alice", events)
IO.inspect(result)

# Note:
# Explanation of the code block:
# total_score = for {^target_player, _action, points} <- events, reduce: 0 do
#   acc -> acc + points
# end
#
# 1. reduce: 0 (The Initial State)
# The reduce: 0 option tells Elixir: "We aren't just filtering or transforming this list; we are reducing it down to a single value. Start our running total at 0."
#
# 2. acc -> (The Accumulator)
# Inside the do/end block, the syntax changes slightly from a standard block to an anonymous function-like syntax (acc -> ...).
#   - acc stands for accumulator.
#   - On the very first iteration, acc takes the initial value you provided (0). This 0 is provided as reduce: 0.
#   - On every subsequent iteration, acc holds the result of the previous iteration.
#
# 3. acc + points (The Update)
# The value returned by this block becomes the new value of acc for the next matching item. Once the loop finishes checking all elements in events,
# the final value of acc is assigned to total_score.
#
#
# Why use for ... reduce instead of Enum.reduce?
# You might wonder why someone would write this instead of using the standard Enum.reduce/3.
#
# The for comprehension allows you to pattern match and filter directly in the generator line.
# Doing this with Enum.reduce would require an extra if statement or multiple function clauses inside the reducer.
# The for ... reduce approach keeps the filtering logic cleanly separated on the first line, leaving the do block to focus purely on the math.


IO.puts("")
#----------------------------------------------------------------------------------------------------



# Multiple Pin Operators in Complex Patterns
status = :active
priority = :high

tasks = [
  {:active, :high, "Fix critical bug"},
  {:active, :low, "Update docs"},
  {:inactive, :high, "Refactor code"},
  {:active, :high, "Deploy to prod"}
]

# Find all tasks matching both status AND priority
matching_tasks = for {^status, ^priority, description} <- tasks do
  description
end

IO.inspect(matching_tasks)


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Case Statements with Strategic Pinning (Pin Operators)
current_user_role = :admin
action = :delete_user

result = case {action, current_user_role} do
  {:view_user, _role} ->
    "Anyone can view users"

  {:edit_user, ^current_user_role} when current_user_role in [:admin, :manager] ->
    "Edit permission granted"

  {:delete_user, ^current_user_role} when current_user_role == :admin ->
    "Delete permission granted"

  {_action, _role} ->
    "Permission denied"
end

IO.puts(result)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Advanced Pinning Patterns
expected_version = "2.1.0"
required_features = [:websockets, :auth]

config_options = [
  %{version: "2.1.0", features: [:websockets, :auth], name: "prod-config"},
  %{version: "2.0.5", features: [:websockets, :auth], name: "staging-config"},
  %{version: "2.1.0", features: [:websockets], name: "minimal-config"}
]

# Find configs with exact version and feature match
valid_configs = for %{version: ^expected_version, features: ^required_features, name: name} <- config_options do
  name
end

IO.inspect(valid_configs)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# When Not to Use Pin Operator
# Try to understand when Pin Operator is unnecessary or invalid.
# Good: Simple assignment - no pin needed
name = "Alice"

# Good: Fresh binding in pattern match
{x, y} = {10, 20}

# Unnecessary pinning - this would cause an error
# {^new_var, other} = {42, "hello"}  # new_var doesn't exist yet!

# Good: Extracting different parts
{first, second, third} = {1, 2, 3}
IO.inspect({first, second, third})

# When you DO need pinning
expected_first = 1
{^expected_first, new_second, new_third} = {1, 2, 3}
IO.inspect({expected_first, new_second, new_third})
