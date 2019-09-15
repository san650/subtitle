alias Subtitle.Frame
alias Subtitle.SubRip.Parser

defmodule Subtitle.SubRip.ParserTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Parser

  describe "new/0" do
    test "returns new struct" do
      assert %Parser{
               state: :frame_index,
               frame: %Frame{}
             } == Parser.new()
    end
  end

  describe "parse/2 in frame_index state" do
    @parser %Parser{
      state: :frame_index
    }

    test "parses index" do
      check all(index <- StreamData.positive_integer()) do
        assert {:cont, %{frame: frame}} = Parser.parse(@parser, "#{index}\n")
        assert %{index: ^index} = frame
      end
    end

    # FIXME: Need to make sure the gen string is not a positive_integer
    #
    # test "ignores everything else" do
    #   check all string <- StreamData.string(:printable) do
    #     assert {:cont, %{status: :frame_index, frame: frame}} = Parser.parse(@parser, string)
    #     assert %{index: nil} = frame
    #   end
    # end

    test "moves to the next state" do
      string = "1"

      assert {:cont, %{state: :frame_time}} = Parser.parse(@parser, string)
    end
  end

  describe "parse/2 in frame_time state" do
    @parser %Parser{
      state: :frame_time
    }

    test "parses begin_time" do
      check all(
              hour <- StreamData.integer(0..23),
              minute <- StreamData.integer(0..59),
              second <- StreamData.integer(0..59),
              millisecond <- StreamData.integer(0..999)
            ) do
        {:ok, time} = Time.new(hour, minute, second, millisecond)
        timestamp = to_timestamp(hour, minute, second, millisecond)

        assert {:cont, %{frame: frame}} = Parser.parse(@parser, "#{timestamp} --> 00:00:00,000")
        assert %{begin_time: ^time} = frame
      end
    end

    test "parses end_time" do
      check all(
              hour <- StreamData.integer(0..23),
              minute <- StreamData.integer(0..59),
              second <- StreamData.integer(0..59),
              millisecond <- StreamData.integer(0..999)
            ) do
        {:ok, time} = Time.new(hour, minute, second, millisecond)
        timestamp = to_timestamp(hour, minute, second, millisecond)

        assert {:cont, %{frame: frame}} = Parser.parse(@parser, "00:00:00,000 --> #{timestamp}")
        assert %{end_time: ^time} = frame
      end
    end

    test "ignores everything else" do
      check all(string <- StreamData.string(:printable)) do
        assert {:cont, %{state: :frame_time, frame: frame}} = Parser.parse(@parser, string)
        assert %{begin_time: nil, end_time: nil} = frame
      end
    end

    test "moves to the next state" do
      string = "00:00:00,000 --> 00:00:00,000"

      assert {:cont, %{state: :frame_caption}} = Parser.parse(@parser, string)
    end
  end

  describe "parse/2 in frame_caption state" do
    @parser %Parser{
      state: :frame_caption
    }

    test "parses one line captions" do
      check all(
              string <- StreamData.string(:printable),
              string != ""
            ) do
        assert {:cont, parser} = Parser.parse(@parser, string)
        assert {:ok, %{caption: ^string}} = Parser.parse(parser, "\n")
      end
    end

    test "supports latin1" do
      latin1 = <<0x53, 0x45, 0xD1, 0x4F, 0x52>>
      assert {:cont, parser} = Parser.parse(@parser, latin1)
      assert {:ok, %{caption: "SEÑOR"}} = Parser.parse(parser, "\n")
    end

    test "supports utf8" do
      utf8 = <<0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE4, 0xBA, 0xBA>>
      assert {:cont, parser} = Parser.parse(@parser, utf8)
      assert {:ok, %{caption: "日本人"}} = Parser.parse(parser, "\n")
    end
  end

  defp to_timestamp(hour, minute, second, millisecond) do
    String.pad_leading(to_string(hour), 2, "0") <>
      ":" <>
      String.pad_leading(to_string(minute), 2, "0") <>
      ":" <>
      String.pad_leading(to_string(second), 2, "0") <>
      "," <>
      String.pad_leading(to_string(millisecond), 3, "0")
  end
end
