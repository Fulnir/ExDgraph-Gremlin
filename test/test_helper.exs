#ExUnit.start()

ExUnit.start(exclude: [:skip])

defmodule ExDgraph.TestHelper do
end

if Process.whereis(ExDgraph.pool_name()) == nil do
  {:ok, _pid} = ExDgraph.start_link(Application.get_env(:ex_dgraph, ExDgraph))
end

Process.flag(:trap_exit, true)

defmodule Person do
  @moduledoc false

  @doc """
  A sample struct
  """
  defstruct person_id: String,
            name: String,
            alias_name: [],
            is_jedi: Boolean,
            gender: String,
            age: Integer,
            friend: [],
            knows: Person,
            comment: String

end
