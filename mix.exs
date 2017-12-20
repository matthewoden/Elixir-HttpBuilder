defmodule HttpBuilder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :http_builder,
      name: "HttpBuilder",
      source_url: "https://github.com/matthewoden/Elixir-HttpBuilder",
      docs: docs(),
      package: package(),
      description: description(),
      version: "0.2.6",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Matthew Potter"],
      links: %{"GitHub" => "https://github.com/matthewoden/Elixir-HttpBuilder"}
    ]
  end

  def description do
    "A simple DSL for composing HTTP requests. Based off the lovely Elm-Http-Builder."
  end

  defp docs do
    [
      main: "HttpBuilder", 
      extras: ["README.md"],
      logo: "images/logo.png"
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.10", optional: true},
      {:httpoison, "~> 0.13.0", optional: true},
      {:poison, "~> 3.0", optional: true},
      {:httpotion, "~> 3.0", optional: true},
      {:ibrowse, "~> 4.4.0", optional: true},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
