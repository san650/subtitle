alias Subtitle.Frame

defmodule SubtitleTest do
  use ExUnit.Case, async: true
  doctest Subtitle

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

  @subrip "support/fixtures/subrip.srt"
  @microdvd "support/fixtures/microdvd"

  describe "from_file/1" do
    test "generates stream of frames for SubRip" do
      assert [@frame1, @frame2] ==
               Path.join([__DIR__, @subrip])
               |> Subtitle.from_file()
               |> Enum.to_list()
    end

    test "generates stream of frames for MicroDVD (.txt)" do
      assert [@frame1, @frame2] ==
               Path.join([__DIR__, "#{@microdvd}.txt"])
               |> Subtitle.from_file(fps: 1.0)
               |> Enum.to_list()
    end

    test "generates stream of frames for MicroDVD (.sub)" do
      assert [@frame1, @frame2] ==
               Path.join([__DIR__, "#{@microdvd}.sub"])
               |> Subtitle.from_file(fps: 1.0)
               |> Enum.to_list()
    end
  end
end
