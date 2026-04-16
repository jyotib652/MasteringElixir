#---------------------------------------------------------------------------
# Control Flow with Case and Cond
#---------------------------------------------------------------------------
# Your first case statement adventure
defmodule WeatherBot do
  def suggest_activity(weather) do
    case weather do
      :sunny -> "Perfect day for a picnic in the park."
      :rainy -> "Great time to curl up with a good book."
      :snowy -> "Time to build a snowman!"
      :cloudy -> "Maybe visit that indoor museum you've been postponing."
      _ -> "Weather unpredictable but adventure awaits!"
    end
  end
end

IO.puts WeatherBot.suggest_activity(:sunny)
IO.puts WeatherBot.suggest_activity(:volcanic_ash)
# In Elixir, parentheses for function calls are often optional.
# This is a design choice aimed at making the code more readable and "clean," similar to the philosophy found in Ruby.
# In Elixir, you can call functions with or without parentheses as long as there is no ambiguity.
#
# IO.puts("Hello") is perfectly valid.
# IO.puts "Hello" is also perfectly valid.
# While it's a matter of style, the Elixir community generally follows these "unwritten" rules for when to leave parentheses out:
#
# 1. Standard Macros: Keywords like def, defmodule, if, and case are actually macros, and we almost never use parentheses with them.
# 2. Simple Scripting: In short scripts or when piping data, developers often omit them to reduce visual "noise."
# 3. DSL (Domain Specific Languages): Many Elixir libraries use the lack of parentheses to make the code look more like a configuration file or natural language.

# Pattern matching magic with data structures
defmodule OrderProcessor do
  def handle_order(order) do
    case order do
      {:priority, item, quantity} when quantity > 10 ->
        "Rush processing #{quantity} units of #{item}"

      {:priority, item, quantity} ->
        "Priority order #{quantity} #{item}"

      {:standard, item, quantity} when quantity > 100 ->
        "Bulk order alert: #{quantity} #{item}"

      {:standard, item, quantity} ->
        "Standard processing for #{quantity} #{item}"

      {:cancelled, reason} ->
        "Order cancelled: #{reason}"
    end
  end
end

IO.puts("")
IO.puts OrderProcessor.handle_order({:priority, "laptops", 5})
IO.puts OrderProcessor.handle_order({:standard, "keyboards", 150})


# Cond - Your Multi Condition Champion
defmodule StudentEvaluator do
  def determine_statue(attendance, grade_average, assignments_completed) do
    cond do
      attendance < 60 ->
        "At risk: Attendance below minimum requirement."

      grade_average >= 90 and assignments_completed >= 95 ->
        "Dean's List candidate - Outstanding performance!"

      grade_average >= 80 and assignments_completed >= 85 ->
        "Honor Role - Excellent work!"

      grade_average >= 70 and assignments_completed >= 75 ->
        "Good standing - Keep up the solid progress."

      grade_average >= 60 and assignments_completed >= 65 ->
        "Passing - Consider study group support."

      true ->
        "Academin intervention recommended."
    end
  end
end

IO.puts("")
IO.puts StudentEvaluator.determine_statue(85, 92, 96)
IO.puts StudentEvaluator.determine_statue(45, 95, 100)
# For cond catch all syntax is: true ->  not _ ->
# Actually _ -> is the catch all syntax for case


# case with Complex Pattern Matching
defmodule GameAnalyzer do
  def analyzer_mode(game_state) do
    case game_state do
      %{health: health, mana: mana, level: level} when health > 80 and mana > 50 and level > 10 ->
        "Ready for Boss battle."

      %{health: health, items: items} when health < 20 and length(items) > 0 ->
        "Critical health - Use healing item: #{hd(items)}"

      %{health: health, position: {x, y}} when health > 50 and x > 100 and y > 100 ->
        "Exploring advanced territory."

      %{level: level} when level > 5 ->
        "Still in tutorial zone."

      %{} ->  # catches any map that doesn't match our specific patterns
        "Standard gameplay mode."
    end
  end
end

player_state = %{health: 85, mana: 75, level: 12, position: {50, 30}, items: ["potion"]}
IO.puts("")
IO.puts GameAnalyzer.analyzer_mode(player_state)

injured_player = %{health: 15, mana: 20, level: 8, items: ["health_potion", "mana_crystal"]}
IO.puts(GameAnalyzer.analyzer_mode(injured_player))


