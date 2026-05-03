#------------------------------------------------------------------------
# Process -> Concurrency -> Stateful Process With Recursion
#------------------------------------------------------------------------

# Everything in Elixir is immutable so how on earth you keep track of changing state?
# Answer is:
# You spawn a process that carries state in its function arguments then loops forever
# in recursion. Each time it loops it passes along the updated values
#
# Explanation:
# In Elixir, a process can hold state by passing updated values as arguments to
# a recursive function call. Each recursion is a new iteration of the loop, carrying
# fresh state forward. The process never mutates anything. It simply calls itself with
# new data. This is how immutability and statefullness coexist in the same language.

# Let's start with simplest possible recursive Process
defmodule Looper do
  def start do
    spawn(fn -> loop() end)   # creating or invoking the Process
  end

  defp loop do              # Private recursive function. It's an infinite loop.
    IO.puts("Still running...")
    Process.sleep(1000)
    loop()                      # This is a tail call as it's the last instruction in the function
  end
end

pid = Looper.start()      # spawn returns the pid so it's pid for child process
Process.sleep(3000)       # Here, Parent process is in sleep, so the child process is doing its work for this 3 seconds(While the main process (the caller) is blocked by sleep, the spawned process runs concurrently in the background.).
Process.exit(pid, :kill)  # Here, pid refers to the child process so we are killing the child, not the parent.
# NOTE:
# In Elixir, processes are isolated by default. If you did kill the parent process, the child would actually keep running!
# If you want the child to die automatically when the parent dies,
# you must Link them using spawn_link. Without a link, they are independent; the death of one does not affect the other.

IO.puts("")
#----------------------------------------------------------------------------------------------------

# Statful Process
defmodule Counter do
  def start(initial \\ 0) do
    spawn(fn -> loop(initial) end)
  end

  defp loop(count) do             # Here the function takes an argument
    IO.puts("Count is: #{count}")
    Process.sleep(1000)
    loop(count + 1)               # Here the function calls itself with a new argument.***
  end
end

# *** Instead of calling loop() without any argument we're calling it with a new value.
# Calling loop() with a new value, it creates a state. This is how state is created in recursion.
# The old count is never modified which is passing new value to the next call. It's also
# an accumulator pattern as well as a tail call.

pid = Counter.start(10)
Process.sleep(3000)
Process.exit(pid, :kill)


IO.puts("")
#----------------------------------------------------------------------------------------------------

defmodule Inbox do
  def start do
    spawn(fn -> loop() end)
  end

  defp loop do      # flishing mailbox function
    receive do
      {:hello, name} ->
        IO.puts("Hi there, #{name}!")

      {:bye, name} ->
        IO.puts("Goodbye, #{name}!")

      {:shout, name} ->
        IO.puts("A shout out to: #{String.upcase(name)}")
    end
    loop()        # Without this recursive call the process handles one message then dies. So this recursive call is crucial for flushing mailbox.
  end
end

pid = Inbox.start()
send(pid, {:hello, "Frodo"})  # sending message to the child process's mailbox
send(pid, {:bye, "Gendalf"})  # sending message to the child process's mailbox
send(pid, {:shout, "Calibrimbor"})  # sending message to the child process's mailbox
Process.sleep(100)


IO.puts("")
#----------------------------------------------------------------------------------------------------

# Another Stateful Process: recursive call carries the updated state forward. It never modifies the original state
# rather creates new value/state and pass that on to the recursive calls.
defmodule Tally do
  def start(initial \\ 0) do
    spawn(fn -> loop(initial) end)
  end

  defp loop(count) do
    receive do
      :increment ->
        new_count = count + 1
        IO.puts("Incremented to: #{new_count}")
        loop(new_count)

      :decrement ->
        new_count = count - 1
        IO.puts("Decremented to: #{new_count}")
        loop(new_count)

      :reset ->
        IO.puts("Resetting the count to 0.")
        loop(0)

      :print ->
        IO.puts("Current count: #{count}")
        loop(count)
    end
  end
end

pid =  Tally.start()
send(pid, :increment)
send(pid, :increment)
send(pid, :increment)
send(pid, :decrement)
send(pid, :print)
send(pid, :reset)
send(pid, :print)
Process.sleep(100)


