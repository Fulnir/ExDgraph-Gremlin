defmodule ExdgraphGremlin.GraphQL do
  @moduledoc """
  """
  require Logger

  alias ExdgraphGremlin.GraphQL

  @enforce_keys [:conn]
  @doc """
  The graph properties.
  """
  defstruct conn: DBConnection,
            name: String,
            query: String,
            query_root: nil,
            filter_root: nil,
            body: nil

  @doc """
  Creates a new graph
  # graph_query
  """
  def new(conn, name \\ "graphql") do
    {:ok, %GraphQL{conn: conn, name: name}}
  end

  #@spec query(GraphQL) :: GraphQL
  def root(graph_in, matching_type, predicate_object) do
    predicate = elem(predicate_object, 0)
    object = elem(predicate_object, 1)
    #IO.inspect graph_in
    case graph_in do
      {:ok, graph} ->
        query_root = {matching_type, predicate, object}
        {:ok, %GraphQL{graph | query_root: query_root}}
      {:error, error} ->
        {:error, error}
    end
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
    if graph.body != nil do
      IO.inspect graph.body
      ""
    else
      # default name, expand(_all_) or empty ? 
      "expand(_all_)"
    end
  end

  @spec query(GraphQL) :: GraphQL
  def query(graph_in) do
    case graph_in do
      {:ok, graph} ->
        # <> "\n\t}"
        query =
          "\n{ #{graph.name}(#{GraphQL.query_root(graph)}) #{
            GraphQL.filter_root(graph)
          } \n\t{\n" 
          <> "\t\t" <> "#{GraphQL.query_body(graph)}"
          <> "\n\t}" <> "\n}"

        # IO.write query
        IO.puts(query)
        %GraphQL{graph | query: query}
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

end