# Cond for Mathematical Logic Chains
defmodule LoanCalculator do
  def asess_loan_risk(credit_score, income, debt_ratio, employment_years) do
    cond do
      credit_score >= 800 and income >= 75000 and debt_ratio <= 0.3 ->
        {:approved, "Excellent - Premium rate: 3.2%"}

      credit_score >= 720 and income >= 50000 and debt_ratio <= 0.4 and employment_years >= 2 ->
        {:approved, "Good standing- Standard rate: 4.1%"}

      credit_score >= 650 and income >= 35000 and debt_ratio <= 0.5 ->
        {:conditional, "Requires co-signer- Rate: 5.8%"}

      credit_score >= 600 and employment_years >= 1 ->
        {:conditional, "High risk- Secured loan only: Rate: 7.2%"}

      credit_score >= 600 ->
        {:denied, "Credit rebuilding program recommended"}

      true ->
        {:review, "Manual underwriting required"}
    end
  end
end

result = LoanCalculator.asess_loan_risk(750, 60000, 0.35, 3)
IO.puts("")
IO.inspect result

risky_result = LoanCalculator.asess_loan_risk(580, 45000, 0.6, 0.5)
IO.inspect risky_result


# Mixing Case and Cond for Ultimate Control
defmodule SmartThermostat do
  def adjust_temparature(sensor_data, user_preferences) do
    case sensor_data do
      {:indoor, temp, humidity} ->
        optimize_indoor_climate(temp, humidity, user_preferences)

      {:outdoor, temp, weather_condition} ->
        prepare_for_weather(temp, weather_condition, user_preferences)

      {:error, sensor_id} ->
        "Sensor #{sensor_id} is malfunction- Switching to backup mode."
    end
  end

  def optimize_indoor_climate(temp, humidity, %{comfort_temp: target}) do
    cond do
      temp > target + 3 and humidity > 60 ->
        "Activating AC and dehumidifier - High cooling mode"

      temp > target + 1 ->
        "Cooling to #{target}°F - standard mode"

      temp < target - 3 and humidity < 30 ->
        "Heating and humidifying - Comfort boost mode"

      temp < target - 1 ->
        "Warming to #{target}°F - Gentle heat"

      true ->
        "Perfect climate achieved - Maintainging #{temp}°F"
    end
  end

  def prepare_for_weather(temp, condition, _preferences) do
    case condition do
      :storm -> "Storm mode: Sealing system and backup power ready"
      :heat_wave when temp > 95 -> "Extreme cooling protocol activated"
      _ ->
        "Standard weather adaptation in progress"
    end
  end
end

indoor_reading = {:indoor, 78, 65}
prefs = %{comfort_temp: 72, eco_mode: false}
IO.puts("")
IO.puts SmartThermostat.adjust_temparature(indoor_reading, prefs)
# Note:
# The error "misplaced operator ->" is happening because you are trying to use clauses (the -> arrows) directly inside a function body.
# In Elixir, the -> syntax is reserved for specific control structures like cond, case, receive, or anonymous functions.



# Guard Clauses and  Edge Case Mastery
defmodule SafeCalculator do
  def calculate_discount(price, discount_percent, customer_type) when is_number(price) and price > 0 do
    case {customer_type, discount_percent} do
      {:vip, percent} when percent >= 0 and percent <= 50 ->
        apply_vip_discount(price, percent)

      {:regular, percent} when percent >= 0 and percent <= 25 ->
        price * (1 - percent / 100)

      {:student, percent} when percent >= 0 and percent <= 30 ->
        max_discount = min(price * 0.3, 100)  # Cap student discount at $100
        price - max_discount

      {_, percent} when percent < 0 ->
        {:error, "Discount cannot be negative"}

      {_, percent} when percent > 100 ->
        {:error, "Discount cannot exceed 100%"}

      _ ->
        {:error, "Invalid customer type or discount"}
    end
  end

  def calculate_discount(price, _, _) when price <= 0 do
    {:error, "Price must be positive"}
  end

  def calculate_discount(_, _, _) do
    {:error, "Price must be a number"}
  end

  defp apply_vip_discount(price, percent) do
    cond do
      percent >= 40 -> price * 0.6  # VIP gets extra 10% off high discounts
      percent >= 20 -> price * (1 - percent / 100)
      true -> price * 0.95  # Minimum 5% VIP discount
    end
  end
end

IO.puts("\n")
IO.inspect SafeCalculator.calculate_discount(100, 25, :regular)
IO.inspect SafeCalculator.calculate_discount(-50, 10, :regular)
IO.inspect SafeCalculator.calculate_discount(200, 45, :vip)
