defmodule ExdgraphGremlin.Toon do
  @moduledoc false

  alias ExdgraphGremlin.Toon

  @doc """
  A sample struct
  """
  defstruct toon_id: String,
            name: String,
            type: String,
            friend: [],
            comment: String

  @doc """
  Creates a new toon
  """
  def new(id) do
    {:ok, %Toon{toon_id: id}}
  end
end
