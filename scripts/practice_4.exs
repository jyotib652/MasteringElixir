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


# Converting Between Data Structures
# Starting with a keyword list
movie_ratings = [action: 8, comedy: 7, drama: 9, horror: 6]

# Converting to a map for easier updates
ratings_map = Enum.into(movie_ratings, %{})  # converting enumerable into a collectable which is a map for this scenario denoted by "%{}" symbol.
IO.puts("")
IO.inspect(ratings_map, label: "As Map")

# Updating - Adding a new rating is now simpler
updated_ratings = Map.put(ratings_map, :sci_fi, 10)
IO.inspect(updated_ratings, label: "With Sci-fi")

# Converting back to keyword list when needed
final_list = Map.to_list(updated_ratings)
IO.inspect(final_list, label: "Back to KeywordList")

# Why use Keyword List not Map - Keyword List preserves order, maps doesn't guarantee it.
# But to update the keyword List, you need to convert it back to Map.
ordered_genre = [romance: 5, thriller: 8, western: 7]
as_map = Enum.into(ordered_genre, %{})
back_to_list = Map.to_list(as_map)

IO.inspect(as_map, label: "Original Order")
IO.inspect(back_to_list, label: "After Conversion")


# Choosing your Data Structures Wisely
# Keyword Lists excel at configuration and option
defmodule APIClient do
  def fetch_data(url, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 5000)
    retries = Keyword.get(opts, :retries, 3)
    headers = Keyword.get(opts, :headers, [])

    "Fetching #{url} with timeout: #{timeout}ms, retries: #{retries}, headers: #{headers}"
  end
end

# Multiple headers with same key - keyword lists handle this
result1 = APIClient.fetch_data("https://api.heroes.com",
  timeout: 10000,
  headers: ["Accept: application/json", "Accept: text/html"])

  IO.puts("")
  IO.puts(result1)

# Maps excel at structured data representation
superhero_database = %{
  "hero_001" => %{name: "Superman", city: "Metropolis", active: true},
  "hero_002" => %{name: "Batman", city: "Gotham", active: true},
  "hero_003" => %{name: "Wonder Woman", city: "Themyscira", active: true},
}

superman = Map.get(superhero_database, "hero_001")
IO.puts("Found hero: #{superman.name} protecting #{superman.city}")


# Safe Navigation through nested structures
hero_profile = %{
  name: "Doctor Strange",
  location: %{
    dimension: "Earth-616",
    address: %{
      building: "Sanctum Sanctorum",
      street: "177A Bleecker Street",
      city: "New York"
    }
  },
  spells: ["Time manipulation", "Portal creation", "Astral projection"]
}

# using get_in for deep access
building = get_in(hero_profile, [:location, :address, :building]) # The reason we provide those three specific atoms—[:location, :address, :building]—is because
# they represent the sequential path required to reach the specific value you want.
# A quick tip: If you ever try to access a key that is actually a string (e.g., "name") instead of an atom (:name),
# get_in will return nil because they are different types in Elixir. Always match your path keys to the data types in your map!

IO.puts("")
IO.puts("Hero base: #{building}")

# Safe access that won't crash
dimension = get_in(hero_profile, [:location, :dimension])
unknown = get_in(hero_profile, [:location, :phone_number])  # returns nil gracefully without crashing the program

IO.puts("Dimension: #{dimension}")
IO.puts("Phone: #{unknown}")

# Pattern matching for safe extraction
case Map.fetch(hero_profile, :spells) do
  {:ok, spells} ->
    IO.puts("Available spells: #{Enum.join(spells, ", ")}")
  :error ->
    IO.puts("No spells found for this hero")
end
