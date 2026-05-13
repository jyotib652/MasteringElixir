#---------------------------------------------------------------
# Pattern Matching: Destructuring Lists with Pattern Matching
#---------------------------------------------------------------

defmodule ListMagic do
  def show_head_tails(list) do
    case list do
      [head | tail] ->
        IO.puts("First element: #{head}")
        IO.puts("Rest of the elements: #{inspect(tail)}")

      [] ->
        IO.puts("Empty list - nothing to show")
    end
  end
end

ListMagic.show_head_tails([1, 2, 3, 4, 5])
ListMagic.show_head_tails([42])
ListMagic.show_head_tails([])


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Function Parameters with Pattern Matching
defmodule RecursiveCounter do
  # Pattern matching directly in function parameters
  def count_elements([]), do: 0

  def count_elements([_head | tail]) do
    1 + count_elements(tail)
  end

  # Let's also create a sum function
  def sum_list([]), do: 0

  def sum_list([head | tail]) do
    head + sum_list(tail)
  end
end

my_list = [10, 20, 30, 40]
IO.puts("List: #{inspect(my_list)}")
IO.puts("Element count: #{RecursiveCounter.count_elements(my_list)}")
IO.puts("Sum of elements: #{RecursiveCounter.sum_list(my_list)}")


# Note:
# In the above code there is no Tail Call so no Tail Call Optimization.
# def sum_list([head | tail]) do
#   head + sum_list(tail) # The addition happens AFTER the recursive call returns
# end

# Achieving Tail Call Optimization using accumulator pattern for sum_list():
# defmodule OptimizedCounter do
#   # Public API
#   def sum_list(list), do: do_sum(list, 0)

#   # Private helper using an accumulator
#   defp do_sum([], acc), do: acc

#   defp do_sum([head | tail], acc) do
#     # The recursive call is the final operation.
#     # We pass the running total (acc + head) forward.
#     do_sum(tail, acc + head)
#   end
# end

# The same needs to be done for count_elements() to make it TCO compliant.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Extracting multiple elements at once
defmodule AdvancedPatterns do
  def analyze_playlist(songs) do
    case songs do
      [] ->
        "Your Playlist is empty. Time to discover some music!"

      [only_song] ->
        "You have one song: #{only_song}. Maybe add a few more."

      [first, second | rest] ->
        count = length(rest) + 2
        "Your top 2 songs are #{first} and #{second}. Plus #{length(rest)} more tracks for a total of #{count} songs."
    end
  end

  def get_bookends([first | _] = full_list) do
    last = List.last(full_list)
    {first, last}
  end
end

playlist = ["Bohemian Rhapsody", "Stairway to Heaven", "Hotel California", "Sweet Child O Mine"]
IO.puts(AdvancedPatterns.analyze_playlist(playlist))

{first_song, last_song} = AdvancedPatterns.get_bookends(playlist)
IO.puts("from #{first_song} to #{last_song}")


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Patetrnn Matching with Guards and Conditions
defmodule SmartProcessor do
  def process_numbers(numbers) when is_list(numbers) do
    case numbers do
      [] ->
        "No numbers to process"

      [single] when single > 100 ->
        "Single large number: #{single}"

      [single] when single <= 100 ->
        "Single small number: #{single}"

      [first, second | _rest] when first > second ->
        "Descending start: #{first} > #{second}"

      [first, second | _rest] when first <= second ->
        "Ascending start: #{first} <= #{second}"
    end
  end

  def safe_divide_first_two([a, b | _rest]) when b != 0 do
    {:ok, a / b}
  end

  def safe_divide_first_two(_), do: {:error, "Cannot divide - need at least 2 numbers and second cannot be zero"}
end

IO.puts(SmartProcessor.process_numbers([150]))
IO.puts(SmartProcessor.process_numbers([50]))
IO.puts(SmartProcessor.process_numbers([100, 50, 25]))
IO.puts(SmartProcessor.process_numbers([25, 50, 75]))

IO.inspect(SmartProcessor.safe_divide_first_two([100, 4, 2]))
IO.inspect(SmartProcessor.safe_divide_first_two([100, 0, 2]))

