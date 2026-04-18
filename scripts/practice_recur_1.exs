#------------------------------------------------------
# Recursion in Elixir
#------------------------------------------------------
defmodule CountDown do
  def start(0) do
    IO.puts("Liftoff!")
  end

  def start(n) when n > 0 do
    IO.puts(n)
    start(n - 1)
  end
end

CountDown.start(5)


# Trace count
defmodule Trace do
  def count(0) do
    IO.puts("Base case reached")
    :done
  end

  def count(n) when n > 0 do
    IO.puts("Calling count(#{n - 1})")
    result = count(n - 1)
    IO.puts("Returned from count(#{n - 1})")
    result
  end
end

IO.puts("")
Trace.count(3)


# Grocery Cart
defmodule ListMatch do
  def sum([]) do
    0
  end

  def sum([head | tail]) do  # This head, tail pattern matching is the "bread and butter" of list pattern matching in Elixir
    head + sum(tail)
  end

  def count([_head | tail]) do
    1 + length(tail)
  end

  def count_rec([]) do
    0
  end

  def count_rec([_head | tail]) do
    result = count(tail)
    1 + result
  end
end

groceries = [4.99, 2.50, 8.75, 1.25]
total = ListMatch.sum(groceries)
number_Of_items = ListMatch.count(groceries)
IO.puts("")
IO.puts("cart total: #{total}")
IO.puts("The cart has: #{number_Of_items} items")
IO.puts("The cart has: #{number_Of_items} items (recursively)")


# Tail recursion; Elixir can optimize this so uses constant stack space
defmodule Score do
  def total(list) do
    do_total(list, 0)  # here, 0 is the accumulator. Accumulator pattern is a standard elixir pattern matching use.
  end

  defp do_total([], acc) do
    acc
  end

  defp do_total([head | tail], acc) do
    do_total(tail, acc + head)  # here tail recursion happens
  end

  # Calculating Total and nunber of items at the same time using accumulator pattern
  def total_and_count(list) do
    do_total_and_count(list, {0, 0})  # here the accumulator is a tuple
  end

  defp do_total_and_count([], {total, count}) do
    {total, count}
  end

  defp do_total_and_count([head | tail], {total, count}) do
    do_total_and_count(tail, {total + head, count + 1})
  end

end

scores = [85, 97, 100, 72, 63]
IO.puts("\n")
IO.puts("total score: #{Score.total(scores)}")
{total, items} = Score.total_and_count(scores)
IO.puts("total score: #{total} and number of subjects: #{items}")


# Safer Count down
defmodule SafeCount do
  def down(0), do: IO.puts("Done!")

  def down(n) when is_number(n) and n > 0 do
    IO.puts("#{n}...")
    down(n - 1)
  end

  # These edge cases are called guards
  def down(n) when is_number(n) and n < 0 do
    IO.puts("Error: #{n} is negetive")
  end

  # # Also handle non-number scenarios
  # def down(n) when !is_number(n) and n > 0 do  # Note1 ********************
  #   IO.puts("Error: #{n} is not a number")
  # end

  # So the correct way to handle non-number scenarios is to use catch all pattern
  # Catch-all: If it wasn't a number handled above, it ends up here
  def down(n) do    # Note2 **************************************
    IO.puts("Error: #{inspect(n)} is not a number")
  end
end

# Note1 ********************
# In Elixir, guards are restricted to a specific set of built-in functions to ensure they are "pure" and fast.
# The ! operator is actually a macro that doesn't exist in the guard scope.
# Instead, you must use the "not" keyword. So this code snippet would crash.

# Note2 **************************************
# You've just discovered one of the most interesting "quirks" of Elixir: Term Ordering.
# You might expect "safe" to fall through to your "catch-all" function at the bottom, but instead, it matched def down(n) when n > 0.
# This happened because, in Elixir, strings are considered "greater than" numbers.
#
# A) Why it crashed
# When SafeCount.down("safe") is called, Elixir looked at your functions from top to bottom:
# 1. down(0): No match ("safe" is not 0).
# 2. down(n) when n > 0: Match! Because of Elixir's internal sorting rules, any string is "greater than" any integer.
# 3. Inside the function: It printed "safe..." (which you see in your output).
# 4. The Crash: It then tried to execute down("safe" - 1). Since you can't subtract 1 from a string, the Erlang VM threw an ArithmeticError.
#
# B) Understanding Term Ordering
# Elixir allows you to use comparison operators (>, <, etc.) between any two types. This is useful for sorting lists that contain mixed data, but it can bite you in guards. The official order is:
# number < atom < reference < function < port < pid < tuple < map < list < bitstring (strings)
#
# Since bitstrings (strings) are at the very top of the list, they will always be "greater than" numbers.
#
# C) The "Bulletproof" Fix
# To prevent strings or other types from entering your math logic, you should explicitly check if the input is a number in your primary guard.
# You can use is_number() function to check the input is a number or not.

