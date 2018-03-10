defmodule ExdgraphGremlin.QueryErrorTest do
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
#  import ExDgraph
  import ExdgraphGremlin
  alias ExdgraphGremlin.Toon
#  alias ExdgraphGremlin.Person
  alias ExdgraphGremlin.Graph
#  import GRPC
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

    conn = ExDgraph.conn()
    ExDgraph.operation(conn, %{drop_all: true})
    ExDgraph.operation(conn, %{schema: @testing_schema})

    on_exit(fn ->
      # close channel ?
      :ok
    end)

    [conn: conn]
  end

  test "Query Error", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = Graph.new(conn)

    graph
    |> addV(Toon)
    |> property("name", "Duffy Duck")
    |> property("type", "Toon")

    {status, error} = ExdgraphGremlin.LowLevel.query_vertex(graph, "anyofterms", "nameERROR", "Duffy Duck")
    assert status == :error
    assert error == [code: 2, message: ": Attribute nameERROR is not indexed with type term"]
    #assert "Duffy Duck" == toon_one.name
    #assert "Toon" == toon_one.type
  end

end
