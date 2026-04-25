#------------------------------------------------------------------------
# Process -> Concurrency -> Sending and Receiving Messages
#------------------------------------------------------------------------
#
# Every Elixir process has a private mailbox. Processes never share memory.
# They communicate ony by sending and receiving messages. This eliminates
# race conditions and make concurrent code surprisingly straight forward.
#
# Actor Model:
# Every process has their own mailbox nobody can peek inside your box or
# steal your mail. The only way to communicate is dropping a letter in
# someone else's box and waiting for reply in your box. This is the "Actor"
# model. It's the reason Elixir handles concurrently so smoothly without
# a headache. No shared states means no lock no race conditions and no
# mysterious bugs.

# Now we'll Send a message to our own mailbox
self_id  = self()  # grab our own process id using self : self is generally used for main process
IO.puts("My PID: #{inspect(self_id)}")

# Drop a message to our own mailbox
send(self_id, {:greeting, "Hello There!"})
IO.puts("Message sent!")

# check the mailbox
# "receive block opens your mailbox" and pattern matches against its contents
# pattern must matches to exactly what sent
receive do
  {:greeting, text} ->
    IO.puts("Got message: #{text}")
end

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another example
send(self(), {:order, "Pizza", 2})
send(self(), {:order, "Tacos", 5})
send(self(), {:tip, 4.50})

# all messages are processed in the order they arrive. First in First out(FIFO). This is
# the natural queue behaviour of every mailbox.
#
# First receive block matches any tuple tagged with atom order
receive do
  {:order, item, qty} ->
    IO.puts("Order: #{item} x #{qty}")
end

# Second receive block matches any tuple tagged with atom order
receive do
  {:order, item, qty} ->
    IO.puts("Order: #{item} x #{qty}")
end

# Third receive block matches any tuple tagged with atom tip
receive do
  {:tip, amount} ->
    IO.puts("Tip: $#{amount}")
end

# Note:
# mailbox holds all unread messages until you explicitly pulled them out.
# each receive block pulls one message in order from mailbox.

IO.puts("")
#----------------------------------------------------------------------------------------------------

# another example
send(self(), {:score, "Mario", 9800})
send(self(), {:health, "Link", 3})
send(self(), {:score, "Zelda", 7200})

# Here in the receive block we're pattern matching for 2 messages but
# every receive block handles only one message so we'll get only one
# output.
receive do
  {:health, name, hearts} ->
    IO.puts("#{name}: #{hearts} hearts")
  {:score, name, points} ->
    IO.puts("#{name}: #{points} points")
end

# But if we want to handle all the messages with one recieve block.
# Then we have to call the receive block multiple times which can be done
# through a recursive function.

defmodule HandleMessage do
  @doc """
  Recursively drains the process mailbox until empty.
  """
  def drain_mailbox do
    receive do
      {:health, name, hearts} ->
        IO.puts("#{name}: #{hearts} hearts")
        drain_mailbox() # Tail call

      {:score, name, points} ->
        IO.puts("#{name}: #{points} points")
        drain_mailbox() # Tail call

    after 0 ->
      # This block executes immediately if no messages match
      # or the mailbox is empty.
      IO.puts("Mailbox empty. Processing complete.")
      :ok
    end
  end
end

# Note:
# The Tail Call:
# Each time a message is matched, drain_mailbox() is called again. Because it is the last expression in the block,
# the BEAM (Erlang VM) performs Tail Call Optimization.
#
# The after 0 Trick:
# A standard receive block is "blocking"—it will sit and wait forever for a message to arrive.
# By adding after 0, we tell Elixir: "Check the mailbox right now. If there's a match, take it.
# If there is nothing there at this exact millisecond, move on." This is the "Base Case" for our recursion.

HandleMessage.drain_mailbox()

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Example of concurrency: sending message from parent process to child/spawned process and after
# capturing that message in child again sending a new message from child to parent process.
parent_pid = self()

# Capturing parent message in child then sending new message from child to parent
child_pid = spawn(fn ->
  receive do
    {:calculate, a, b} ->
      # result = a + b
      result = a * b
      send(parent_pid, {:result, result})
  end
end)

# Parent sending message to child
# send(child_pid, {:calculate, 85, 165})
send(child_pid, {:calculate, 12, 9})

# Parent receiving message from child
receive do
  {:result, total} ->
    IO.puts("Budget total: #{total}")
end

# Note:
# This request and response pattern is the bread butter of Elixir process communication.

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another beautiful example of sending and receiving messages using recursive calls with TCO
defmodule PingPong do
    # Base case
    def ping(pong_pid, 0) do
        send(pong_pid, :stop)
        IO.puts("Ping: done!")
    end

    def ping(pong_pid, n) do
        send(pong_pid, {:ping, self()})
        receive do
            :pong ->
                IO.puts("Ping: got pong")
        end
        ping(pong_pid, n - 1)
    end

    def pong do
        receive do
            {:ping, from} ->
                IO.puts("Pong: got ping")
                send(from, :pong)
                pong()
            :stop ->
                IO.puts("Pong: stopping")
        end
    end