# Note:
# In Elixir, guards and conditions (patterns) work together to decide which code block to execute, but they live in different parts of the syntax and have different rules.
#
# Here is the breakdown of your code:
#
# 1. Guards
# Guards are the expressions following the when keyword. They act as a secondary "filter" that only runs if the initial pattern matches.
#
# a) is_list(numbers): In the function signature process_numbers(numbers).
#
# b) single > 100: In the case statement for a single element list.
#
# c) single <= 100: In the case statement for a single element list.
#
# d) first > second: In the case statement for lists with at least 2 elements.
#
# e) first <= second: In the case statement for lists with at least 2 elements.
#
# f) b != 0: In the function signature safe_divide_first_two([a, b | _rest]).
#
# Note: Guards must be pure and fast. You can only use a specific subset of functions in guards (like is_list/1, !=, or >) to ensure the BEAM VM can check them efficiently without side effects.
#
# 2. Patterns (Structural Conditions)
# These are the shapes of the data you defined. In Elixir, we usually call these patterns rather than conditions, as they involve "matching" the structure of the data.
#
# a) []: Matches an empty list.
#
# b) [single]: Matches a list with exactly one element and binds it to the variable single.
#
# c) [first, second | _rest]: Matches a list with at least two elements, binding the first two and ignoring the remainder.
#
# d) _ (Underscore): The "catch-all" pattern in your safe_divide_first_two function.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Building a Recursive List Transformer
defmodule ListTransformer do
  # Double all numbers in a list
  def double_all([]), do: []

  def double_all([head | tail]) do
    [head * 2 | double_all(tail)]
  end

  # Filter even numbers only
  def evens_only([]), do: []

  def evens_only([head | tail]) when rem(head, 2) == 0 do
    [head | evens_only(tail)]
  end

  def evens_only([_head | tail]) do
    evens_only(tail)
  end

  # Generic transformer - takes a function
  def transform([], _func), do: []

  def transform([head | tail], func) do
    [func.(head) | transform(tail, func)]
  end
end

original = [1, 2, 3, 4, 5, 6]
IO.puts("Original: #{inspect(original)}")
IO.puts("Doubled: #{inspect(ListTransformer.double_all(original))}")
IO.puts("Evens only: #{inspect(ListTransformer.evens_only(original))}")

# Using the generic transformer
squared = ListTransformer.transform(original, fn x -> x * x end)
IO.puts("Squared: #{inspect(squared)}")

# Note:
# Why the following function is used in the above code:
#
#   def evens_only([_head | tail]) do
#     evens_only(tail)
#   end
#
# Explanation:
# The Logic Flow
# When you call evens_only([head | tail]), Elixir tries to match the clauses from top to bottom:
# 1. Clause 1 ([]): Checks if the list is empty. If not, it moves to the next.
#
# 2. Clause 2 ([head | tail] when rem(head, 2) == 0): This checks if the head is even. If it is, the number is kept: [head | evens_only(tail)].
#
# 3. Clause 3 ([_head | tail]): This is only reached if Clause 2 failed (meaning the number was odd).
#
# Why it is necessary
# If you removed that third clause and passed a list containing an odd number (like 1),
# the program would crash with a FunctionClauseError. Elixir wouldn't know what to do with an odd number because no pattern would match.
#
# Breakdown of the syntax:
#
# _head: The underscore prefix tells Elixir: "I know there is a value here, but I’m going to ignore it."
# Since we know the number is odd (because Clause 2 failed), we don't need to do anything with it.
#
# evens_only(tail): Notice that we don't add the head to a new list. We simply discard it and move straight to processing the rest of the list.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Working with Nested Lists and Complex Patterns
# Pattern matching truly sihines when dealing with nested data structure
defmodule NestedMagic do
  # Flatten one level of nesting
  def flatten_one_level([]), do: []

  def flatten_one_level([head | tail]) when is_list(head) do
    head ++ flatten_one_level(tail)
  end

  def flatten_one_level([head | tail]) do
    [head | flatten_one_level(tail)]
  end

  # Extract coordinates from a list of tuples
  def extract_x_coords([]), do: []

  def extract_x_coords([{x, _y} | rest]) do
    [x | extract_x_coords(rest)]
  end

  # Process mixed data types
  def process_mixed([]), do: []

  def process_mixed([head | tail]) when is_number(head) do
    [head * 10 | process_mixed(tail)]
  end

  def process_mixed([head | tail]) when is_binary(head) do
    [String.upcase(head) | process_mixed(tail)]
  end

  def process_mixed([_head | tail]) do
    ["UNKNOWN" | process_mixed(tail)]
  end
