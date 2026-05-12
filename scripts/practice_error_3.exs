#------------------------------------------------------
# Error handling: Protocols for Polymorphism
#------------------------------------------------------
# We'll learn:
# 1. How to define a protocol using defprotocol to create a shared interface
# 2. How to implement protocols for different data types using defimpl
# 3. How Elixir achieves polymorphism without classes or inheritance
# 4. How to write extensible code that works with existing and future types

# Note:
# A protocol defines a set of functions that different data types can
# implement in their own way. Think of it like a contract. Any type
# that signs the contract promises to respond to certain function calls,
# but each type gets to decide how it responds.

# Defining our first protocol
defprotocol Describable do                  # This is the contract. Any type that wants to be Describable must implement the function describe()
    @doc "Returns a description string"
  def describe(data)                        # Here, we only provide the function signature not the function body.
end

defimpl Describable, for: Map do            # This is the implementation of the above mentioned protocol for Map type.
    def describe(map) do                    # Here, we define the function body for the functions of the protocol/contract.
      count = map_size(map)
      "A map with #{count} entries"
    end
end


result = Describable.describe(%{a: 1, b: 2})
IO.puts(result)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another Example of Protocol
defprotocol Summarize do
  def summary(item)
end

defimpl Summarize, for: List do
  def summary(list) do
    len = length(list)
    "List of #{len} items"
  end
end

defimpl Summarize, for: Tuple do
  def summary(tuple) do
    size = tuple_size(tuple)
    "Tuple with #{size} elements"
  end
end


IO.puts(Summarize.summary([1, 2, 3]))
IO.puts(Summarize.summary({:ok, "done"}))

# Note:
# Here, we're calling summary function with different data types
# and it's able to handle them. The interface(Protocol) is able to handle
# them without any inheritance that's the polymorphism in Elixir.

# Gotchas:
# If you call a protocol function on a type that has no implementation, Elixir raises
# a Protocol.UndefinedError at runtime. Always implement for all types you plan to use,
# or define a fallback with Any.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another example of Protocol but this time with a fallback using Any
defprotocol Labelable do
  @fallback_to_any true   # this line tells eixir if no specific implementation exists for a type, it should look for an implementation for Any. It's an macro.
  def label(item)
end

defimpl Labelable, for: Integer do
  def label(n), do: "Number: #{n}"
end

defimpl Labelable, for: Atom do
  def label(a), do: "Atom: #{a}"
end

# Here, it will handle any data type other than Integer. This is the fallback implementation for Any.
defimpl Labelable, for: Any do
  def label(_item), do: "Unknown item"
end

IO.puts(Labelable.label(42))
IO.puts(Labelable.label(3.14))
IO.puts(Labelable.label(:hello))

# Note:
# @fallback_to_any - is it a macro in elixir?
#
# Technically, yes—@fallback_to_any is a module attribute that acts as a configuration flag for the defprotocol macro.
#
# In Elixir, when you use the @ symbol, you are defining or accessing a module attribute.
# When placed inside a defprotocol block, the protocol-defining macro looks for this specific attribute to change how the dispatching logic is compiled.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Protocol with multiple functions
defprotocol Trackable do
  def status(item)
  def progress(item)
end

defimpl Trackable, for: Map do
  def status(map) do
    done = Map.get(map, :done, false)  # Map.get(map, key, default \\ nil)
    if done, do: "Complete", else: "Pending"
  end

  def progress(map) do
    pct = Map.get(map, :percent, 0)
    "#{pct}% done"
  end
end

task = %{name: "Learn Elixir", percent: 75}
IO.puts(Trackable.status(task))
IO.puts(Trackable.progress(task))


# Note:
# Both functions status() and progress() must be implemented for Protocol.


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Protocol Dispatch in action
defprotocol Cost do
  def total(item)
end

defimpl Cost, for: Map do
  def total(map) do
    price = Map.get(map, :price, 0)
    qty = Map.get(map, :qty, 1)  # qty short for quantity
    price * qty
  end

defimpl Cost, for: List do
  def total(items) do
    Enum.reduce(items, 0, fn item, acc ->
      acc + Cost.total(item)  # Here it's calling total(map) as each item is a map. Protocols calling protocols.
    end )
  end
end

end

cart = [
  %{name: "Book", price: 15, qty: 2},
  %{name: "Pen", price: 3, qty: 5}
]

IO.puts("Total: #{Cost.total(cart)}")


# Note:
# When we're calling "Cost.total(cart)", first it's dispatched to fuction total() for List
# then from there it's get dispatched to function total() for Map. And finally we get the
# total value for the cart.
# Protocols calling protocols. It's like russian nesting dolls of Polymorphism.

# Recap:
# 1. Use defprotocol to define a shared interface that multiple types can implement.
# 2. Use defimpl to provide type-specific behaviour for each protocolfunction.
# 3. Enable fallback to Any or use derive to handle types without specific implementations.
# 4. Protocols give you polymorphism without inheritance, keeping your Elixir code extensible and clean.

#** Protocols are Elixir's way of achieving Polymorphism without classes or inheritance.
