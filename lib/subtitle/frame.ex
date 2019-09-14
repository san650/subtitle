defmodule Subtitle.Frame do
  defstruct [
    :index,
    :begin_time,
    :end_time,
    caption: [],
  ]

  def normalize(%__MODULE__{} = frame) do
    frame
    |> Map.put(:caption, normalize_caption(frame))
    |> Map.put(:index, normalize_index(frame))
  end

  defp normalize_caption(%__MODULE__{caption: caption}) do
    caption
    |> Enum.map(fn value ->
      {encoding, _length} = :unicode.bom_to_encoding(value)
      :unicode.characters_to_binary(value, encoding)
    end)
    |> to_string()
    |> String.trim_trailing()
  end

  defp normalize_index(%__MODULE__{index: value}) do
    value
    |> String.to_integer()
  end
end
