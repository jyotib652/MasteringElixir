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
