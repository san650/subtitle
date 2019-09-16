alias Subtitle.{
  Frame,
  SubRip
}

defmodule Subtitle.SubRipTest do
  use ExUnit.Case, async: true
  doctest SubRip

  import Subtitle.StreamHelper

  @subtitle """
  1
  00:00:00,000 --> 00:00:01,000
  Hello, world!

  2
  00:00:02,000 --> 00:00:03,000
  This is the second frame

  3
  00:00:04,000 --> 00:00:05,000
  This is the third line

  """

  @frame1 %Frame{
    begin_time: ~T[00:00:00.000000],
    end_time: ~T[00:00:01.000000],
    caption: "Hello, world!"
  }

  @frame2 %Frame{
    begin_time: ~T[00:00:02.000000],
    end_time: ~T[00:00:03.000000],
    caption: "This is the second frame"
  }

  @frame3 %Frame{
    begin_time: ~T[00:00:04.000000],
    end_time: ~T[00:00:05.000000],
    caption: "This is the third line"
  }

  describe "#stream" do
    test "returns a stream of frames" do
      assert [@frame1, @frame2, @frame3] ==
               @subtitle
               |> create_stream()
               |> SubRip.stream()
               |> Enum.to_list()
    end
  end
end
