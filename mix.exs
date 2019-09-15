defmodule Subtitle.MixProject do
  use Mix.Project

  def project do
    [
      app: :subtitle,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:stream_data, "~> 0.4", only: :test}
    ]
  end

  defp aliases do
    [
      perf: "run perf/benchee.exs"
    ]
  end
end
