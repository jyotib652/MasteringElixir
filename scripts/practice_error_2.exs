#------------------------------------------------------
# Error handling: With Expressions for Happy Paths
#------------------------------------------------------
# Points:
# 1. How the with expression chains multiple pattern matches in to a clean pipeline
# 2. How each step in a with block must succeed before the next one runs
# 3. How a failed match short-circuits the entire with block and returns the non-matching value
# 4. How to use else clauses to handle failures gracefully in real world workflows

#
defmodule Greeter do
  def parse(input) do
    {:ok, String.trim(input)}
  end

  def validate(name) do
    if String.length(name) > 0,
    do: {:ok, name},
    else: {:eroor, "empty name"}
  end

  def greet(name) do
    {:ok, "Hello, #{name}!"}
  end
end

result = with {:ok, n} <- Greeter.parse("  Frodo "),
              {:ok, v} <- Greeter.validate(n),
              {:ok, msg} <- Greeter.greet(v) do
                msg
end

IO.puts(result)

# Note:
# 1. The Anatomy of the One-Liner
# In Elixir, if is a macro. When you write it on a single line, you are passing a keyword list as the second argument to that macro.
# if String.length(name) > 0, do: {:ok, name}, else: {:error, "empty name"}
#
# 2. Under the Hood (Syntactic Sugar)
# If you were to write this without the "sugar," it would look like a standard function call:
# if(condition, [do: value1, else: value2])
#
# Because Elixir allows you to omit the square brackets [] for the last argument if it’s a keyword list, it becomes:
# if condition, do: value1, else: value2

# In a with expression, the commas act as delimiters between multiple clauses.
# Think of the with block as a pipeline of "guards." Each step must match for the code to continue.
# 1. The Comma as a "Step Separator"
# In our snippet, the with block has three distinct steps. The commas tell Elixir where one pattern-match ends and the next begins:
# result = with {:ok, n} <- Greeter.parse("  Frodo "), # Comma 1: End of step 1
#               {:ok, v} <- Greeter.validate(n),       # Comma 2: End of step 2
#               {:ok, msg} <- Greeter.greet(v)         # No comma here
#          do
#            msg
#          end
# Comma 1: Separates the parse attempt from the validate attempt.
# Comma 2: Separates the validate attempt from the greet attempt.
# The do: Once you hit the keyword do, the commas stop because you are entering the "success body."
# 2. Why is this useful?
# The with macro is designed to handle "Happy Path" programming.
# It executes the first line.
# If the result matches {:ok, n}, it moves past the comma to the next line.
# If at any point a line does not match (e.g., validate returns {:error, "empty name"}), the chain breaks immediately.
# It skips the remaining commas and returns the value that failed to match.
#
# A "Hidden" Comma Trick
# Just like the if statement, if you wanted to write the entire with block on a single line, you would need an extra comma before the "do:" :
# # Note the comma after the last clause and the colon after "do"
# result = with {:ok, n} <- Greeter.parse("Frodo"), {:ok, msg} <- Greeter.greet(n), do: msg
# In our original multi-line version, the newline replaces the need for a comma before the do,
# but the commas between the clauses remain mandatory so Elixir knows they aren't all one giant line of code.
# with block spread over multiple lines is dsirable as they increases the readability of the code.


# Another Note:
# A with expression evaluates each left arrow clause from top to bottom.
# If every pattern matches, the do block runs. If any pattern fails to match,
# the with expression immediately returns the non-matching value without evaluating
# the remaining clauses. No exceptions, no crashes. Just the raw vaue that did not
# match.


IO.puts("")
#----------------------------------------------------------------------------------------------------

defmodule Cart do
  def find_items(id) do
    items = %{1 => "Laptop", 2 => "Mouse"}
    case Map.fetch(items, id) do
      {:ok, name} -> {:ok, name}
      :error -> {:error, "item not found"}
    end
  end

  def check_stock(name) do
    {:error, "#{name} is out of stock"}
  end
end

result = with {:ok, name} <-  Cart.find_items(1),
              {:ok, _} <- Cart.check_stock(name) do     # code short-circuits here as it never matches with the value {:ok, name}. It returns {:error, "... is out of stock"}**
                "Added to the cart"
end

IO.inspect(result)

# ** This line short-circuited the program but it didn't crash the program
# as it's inside with block. Since it short-circuited, "Added to the cart"
# line never evaluates/executes.


# Note:
# In idiomatic Elixir, Map.fetch already returns {:ok, value} or :error
# If the key exists, Map.fetch returns {:ok, value}.
# If the key does not exist, it returns the atom :error.
#
# Explanation of the line:
# {:ok, name} -> {:ok, name}
# So {:ok, name} -> {:ok, name} means
# the first "{:ok, name}"", pattern matches with the return value of Map.fetch() which is {:ok, value}
# and when it is successful it returns the same value which is denoted by the rest of that line which is "-> {:ok, name}"


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Adding a else clause to the with block chaining
defmodule Auth do
  def find_user(email) do
    users = %{"neo@matrix.io" => "neo"}
    case Map.fetch(users, email) do
      {:ok, name} -> {:ok, name}
      :error -> {:error, :not_found}
    end
  end

  def check_password(_user, pass) do
    if pass == "red_pill", do: {:ok, :authenticated},
    else: {:error, :wrong_password}
  end
end

email = "neo@matrix.io"
# email = "morpheus@matrix.io"
result = with {:ok, user} <-  Auth.find_user(email),
              {:ok, _} <- Auth.check_password(user, "blue") do
                "Welcome back, #{user}!"
else
  {:error, :not_found} ->
    "User dioes not exist."

  {:error, :wrong_password} ->
    "Incorrect password."
