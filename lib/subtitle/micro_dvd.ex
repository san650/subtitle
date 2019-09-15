alias Subtitle.Streamer
alias Subtitle.MicroDVD.Parser

defmodule Subtitle.MicroDVD do
  @moduledoc """
  Parse MicroDVD Subtitle files (.txt or .sub)

  Example of a .sub file format

  ```
  {25}{125}El mundo ha cambiado.
  {200}{350}Lo siento en el agua.|Lo siento en la tierra.
  ```
  """

  @behaviour Streamer

  def stream(stream, fps: fps) do
    Stream.transform(stream, Parser.new(fps: fps), &do_stream/2)
  end

  defp do_stream(nil, %Parser{} = parser) do
    {:halt, parser}
  end

  defp do_stream(line, %Parser{fps: fps} = parser) do
    case Parser.parse(parser, line) do
      {:ok, frame} -> {[frame], Parser.new(fps: fps)}
      {:cont, parser} -> {[], parser}
    end
  end
end
