defmodule ExdgraphGremlin.GremlinGraphQL do
  @moduledoc """
  The graph for gremlin
  """
  require Logger

  alias ExdgraphGremlin.GremlinGraphQL

  @doc """
  The graph properties.
  Reserved for a cache (gen_server) and other
  """
  defstruct conn: DBConnection,
            name: String,
            query: String,
            query_root: Tuple,
            vertex: Vertex,
            edge: Edge,
            vertex_cache: nil

  @doc """
  Creates a new graph
  """
  def new(conn, name \\ "graphql") do
    {:ok, %GremlinGraphQL{conn: conn, name: name}}
  end

  def set_root(graph, predicate, object) do
    query_root = {:allofterms, predicate, object}
    {:ok, %GremlinGraphQL{graph | query_root: query_root}}
  end

  def query_root(graph) do
    # :allofterms, {"name", "Star Wars"} func: allofterms(name, "Edwin"
    if graph.query_root != nil do
      IO.inspect graph.query_root
      "func: allofterms(#{elem(graph.query_root, 1)}, \"#{elem(graph.query_root, 2)}\")"
    else
      ""
    end
  end


  def filter_root(graph) do
    ""
  end

  def query_body(graph) do
    "name"
  end
end
