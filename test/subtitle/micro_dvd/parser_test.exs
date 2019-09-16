alias Subtitle.MicroDVD.Parser

defmodule Subtitle.MicroDVD.ParserTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Parser

  describe "new/1" do
    test "returns new struct" do
      assert %Parser{fps: 1.0} == Parser.new(fps: 1.0)
    end
  end

  describe "parse/2" do
    @parser %Parser{fps: 1.0}

    test "parses start frame" do
      check all(frame <- StreamData.positive_integer()) do
        time = Time.add(~T[00:00:00], frame, :second)

        assert {:ok, %{begin_time: ^time}} = Parser.parse(@parser, "{#{frame}}{0}Foo")
      end
    end

    test "parses end frame" do
      check all(frame <- StreamData.positive_integer()) do
        time = Time.add(~T[00:00:00], frame, :second)

        assert {:ok, %{end_time: ^time}} = Parser.parse(@parser, "{0}{#{frame}}Foo")
      end
    end

    test "parses caption" do
      check all(
              caption <- StreamData.string(:printable),
              caption != ""
            ) do
        assert {:ok, %{caption: ^caption}} = Parser.parse(@parser, "{0}{0}#{caption}")
      end
    end

    test "parses multiline caption" do
      check all(
              line1 <- StreamData.string(:printable),
              line2 <- StreamData.string(:printable)
            ) do
        caption = "#{line1}\n#{line2}"
        assert {:ok, %{caption: ^caption}} = Parser.parse(@parser, "{0}{0}#{line1}|#{line2}")
      end
    end
  end
end
