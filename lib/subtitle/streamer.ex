defmodule Subtitle.Streamer do
  @moduledoc """
  Use this behavior to define a new streamer module
  """

  @callback stream(Stream.t()) :: {:ok, Stream.t()} | {:error, String.t()}
end
