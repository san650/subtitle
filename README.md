# Subtitle

Elixir library to parse subtitle files.

Current supported formats:

* SubRip subtitle files (`.srt`).
* MicroDVD subtitle fiels (`.txt` or `.sub`).

## Installation

Add `subtitle` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [{:subtitle, github: "https://github.com/san650/subtitle"}]
end
```

Install via `mix deps.get`.

## Usage

After installing just write a little Elixir function:

```elixir
# Returns a stream of %Subtitle.Frame{} structs
Subtitle.from_file("lord_of_the_rings.srt")
|> Enum.to_list
```

Streaming subtitles from any `IO.stream`

```elixir
subtitle = """
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

{:ok, file} = StringIO.open(subtitle, [:line])
file
|> IO.stream(:line)
|> Subtitle.SubRip.stream()
|> Enum.take(1)
# => %Subtitle.Frame{
#      index: 1,
#      begin_time: ~T[00:00:00.000000],
#      end_time: ~T[00:00:01.000000],
#      caption: "Hello, world!"
#    }
```

## License

`Subtitle` is licensed under the MIT license.

See [LICENSE](./LICENSE) for the full license text.
