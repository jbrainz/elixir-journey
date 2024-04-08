defmodule Servy.PledgeServerHandlCustom do
  @name :pledge_server_hand
  #Client Process
  def start do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    call @name,  :recent_pledges
  end

  def total_pledged do
   call @name, :total_pledge
  end

  def call(pid, message) do
    send pid, {self(), message}
    receive do {:response, response} -> response end
  end
  def clear do
    send @name, :clear
  end
  def send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  #Server Process
  @spec listen_loop(any()) :: no_return()
  def listen_loop(state) do
    receive do
      {sender, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state)

      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state)
    end
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount}| most_recent_pledges]
    {id, new_state}
  end
end

# alias Servy.PledgeServerHandlCustom

# pid = PledgeServerHandlCustom.start()

# PledgeServerHandlCustom.create_pledge( "larry", 10)
# PledgeServerHandlCustom.create_pledge( "moe", 20)
# PledgeServerHandlCustom.create_pledge( "curly", 30)
# PledgeServerHandlCustom.create_pledge( "daisy", 40)
# PledgeServerHandlCustom.create_pledge( "grace", 50)

# PledgeServerHandlCustom.recent_pledges