IO.puts("")
#----------------------------------------------------------------------------------------------------


# "Two way communication" with State. From Parent sending message to Child and agian sending message from
# Child to Parent process. This is a powerful pattern.
# Here, we're implementing Two way comminication with State.
defmodule StoreKeeper do
  def start(initial \\ 0) do
    spawn(fn -> loop(initial) end)
  end

  defp loop(score) do
    receive do
      {:add, points} ->
        loop(score + points)    # Stateful recursion

      {:factor, number, caller} ->
        new_score = score * number
        send(caller, {:factor, new_score})   # Sending message to Parent's mailbox from Child process.
        loop(new_score)     # Stateful recursion

      {:get, caller} ->
        send(caller, {:score, score})   # Sending message to Parent's mailbox from Child process.
        loop(score)         # Stateful recursion
    end
  end
end

pid = StoreKeeper.start()
send(pid, {:add, 50})
send(pid, {:add, 30})
send(pid, {:get, self()})
send(pid, {:factor, 1.5, self()})

# Now read the Parent process's mailbox to get the message from Child process
#
receive do
  {:score, value} ->
    IO.puts("Player score: #{value}")
end

receive do
  {:factor, value} ->
    IO.puts("New score after the upgrade: #{value}")
end

# Note:
# To read more than one message in Parent process. You have to read them
# sequentially with receive block as shown in the above example. Or
# You have to read them in a helper function like you do in the flushing/
# draining mailbox pattern.
# Here, is an example of flushing/draining mailbox pattern to read messages
# sent from child process:
# defmodule MailboxReader do
#   def read_messages(0), do: :ok
#   def read_messages(count) do
#     receive do
#       {:score, value} ->
#         IO.puts("Received score: #{value}")
#         read_messages(count - 1)

#       {:factor, value} ->
#         IO.puts("Received factor update: #{value}")
#         read_messages(count - 1)
#     after
#       5000 -> IO.puts("Timed out waiting for message")
#     end
#   end
# end

# # Usage:
# MailboxReader.read_messages(2)



IO.puts("\n")
#----------------------------------------------------------------------------------------------------

# Synchronus call: First send message immediately after wait for reply/message. This send then receive
# pattern is called synchronus call. The caller is blocked until the response arrives. And it is very common.
# GenServer automates exactly this pattern with its handle call callback.
defmodule Wallet do
  def start(balance \\ 0) do
    spawn(fn -> loop(balance) end)
  end

  def deposit(pid, amount) do
    send(pid, {:deposit, amount})
  end

  def withdraw(pid, amount) do
    send(pid, {:withdraw, amount})
  end

  def balance(pid) do                 # This function implements Synchronus call
    send(pid, {:balance, self()})     # Sending message
    receive do                        # Immediately after waiting for reply/message. It's waiting for a reply from loop() function
      {:balance, amount} -> amount
    end
  end

  defp loop(balance) do
    receive do
      {:deposit, amount} ->
        loop(balance + amount)

      {:withdraw, amount} ->
        loop(balance - amount)

      {:balance, caller} ->
        send(caller, {:balance, balance})
        loop(balance)
    end
  end
end

w = Wallet.start()
Wallet.deposit(w, 25)
Wallet.deposit(w, 75)
IO.puts("Balance: $#{Wallet.balance(w)}")
Wallet.withdraw(w, 15)
IO.puts("Balance after withdrawal: $#{Wallet.balance(w)}")

# Note:
# Synchronus call blocks the caller. "balnce()" function implements the Synchronus Call
# pattern here.
# So the Parent Process (the one calling Wallet.balance(w)) is the one being blocked.
#
#
# If the Child process (the Wallet) crashes or is too busy to reply,
# the Parent process will stay blocked forever (a "deadlock" or "hang").
# In production Elixir code, you would typically use after to set a timeout:
# receive do
#   {:balance, amount} -> amount
# after
#   5000 -> exit(:timeout) # Stop waiting after 5 seconds
# end


# Gotchas:
#------------------------------------
# If you forget to call loop at the end of a receive clause, the process handles one
# message and silently dies. No error is raised. Subsequent messages vanish into a
# dead mailbox. Always ensure every clause ends with a recursive call.



