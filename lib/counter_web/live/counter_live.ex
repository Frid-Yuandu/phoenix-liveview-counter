defmodule CounterWeb.CounterLive do
  use CounterWeb, :live_view
  alias Counter.Count
  alias Phoenix.PubSub
  alias Counter.Presence

  @topic Count.topic()
  @presence_topic "presence"

  @impl true
  def mount(_params, _session, socket) do
    initial_present =
      if connected?(socket) do
        PubSub.subscribe(Counter.PubSub, @topic)
        CounterWeb.Endpoint.subscribe(@presence_topic)
        Presence.track(self(), @presence_topic, socket.id, %{})

        Presence.list(@presence_topic) |> map_size()
      else
        0
      end

    {:ok, assign(socket, val: Count.current(), present: initial_present)}
  end

  @impl true
  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :val, Count.incr())}
  end

  @impl true
  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :val, Count.decr())}
  end

  @impl true
  def handle_info({:count, count}, socket) do
    {:noreply, assign(socket, val: count)}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: present}} = socket
      ) do
    dbg(joins)
    dbg(socket.id)
    {_, joins} = Map.pop(joins, socket.id, %{})
    dbg(joins)

    changes = map_size(joins) - map_size(leaves)
    new_present = (present + changes) |> dbg()

    {:noreply, assign(socket, :present, new_present)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={CounterComponent} id="counter" val={@val} />
    <.live_component module={PresenceComponent} id="presence" present={@present} />
    """
  end
end
