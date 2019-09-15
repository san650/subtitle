alias Subtitle.SubRip.Parser

Benchee.run(%{}, load: "perf/lastest.benchee")
Benchee.run(
  %{
    "sub_rip_parser" => fn ->
      {:cont, parser} = Parser.parse(%Parser{state: :frame_caption}, "hello world")
      Parser.parse(parser, "\n")
    end
  },
  save: [path: "perf/lastest.benchee", tag: "latest"]
)
