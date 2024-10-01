defmodule CounterWeb.CounterComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <h1 class="text-4xl font-bold text-center">Counter: <%= @val %></h1>
      <button phx-click="dec" class={btn("red")}>-</button>
      <button phx-click="inc" class={btn("green")}>+</button>
    </div>
    """
  end

  # Avoid duplicating Tailwind classes and show hot to inline a function call:
  defp btn(color) do
    "w-20 bg-#{color}-500 hover:bg-#{color}-600"
  end
end
