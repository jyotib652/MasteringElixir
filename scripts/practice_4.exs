# ----------------------------------------------------
# Maps and Keyword Lists for Structured Data
# ----------------------------------------------------
# Your First Keyword List Adventure
# Creating a character profile using keyword lists
hero_stats = [name: "Wonder Woman", speed: 95, strength: 85, wisdom: 90]

# Accessing values - order matters!
IO.puts("Hero: #{hero_stats[:name]}")
IO.puts("Strength Level: #{hero_stats[:strength]}")

# Adding duplicate keys (perfectly legal!)
extended_stat = [name: "Wonder Woman", strength: 85, strength: 92, speed: 85]
IO.puts("")
IO.puts("First Strength Value: #{extended_stat[:strength]}") # Elixir starts searching for the value from the begining -
# and returns the first matching key it finds

# To access the second occurrence, get all values as a list and pick the second one (index 1)
all_strengths = Keyword.get_values(extended_stat, :strength)
second_strength = Enum.at(all_strengths, 1)

IO.puts("Second Strength Value: #{second_strength}")

# Creating a superhero with maps - more flexible structure
superhero = %{
  name: "Spider-Man",
  real_name: "Peter Parker",
  age: 23,
  powers: ["web-slinging", "spider-sense", "wall-crawling"],
}

# Multiple ways to access map values
IO.puts("")
IO.puts("Superhero Name: #{superhero[:name]}")
IO.puts("Real identity: #{superhero.real_name}")
IO.puts("Age: #{Map.get(superhero, :age)}")

# Safe access with default values
villain_threat = Map.get(superhero, :nemesis, "no current nemesis")
IO.puts("Current threat: #{villain_threat}")

# Updating keyword lists - creates new lists
original_config = [timeout: 5000, retries: 3, debug: false]
updated_config = Keyword.put(original_config, :timeout, 10000)

IO.puts("\n")
IO.inspect(original_config, label: "Original")
IO.inspect(updated_config, label: "Updated")

# Updating maps - also creates new maps
hero = %{hero: "Batman", gadgets: 50}
upgraded_hero = %{hero | gadgets: 75}  # creates new map
hero_with_vehicle = Map.put(hero, :vehicle, "Batmobile") # creates new map

IO.puts("")
IO.inspect(hero, label: "Orginal Hero")
IO.inspect(upgraded_hero, label: "Upgraded Hero")
IO.inspect(hero_with_vehicle, label: "Hero with Vehicle")

# Pattern matching with keyword lists
process_hero_config = fn
  [name: hero_name, active: true] ->
    "#{hero_name} is ready for action"
  [name: hero_name, active: false] ->
    "#{hero_name} is taking a well-deserved break"
  config ->
    "Invalid hero configuration: #{inspect(config)}"
   end

  result1 = process_hero_config.([name: "Captain Marvel", active: true])
  result2 = process_hero_config.([name: "Thor", active: false])

  IO.puts("\n")
  IO.puts(result1)
  IO.puts(result2)

# Pattern matching with maps
analyze_villain = fn
  %{threat_level: level} when level > 80 ->
    "Call entire Justice League!"
  %{threat_level: level} when level > 50 ->
    "Send a small hero team"
  %{name: name} ->
    "#{name} can be handled by local authorities"
   end

IO.puts("")
IO.puts(analyze_villain.(%{name: "Joker", threat_level: 85}))
IO.puts(analyze_villain.(%{name: "Penguin", threat_level: 30}))
