alias Subtitle.Frame

defmodule SubtitleTest do
  use ExUnit.Case
  doctest Subtitle

  @frame1 %Frame{
    index: 1,
    begin_time: ~T[00:00:00.000000],
    end_time: ~T[00:00:01.000000],
    caption: "Hello, world!",
  }

  @frame2 %Frame{
    index: 2,
    begin_time: ~T[00:00:02.000000],
    end_time: ~T[00:00:03.000000],
    caption: "This is the second frame",
  }

  @subrip "support/fixtures/subrip.srt"

  describe "from_file/1" do
    test "generates stream of frames for SubRip" do
      assert [@frame1, @frame2] ==
        Path.join([__DIR__, @subrip])
        |> Subtitle.from_file()
        |> Enum.to_list()
    end
  end
end