IO.puts("")
SafeCount.down(3)
SafeCount.down(-3)
SafeCount.down("safe")


# Recursion for strings using concatenation
defmodule Repeat do
  # base case
  def times(_msg, 0), do: ""

  def times(msg, n) when is_number(n) and n > 0 do
    msg <> " " <> times(msg, n - 1)   # "<>" is concatenation operator in Elixir
  end
end

IO.puts("\n")
cheer = Repeat.times("Go!", 3)
IO.puts(String.trim(cheer))  # trim is used to clean the trailing space at the end

reminder = Repeat.times("Stydy", 2)
IO.puts(String.trim(reminder)) # trim is used to clean the trailing space at the end


# 5 star ratings
defmodule Stars do
  def times(0), do: ""

  def times(n) when is_number(n) and n > 0 do
    "*" <> times(n - 1)
  end
end

IO.puts("\n")
IO.puts(Stars.times(5))
IO.puts(Stars.times(4))


# Determine the highest temparature of the list
defmodule Stats do
  def max_val([only]), do: only

  def max_val([head | tail]) do
    tail_max = max_val(tail)

    if head > tail_max do
      head
    else
      tail_max
    end
  end

  def min_val([only]), do: only

  def min_val([head | tail]) do
    tail_min = min_val(tail)

    if head < tail_min do
      head
    else
      tail_min
    end
  end

end

IO.puts("")
temps = [72, 85, 91, 68, 77]
IO.puts("Highest temp: #{Stats.max_val(temps)}")

scores = [42, 99, 17, 88]
IO.puts("Highest score: #{Stats.max_val(scores)}")
IO.puts("Lowest score: #{Stats.min_val(scores)}")
IO.puts("Lowest temp: #{Stats.min_val(temps)}")


# Accumulator pattern again
defmodule Math do
  def factorial(n) when is_number(n) and n >= 0 do
    do_factorial(n, 1)
  end

  defp do_factorial(0, acc), do: acc

  defp do_factorial(n, acc) do
    do_factorial(n - 1, acc * n)  #  NOte: Since the recursion call is the last operation, elixir optimizes it as a loop internally,
    # you get elegance of recursion with the efficiency of iteration. This is the accumulator pattern at its finest.
  end

  # function for raise to the power
  def power(m, n) when is_number(m) and is_number(n) and m >= 0 and n >= 0 do
    do_power(m, n, 1)
  end

  defp do_power(0, n, _acc), do: 0
  defp do_power(m, 0, acc), do: acc
  defp do_power(m, n, acc) do
    do_power(m, n - 1, acc * m)
  end
end

# NOte:
# What you are looking at is a fundamental concept in functional programming called Tail Call Optimization (TCO).
# While it's true that Elixir (and the Erlang VM it runs on) does not have for or while loops in the traditional sense,
# TCO is the "magic" that allows recursion to behave exactly like a loop under the hood.
#
# 1. The Problem with Regular Recursion
# In most languages, every time a function calls itself, a new "frame" is added to the Call Stack.
# If you calculate the factorial of 1,000,000 using regular recursion, the stack grows so large that the computer runs out of memory,
# resulting in a Stack Overflow.
#
# 2. How Tail Call Optimization (TCO) Works
# TCO is a compiler optimization. If the very last thing a function does is call another function (or itself),
# the compiler realizes it doesn't need to keep the current stack frame alive. It can simply "jump" back to the start of the function with the new arguments
#
# 3. Comparing the Two Patterns
# Feature       Regular Recursion (Body Recursive)    Tail Recursion (Accumulator Pattern)
# Example         n * factorial(n - 1)                    do_factorial(n - 1, n * acc)
# Memory          Grows with every call (O(n))            Constant memory (O(1))
# Performance     Risks Stack Overflow                    As fast as a loop
# Last Action     Multiplication                          Calling the function

IO.puts("")
IO.puts("5! = #{Math.factorial(5)}")
IO.puts("5! = #{Math.factorial(10)}")
IO.puts("5! = #{Math.factorial(0)}")

IO.puts("")
IO.puts(" 2 to the power 8 is: #{Math.power(2, 8)}")
IO.puts(" 2 to the power 4 is: #{Math.power(2, 4)}")
IO.puts(" 2 to the power 1 is: #{Math.power(2, 1)}")
IO.puts(" 2 to the power 0 is: #{Math.power(2, 0)}")
