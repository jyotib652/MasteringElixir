#------------------------------------------
# Pattern Matching With Simple Values
#------------------------------------------

x = 42
IO.puts("The value of x: #{x}")

42 = x
IO.puts("Match successful! x is indeed 42")

y = "Elixir"
"Elixir" = y
IO.puts("String match confirmed: #{y}")


IO.puts("")
#----------------------------------------------------------------------------------------------------


# When Patterns Don't Match
secret_code = 007

try do
  123 = secret_code
  IO.puts("This won't print")  # Because the previous line will cause an error
rescue
  MatchError -> IO.puts("Pattern match failed! expected 123 but got #{secret_code}")
end

name = "Bond"
try do
  "Smith" = name  # This line will also cause an error as we're trying "Smith" to match with "Bond". It's not assignment, it's match operator.
  IO.puts("This won't print either")
rescue
  MatchError -> IO.puts("Name mismatch! expected Smith but got #{name}")
end


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Pattern Matching with Atoms
status = :ok
:ok = status
IO.puts("Status is healthy!")

response = :error
:error = response
IO.puts("Houston, we have a problem")

# Common pattern in API responses
api_result = :success
case api_result do
  :success -> IO.puts("API call succeeded")
  :failure -> IO.puts("API call failed")
  :timeout -> IO.puts("API call timed out")
end


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Flexible Pattern Matching with Variables

# First assignment
user_id = 12345
IO.puts("Used id is set to: #{user_id}")

# Pattern match and reassign
54321 = user_id = 54321
IO.puts("User ID is updated to:#{user_id}")

# Note:
# In Elixir, evaluation moves from right to left.
# I'm talking about extreme right side of the line, 54321 = user_id = 54321

# The extreme right side, user_id = 54321

# Here Elixir will match 54321 with the value of user_id and the value of user_id is not 54321 rather 12345
# but still it rebinds the value 54321 with user_id and in the next step it tries to match it's value with 54321 and it succeeds.
# So at the first attempt when it tries to match user_id with 54321 and at that time the value of user_id was 12345 so it wasn't a
# match still it rebinds the value of user_id. Why it behaved like this?
# Explanation:

# You've hit on the most important distinction between variables and literals in Elixir's pattern matching.

# Your intuition is correct: user_id = 54321 always rebinds if it's a plain variable. Here is the nuance you're looking for:
# Variables vs. Literals
# In Elixir, the = operator behaves differently depending on what is on the left side:
#   1. If the left side is a Variable (user_id): Elixir says, "I will make this match work by giving this variable a new value."
#   This is rebinding. It doesn't care what the previous value was; it just overwrites it.

#   2. If the left side is a Literal (54321): Elixir says, "I cannot change the number 54321.
#   Therefore, I must check if the right side is already equal to 54321." This is strict matching.


# match with a new variable
admin_level = 5
current_level = admin_level
5 = current_level
IO.puts("Access level confirmed: #{current_level}")



IO.puts("")
#----------------------------------------------------------------------------------------------------

# Real-World Authentication Example
defmodule SimpleAuth do
  def check_credentials(username, password) do
    # Simulate database look up
    stored_username = "Alice"
    stored_password = "Secret123"

    # Pattern match both credentials
    ^stored_username = username
    ^stored_password = password

    :authenticated
  end
end


# test with correct credentials
result = SimpleAuth.check_credentials("Alice", "Secret123")
IO.puts("Login result: #{result}")


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Data validation pipeline
defmodule DataValidator do
  def process_user_input(input) do
    # Validate input type
    input_string = to_string(input)

    # Pattern match expected format
    "USER:" <> user_data = input_string

    # Extract and validate user ID
    [id_str, role] = String.split(user_data, ":")
    user_id = String.to_integer(id_str)

    # validate specific values
    true = user_id > 0
    true = role in ["admin", "user", "guest"]

    {user_id, String.to_atom(role)}
  end
end

# Note:
# In Elixir, the <> operator is the Binary Concatenation Operator. It is used to join two binaries (usually strings) together.
# <> operator usually is called concatenation operator.
#
# However, in your specific snippet, it is being used inside a Pattern Match, which is one of Elixir's most powerful features.
# 1. As a Concatenator (Standard Use)
# When used in a normal expression, it simply glues strings together:
# "Hello " <> "World"
# # Returns: "Hello World"
#
# 2. In Pattern Matching (Your Snippet)
# When you use <> on the left side of the = operator, you are performing a "prefix match."
# "User:" <> user_data = "User:Alice"
# In this case, Elixir does the following:
#   a) It checks if the string on the right (input_string) starts with the literal prefix "User:".
#   b) If it matches, it "chops off" that prefix and binds the remainder of the string to the variable user_data.
#   c) If the string does not start with "User:", it raises a MatchError.
#
# Constraints to Keep in Mind
# There is one major rule when using <> in pattern matches: "The left side of the operator must be a literal string".
# Valid: "User:" <> name = input (Elixir knows exactly how many bytes to skip to find name).
#
# Invalid: prefix <> "Data" = input (Elixir doesn't know where the prefix ends and the data begins, so this will throw a compile error).


# Test the validator
result = DataValidator.process_user_input("USER:123:admin")
IO.inspect(result, label: "Parsed user data")


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Pattern Matching Best Practises

# Good: Clear and specific patterns
defmodule StatusChecker do
  def handle_response(status_code) do
    200 = status_code
    "Success: Everything is working perfectly"
  end

  def handle_multiple_success_codes(code) do
    true = code in [200, 201, 202]
    "Success: Operation completed"
  end

  def safe_pattern_match(value, expected) do
    case value do
      ^expected -> {:ok, "Match successful"}
      _ -> {:error, "No match found"}
    end
  end
end

# Testing our patterns
IO.puts(StatusChecker.handle_response(200))
IO.puts(StatusChecker.handle_multiple_success_codes(201))
IO.inspect(StatusChecker.safe_pattern_match(42, 42))
IO.inspect(StatusChecker.safe_pattern_match(42, 99))


# Note:
# Why ^expected is used instead of expected here in the above code block?
# Explanation:
# In Elixir, variables are usually greedy. When you use a variable in a pattern match,
# Elixir's default behavior is to rebind that variable to whatever is on the right side.
#
# The Pin Operator (^) is how you tell Elixir: "Don't rebind this. Use its current value to see if the match is true."

# The carrot sign(^) is called Pin operator in Elixir.
