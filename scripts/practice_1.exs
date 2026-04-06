# Variables and Pattern Matching Basics
#----------------------------------------------

# in elixir variable are labels that point to the data
hero_name = "Wonder Woman"
IO.puts(hero_name)

# we can rebind the same label to new data
hero_name = "Superman"
IO.puts(hero_name)

# the original data still exists in memory until garbage collection
power_level = 9000
new_power = power_level
power_level = 8500
IO.puts("new power: #{new_power}")
IO.puts("Updated power: #{power_level}")

# in elixir the = is not assignment, it's the match operator
x = 42
IO.puts("\n") # This will print 2 new lines not one
IO.puts("x is: #{x}")

# This works because 42 matches 42. "=" is not assignment operatopr in elixir. It's the match operator
42 = x
IO.puts("Match successful!")

# We can use "=" to assert values
expected_result = 100
actual_result = 50 + 50
expected_result = actual_result
IO.puts("Results match: #{expected_result}")

# Pattern matching with tuples
IO.puts("") # This will print a new line
# IO.puts("\n") # But this will actually print 2 newlines
hero_info = {"Batman", "Gotham City", 35}
{name, city, age} = hero_info
IO.puts("Hero: #{name}, live in #{city}, age: #{age}")

# Pattern matching with lists
IO.puts("\n")
side_kicks = ["Robin", "Batgirl", "Nightwing"]
[first_sidekick| rest] = side_kicks
IO.puts("First sidekick: #{first_sidekick}")
IO.puts("Rest of the sidekicks: #{rest}")  # IO.puts always spits out a single string
IO.inspect(rest, label: "Remaining Sidekicks") # it shows the data as it is and  The :label option is a convenient way to prefix the output so you can identify it in a busy log.
# This makes IO.inspect "pipeable"—you can insert it into the middle of a chain of functions without breaking the flow of data.
IO.puts("Rest of the sidekicks: #{Enum.join(rest, ", ")}")  # if you want IO.puts to output in a comma separated way

# We can ignore the parts we don't need
IO.puts("")
{_, location, _} = hero_info
IO.puts("The hero operates in: #{location}")


# Pattern Matching in Function Definitions
defmodule Superhero do
    # Pattern matching on different hero types
    def describe_power({"Superman", power_level}) do
      "Man of Steel with power level #{power_level}"
    end

    def describe_power({"Batman", power_level}) do
        "World's greatest detective with power level #{power_level}"
    end

    def describe_power({name, power_level}) do
      "#{name} with power level #{power_level}"
    end

    # Pattern match on list length
    def assemble_team([hero]) do
      "#{hero} works alone"
    end

    def assempble_team([leader | follower]) do
      "Team lead by #{leader} with #{length(follower)} members"
    end

end

IO.puts("\n")
IO.puts(Superhero.describe_power({"Superman", 9000}))
IO.puts(Superhero.describe_power({"Batman", 7000}))
IO.puts(Superhero.describe_power({"Wonder Woman", 8500}))
IO.puts(Superhero.assemble_team(["Batman"]))
IO.puts(Superhero.assemble_team([007]))
IO.puts(Superhero.assempble_team(["Captain America", "Iron Man", "Thor"]))

# Handling Pattern Match Failures
IO.puts("\n")
defmodule SafeExtraction do
  # using case for safe pattern matching
  def extract_hero_name(data) do
    case data do
      {name, _city, _age} when is_binary(name) ->
        {:ok, name}
      [name | _rest] when is_binary(name) ->
        {:ok, name}
      _ ->
        {:error, "Cannot extract name from this data"}
    end
  end

  # Multiple attempts with different patterns
  def get_first_element(data) do
    case data do
      [first | _rest] -> {:ok, first}
      {first, _rest} -> {:ok, first}
      _ -> {:error, "Data structure not supported"}     # _ catches everything and also throws them away

    end
  end
end

# Successful extraction
IO.inspect(SafeExtraction.extract_hero_name({"Spider man", "New York", 25}))
IO.inspect(SafeExtraction.extract_hero_name(["Iron Man", "Avenger"]))

# failed extraction
IO.inspect(SafeExtraction.extract_hero_name("Just a string"))

# Testing different structures
IO.inspect(SafeExtraction.get_first_element([1, 2, 3]))
IO.inspect(SafeExtraction.get_first_element({:a, :b}))
IO.inspect(SafeExtraction.get_first_element("oops"))

# Note:
# In Elixir (and Erlang), the function is_binary/1 returns true specifically for strings and bitstrings that are composed of complete bytes.
# is_binary("Spider Man") # => true
# is_binary("")           # => true
#
# A binary is a specialized "bitstring" where the total number of bits is divisible by 8
# Binaries: <<1, 2, 3>> is a binary because it has 24 bits (3 bytes). is_binary will be true.
# Bitstrings: <<1::size(3)>> is a bitstring but not a binary because it only has 3 bits (not a full byte). is_binary will be false. Full byte = 8 bits.
# Data Type	    Example	    is_binary Result	Why?
# Integers ->	1 or 0	->  false            -> These are numeric types, not byte-sequences.
# Booleans	->  true	->  false	         -> Booleans are technically "atoms" in Elixir.
# Atoms	    -> :name	->  false	         -> Atoms are unique constants, not byte-strings.
# Charlists	-> 'abc'	->  false	         -> Single-quoted('') strings are Lists of integers, not binaries. Single quote('') is CharLists.
# Strings   -> "abc"    ->  true             -> Double quoted ("") strings are considered Strings and hence produces result true for is_binary.


