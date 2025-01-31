defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view
  @range 1..5

  def mount(_params, _session, socket) do
    {:ok, assign(socket, default_assigns())}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold">Your score: {@score}</h1>

    <h2>{@message}</h2>

    <div class="my-4">
      <%= if @score <= @win_threshold do %>
        <%= for n <- @range do %>
          <.link
            class="bg-blue-500
                 hover:bg-blue-700 text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
            phx-click="guess"
            phx-value-number={n}
          >
            {n}
          </.link>
        <% end %>
      <% end %>
    </div>

    <div class="mt-4">
      <button class="px-2 py-1 rounded bg-red-500" phx-click="reset">Reset</button>
    </div>
    """
  end

  def handle_event("guess", %{"number" => guess_str}, socket) do
    guess_str
    |> String.to_integer()
    |> process_guess(socket)
    |> check_win_condition(socket.assigns.win_threshold)
    |> update_socket(socket)
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, default_assigns())}
  end

  # --- Helper funkce ---

  defp default_assigns do
    %{
      score: 0,
      message: "Make a guess:",
      random: get_random(),
      range: @range,
      win_threshold: @range.last
    }
  end

  defp get_random, do: Enum.random(@range)

  defp process_guess(guess, socket) do
    if guess == socket.assigns.random do
      %{
        message: "Your guess: #{guess}. Correct!",
        score: socket.assigns.score + (@range.last - 1),
        random: get_random()
      }
    else
      %{
        message: "Your guess: #{guess}. Wrong!",
        score: socket.assigns.score - 1,
        random: socket.assigns.random
      }
    end
  end

  defp check_win_condition(%{score: score} = state, win_threshold) when score >= win_threshold do
    %{state | message: "YOU WON!", random: get_random()}
  end

  defp check_win_condition(state, _win_threshold), do: state

  defp update_socket(state, socket) do
    {:noreply, assign(socket, state)}
  end
end
