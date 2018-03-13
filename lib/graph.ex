defmodule ExdgraphGremlin.Graph do
  @moduledoc """
  The graph for gremlin
  """
  require Logger

  alias ExdgraphGremlin.Graph

  @doc """
  The graph properties.
  Reserved for a cache (gen_server) and other
  """
  # FIXME: deprecated. Using conn
  defstruct channel: GRPC.Channel,
            conn: DBConnection,
            vertex: Vertex,
            edge: Edge,
            vertex_cache: nil

  @doc """
  Creates a new graph
  """
  def new(conn) do
    {:ok, %Graph{conn: conn}}
  end
end
