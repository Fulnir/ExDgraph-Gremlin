defmodule ExdgraphGremlin.MixProject do
  use Mix.Project

  def project do
    [
      app: :exdgraph_gremlin,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "ExDgraph-Gremlin",
      source_url: "https://github.com/fulnir/exdgraph_gremlin",
      # The main page in the docs
      docs: [main: "ExdgraphGremlin", extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc, github: "tony612/grpc-elixir"},
      {:ex_dgraph, "~> 0.1.0", github: "ospaarmann/exdgraph", branch: "master"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.2", only: :dev, runtime: false},
      {:bunt, "~> 0.2.0"}
    ]
  end

  defp description do
    """
    ExDgraph-Gremlin is an addition for ExDgraph. WORK IN PROGRESS.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Edwin Bühler"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fulnir/exdgraph_gremlin"}
    ]
  end
end
