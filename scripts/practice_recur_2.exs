#------------------------------------------------------
# Recursion in Elixir - TCO : Tail Call Optimization
#------------------------------------------------------
# TCO - Tail Call Optimization an technic that lets you recurse -
# as deeply as you want without ever blowing up the call stack

# naive recursion - without any optimization
defmodule Factorial do
  def calc(1), do: 1

  def calc(n) when n > 1 do
    n * calc(n - 1)
  end
end

result = Factorial.calc(5)
IO.puts("5 factorial is: #{result}")
# # Here, in this naive approach the multiplication (n * calc(n - 1))
# can not happen until the last call returns. So every call sits on the stack
# waiting until the last call gets executed. So for small numbers it works
# but if you call Factorial.calc(1000000), here 1 million stack frames would be
# piled up and your process would run out of memory very very fast.
# In this scenario, Factorial.calc(5) - 5 function calls stacked up in the memory(stack)
# before the multiplication happen which is very bad scenario. So we need to avoid this.
# And we can avoid this my Tail Call Optimization(TCO)

#--------------------------------------------------------------------------------------------------
#  V.V.V.I - TCO : How Beam virtual machine handles TCO internally
#--------------------------------------------------------------------------------------------------
# Explanation:
# A tail call happens when a function call is the very last operation before returning.
# Nothing else wraps around it, no addition, no multiplication, no string concatenation.
# When the BEAM virtual machine sees a tail call, it reuses the current stack frame instead
# of adding a new one, keeping memory constant. And that allows you to recurse as deeply as you want.

# Recursion with Tail Call Optimization - Here we're using accumulator pattern. Here "acc" is the accumulator.
defmodule TailFactorial do
  def calc(n), do: calc(n, 1)

  # Base case for recursion
  defp calc(1, acc), do: acc

  defp calc(n, acc) when n > 1 do
    IO.puts("accumulator: #{acc}")
    calc(n - 1, acc * n)            # Tail call is happening here in this line. Since it's tail call BEAM optimizes it and reuses this stack frame.
  end
end

# Note:
# Since calc(n - 1, acc * n) is a function and it's the very last operation before returning for
# function calc(n, acc) ( for the line number 43. defp calc(n, acc) when n > 1 do),
# and no addition, no multiplication, no string concatenation is wrapped around the
# function calc(n - 1, acc), calling the function calc(n - 1, acc) becomes a tail call.
# And BEAM virtual machine reuses stack frame for this function each time without creating
# new stack frames for the successive recursion calls for this function and this way you
# would not go out of memory for this application even if you choose to go very deep with
# recursion for this application/function.

result = TailFactorial.calc(5)
IO.puts("5 factorial is: #{result}")

result = TailFactorial.calc(100)  # you can even try for 1 million (1000000) but it will take a few seconds to complete calculation.
IO.puts("10000 factorial is: #{result}")

# Naive Shopping Cart Total implementation
defmodule Cart do
  def total([]), do: 0

  def total([head | tail]) do
    head + total(tail)          # No tail call is happening here as the function call(total(tail)) is wrapped around an addition, so no Tail Call Optimization for this scenario.
  end
end

prices = [12.99, 5.49, 8.00, 3.50]
result = Cart.total(prices)
IO.puts("")
IO.puts("Cart total: #{result}")


# TCO Shopping Cart Total implementation
defmodule ShoppingCart do
  def total(list), do: total(list, 0)

  # Base case for recursion
  defp total([], acc), do: acc

  defp total([head | tail], acc) do
    total(tail, acc + head)           # Tail call is happening here as the reursive call is the last thing and nothing is wrapped around the recursive call. So, Tail Call Optimization is applied here.
  end
end

prices = [12.99, 5.49, 8.00, 3.50]
result = ShoppingCart.total(prices)
IO.puts("Shopping Cart total: #{result}")


# Step Counter with TCO (obviously using accumulator pattern)
defmodule StepCounter do
  def total(days), do: total(days, 0)

  defp total([], acc), do: acc

  defp total([steps | rest], acc) do
    total(rest, acc + steps)
  end
end

week = [8042, 6519, 12300, 9501, 7888, 11042, 5430]
result = StepCounter.total(week)
IO.puts("Weekly steps: #{result}")
# Note:
# For tail calls memory is constant as same stack frame is used over and over instead
# of creating new stack frames.


# Reverse a list using accumulator pattern (TCO)
defmodule ListReverser do
  def reverse(list), do: reverse(list, [])

  defp reverse([], acc), do: acc

  defp reverse([head | tail], acc) do
    # using the tail call so the TCO
    reverse(tail, [head | acc])       # here we are updating the accumulator list by prepending head to the "acc" list.
  end
end

playlist = ["Bohemian Rhapsody", "Stairway", "Hotel California", "Imagine"]
result = ListReverser.reverse(playlist)
IO.inspect result