end

pong_pid = spawn(PingPong, :pong, [])
PingPong.ping(pong_pid, 3)
IO.puts("")

IO.puts("Now calling the Ping Pong 5 times/rounds")
pong_pid = spawn(PingPong, :pong, [])
PingPong.ping(pong_pid, 5)

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Send ourselves(Parent process) a task message and then open a receive block
# to receive the data from parent mailbox and pattern match the message.
send(self(), {:task, "Buy groceries"})  # Here, we're sending the message

# The receive block will get the message immediately as the message
# was already there. It's not an empty mailbox when we're trying to pull
# the message from mailbox through receive block.
receive do
  {:task, item} ->
    IO.puts("Task: #{item}")

after           # when receive didn't get any matching message right away then this after clause will execute. **
  2000 ->
    IO.puts("No task found")
end

# ** This after clause says if there is no matching message right now then it will wait for 2000 milliseconds.
# After this 2000 miliseconds timeout if no matching message arrives, the code after runs instead.
#
# But in this scenario as the mailbox already contains the matching message so the receive block
# gets the message instantly and this after clause will not execute.

# NOW let's try with an empty mailbox.
receive do
  {:task, item} ->
    IO.puts("Task: #{item}")

after
  1000 ->
    IO.puts("")
    IO.puts("Mailbox empty. Timeout!")
end


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Standard Pattern for Draining Mailbox Completely: Flush Pattern
#------------------------------------------------------------------
# This pattern uses after clause with 0 millisecond as timeout

send(self(), {:weather, "Sunny", 72})
send(self(), {:weather, "Rainy", 58})

# Flush all messages with after 0
defmodule MailBox do
  def flush do
    receive do
      msg ->
        IO.puts("Found: #{inspect(msg)}")
        flush()

    after
      0 ->
        IO.puts("Mailbox is empty now.")
    end

  end
end

MailBox.flush()

# Note:
# using after 0 is perfect for non-blocking checks. Here, 0 is timeout means
# 0 millisecond timeout which is immediately.

IO.puts("")
#----------------------------------------------------------------------------------------------------


# Flush pattern (using after 0) picks any kind of messages as it doesn't pattern match
# the messages. Even if these messages contain different atoms, it doesn't matter.

send(self(), {:weather, "Sunny", 72})
send(self(), {:weather, "Rainy", 58})
send(self(), {:alert, "Heat Wave", 85, "Stay indoor and hidrated"})

# Flush all messages with after 0
defmodule MailBoxWeather do
  def flush do
    receive do
      msg ->
        IO.puts("Found: #{inspect(msg)}")
        flush()

    after
      0 ->
        IO.puts("Mailbox is empty now.")
    end

  end
end

MailBoxWeather.flush()

# Note:
# Messages that do not match any clause in receive stay in the mailbox
# permanently quitely eating memory. Over time this can cause memory leaks(overflows).
# Always handle unexpected messages or flush your mailbox periodically.


IO.puts("")
#----------------------------------------------------------------------------------------------------


# Handling unexpected messages without flushing. It's almost same as flushing
# but we do not use "after 0" rather use pattern matching and
# catch all type scenario with recursive call

send(self(), {:valid, "Study Elixir"})
send(self(), :random_noise)
send(self(), {:priority, "Buy the game asap!!!"})
send(self(), :another_random_noise)
send(self(), {:valid, "Practice IEx"})

defmodule SafeReceiver do
  def listen(count \\ 0) do
    receive do
      {:valid, task} ->
        IO.puts("Task: #{task}")
        listen(count + 1)           # This recursive call is there so that all the messages inside the mailbox can be read.
        # And without this recursive call, listen() function will stop here after this pattern match.

      {:priority, task} ->
        IO.puts("Priority Task: #{task}")
        listen(count + 1)

      other ->
        IO.puts("Ignored: #{inspect(other)}")
        listen(count)   # count remains same as we're not doing any task. We're not even counting these messages.
        # These messages are ignored as they're of no use.

    after
      500 ->
        IO.puts("Done. #{count} tasks.")
    end
  end
end

SafeReceiver.listen()  # We're not providing any argument to listen but still it's counting the tasks.

# Note:
# Is this code snippet Tail Call Optimized?
# Yes, it is.
# In this specific code, you are using an accumulator—it's just hidden in plain sight as the count argument.
# 1. Is your code TCO?
# Yes. For a function to be tail-recursive, the recursive call must be the last thing the function does.
# So in total. It's a tail call and also using accumulator pattern.
