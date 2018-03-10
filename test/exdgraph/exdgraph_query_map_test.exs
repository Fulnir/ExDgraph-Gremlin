defmodule ExDgraphStructTest do
  @moduledoc """
  """
  use ExUnit.Case
  require Logger
  import ExDgraph
#  import ExdgraphGremlin

  doctest ExdgraphGremlin.LowLevel

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
    ExDgraph.operation(conn, %{drop_all: true})
    ExDgraph.operation(conn, %{schema: @testing_schema})

    on_exit(fn ->
      # close channel ?
      :ok
    end)

    [conn: conn]
  end

  test "Create & Query", %{conn: conn} do
    person = %Person{person_id: "Jedi_Luke", name: "Luke Skywalker", is_jedi: true, alias_name: ["Luke", "Master Luke"]}
    {status, _} = ExdgraphGremlin.LowLevel.mutate_struct(conn, person)
    assert :ok == status

    query = """
      {
          starwars(func: eq(person_id, "Jedi_Luke"))
          {
            person_id
            name
            is_jedi
            alias_name {expand(_all_)}
          }
      }
    """

    {:ok, query_msg} = ExDgraph.query(conn, query)
    res = query_msg.result
    starwars = res["starwars"]
    one = List.first(starwars)
    assert "Jedi_Luke" == one["person_id"]
    assert "Luke Skywalker" == one["name"]
    assert true == one["is_jedi"]
    assert ["Master Luke", "Luke"] == one["alias_name"]

  end
end
