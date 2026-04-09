#---------------------------------------------------
# Creating Your First List
#---------------------------------------------------
# Lists in Elixir are like dynamic arrays
heroes = ["Superman", "Batman", "Wonder Woman", "Flash"]
numbers = [1, 2, 3, 4, 5]
mixed_bag = ["Elixir", 42, true, :awesome]

IO.inspect(heroes, label: "Our superhero team")
IO.inspect(numbers, label: "Lucky Numbers")
IO.inspect(mixed_bag, label: "Mixed Collection")

# The Head and Tail Dance
[head | tail] = heroes
IO.puts("")
IO.puts("The leader of the team: #{head}")
IO.puts("The rest of the team: #{tail}")
IO.inspect(tail, label: "The rest of the team")

# Using hd and tl functions
first_hero = hd(heroes)
remaining_heroes = tl(heroes)
IO.puts("")
IO.puts("first hero using hd: #{first_hero}")
IO.inspect(remaining_heroes, label: "remaining heroes using tl")

# NOte: both [|] and hd & tl does the same thing but [|] is preferred for pattern matching.

# Adding elements to the front of the list(prepending) - Fast!
original_list = ["Batman", "Superman"]
new_list = ["Wonder Woman" | original_list]
IO.puts("")
IO.inspect(new_list, label: "Prepended list")

# Adding multiple elements
extended_list = ["Flash", "Green Lantern" | original_list]
IO.inspect(extended_list, label: "Extended team")

# using ++ for concatenation (slower but sometimes useful)
team_a = ["Batman", "Superman"]
team_b = ["Wonder Woman", "Flash"]
combined_team = team_a ++ team_b
IO.inspect(combined_team, label: "Combined team")


# Meet Tuples - Your Fixed-Size Container
# Unlike lists, tuples has fixed size when created
superhero_info = {"Superman", 30, true, "Krypton"}
coordinates = {10.5, 20.3}
status_result = {:ok, "Mission completed successfully"}

IO.inspect(superhero_info, label: "Superhero profile")
IO.inspect(coordinates, label: "Location")
IO.inspect(status_result, label: "Mission status")

# Accessing elements by position(zero-indexed)
name = elem(superhero_info, 0)
age = elem(superhero_info, 1)
IO.puts("")
IO.puts("Hero: #{name}, Age: #{age}")

# Pattern Matching With Tuples
hero_data = {"Batman", "Gotham", 35, :active}

# Extracting all elements at once
{name, city, age, status} = hero_data
IO.puts("")
IO.puts("#{name} operates in #{city}, age: #{age}, status: #{status}")

# Pattern matching with specific atoms
result = {:ok, "Data retrieved successfully"}
case result do
  {:ok, message} -> IO.puts("Success: #{message}")
  {:error, reason} -> IO.puts("Failed: #{reason}")
end

# Partial matching - ignoring some elements
{hero_name, _, hero_age, _} = hero_data
IO.puts("Focus on #{hero_name} who is #{hero_age} years old}")

# When Lists Meets Tuples
# List of Tuples - common pattern for structured data
superhero_roster = [
  {"Superman", :leader, 95},
  {"Batman", :strategist, 88},
  {"Wonder Woman", :warrior, 92},
  {"Flash", :speedstar, 85}
]

IO.puts("\n")
IO.inspect(superhero_roster, label: "Full roster")

# Processing each hero
for {name, role, power_level} <- superhero_roster do
  IO.puts("#{name}, (#{role}), Power Level: #{power_level}")
end

# Finding heroes with high power levels
strong_heroes = for {name, _role, power} <- superhero_roster, power > 90, do: name
# strong_heroes is a list of names: ["Superman", "Wonder Woman"]
IO.inspect(strong_heroes, label: "Elite heroes")

# Note:
# In Elixir, the keyword "when" is used specifically for Guards (like in function signatures or case statements), while the "for" comprehension uses a simpler mechanism called Filters.
# 1. Filters vs. Guards
# In a for comprehension, any expression that follows the generator (<-) and evaluates to a boolean is treated as a Filter.
# Filter: If the expression returns true, the element is kept. If it returns false or nil, the element is discarded.
# Syntax: You simply comma-separate the filter from the generator.
# # This is a Filter
# for {name, _role, power} <- superhero_roster, power > 90, do: name
#
# 2. The Scope of when
# In Elixir, when is reserved for Pattern Matching contexts. You typically see it in:
# a) Function headers: def power_up(val) when val > 90, do: ...
# b) Case statements: case hero do {name, p} when p > 90 -> ... end
# In a comprehension, the "filtering" happens after the pattern has already been matched and the variables have been bound.
# Because it's a general-purpose filter, it allows for more complex logic than a standard Guard (which is restricted to a small set of built-in functions for performance reasons)
