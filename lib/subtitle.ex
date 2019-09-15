alias Subtitle.SubRip
alias Subtitle.MicroDVD

defmodule Subtitle do
  @moduledoc """
  Documentation for Subtitle.
  """

  @doc """
  Returns a stream of %Subtitle.Frame{} structs
  """
  def from_file(path, options \\ []) do
    file_options =
      case Keyword.get(options, :encoding) do
        nil -> []
        encoding -> [encoding: encoding]
      end

    path
    |> File.stream!(file_options, :line)
    |> by_file_extension(Path.extname(path), options)
  end

  defp by_file_extension(stream, ".srt", _options) do
    SubRip.stream(stream)
  end

  defp by_file_extension(stream, ext, options) when ext in [".txt", ".sub"] do
    fps = Keyword.get(options, :fps, 23.976)

    MicroDVD.stream(stream, fps: fps)
  end
end
