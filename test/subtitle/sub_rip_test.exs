defmodule Subtitle.SubRipTest do
  use ExUnit.Case
  doctest Subtitle.SubRip
  alias Subtitle.SubRip
  alias Subtitle.SubRip.Frame

  @subtitle """
  1
  00:00:00,0000 --> 00:00:01,0000
  Hello, world!

  2
  00:00:02,0000 --> 00:00:03,0000
  This is the second frame

  """

  describe "#next_frame" do
    test "returns next frame" do
      stream = dummy_stream()

      assert %Frame{
        index: "1",
        begin_time: ~T[00:00:00.000000],
        end_time: ~T[00:00:01.000000],
        caption: "Hello, world!",
      } == SubRip.next_frame(stream)

      assert %Frame{
        index: "2",
        begin_time: ~T[00:00:02.000000],
        end_time: ~T[00:00:03.000000],
        caption: "This is the second frame",
      } == SubRip.next_frame(stream)
    end
  end

  defp dummy_stream() do
    {:ok, file} = StringIO.open(@subtitle, [:line])
    IO.stream(file, :line)
  end
end
