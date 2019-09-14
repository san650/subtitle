alias Subtitle.Frame

defmodule Subtitle.SubRip.Parser do
  @moduledoc """
  Parse a single Frame. The parser is defined as a finite state machine where
  each line of text contains a fraction of a Frame (index or time or caption).

  The Frame struct is returned once it's completely parsed, it returns an
  intermediate parser state otherwise.
  """
  @states [
    :frame_index,
    :frame_time,
    :frame_caption,
    :frame_end,
  ]

  defstruct [
    :state,
    :frame
  ]

  @doc """
  Returns a new parser struct configured to start parsing a new frame
  """
  def new() do
    %__MODULE__{
      state: :frame_index,
      frame: %Frame{}
    }
  end

  @doc """
  Parses a line of text into a frame part. The parser struct holds the
  information about what part of the Frame is expected next.

  You need to call this function with the previous parser state and the next
  subtitle line until a Frame is completed. When all the information about the
  frame is extracted, the new frame is returned.
  """
  # @spec t() :: {:ok, Frame.t()} | {:cont, t()}
  def parse(%__MODULE__{state: :frame_index, frame: frame} = parser, line) do
    case Regex.scan(~r/^(\d+)$/, line) do
      [] -> continue(parser)
      [[_match, value]] ->
        parser
        |> put_frame(%{frame | index: value})
        |> transition()
    end
  end

  def parse(%__MODULE__{state: :frame_time, frame: frame} = parser, line) do
    case Regex.scan(~r/^(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})$/, line) do
      [] -> continue(parser)
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
    end
  end

  def parse(%__MODULE__{state: :frame_caption, frame: frame} = parser, "\n") do
    parser
    |> put_frame(%{frame | caption: Enum.reverse(frame.caption)})
    |> transition()
  end

  def parse(%__MODULE__{state: :frame_caption, frame: frame} = parser, line) do
    parser
    |> put_frame(%{frame | caption: [line | frame.caption]})
    |> continue()
  end

  defp continue(%__MODULE__{} = parser) do
    {:cont, parser}
  end

  defp transition(%__MODULE__{state: state, frame: frame} = parser) do
    index = Enum.find_index(@states, &(&1 == state))

    case Enum.at(@states, index + 1) do
      :frame_end -> {:ok, Frame.normalize(frame)}
      state -> continue(%{parser|state: state})
    end
  end

  defp put_frame(%__MODULE__{} = parser, %Frame{} = frame) do
    %{parser|frame: frame}
  end
end
