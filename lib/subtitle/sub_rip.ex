defmodule Subtitle.SubRip do
  @moduledoc """
  Parse SubRip Subtitle files (.srt)

  1. The number of the caption frame in sequence
  2. Beginning and end timecodes for when the caption frame should appear
  3. The caption itself
  4. A blank line to indicate the start of a new caption sequence
  ```
  """

  defmodule Frame do
    defstruct [
      :index,
      :begin_time,
      :end_time,
      caption: [],
    ]
  end

  @states [
    :frame_start,
    :frame_index,
    :frame_time,
    :frame_caption,
    :frame_end,
  ]

  defstruct [
    :state,
    :stream,
    :frame
  ]

  defp transition(%__MODULE__{state: state} = parser) do
    index = Enum.find_index(@states, &(&1 == state))

    %{parser|state: Enum.at(@states, index + 1)}
  end
  defp put_frame(%__MODULE__{} = parser, %Frame{} = frame) do
    %{parser|frame: frame}
  end

  def next_frame(stream) do
    parse(%__MODULE__{
      state: :frame_index,
      stream: stream,
      frame: %Frame{}
    })
  end

  defp parse(%__MODULE__{state: :frame_index, stream: stream, frame: frame} = parser) do
    case Enum.take(stream, 1) do
      [line] -> case Regex.scan(~r/^(\d+)$/, line) do
        [] -> parse(parser) # move to next line
        [[_match, value]] ->
          parser
          |> put_frame(%{frame | index: value})
          |> transition()
          |> parse
      end

      [] ->
          parser
          |> transition()
          |> parse
    end
  end

  defp parse(%__MODULE__{state: :frame_time, stream: stream, frame: frame} = parser) do
    case Enum.take(stream, 1) do
      [line] -> case Regex.scan(~r/^(\d{2}):(\d{2}):(\d{2}),(\d{4}) --> (\d{2}):(\d{2}):(\d{2}),(\d{4})$/, line) do
        [] -> parse(parser) # move to next line
        [
          [
            _,
            begin_hour,
            begin_minute,
            begin_second,
            begin_microsecond,
            end_hour,
            end_minute,
            end_second,
            end_microsecond
          ]
        ] ->
          {:ok, begin_time} = Time.new(
            String.to_integer(begin_hour),
            String.to_integer(begin_minute),
            String.to_integer(begin_second),
            String.to_integer(begin_microsecond)
          )
          {:ok, end_time} = Time.new(
            String.to_integer(end_hour),
            String.to_integer(end_minute),
            String.to_integer(end_second),
            String.to_integer(end_microsecond)
          )

          parser
          |> put_frame(%{frame | begin_time: begin_time, end_time: end_time})
          |> transition()
          |> parse
      end

      [] ->
          parser
          |> transition()
          |> parse
    end
  end

  defp parse(%__MODULE__{state: :frame_caption, stream: stream, frame: frame} = parser) do
    case Enum.take(stream, 1) do
      [line] -> case Regex.scan(~r/^\n$/, line) do
        [] ->
          parser
          |> put_frame(%{frame | caption: [line, frame.caption]})
          |> parse
        [[_match]] ->
          parser
          |> transition()
          |> parse
      end

      [] ->
          parser
          |> transition()
          |> parse
    end
  end

  defp parse(%__MODULE__{state: :frame_end, frame: frame}) do
    %{frame | caption: frame.caption |> to_string() |> String.trim_trailing()}
  end
end
