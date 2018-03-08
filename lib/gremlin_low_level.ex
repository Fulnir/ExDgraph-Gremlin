defmodule ExdgraphGremlin.LowLevel do
  @moduledoc """
  Low level functions
  """
  require Logger
  alias ExdgraphGremlin.LowLevel
  import ExDgraph
  #alias ExDgraph.{Mutation}
  @doc """
  Creates a mutation request with a commit_now and send it to dgraph.
  """
  def mutate_with_commit(graph, nquad) do
    # Logger.info(fn -> "💡 request: #{inspect request}" end)
    #channel = graph.channel
    #request = ExDgraph.Api.Mutation.new(set_nquads: nquad, commit_now: true)
    #channel |> ExDgraph.Api.Dgraph.Stub.mutate(request)
    conn = graph.conn
    {:ok, _} = ExDgraph.mutation(conn, nquad)
  end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_node(graph, predicate, object) do
    mutate_with_commit(graph, ~s(_:identifier <#{predicate}> "#{object}" .))
  end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_node(graph, subject_uid, predicate, object) do
    mutate_with_commit(graph, ~s(<#{subject_uid}> <#{predicate}> "#{object}" .))
  end

  @doc """
  Creates the nquad and send it as mutaion request with a commit
  """
  def mutate_edge(graph, subject_uid, predicate, object_uid) do
    mutate_with_commit(graph, ~s(<#{subject_uid}> <#{predicate}> <#{object_uid}> .))
  end

  @doc """

  """
  def query_vertex(graph, vertex_uid) do
    conn = graph.conn

    query = """
    { vertex(func: uid(#{vertex_uid})) { expand(_all_) } }
    """

    {:ok, query_msg} = ExDgraph.query(conn, query)
    res = query_msg.result

    #request = ExDgraph.Api.Request.new(query: query)
    #{:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    # Logger.info(fn -> "💡 msg.json: #{inspect msg.json}" end)
    #Logger.info(fn -> "💡res: #{inspect res}" end)
    #decoded_json = Poison.decode!(query_msg.json)
    vertices = res["vertex"]
    [vertex_one] = vertices
    vertex = for {key, val} <- vertex_one, into: %{}, do: {String.to_atom(key), val}
    struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
    struct(struct_type, vertex)
  end

  @doc """

  """
  def query_vertex(graph, search_type, predicate, object, display) do
    conn = graph.conn
    if display != "expand(_all_)" do
      display = "vertex_type " <> display
    end
    query = """
    { vertices(func: #{search_type}(#{predicate}, \"#{object}\")) { #{display} } }
    """
    {:ok, query_msg} = ExDgraph.query(conn, query)
    res = query_msg.result
    #request = ExDgraph.Api.Request.new(query: query)
    #{:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    #decoded_json = Poison.decode!(msg.json)
    vertices = res["vertices"]
    #Logger.info(fn -> "💡 vertices: #{inspect vertices}" end)
    map =
      Enum.map(vertices, fn vertex_map ->
        vertex = for {key, val} <- vertex_map, into: %{}, do: {String.to_atom(key), val}
        struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
        struct(struct_type, vertex)
      end)

    {:ok, map}
  end
  @doc """
  Similar to `query_vertex/4`, but raises an `Error` if the dgraph query is not possible.
  """
  def query_vertex!(graph, search_type, predicate, object, display) do
    {:ok, vertex} = query_vertex(graph, search_type, predicate, object, display)
    vertex
  end
  def query_vertex(graph, search_type, predicate, object) do
    {:ok, map} = query_vertex(graph, search_type, predicate, object, "expand(_all_)")
    map
  end
  @doc """
  Similar to `query_vertex/3`, but raises an `Error` if the dgraph query is not possible.
  """
  def query_vertex!(graph, search_type, predicate, object) do
    {:ok, vertex} = query_vertex(graph, search_type, predicate, object, "expand(_all_)")
    vertex
  end

  def query_eq_vertex!(graph, predicate, object, display) do
    conn = graph.conn
    if display != "expand(_all_)" do
      display = "vertex_type " <> display
    end
    query = """
    { vertices(func: eq(#{predicate}, \"#{object}\")) { #{display} } }
    """
    {:ok, query_msg} = ExDgraph.query(conn, query)
    res = query_msg.result
    #request = ExDgraph.Api.Request.new(query: query)
    #{:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    #decoded_json = Poison.decode!(msg.json)
    vertices = res["vertices"]
    #Logger.info(fn -> "💡 vertices: #{inspect vertices}" end)
    map =
      Enum.map(vertices, fn vertex_map ->
        vertex = for {key, val} <- vertex_map, into: %{}, do: {String.to_atom(key), val}
        struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
        struct(struct_type, vertex)
      end)

    map
  end
  def query_eq_vertex!(graph, predicate, object) do
    query_eq_vertex!(graph, predicate, object, "expand(_all_)")
  end
end
