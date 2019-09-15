defmodule Subtitle.Streamer do
  @moduledoc """
  Use this behavior to define a new streamer module
  """
  @type options :: [{atom(), any()}]

  @callback stream(Stream.t(), options()) :: {:ok, Stream.t()} | {:error, String.t()}
end
