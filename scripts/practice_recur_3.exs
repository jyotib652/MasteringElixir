#------------------------------------------------------
# Recursion in Elixir - Spawning Process
#------------------------------------------------------
# Now we're stepping into the world of concurrency in Elixir. We'll
# learn how to create light weight processes that run independently.
# -------Think of each process as its own tiny worker with its own brain and
# its own memory.-------


# Elixir processes are not operating system threads. They are ultra lightweight
# units of execution managed by the BEAM virtual machine. Each process has its own
# memory, its own mailbox and runs independently. You can spin up millions of them
# without breaking a sweat.
# Beam virtual machine manages its own schedular and its own processes, each one takes
# about 2KB of memory that means you can create millions of them on a single machine.
# Think of them as single workers in a massive factory, each doing their own job without
# stepping on anyone else's toes.



# Spawn a process that prints a greeting
spawn(fn ->
  IO.puts("Hello from a new process!")
end)

# The parent process continues immediately without waiting
IO.puts("Hello from the parent!")
# The concurrency in Elixir - parent process does not pause or block, it keeps rolling.
# Both the parent process and the spawned process(child process) run concurrently.
# Concurrency does not guratee ordering - Here the parent or child process do not finish executing
# in any specific order. Sometimes the parent process finishes first and sometimes child process
# finishes first.


# When you call spawn it doesn't fire and forget silently. It returns a pid. pid stands for
# process identifier.
# spawn returns a pid
pid = spawn(fn ->
  IO.puts("Working hard over here!")
end)

# Inspect the PID
IO.puts("\n")
IO.puts("Spawned process: #{inspect(pid)}")

# Check you parent process's PID
IO.puts("Parent process: #{inspect(self())}")
IO.puts("")

# "#PID<0.128.0>" -> pid always has 3 numbers separated by . which
# identifies a single process in the Beam virtual machine and these pids
# are unique.
# Each pid is unique. This establishes each spawn call creates truly separate process.


# Parent defines a shopping list
items = ["bread", "milk", "eggs"]

spawn(fn ->
  # Child has its own copy
  my_items = items ++ ["chocolate"]
  IO.puts("Child: #{inspect(my_items)}")
end)

# wait briefly for child output. Here we're putting the Parent process to sleep briefly.
Process.sleep(100)

# Parent list is unchanged
IO.puts("Parent: #{inspect(items)}")

# Note:
# Parent's item does not contain the chocolate while the child's item contains the chocolate -
# this memory isolation is the fundamental feature of Beam. It prevents processes to acidentally
# corrupting each other's data.
# Child added chocolate to its copy of list but the Parent's list doesn't contain chocolate this prooves
# processes do not share memory, eah one works with its own isolated copy of data.

# Another example of data isolation in the processes
items = ["bread", "milk", "bananas"]

spawn(fn ->
  # Child has its own copy of the data
  my_item = items ++ ["Chocolate"]
  IO.puts("")
  IO.puts("Child One: #{inspect(my_item)}")
end)

# wait briefly for child output. Here we're putting the Parent process to sleep briefly.
Process.sleep(100)

spawn(fn ->
  # Child has its own copy of the data
  my_item = List.delete(items, "milk")
  IO.puts("Child Two: #{inspect(my_item)}")
end)

# wait briefly for child output. Here we're putting the Parent process to sleep briefly.
Process.sleep(100)

# Parent list is unchanged
IO.puts("Parent: #{inspect(items)}")
# This prooves the guarantee of data isolation for processes.



# Spawning using reusable function
defmodule Greeter do
  def hello(name) do
    IO.puts("")
    IO.puts("Hey #{name}, Welcome!")
    IO.puts("PID: #{inspect(self())}")
  end
end

# Spawn using a module function. It's the child process
spawn(Greeter, :hello, ["Tony Stark"])  # spawn(module, function name as atome, list of arguments) This is the preferred style for Spawning named function -
# but there are other spawn arguments usages -
# Kernel.spawn(fun)
# @spec spawn((-> any())) :: pid()
# Kernel.spawn(module, fun, args)
# @spec spawn(module(), atom(), list()) :: pid()  ---> function name passed on as an atom and spawn returns pid
# Spawns the given function fun from the given module passing it the given args and returns its PID.
# Typically developers do not use the spawn functions, instead they use abstractions such as Task, GenServer and Agent,
# built on top of spawn, that spawns processes with more conveniences in terms of introspection and debugging.
#
# Examples
# spawn(SomeModule, :function, [1, 2, 3])

# Also calling the function directly for comparison. It's the Parent process
Greeter.hello("Bruce Wayne")
# Here we're calling same function twice - Once through spawning and once through parent process directly
# calling the hello function itself. And we get 2 different pids proving they are different processes.


