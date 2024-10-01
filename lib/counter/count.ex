defmodule Counter.Count do
  use GenServer
  alias Phoenix.PubSub

  @name :count_server
  @start_value 0

  # external api

  def topic do
    "count"
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, @start_value, name: @name)
  end

  def incr do
    GenServer.call(@name, :incr)
  end

  def decr do
    GenServer.call(@name, :decr)
  end

  def current do
    GenServer.call(@name, :current)
  end

  # callback

  @impl true
  def init(start_count) do
    {:ok, start_count}
  end

  @impl true
  def handle_call(:current, _from, count) do
    {:reply, count, count}
  end

  @impl true
  def handle_call(:incr, _from, count) do
    make_change(count, +1)
  end

  @impl true
  def handle_call(:decr, _from, count) do
    make_change(count, -1)
  end

  defp make_change(count, change) do
    new_count = count + change
    # send message `{:count, new_count}` to the view via PubSub tube.
    PubSub.broadcast(Counter.PubSub, topic(), {:count, new_count})
    {:reply, new_count, new_count}
  end
end
