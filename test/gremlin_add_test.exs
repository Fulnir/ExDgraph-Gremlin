defmodule ExdgraphGremlin.GremlinAddTest do
  @moduledoc """

  # Gremlin tests

  ## AddVertex Step & AddProperty Step

      graph
          |> addV(Toon)
          |> property("name", "Bugs Bunny")
          |> property("type", "Toon")

  ## AddEdge Step

      graph
          |> addE("knows")
          |> from(marko)
          |> to(peter)



  """
  require Logger
  use ExUnit.Case
  import ExDgraph
  import ExdgraphGremlin
  alias ExdgraphGremlin.Toon
  alias ExdgraphGremlin.Person
  alias ExdgraphGremlin.Graph
  import GRPC
  # Extend the timeout
  @moduletag timeout: 120_000

  doctest ExdgraphGremlin
  @testing_schema "id: string @index(exact).
    name: string @index(exact, term) @count .
    knows: uid .
    type: string .
    age: int @index(int) .
    friend: uid @count .
    dob: dateTime ."

  setup do
    # Logger.info fn -> "💡 GRPC-Server: #{Application.get_env(:ex_dgraph, :dgraphServerGRPC)}" end
    {:ok, channel} = GRPC.Stub.connect(Application.get_env(:ex_dgraph, :dgraphServerGRPC))
    operation = ExDgraph.Api.Operation.new(drop_all: true)
    {:ok, _} = channel |> ExDgraph.Api.Dgraph.Stub.alter(operation)
    operation = ExDgraph.Api.Operation.new(schema: @testing_schema)
    {:ok, _} = channel |> ExDgraph.Api.Dgraph.Stub.alter(operation)

    on_exit(fn ->
      # close channel ?
      :ok
    end)

    [channel: channel]
    conn = ExDgraph.conn()
    # TODO: It fails right at the connect on TravisCI
    ExDgraph.operation(conn, %{drop_all: true})
    ExDgraph.operation(conn, %{schema: @testing_schema})

    on_exit(fn ->
      # close channel ?
      :ok
    end)

    [conn: conn]
  end

  test "Gremlin AddVertex Step ; AddProperty Step", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = Graph.new(conn)

    graph
    |> addV(Toon)
    |> property("name", "Duffy Duck")
    |> property("type", "Toon")

    [toon_one] = ExdgraphGremlin.LowLevel.query_vertex(graph, "anyofterms", "name", "Duffy Duck")
    assert "Duffy Duck" == toon_one.name
    assert "Toon" == toon_one.type
  end

  test "Gremlin AddVertex Step ; AddProperty Step ! version", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = Graph.new(conn)

    graph
    |> addV!(Toon)
    |> property!("name", "Bugs Bunny")
    |> property!("type", "Toon")

    [toon_one] = ExdgraphGremlin.LowLevel.query_vertex(graph, "anyofterms", "name", "Bugs Bunny")
    assert "Bugs Bunny" == toon_one.name
    assert "Toon" == toon_one.type
  end

  test "Gremlin AddEdge Step", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = Graph.new(conn)

    {:ok, marko} =
      graph
      |> addV(Person)
      |> property("name", "Marko")

    {:ok, peter} =
      graph
      |> addV(Person)
      |> property("name", "Peter")

    # gremlin> g.addE('knows').from(marko).to(peter)
    graph
    |> addE("knows")
    |> from(marko)
    |> to(peter)

    # gremlin> g.V(john).addE('knows').to(peter)
    {:ok, edge} =
      graph
      |> addV(Person)
      |> property("name", "John")
      |> addE("knows")
      |> to(peter)

    assert "knows" == edge.predicate

    {:ok, [person_one]} =
      ExdgraphGremlin.LowLevel.query_vertex(
        graph,
        "anyofterms",
        "name",
        "John",
        "uid name knows { name }"
      )

    # Logger.info(fn -> "💡 person_one: #{inspect person_one}" end)
    assert "John" == person_one.name
    assert "Peter" == List.first(person_one.knows)["name"]

    {:ok, out_vertex} =
      edge
      |> outV

    assert "John" == out_vertex.vertex_struct.name

    {:ok, in_vertex} =
      edge
      |> inV

    assert "Peter" == in_vertex.vertex_struct.name

    {:ok, {b_out_vertex, b_in_vertex}} =
      edge
      |> bothV

    assert "John" == b_out_vertex.vertex_struct.name
    assert "Peter" == b_in_vertex.vertex_struct.name
  end

  test "Gremlin Vertex Step", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = Graph.new(conn)

    {:ok, edwin} =
      graph
      |> addV(Person)
      |> property("name", "Edwin")

    # Get all the vertices in the Graph (NOT IMPLEMENTED)
    vertices =
      graph
      |> v()

    assert [] == vertices

    # Get a vertex with the unique identifier of "1".
    vertex =
      graph
      |> v(edwin.uid)

    assert edwin.uid == vertex.uid
    %{__struct__: match_struct} = vertex.vertex_struct
    assert Person == match_struct
    assert "Edwin" == vertex.vertex_struct.name

    # Get the value of the name property on vertex with the unique identifier of uid.
    vertex =
      graph
      |> v(edwin.uid)
      |> values("name")

    vertex
  end
end