end

nested_data = [[1, 2], [3, 4], 5, [6]]
coordinates = [{10, 20}, {30, 40}, {50, 60}]
mixed_list = [5, "hello", :atom, 10, "world"]

IO.puts("Nested: #{inspect(nested_data)}")
IO.puts("Flattened one level: #{inspect(NestedMagic.flatten_one_level(nested_data))}")
IO.puts("Coordinates: #{inspect(coordinates)}")
IO.puts("X values: #{inspect(NestedMagic.extract_x_coords(coordinates))}")
IO.puts("Mixed: #{inspect(mixed_list)}")
IO.puts("Processed: #{inspect(NestedMagic.process_mixed(mixed_list))}")


# Note:
# In Elixir, the ++ operator is the List Concatenation operator. Its job is to join two lists together into a single new list.

# In the context of your flatten_one_level function, it is being used to "unwrap" a nested list and merge its contents into the result of the rest of the recursion.



IO.puts("")
#----------------------------------------------------------------------------------------------------

# Advanced Destructuring with Multiple Patterns
defmodule AdvancedDestructuring do
  # Match specific patterns and structures
  def analyze_sequence(sequence) do
    case sequence do
      [a, b, c] when a == b and b == c ->
        "All three elements are the same: #{a}"

      [a, b, c] when a + c == 2 * b ->
        "Arithmetic sequence: #{a}, #{b}, #{c}"

      [first | _] = list when length(list) >= 5 ->
        "Long sequence starting with #{first}, total length: #{length(list)}"

      [single] ->
        "Single element: #{single}"

      list when length(list) in 2..4 ->
        "Short sequence: #{inspect(list)}"

      [] ->
        "Empty sequence"
    end
  end

  # Extract patterns from the middle of lists
  def find_sandwich_filling([_bread1, filling, _bread2]), do: {:ok, filling}
  def find_sandwich_filling([_bread1, filling1, filling2, _bread2]), do: {:ok, [filling1, filling2]}
  def find_sandwich_filling(_), do: {:error, "Not a proper sandwich structure"}

  # Work with alternating patterns
  def separate_odds_evens(list, odds \\ [], evens \\ [])
  def separate_odds_evens([], odds, evens), do: {Enum.reverse(odds), Enum.reverse(evens)}

  def separate_odds_evens([head | tail], odds, evens) when rem(head, 2) == 1 do
    separate_odds_evens(tail, [head | odds], evens)
  end

  def separate_odds_evens([head | tail], odds, evens) do
    separate_odds_evens(tail, odds, [head | evens])
  end
end

IO.puts(AdvancedDestructuring.analyze_sequence([5, 5, 5]))
IO.puts(AdvancedDestructuring.analyze_sequence([2, 4, 6]))
IO.puts(AdvancedDestructuring.analyze_sequence([1, 2, 3, 4, 5, 6]))

IO.inspect(AdvancedDestructuring.find_sandwich_filling(["bread", "turkey", "bread"]))
IO.inspect(AdvancedDestructuring.find_sandwich_filling(["bread", "ham", "cheese", "bread"]))

{odds, evens} = AdvancedDestructuring.separate_odds_evens([1, 2, 3, 4, 5, 6, 7, 8, 9])
IO.puts("Odds: #{inspect(odds)}, Evens: #{inspect(evens)}")


# Note:
# 2..4: This is Range syntax in Elixir. It represents the inclusive integers 2, 3, and 4.
# What it means in plain English:
# "Match any list, but only execute this block if that list has 2, 3, or 4 elements."
#
# The Final Step: Enum.reverse(odds), Enum.reverse(evens)
# This is the Base Case of our tail-recursive function. It is necessary because of how Elixir (and the underlying Erlang VM) handles memory and lists.

