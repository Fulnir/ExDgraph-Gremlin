defmodule ExdgraphGremlin.GremlinQueryTest do
  @moduledoc """

  # Gremlin tests


  """
  require Logger
  use ExUnit.Case
  import ExDgraph.TestHelper
  import ExdgraphGremlin.GremlinToQraphQL

  alias ExdgraphGremlin.Toon
  alias ExdgraphGremlin.Person
  alias ExdgraphGremlin.GremlinGraphQL

  setup do
    # Logger.info fn -> "💡 GRPC-Server: #{Application.get_env(:ex_dgraph, :dgraphServerGRPC)}" end
    conn = ExDgraph.conn()
    drop_all()
    import_starwars_sample()

    on_exit(fn ->
      # close channel ?
      :ok
    end)

    [conn: conn]
  end

  test "Gremlin Query", %{conn: conn} do
    # {:ok, channel} = GRPC.Stub.connect(Application.get_env(:exdgraph, :dgraphServerGRPC))
    {:ok, graph} = GremlinGraphQL.new(conn, "test_query")
    assert "test_query" == graph.name
    {status, query_msg} = 
    graph
    |> v()
    |> has("name", "VI") # :allofterms, {"name", "Star Wars"} func: allofterms(name, "Edwin"
    |> query()

    assert status == :ok

    # res = query_msg.result
    # starwars = res["test_query"]
    one = List.first(query_msg)
    assert "Star Wars: Episode VI - Return of the Jedi" == one["name"]
    
  end

end
