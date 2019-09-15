alias Subtitle.{
  Frame,
  MicroDVD
}

defmodule Subtitle.MicroDVDTest do
  use ExUnit.Case, async: true
  doctest MicroDVD

  import Subtitle.StreamHelper

  @subtitle """
  {100}{200}El mundo ha cambiado.
  {300}{400}Lo siento en el agua.|Lo siento en la tierra.
  """

  @fps 10.0

  @frame1 %Frame{
    begin_time: ~T[00:00:10.000000],
    end_time: ~T[00:00:20.000000],
    caption: "El mundo ha cambiado."
  }

  @frame2 %Frame{
    begin_time: ~T[00:00:30.000000],
    end_time: ~T[00:00:40.000000],
    caption: "Lo siento en el agua.\nLo siento en la tierra."
  }

  describe "#stream" do
    test "returns a stream of frames" do
      assert [@frame1, @frame2] ==
               @subtitle
               |> create_stream()
               |> MicroDVD.stream(fps: @fps)
               |> Enum.to_list()
    end
  end
end