IO.puts("")
#---------------------------------------------------------------------------------------------------------
# An example of what happens when you forget to call loop (recursive call) at the end of a receive clause
defmodule Buggy do
  def start, do: spawn(fn -> loop(0) end)

  defp loop(count) do
    receive do
      :increment ->
        new = count + 1
        IO.puts("Now: #{new}")
        # Oops! No loop(new) here       # Lack of the recursive call at the end makes the process die after receiving only one message. **

      :get ->
        IO.puts("Count: #{count}")
        loop(count)
    end
  end
end

pid = Buggy.start()
send(pid, :increment)
Process.sleep(50)
IO.puts("Alive? #{Process.alive?(pid)}")

send(pid, :get)
Process.sleep(50)
IO.puts("Alive? #{Process.alive?(pid)}")


# ** This proves the point of having recursive call at the end of
# every message handling otherwise it would always handle only one message.



IO.puts("")
#---------------------------------------------------------------------------------------------------------
# Always include a catch all so that you can analyze later what went wrong
defmodule SafeCounter do
  def start, do: spawn(fn -> loop(0) end)

  defp loop(count) do
    receive do
      {:add, n} ->
        loop(count + n)   # State is being updated

      {:get, caller} ->
        send(caller, {:count, count})
        loop(count)       # State is not being updated

      other ->
        IO.puts("Unknown: #{inspect(other)}")
        loop(count)       # State is not being updated

      after
        1000 ->
          IO.puts("Waiting for messages.")
          loop(count)       # ** Simple Heart Beat mechanism. It wouldn't die. It would periodically run the loop letting the user know that the process is still running.
    end
  end
end

pid = SafeCounter.start()
send(pid, {:add, 5})
send(pid, "oops")
send(pid, {:get, self()})
# Process.sleep(2500)

receive do
  {:count, val} ->
    IO.puts("Final count: #{val}")
end

# Explanation why the above Heart Beat mechanism isn't working:
# The reason your heartbeat mechanism isn't "working" as expected is likely due to how
# the Elixir process mailbox handles messages. In your script, the messages are sent almost instantaneously,
# which prevents the after clause from ever triggering.
# 1. The "Starvation" of the after Clause
# The after block in a receive do-loop only executes if the process mailbox is
# completely empty for the entire duration of the specified timeout (1000ms).
# In your execution flow:
# a) send(pid, {:add, 5}) arrives instantly.
# b) send(pid, "oops") arrives instantly.
# c) send(pid, {:get, self()}) arrives instantly.
# Because the process finds a message waiting every time it enters the receive block, the timer resets.
# The "Heart Beat" will only print if you stop sending messages to the process for longer than one second.
# So The Parent process exits before reaching 1000ms timeout as a result
# after block doesn't get a chance to call the loop() and the whole program exits before hitting 1000ms timeout.
#
# 2. Testing the Heartbeat
# To see the heartbeat in action, you need to introduce a delay in your main script to give the process time to idle.
# Try adding a Process.sleep after your sends:
# pid = SafeCounter.start()
# send(pid, {:add, 5})
# # Wait for 2.5 seconds to see the heartbeat trigger twice
# Process.sleep(2500)
# send(pid, {:get, self()})
# # ... rest of your code
#
# 3. A Note on "Dying" vs. "Idling"
# You mentioned the heartbeat ensures the process "wouldn't die." In Elixir/Erlang, a process stays alive as long as its recursive loop continues.
# Without the after block: The process would simply sleep (block) indefinitely until a new message arrives.
# It doesn't "die"; it just consumes zero CPU cycles while waiting.
# With the after block: The process "wakes up" every 1000ms to perform an action (printing the message) before going back to waiting.

# ** If you want a true "Heartbeat" that monitors if a process has crashed, you would typically use Monitors or Links via a Supervisor,
# rather than an internal after clause.



### V.V.V.I ##########
# 1. State lives in function arguments passed through recursive calls, it is never stored in mutable variables.
# 2. The receive block pauses a process (Parent process) until a message arrives, then pattern matches to handle it.
# 3. Every clause in receive must end with a recursive call or the process silently dies.
# 4. Wrapping send and receive in public function creates a clean client API, which is exactly what GenServer formalizes.