# Advanced Pattern Matching with Guards
defmodule PowerAnalyzer do
  # Using guards to add conditions to pattern
  def classify_hero({name, power}) when power > 8000 do
    "#{name} is a S-class hero with devastating power."
  end

  def classify_hero({name, power}) when power > 5000 and power <= 8000 do
    "#{name} is an A-class hero with impressive abilities."
  end

  def classify_hero({name, power}) when power > 0 do
    "#{name} is learning their powers."
  end

  def battle_outcome({hero1, power1}, {_hero2, power2}) when power1 > power2 and power1 - power2 > 1000 do
    "#{hero1} wins decisively"
  end

  def battle_outcome({hero1, power1}, {hero2, power2}) when abs(power1 - power2) <= 1000 do
    "#{hero1} and  #{hero2} are evenly matched!"
  end

  def battle_outcome({_hero1, _power1}, {hero2, _power2}) do
    "#{hero2} emerges victorious!"
  end
end

IO.puts("\n")
IO.puts(PowerAnalyzer.classify_hero({"Superman", 9000}))
IO.puts(PowerAnalyzer.classify_hero({"Batman", 7000}))
IO.puts(PowerAnalyzer.classify_hero({"Wonder Woman", 8500}))
IO.puts(PowerAnalyzer.battle_outcome({"Superman", 9000}, {"Batman", 7000}))
IO.puts(PowerAnalyzer.battle_outcome({"Superman", 9000}, {"Wonder Woman", 8500}))
IO.puts(PowerAnalyzer.battle_outcome({"Batman", 7000}, {"Wonder Woman", 8500}))


# Real World Pattern Matching Applications
defmodule APIResponse do
  # Pattern matching on HTTP response structures
  def handle_response({:ok, %{status: 200, body: data}}) do
    {:success, "Data received: #{String.slice(data, 0..50)}..."}
  end

  def handle_response({:ok, %{status: 404, body: _}}) do
    {:error, "resource not found"}
  end

  def handle_response({:ok, %{status: status, body: _}}) when status >= 500 do
    {:error, "Server error: #{status}"}
  end

  def handle_response({:error, reason}) do
    {:error, "Network error: #{reason}"}
  end

  # Processing user registration data
  def validate_user(%{email: email, name: name, age: age}) when byte_size(email) > 5 and age >= 18 and byte_size(name) > 2 do
    {:valid, "Welcome: #{name}"}
  end

  def validate_user(%{age: age}) when age < 18  do
    {:invalid, "Must be 18 or older"}
  end

  def validate_user(_user) do
    {:invalid, "Missing required fields"}
  end
end

# Simulating API responses
IO.puts("\n")
good_response = {:ok, %{status: 200, body: "user data loaded successfully"}}
not_found = {:ok, %{status: 404, body: "not found"}}
server_error = {:ok, %{status: 500, body: "Internal server error"}}

IO.inspect(APIResponse.handle_response(good_response))
IO.inspect(APIResponse.handle_response(not_found))
IO.inspect(APIResponse.handle_response(server_error))

# Testing user validation
IO.puts("")
valid_user = %{email: "here@example.com", name: "Clark Kent", age: 25}
young_user = %{email: "kid@example.com", name: "Billy Batson", age: 16}

IO.inspect(APIResponse.validate_user(valid_user))
IO.inspect(APIResponse.validate_user(young_user))

# Note:
# To trigger that specific validate_user(_user) function, you need to pass an argument that fails to match the patterns and guards of the two functions defined above it.
# In Elixir, function clauses are checked from top to bottom. The last function acts as a "catch-all" because it uses an underscore (_user), which matches absolutely anything.
# What triggers the Catch-all?
# You will evoke that function if the data you pass falls into any of these categories:
# 1. A Map with missing keys
# The first function requires a map containing exactly :email, :name, and :age. If any of those are missing (and the age isn't under 18), it hits the catch-all.
# # Missing :email and :name
# APIResponse.validate_user(%{age: 25})
#
# # Missing :age entirely
# APIResponse.validate_user(%{email: "test@web.com", name: "Bruce"})
# 2. Data that fails the "Guards" (when)
# Even if the map has the right keys, the values must meet the requirements. If they don't, and the age isn't < 18, it drops to the bottom.
# # Fails 'byte_size(name) > 2' (name is too short)
# APIResponse.validate_user(%{email: "clark@daily.com", name: "C", age: 30})
# 3. Completely different data types
# Since the first two functions expect a Map, passing any other data type (like a List, Tuple, or String) will trigger the catch-all.
# APIResponse.validate_user(["not", "a", "map"])
# APIResponse.validate_user(nil)
# APIResponse.validate_user("I am a user")