# Spawning using reusable function - another example
defmodule GreeterAndFarewell do
  def hello(name, process \\ "Parent") do
    IO.puts("Hey #{name}, Welcome!")
    IO.puts("PID for #{name} #{process} process: #{inspect(self())}")
  end

  def farewell(name, process) do
    IO.puts("Hey #{name}, Bye Bye!")
    IO.puts("PID for #{name} #{process} process: #{inspect(self())}")
  end
end

# Spawn using a module function. It's the child process
IO.puts("---------------------------------------------------")
spawn(GreeterAndFarewell, :hello, ["Tony Stark", "Spawned hello"])
spawn(GreeterAndFarewell, :farewell, ["Green Lantern", "Spawned farewell"])
GreeterAndFarewell.hello("Bruce Wayne")


# Spawn 5 workout tracker processes
IO.puts("\n")
Enum.each(1..5, fn rep ->
  spawn(fn ->
    # Simulate some work
    Process.sleep(rep * 50)
    IO.puts("Rep: #{rep} complete!")
  end)
end )

# Give them some time to finish
Process.sleep(500)
IO.puts("Workout done!")
#-------------------------------------------------------------------------------------
# Gotchas:
# When a spawned process crashes, the parent keeps running and has no idea anything went wrong.
# Errors vanish into the void unless you link or monitor the child process.

# This process will crash but the application will run unaffected [Beauty of Elixir]
spawn(fn ->
  raise "Something went wrong!"
end)

# Parent process keeps running unaware and uneffected
Process.sleep(200)
IO.puts("Parent is still alive!")

# check if Parent is alive
IO.puts("Parent PID: #{inspect(self())}")
IO.puts("Parent Alive? #{Process.alive?(self())}")
# Processes run in isolation so if one of the process crashes it doesn't effect other processes.
IO.puts("\n")
#-------------------------------------------------------------------------------------


# Another example of process isolation (among spawned processes also)
spawn(fn ->
  raise "Something went wrong for first child/spawned process"
end)

spawn(fn ->
  IO.puts("Second child/spawned process is successful")
end)

# Parent process keeps running unaware and uneffected
Process.sleep(200)
IO.puts("Parent is still alive!")

# check if Parent is alive
IO.puts("Parent PID: #{inspect(self())}")
IO.puts("Parent Alive? #{Process.alive?(self())}")
IO.puts("\n")
#-------------------------------------------------------------------------------------

# Making Parent process aware of child process's staus by using trap exit

# Trap exits so we can observe the link
Process.flag(:trap_exit, true)

# spawn_link ties child to parent. spawn_link creates a bidirectional link to child and parent processes
pid = spawn_link(fn ->
  IO.puts("Child starting ...")
  Process.sleep(100)
  raise "Child process crashed!"
end)

# Parent receives exit signal
Process.sleep(200)
receive do
  {:EXIT, ^pid, reason} ->          # child pid and crash reason
    IO.puts("Child process died!")
    IO.puts("Reason: #{inspect(reason)}")
    IO.puts("Child PID: #{inspect(pid)}")
    IO.puts("Parent PID: #{inspect(self())}")
end
# This is how you build resilient system. You link processes together so failures propagate and
# can be handled.
# Note:
# If you don't trap the exit by using "Process.flag(:trap_exit, true)"
# when the linked child process crashes it takes the parent down with it.

#-------------------------------------------------------------------------------------

# Differences between spawn and spawn_link:
# Spawn:
# Creates an independent process with no connection to the parent process.
# If the child process crashes, the parent process has no idea and keeps running.
# Use when failures can be safely ignored.
#
# spawn_link:
# Creates a linked process tied to the parent process. If either one crashes,
# the other one receives an exit signal. Use when you need crash awareness
# and fault propagation.
#
# In practice spawn_link is used far more often as you almost always want to know
# when something fails. Supervisor in elixir relies on these links to automatically
# restart these crashed processes which is the foundation of the famous "Let it crash" philosophy.

IO.puts("\n")
# A common practice/usage of spawn in Elixir: Spawn multiple processes concurrently
defmodule TripBudget do
  def estimate(city, days, rate) do   # rate stands for daily rate
    total = days * rate
    IO.puts("#{city}: #{total}")
  end
end

# Plan three trips concurrently
trips = [
  {"Tokyo", 7, 150},
  {"Paris", 5, 180},
  {"New York", 4, 200},
]

Enum.each(trips, fn {city, days, rate} ->
  spawn(TripBudget, :estimate, [city, days, rate])
end)

Process.sleep(100)
IO.puts("All estimates ready!")