# Reverse a list (now apply a condition on it) using accumulator pattern (TCO)
defmodule ListReverserNew do
  def reverse(list), do: reverse(list, [])

  defp reverse([], acc), do: acc

  # Clause A: If track is > 7 characters, add it to the accumulator
  defp reverse([head | tail], acc) when byte_size(head) > 7 do
    # using the tail call so the TCO is happening
    reverse(tail, [head | acc])       # here we are updating the accumulator list by prepending head to the "acc" list.
  end

  # Clause B: It matches anything Clause A missed. We just pass the acc through unchanged.
  # Here we're handling scenarios where the track length is equal to 7 or less than 7 while maintaing the TCO.
  # The same thing can be done using String.length() and if/else block but there would not be any "tail call" (without TCO).
  # Since, String.length() can't be used in guards as it's computation heavy we had to use byte_size()
  defp reverse([_head | tail], acc) do
    # using the tail call so the TCO is happening
    reverse(tail, acc)
  end

  # You can use the following code snippet replacing the Clause A and Clause B code snippets. TCO is also being implemented here.
  # Why this qualifies for TCO
  # Looking at your if/else logic, both possible branches end strictly with a call to reverse/2:
  # 1. Branch 1 (if): The last action is reverse(tail, acc).
  # 2. Branch 2 (else): The last action is reverse(tail, [head | acc]).
  # Even though you are doing work in the else branch (prepending head to acc), that work happens before the function calls itself.
  # Because there is no code left to execute after the recursive call returns, the VM doesn't need to keep the current "stack frame" alive.
  # It simply replaces the current frame with the next one.
  # defp reverse([head | tail], acc) do
  #   if String.length(head) <= 7 do
  #     reverse(tail, acc) # Continue without adding to acc
  #   else
  #     reverse(tail, [head | acc]) # Add to acc
  #   end
  # end

end

playlist = ["Bohemian Rhapsody", "Stairway", "Hotel California", "Imagine"]
result = ListReverserNew.reverse(playlist)
IO.inspect result


# Fibonacci series numbers implementation - Naive and Optimized
defmodule Fib do
  def naive(0), do: 0
  def naive(1), do: 1

  def naive(n) when n > 1 do
    naive(n - 1) + naive(n - 2)  # It's doubly bad. There is no tail call rather it branches into 2 recursive calls resulting in exponential time complexity.
  end

  def fast(n), do: fast(n, 0, 1)  # Here we're using 2 accumulators a & b representing current and next fibonacci numbers. We're using tail call here.

  # Base case for recursion
  defp fast(0, a, _b), do: a

  defp fast(n, a, b) when n > 0 do
    fast(n - 1, b, a + b)
  end
end

IO.puts("")
IO.puts("Naive fib 10: #{Fib.naive(10)}")
IO.puts("Fast fib 10: #{Fib.fast(10)}")

# Note:
# Fib.fast() uses TCO so it's memory uses is constant O(1) and the time taken is linear

# NOte: V.V.V.V.I:
# --------------------------------------------------------------------------------
# If anything wraps around your recursive call, such as addition, multiplication,
# list concatenation or string interpolation, it is NOT a tail call and will NOT
# be optimized. The recursive call must be very last operation.
#----------------------------------------------------------------------------------

#
defmodule Contrast do
  # NOT a tail call: ++ happens after
  def naive_map([], _fun), do: []

  def naive_map([h | t], fun) do
    [fun.(h) | naive_map(t, fun)]
  end

  # Tail call: recurse is last
  def tail_map(list, fun) do
    tail_map(list, fun, [])
  end

  defp tail_map([], _fun, acc) do
    Enum.reverse(acc)
  end

  defp tail_map([h | t], fun, acc) do
    tail_map(t, fun, [fun.(h) | acc])
  end
end

grades = [78, 92, 65, 88]
curved = Contrast.tail_map(grades, &(&1 + 5))   # Here, we're passing a function as argument to the tail_map(). And we handle as anonymous function.
curved_mult = Contrast.tail_map(grades, &(&1 * 2))  # Here, we're passing a function as argument to the tail_map(). And we handle as anonymous function.
# IO.inspect(curved)  # In Elixir (and Erlang), a charlist is simply a list of integers where every integer represents a valid Unicode code point.
IO.inspect(curved, charlists: :as_lists)
IO.inspect(curved_mult, charlists: :as_lists)

# NOte2:
# In Elixir, fun is a variable name representing an anonymous function (often called a "lambda" in other languages),
# while fun.(h) is the specific syntax used to execute (or "invoke") that function.
# In functional programming, functions are "first-class citizens."
# This means you can pass a function into another function just like you would pass an integer or a string.
# Explanation:
# Contrast.tail_map(grades, &(&1 + 5)) --> what does these 2 "&" mean:
# 1. The first &: The "Capture" operator
# The & at the very beginning tells Elixir: "I am about to define a function right here on the spot."
# Instead of writing:
# fn x -> x + 5 end
#
# You start with:
# &(...)
# It "captures" the expression inside the parentheses and turns it into a function that can be
# passed around as a variable (which becomes the fun in your tail_map code).
# 2. The second &1: The "Argument"
# The &1 represents the first argument passed to that function.
# &1 = The 1st argument
# &2 = The 2nd argument (if applicable)
# &n = The nth argument
# In the context of your tail_map, as the code iterates through your list, it takes the current head (h) and plugs it into the place of &1.
# Comparison Table
# To help visualize the shorthand, here is how the capture syntax translates to the standard "long" version:
# Shorthand                   Long Version (Anonymous Function)           What it does
# &(&1 + 5)                   fn x -> x + 5 end                             Adds 5 to the input
# &(&1 * &2)                  fn x, y -> x * y end                          Multiplies two inputs
# &(Integer.to_string(&1))    fn x -> Integer.to_string(x) end              Converts input to string
