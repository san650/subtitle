alias Subtitle.SubRip
alias Subtitle.MicroDVD

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
    |> by_file_extension(Path.extname(path))
  end

  defp by_file_extension(stream, ".srt") do
    SubRip.stream(stream)
  end

  defp by_file_extension(stream, ext) when ext in [".txt", ".sub"] do
    MicroDVD.stream(stream, fps: 23.976)
  end
end