# Why do we need Enum.reverse?
# In Elixir, lists are linked lists.
# Adding an element to the beginning of a list (prepending) is extremely fast (O(1)), but adding an element to the end (appending) is slow (O(n))
# because the computer has to walk through the entire list to find the end.
# To stay efficient, your recursive functions do this:
# 1. They take the head of the input.
# 2. They prepend it to the accumulator: [head | odds].
# 3. This results in a list that is backwards (the last item found is now the first item in the list).
# The Result:
# By the time the function reaches the empty list [] (the base case), your odds and evens lists are fully populated
# but in the reverse order of the original list.
# a) Original: [1, 3, 5]
# b) Accumulator: [5, 3, 1]
# The Enum.reverse/1 call at the very end flips them back to their original relative order before returning them to the user.



IO.puts("")
#----------------------------------------------------------------------------------------------------


# Real-World Application: Log Processing
defmodule LogProcessor do
  # Parse log entries with different formats
  def process_logs([]), do: []

  def process_logs([entry | rest]) do
    case String.split(entry, " ", parts: 4) do
      [timestamp, level, module, message] ->
        processed = %{
          timestamp: timestamp,
          level: String.upcase(level),
          module: module,
          message: message,
          severity: get_severity(level)
        }
        [processed | process_logs(rest)]

      _ ->
        # Skip malformed entries
        process_logs(rest)
    end
  end

  # Extract only error logs using pattern matching
  def extract_errors([]), do: []

  def extract_errors([%{level: "ERROR"} = error | rest]) do
    [error | extract_errors(rest)]
  end

  def extract_errors([_log | rest]) do
    extract_errors(rest)
  end

  # Count logs by severity
  def count_by_severity(logs, counts \\ %{})
  def count_by_severity([], counts), do: counts

  def count_by_severity([%{severity: severity} | rest], counts) do
    updated_counts = Map.update(counts, severity, 1, &(&1 + 1))
    count_by_severity(rest, updated_counts)
  end

  defp get_severity("error"), do: :critical
  defp get_severity("warn"), do: :medium
  defp get_severity("info"), do: :low
  defp get_severity(_), do: :unknown
end

# Sample log data
raw_logs = [
  "2024-01-15T10:30:00 error UserAuth Failed login attempt",
  "2024-01-15T10:31:00 info Database Connected successfully",
  "2024-01-15T10:32:00 warn Cache Memory usage at 85%",
  "2024-01-15T10:33:00 error PaymentAPI Transaction failed"
]

processed = LogProcessor.process_logs(raw_logs)
IO.puts("Processed #{length(processed)} log entries")

errors = LogProcessor.extract_errors(processed)
IO.puts("Found #{length(errors)} error entries:")
Enum.each(errors, fn error ->
  IO.puts("  #{error.timestamp}: #{error.message}")
end)

counts = LogProcessor.count_by_severity(processed)
IO.puts("Severity counts: #{inspect(counts)}")


# Note:
# Map pattern matching and Accumulators to transform and summarize data.
# def extract_errors([%{level: "ERROR"} = error | rest]) do
#   [error | extract_errors(rest)]
# end
#
# This clause is doing three things simultaneously in the function argument:
#
# 1. List Splitting: It splits the incoming list into the first item (the head) and the remainder (rest).
# 2. Map Requirement: The %{level: "ERROR"} part ensures this clause only matches if the head is a map that contains the key :level with the exact value "ERROR".
# 3. Variable Binding (= error): This is the "aliasing" trick. It says: "If the map matches the 'ERROR' requirement, bind the entire map to the variable name error.
#
# And here:
# def count_by_severity([%{severity: severity} | rest], counts) do
#   updated_counts = Map.update(counts, severity, 1, &(&1 + 1))
#   count_by_severity(rest, updated_counts)
# end
#
# We need to know how Map.Update() works:
# This function is a "swiss-army knife" for maps:
# 1. Look up: It looks for the key stored in the variable severity (e.g., :critical).
# 2. Initial Value (1): If the key does not exist yet (first time we see this severity), it sets the value to 1.
# 3. The Function (&(&1 + 1)): If the key already exists, it runs this anonymous function. &1 represents the current value. It adds 1 to the existing count.
