defmodule ExdgraphGremlin.GremlinToQraphQL do
  require Logger
  import ExdgraphGremlin
  # import ExdgraphGremlin.GremlinToQraphQL
  alias ExdgraphGremlin.Vertex
  alias ExdgraphGremlin.Edge
  alias ExdgraphGremlin.GremlinGraphQL

  @spec query(GremlinGraphQL) :: GremlinGraphQL
  def query(graph_in) do
    case graph_in do
      {:ok, graph} ->
        # <> "\n\t}"
        query =
          "\n{ #{graph.name}(#{GremlinGraphQL.query_root(graph)}) #{
            GremlinGraphQL.filter_root(graph)
          } \n\t{\n" 
          <> "\t\t" <> "#{GremlinGraphQL.query_body(graph)}"
          <> "\n\t}" <> "\n}"

        # IO.write query
        IO.puts(query)
        %GremlinGraphQL{graph | query: query}
        result = ExDgraph.Query.query(graph.conn, query)
        case result do
          {:ok, query_msg} ->
            res = query_msg.result[graph.name]
            IO.inspect res
            {:ok, res}

          {:error, error} ->
              {:error, error}
          end
      {:error, error} ->
        {:error, error}
    end
  end

  @spec v(GremlinGraphQL) :: GremlinGraphQL
  def v(graph) do
    # IO.write "{}"
    # {:ok, %GremlinGraphQL{graph | query_root: query_root}}
    {:ok, graph}
  end


  @spec query(GremlinGraphQL) :: GremlinGraphQL
  def has(graph_in, predicate, object) do
    case graph_in do
      {:ok, graph} ->
        GremlinGraphQL.set_root(graph, predicate, object)

      {:error, error} ->
        {:error, error}
    end
  end
end
