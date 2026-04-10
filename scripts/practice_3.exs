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


# The Immutability Advantage
# orginal data remains unchanged
original_heroes = ["Superman", "Batman", "Wonder Woman"]
IO.inspect(original_heroes, label: "Original team")

# Modifying creates new data structures
expanded_team = ["Flash" | original_heroes] # This creates new list. Data/variables in Elixir immutable
filtered_team = List.delete(original_heroes, "Batman") # This also creates a new list. Data/variables in Elixir immutable

IO.puts("\n")
IO.inspect(original_heroes, label: "Original team (unchanged)")
IO.inspect(expanded_team, label: "Expanded team")
IO.inspect(filtered_team, label: "Filtered team")

# Same with tuples
hero_profile = {"Superman", 30, :active}
updated_profile = put_elem(hero_profile, 1, 31)  # remeber, tuples's size is fixed and updating tuples also creates a new tuple. Data/variables in Elixir immutable

IO.puts("")
IO.inspect(hero_profile, label: "Original profile")
IO.inspect(updated_profile, label: "Updated profile")

# Choosing the Right Tool
# Lists: Use for collection that grow/shrink
# Remember: In Elixir, data is immutable, which means once a list is created in memory, it cannot be changed.
shopping_cart = [] # So, it's a new list
shopping_cart = ["milk" | shopping_cart]  # So, it's also a new list
shopping_cart = ["bread" | shopping_cart] # So, it's also a new list
shopping_cart = ["eggs" | shopping_cart]  # So, it's also a new list
# Explanation:
# 1. Immutability & Rebinding
# When you write shopping_cart = ["milk" | shopping_cart], you aren't modifying the memory address where the empty list lived. Instead, you are:
# i) Creating a new list in memory.
# ii) Rebinding the variable name shopping_cart to that new memory location.
# iii) The old version of the list is eventually cleaned up by the garbage collector if nothing else is pointing to it.
#
# 2. Efficiency (The "Breadcrumb" Secret)While it's true you are creating a "new" list, Elixir is very clever about how it does this.
# Because lists are "linked lists", Elixir doesn't copy every single item when you add something to the front.
# Instead, it uses structural sharing:
# i) The new list is just a new "head" (e.g., "eggs") that points to the existing list already in memory.
# ii) The original list remains untouched and is simply reused as the "tail" of the new list.
# iii) This makes prepending (using the [head | tail] syntax) an $O(1)$ operation—it's incredibly fast and memory-efficient.
#
# Pro Tip: Always add to the head of the list like you did here.
# If you try to add to the end (e.g., shopping_cart ++ ["eggs"]),
# Elixir has to traverse the entire list and copy every element to create the new version,
# which becomes very slow as the list grows ($O(n)$ complexity).
#
# Detailed Explanation(V.V.I):
# Structural Sharing in Action
# When you prepend an item to a list, you aren't replacing the old list; you are building on top of it.
# 1. shopping_cart = []: You point the variable to the empty list.
# 2. shopping_cart = ["milk" | shopping_cart]: You create a new "cell" containing "milk". This cell has a pointer that links to the empty list.
# 3. shopping_cart = ["bread" | shopping_cart]: You create a new "cell" containing "bread". Its pointer links to the "milk" cell.
#
# Is the empty list([]) Garbage Collected?
# No, not while you're using it: The empty list [] at the very end of your chain is not garbage collected because your new list is literally sitting on top of it.
# The "milk" element needs that empty list to mark the "end" of its tail.
#
# Yes, if it becomes "orphaned": If you were to suddenly say shopping_cart = ["apples"] (completely ignoring the previous list), the old chain ("bread" -> "milk" -> []) no longer has any variables pointing to it.
# At that point, the garbage collector will eventually sweep it up to free memory.


IO.puts("")
IO.inspect(shopping_cart, label: "Shopping cart")

# Tuples: Use for fixed, structured data
database_record = {:user, "john_doe", 25, "john@example.com"}
api_response = {:ok, %{data: "some info", status: 200}}
coordinates_3d = {10.5, 20.3, 5.7}

IO.puts("")
IO.inspect(database_record, label: "User record")
IO.inspect(api_response, label: "API response")
IO.inspect(coordinates, label: "3D position")

# Performance consideration
large_list = Enum.to_list(1..10000)
{time_list, _} = :timer.tc(fn -> hd(large_list) end)

large_tuple = List.to_tuple(Enum.to_list(1..10000))
{time_tuple, _} = :timer.tc(fn -> elem(large_tuple, 0) end)

IO.puts("")
IO.puts("List head access: #{time_list} microseconds")
IO.puts("Tuple element access: #{time_tuple} microseconds")  # Tuples element acces are faster than Lists operation for random access
