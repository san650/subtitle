alias Subtitle.Frame

defmodule Subtitle.MicroDVD.Parser do
  @moduledoc """
  Parse a single Frame.

  The Frame struct is returned once it's completely parsed, it returns an
  intermediate parser state otherwise.

  Format
  ```
  {START_FRAME}{END_FRAME}Dialog line|Second line of dialog
  ```
  """
  defstruct [
    :fps
  ]

  @format ~r/^\{(\d+)\}\{(\d+)\}(.+)$/

  def new(fps: fps) do
    %__MODULE__{
      fps: fps
    }
  end

  def parse(%__MODULE__{} = parser, line) do
    @format
    |> Regex.scan(line)
    |> to_frame(parser)
  end

  defp to_frame([], %__MODULE__{} = parser) do
    {:cont, parser}
  end

  defp to_frame([[_match, start_frame, end_frame, raw_caption]], %__MODULE__{fps: fps}) do
    frame =
      %Frame{}
      |> Map.put(:begin_time, to_time(start_frame, fps))
      |> Map.put(:end_time, to_time(end_frame, fps))
      |> Map.put(:caption, to_caption(raw_caption))

    {:ok, frame}
  end

  defp to_time(frame_number, fps) do
    millisecond = trunc(String.to_integer(frame_number) / fps * 1000)

    Time.add(~T[00:00:00], millisecond, :millisecond)
  end

  defp to_caption(raw_caption) do
    [raw_caption]
    |> to_string()
    |> String.split("|")
    |> Enum.map(&String.trim/1)
    |> Enum.join("\n")
  rescue
    _error in UnicodeConversionError ->
      # FIXME: If the file was read with an incorrect encoding we might need to
      # fallback to latin1
      raw_caption
      |> :unicode.characters_to_binary(:latin1)
      |> to_string()
      |> String.split("|")
      |> Enum.map(&String.trim/1)
      |> Enum.join("\n")
  end
end
