defmodule ExdgraphGremlin.Edge do
  @moduledoc """
  And edge for gremlin
  """
  require Logger
  alias ExdgraphGremlin.Edge
  alias ExdgraphGremlin.Graph
  alias ExdgraphGremlin.Vertex
  @doc """
  The edge properties.
  Reserved for cache and other
  from => out => tail, to => in => head
  In edges of a vertex are connected to in vertex of a edge.
  """
  defstruct graph: Graph,
            predicate: String,
            from: Vertex,
            to: Vertex

  @doc """
  Creates a new graph
  """
  def new(the_graph, predicate) do
    %Edge{graph: the_graph, predicate: predicate}
  end
end
