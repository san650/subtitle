defmodule Subtitle.StreamHelper do
  def create_stream(string) do
    {:ok, file} = StringIO.open(string)
    IO.stream(file, :line)
  end
end
