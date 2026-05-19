#----------------------------------------
# Pattern Matching: Maps And Structs
#----------------------------------------

# Extracting data from Maps
user = %{name: "Tony Stark", age: 45, occupation: "Inventor"}

# Only extracting the values needed.
%{name: name, age: age} = user

IO.puts("Name: #{name}, Age: #{age}")

# Extract only what you need
%{occupation: job} = user
IO.puts("Day job: #{job}")

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Ensuring Required Keys Exist
defmodule HeroValidator do
  def validate_hero(%{name: name, power: power}=hero) do
    IO.puts("Valid Hero: #{name} with #{power}")
    {:ok, hero}
  end

  def validate_hero(_invalid_data) do
    IO.puts("Missing required fields!")
    {:error, :invalid_hero}
  end
end

# Test with valid data
valid_hero = %{name: "Spider-Man", power: "Web slinging", city: "New York"}
HeroValidator.validate_hero(valid_hero)

# Test With missing data
incomplete_hero = %{name: "Mystery Hero"}
HeroValidator.validate_hero(incomplete_hero)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Pattern Matching with Default Values
defmodule HeroProfile do
  def create_profile(%{name: name} = hero_data) do
    age = Map.get(hero_data, :age, "Unknown")   # Map.get(map, key, default \\ nil) => if the key doesn't exist returns the provided default value.
    location = Map.get(hero_data, :location, "Classified")  # Map.get(map, key, default \\ nil) => if the key doesn't exist returns the provided default value.
    %{
      name: name,
      age: age,
      location: location,
      status: "Active"
    }
  end
end

hero1 = %{name: "Black Widow", age: 35, location: "Mobile"}
hero2 = %{name: "Batman"}

IO.inspect(HeroProfile.create_profile(hero1))
IO.inspect(HeroProfile.create_profile(hero2))


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Netsted Map Pattern Matching
superhero = %{
  identity: %{
    name: "Peter Parker",
    alias: "Spider-Man"
  },
  abilities: %{
    primary: "Web slinging",
    secondary: "Spider sense"
  },
  base: "New York"
}

%{
  identity: %{name: real_name, alias: hero_name},
  abilities: %{primary: main_power}
} = superhero

IO.puts("#{real_name} fights crime as #{hero_name}")
IO.puts("Primary abilities: #{main_power}")


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Guards with Map and Struct Matching
defmodule PowerAnalyzer do
  def analyze_threat(%{power_level: level} = _villain) when level > 8 do
    IO.puts("CRITICAL THREAT: Power level #{level}")
    {:alert, :send_avengers}
  end

  def analyze_threat(%{power_level: level} = _villain) when level > 5 do
    IO.puts("Moderate threat: Power level #{level}")
    {:caution, :local_heroes}
  end

  def analyze_threat(%{power_level: level}) do
    IO.puts("Minor threat: Power level #{level}")
    {:low, :police_backup}
  end
end


low_threat = %{name: "Petty thief", power_level: 3}
mid_threat = %{name: "Rhino", power_level: 7}
high_threat = %{name: "Thanos", power_level: 10}

PowerAnalyzer.analyze_threat(low_threat)
PowerAnalyzer.analyze_threat(mid_threat)
PowerAnalyzer.analyze_threat(high_threat)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Real-World Data Transformation
defmodule DataProcessor do
  def process_user_data(%{
    "user" => %{
      "name" => name,
      "email" => email
    },
    "preferences" => %{
      "theme" => theme
    }
  }) do
    %{
      display_name: String.upcase(name),
      contact: email,
      ui_theme: theme,
      processed_at: DateTime.utc_now()
    }
  end

  def process_user_data(_invalid_data) do
    {:error, "Invalid user data structure"}
  end
end

api_data = %{
  "user" => %{
    "name" => "Wade Wilson",
    "email" => "deadpool@marvel.com"
  },
  "preferences" => %{
    "theme" => "dark",
    "notofications" => true
  }
}

IO.inspect(DataProcessor.process_user_data(api_data))

# Note:
# Maps - Use colon (:) when there is atom values
# Maps - Use fat arrow (=>) when there are values that are not atoms.