end


IO.puts(result)

# Note:
# I your else clause does not match the failed value, Elixir raises a
# WithClauseError at runtime. Always include a catch all pattern or ensure
# every possible failure is covered in your else branch.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Catch all safety net with "with" clause
defmodule Converter do
  def parse_temp(input) do
    case Float.parse(input) do
      {num, _} -> {:ok, num}
      :error -> {:error, :bad_format}
    end
  end

  def celcius(f) do
    {:ok, (f - 32) * 5 / 9}
  end
end

# Note:
# Float.parse() is used to extract a floating-point number from the beginning of a string.
# The Return Values:-
# The function returns one of two things:
# 1. A Tuple: {float, rest}  -
# float: The number successfully parsed.
# rest: The remaining part of the original string that wasn't part of the number.

# 2. An Atom: :error   -
# This occurs if the string does not start with a valid representation of a float or integer.

# Examples:
# Input String                        Return Value                    Note
# "3.14"	                            {3.14, ""}	                    Clean parse.
# "12.55 is the price"	              {12.55, " is the price"}        Returns the "leftover" string.
# "100"	                              {100.0, ""}	                    Integers are converted to floats.
# "3.5e2"	                            {350.0, ""}	                    Supports scientific notation.
# "price is 5.0"	                    :error	                        Fails because it doesn't start with a digit.


temp = "abc"
# temp = "212"
result = with {:ok, temp} <- Converter.parse_temp(temp),
              {:ok, c} <- Converter.celcius(temp) do
                "#{c} degree celcius"
else
  {:error, :bad_format} ->
    "Could not parse temparature."

  other ->                # Catch all pattern inside else block
    "Unexpected #{inspect(other)}"
end

IO.puts(result)

# Note:
# It's best practice to use catch all pattern with else block
# whenever you use else block with "with" clause/block.



IO.puts("")
#----------------------------------------------------------------------------------------------------

# Guards inside with block
defmodule Fitness do
  def parse_steps(input) do
    case Integer.parse(input) do
      {n, _} -> {:ok, n}
      :error -> {:error, "not a number"}
    end
  end
end

steps = "8500"
# steps = "12000"
result = with {:ok, steps} <- Fitness.parse_steps(steps),
              true <- steps >= 10_000 do      # *** this is the guard clause. Further explanations are below
      "Goal reached! #{steps} steps today"
else
  {:error, msg} ->
    "Parse error #{msg}"

  false ->
    "Keep going! You have not hit 10,000 yet."
end

# *** This line pattern matches with true.
# if steps are greater than or equal to 10000 then it
# will return true otherwise false. Here this line
# pattern matches with true(return value from the expression: steps >= 10_000).
# But if the expression returns false then it is handled in else block.
# In the else block the program pattern matches with
# false (return value from the expression: steps >= 10_000)
# and then it provides appropriate message for the value(false).
#
# Integer.Parse() is exactly same as Float.Parse()

IO.puts(result)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Multi step data verification with "with" block
defmodule Signup do
  def check_email(e) do
    if String.contains?(e, "@"),
    do: {:ok, e},
    else: {:error, "Invalid email"}
  end

  def check_age(age) when age >= 13 do      # Guard clause
    {:ok, age}
  end

  def check_age(_), do: {:error, "too young"}     # Catch all for age

  def check_name(name) when byte_size(name) > 0 do    # Guard clause
    {:ok, name}
  end

  def check_name(_), do: {:error, "empty name"}   # Another catch all
end

result = with {:ok, email} <-  Signup.check_email("sam@shire.com"),
              {:ok, age} <- Signup.check_age(25),
              {:ok, name} <- Signup.check_name("Sam") do
                "#{name} #{email}, #{age} age signed up!"
else
  {:error, reason} -> "Signup failed - #{reason}"
end

IO.puts(result)

# Note:
# If any one of the conditions of the with clause
# fails then whole chaining of other processes also
# fails as it short-circuits the rest.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# What happens if you do not use else clause with "with" block/clause.
# In that scenario, there would be nothing to handle failed scenarios.
defmodule Recipe do
  def find(name) do
    recipes = %{"pasta" => ["flour", "eggs"]}
    case Map.fetch(recipes, name) do
      {:ok, items} -> {:ok, items}
      :error -> {:error, "recipe not found"}
    end
  end

  def scale(items, factor) do
    scaled = Enum.map(items, fn i ->
      "#{factor} x #{i}"
    end)
    {:ok, scaled}
  end
end


food = "pizza"
# food = "pasta"
result = with {:ok, items} <- Recipe.find(food),
              {:ok, scaled} <- Recipe.scale(items, 3) do
                IO.inspect(scaled, label: "Ingredients")

end

IO.inspect(result, label: "Result")

# Note:
# Since Recipe.find() does not find a pizza recipe
# and there is no else clause to handle this(errors) it
# diectly returns the error tuple. And it also
# short circuits the chaining of processes inside
# with block because when find fails it automatically
# fails rest of the other processes in the chain.
# So the error tuple ({:error, "recipe not found"})
# becomes the result.
#
# You do not always need else clause with "with" block.
# Use else clause when you want to transform or customize
# error handling. Skip it when raw error value is good enough.


# Benefits of happy paths (process chaining with "with" block):
# 1. The with expression chains pattern matches in a flat, readable
# pipeline that replaces deeply nested case statements.

# 2. If any clause fails to match, with short-circuits immediately
# and returns the non-matching value.

# 3. Use else clauses to handle and transform failures, and always
# include a catch-all to prevent WithClauseError crashes.

# 4. You can use guards, the pin operator and bare expressions
# inside with clauses for flexible control flow.
