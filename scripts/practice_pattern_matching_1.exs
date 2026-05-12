#--------------------------------------------------------------------------------
# Variables and Pattern Matching - Variable binding and rebinding in Elixir
#--------------------------------------------------------------------------------
# We'll learn
# 1. How variable binding works in Elixir and why it's different from assignment.
# 2. The difference between binding and rebinding variables in functional programming.
# 3. Pattern matching with variables and the match operator
# 4. When and why Elixir creates new bindings versus reusing existing ones.
# 5. Best practice for naming and managing variables in Elixir code.

wizard_name = "Gendalf"
magic_power = 9001
is_wise = true

IO.puts("Our wizard is #{wizard_name}")
IO.puts("Power level: #{magic_power}")
IO.puts("Wise: #{is_wise}")

# Note:
# Here we're not storing "Gendalf" in a box labeled wizard_name.
# We're creating a binding where Wizard_name points to the name "Gendalf".
# The equal sign (=) is called match operator. And this operator is doing something
# more sophisticated than assignment. Each binding creates a connection between a name
# and value. And Elixir treats this connection as mutable facts about your program at that
# moment.


IO.puts("")
#----------------------------------------------------------------------------------------------------


hero_level = 1
IO.puts("Starting level: #{hero_level}")

hero_level = hero_level + 10
IO.puts("After training: #{hero_level}")

hero_level = hero_level * 2
IO.puts("After magical boost: #{hero_level}")

# Note:
# hero_level is actually creating bindings each time.
# when we write hero_level = hero_level + 10, here Elixir
# creates new binding to hero_level but the previous value
# of hero_level which was 1 does not get modified it simply
# becomes unreachable. This rebinding makes working with evolving data
# while maintaining immutability of data in Elixir.


IO.puts("")
#----------------------------------------------------------------------------------------------------

{status, message} = {:ok, "mission accomplished"}
IO.puts("Status: #{status}")
IO.puts("Message: #{message}")

{x, y, z} = {10, 20, 30}
result = x + y + z
IO.puts("Coordinates sum: #{result}")

# Note:
# we're pattern matching with right side of the = operator with left side.
# As a result, atom :ok gets bound to status and "mission accomplished" gets
# bound to message variable.


IO.puts("")
#----------------------------------------------------------------------------------------------------

outer_spell = "Fireball"

if true do
  inner_spell = "Lightning Bolt"
  combined_power = "#{outer_spell} + #{inner_spell}"
  IO.puts("Inside: #{combined_power}")
end

IO.puts("Outside: #{outer_spell}")
# inner_spell would cause an error here - As code from inner scope can't be accessed outside of that scope
IO.puts("Outer spell still works: #{outer_spell}")

# Note:
# Scope is important. Codes from inside a scope would only work if you access it only from that scope.
# Outside of the scope that code would not work at all.



IO.puts("")
#----------------------------------------------------------------------------------------------------

# Rebinding in different scopes
power_level = 100
IO.puts("Original power: #{power_level}")

if power_level > 50 do
  power_level = power_level + 200
  IO.puts("Boosted power inside: #{power_level}")
end

IO.puts("Power outside: #{power_level}")


# Note:
# Here, we're rebinding the value of power_level inside the
# if block. This new power_level only exists inside this scope(if block).
# But this power_level is not available outside of the scope. Outside
# of the scope you'll get old value of power_level.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Pin (^) operator for exact matching
expected_code = 42
secret_message = "The answer to everything"

{^expected_code, result} = {42, "Success!"}
IO.puts("Match successful: #{result}")

# This would fail if the first element wasn't 42
{status, ^expected_code} = {:verified, 42}
IO.puts("Status: #{status}, Code verified: #{expected_code}")

# Note:
# In this line {^expected_code, result} = {42, "Success!"}
# Because of the pin operator(^) we're telling elixir not to create a new bound for expected_code
# instead make sure the value matches exactly what expected_code is already bound to.
# So previously expected_code was bound to 42 and we're exactly matching if the new value
# is also 42. This is really powerful for validation and control flow.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Multiple Assignment Patterns:

# Swapping values the Elixir way
a = 1
b = 2
IO.puts("Before: a=#{a}, b=#{b}")

{a, b} = {b, a}
IO.puts("After swap: a=#{a}, b=#{b}")

# Working with list
[first, second | rest] = [10, 20, 30, 40, 50]
IO.puts("First: #{first}, Second: #{second}")
IO.puts("Rest: #{inspect(rest)}")
