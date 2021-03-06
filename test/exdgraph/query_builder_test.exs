defmodule QueryBuilderTest do
  @moduledoc """
  """
  use ExUnit.Case
  import ExDgraph.TestHelper
  require Logger
  import ExDgraph
  import ExdgraphGremlin.GraphQL
  alias ExdgraphGremlin.GraphQL

  @testing_schema "person_id: string @index(exact).
      name: string @index(exact, term) @count .
      gender: string .
      alias_name: [string] .
      is_jedi: bool .
      age: int @index(int) .
      friend: uid @count .
      knows: uid .
      dob: dateTime ."

  setup_all do
    conn = ExDgraph.conn()
    drop_all()
    import_starwars_sample()

    on_exit(fn ->
      :ok
    end)

    [conn: conn]
  end

  test "GraphQL new/1 default name", %{conn: conn} do
    {:ok, graph_query} = GraphQL.new(conn)
    assert "graphql" == graph_query.name
  end

  test "GraphQL new/2 set name", %{conn: conn} do
    {:ok, graph_query} = GraphQL.new(conn, "test_query")
    assert "test_query" == graph_query.name
  end

  test "GraphQL empty query", %{conn: conn} do
    graph_query = GraphQL.new(conn, "test_query")

    {status, error} =
      graph_query
      |> query()

    assert :error == status

    assert [
             code: 2,
             message: "Only aggregation/math functions allowed inside empty blocks. Got: expand"
           ] == error
  end

  test "GraphQL set query_root with :allofterms", %{conn: conn} do
    graph_query = GraphQL.new(conn, "test_query")

    {status, query_result} =
      graph_query
      |> root(:allofterms, {"name", "IV"})
      |> query()

    one = List.first(query_result)
    assert "Star Wars: Episode IV - A New Hope" == one["name"]
  end

  test "GraphQL set first: 1", %{conn: conn} do
    graph_query = GraphQL.new(conn, "test_query")

    {status, query_result} =
      graph_query
      |> root(:allofterms, {"name", "Star Wars"})
      |> first(2)
      |> query()

    assert 2 == Enum.count(query_result)
  end

  test "GraphQL set one filter", %{conn: conn} do
    graph_query = GraphQL.new(conn, "test_query")

    {status, query_result} =
      graph_query
      |> root(:allofterms, {"name", "IV"})
      |> query()
  end

  test "GraphQL", %{conn: conn} do
    graph_query = GraphQL.new(conn, "test_query")
    {status, query_result} = graph_query
    # |> root(:allofterms, {"name", "Star Wars"})
    # |> first(2)
    # |> filter(:has, "genre")
    # |> filter(:or, :le, {"production-cost", "20000000"})
    # |> order(:desc, "initial_release_date")
    # |> return(["uid")
    # |> return(["name", "initial_release_date"])
    # |> return_expand("director.film")
    # |> filter_expand(:le, {initial_release_date, "2000"})
    # |> return_expand(["name@en", "initial_release_date"])
    # |> query()
  end

  test "dummy", %{conn: conn} do
    json = %{
      friends: [%{name: "Betty", uid: "_:a96940b1-8333-4e09-8cc3-366f415aec9f"}],
      identifier: "alice_json",
      name: "Alice",
      uid: "_:2e5f5fb3-db60-4882-8ac9-fd553769677c"
    }

    IO.inspect json
    json = Poison.encode!(json)
    IO.inspect json
    assert 1 == 1
    # |> root(:allofterms, {"name", "Star Wars"})
    # |> first(2)
    # |> filter(:has, "genre")
    # |> filter(:or, :le, {"production-cost", "20000000"})
    # |> order(:desc, "initial_release_date")
    # |> return(["uid")
    # |> return(["name", "initial_release_date"])
    # |> return_expand("director.film")
    # |> filter_expand(:le, {initial_release_date, "2000"})
    # |> return_expand(["name@en", "initial_release_date"])
    # |> query()
  end

end
