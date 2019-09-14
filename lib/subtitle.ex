alias Subtitle.SubRip

defmodule Subtitle do
  @moduledoc """
  Documentation for Subtitle.
  """

  @doc """
  Returns a stream of %Subtitle.Frame{} structs
  """
  def from_file(path) do
    path
    |> File.stream!([], :line)
    |> SubRip.stream()
  end
end
