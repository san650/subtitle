alias Subtitle.SubRip.Parser
alias Subtitle.Streamer

defmodule Subtitle.SubRip do
  @moduledoc """
  Parse SubRip Subtitle files (.srt)

  Example of a .srt file format

  ```
  1
  00:00:32,878 --> 00:00:35,939
  El mundo ha cambiado.

  2
  00:00:36,115 --> 00:00:39,142
  Lo siento en el agua.

  3
  00:00:39,886 --> 00:00:42,820
  Lo siento en la tierra.

  ```
  """

  @behaviour Streamer

  @doc """
  Returns a stream of Frame structs.

  This function receives a stream of lines of text.
  """
  def stream(stream) do
    Stream.transform(stream, Parser.new(), &do_stream/2)
  end

  defp do_stream(nil, %Parser{} = parser) do
    {:halt, parser}
  end

  defp do_stream(line, %Parser{} = parser) do
    case Parser.parse(parser, line) do
      {:ok, frame} -> {[frame], Parser.new()}
      {:cont, parser} -> {[], parser}
    end
  end
end
