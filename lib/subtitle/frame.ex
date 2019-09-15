defmodule Subtitle.Frame do
  @moduledoc """
  Struct that represents one subtitle frame
  """

  defstruct [
    :index,
    :begin_time,
    :end_time,
    :caption
  ]
end
