defmodule ExdgraphGremlin.LowLevel do
  @moduledoc """
  Low level functions
  """
  require Logger
  alias ExdgraphGremlin.LowLevel
  import ExDgraph
  # alias ExDgraph.{Mutation}
  @doc """
  Creates a mutation request with a commit_now and send it to dgraph.
  """
  def mutate_with_commit(graph, nquad) do
    # Logger.info(fn -> "💡 request: #{inspect request}" end)
    # channel = graph.channel
    # request = ExDgraph.Api.Mutation.new(set_nquads: nquad, commit_now: true)
    # channel |> ExDgraph.Api.Dgraph.Stub.mutate(request)
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

    case ExDgraph.Query.query(conn, query) do
      {:ok, query_msg} ->
        res = query_msg.result
        vertices = res["vertex"]
        [vertex_one] = vertices
        vertex = for {key, val} <- vertex_one, into: %{}, do: {String.to_atom(key), val}
        struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
        struct(struct_type, vertex)

      {:error, error} ->
        Logger.error(fn -> "Error: #{inspect(error)}" end)
        {:error, error}
    end

    # request = ExDgraph.Api.Request.new(query: query)
    # {:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    # Logger.info(fn -> "💡 msg.json: #{inspect msg.json}" end)
    # Logger.info(fn -> "💡res: #{inspect res}" end)
    # decoded_json = Poison.decode!(query_msg.json)
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

    case ExDgraph.Query.query(conn, query) do
      {:ok, query_msg} ->
        res = query_msg.result
        # request = ExDgraph.Api.Request.new(query: query)
        # {:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
        # decoded_json = Poison.decode!(msg.json)
        vertices = res["vertices"]
        # Logger.info(fn -> "💡 vertices: #{inspect vertices}" end)
        map =
          Enum.map(vertices, fn vertex_map ->
            vertex = for {key, val} <- vertex_map, into: %{}, do: {String.to_atom(key), val}
            # Logger.info(fn -> "💡 vertex.vertex_type: #{inspect vertex.vertex_type}" end)
            struct_type = String.to_existing_atom("Elixir." <> vertex.vertex_type)
            struct(struct_type, vertex)
          end)

        {:ok, map}

      {:error, error} ->
        Logger.error(fn -> "Error: #{inspect(error)}" end)
        {:error, error}
    end
  end

  @doc """
  Similar to `query_vertex/4`, but raises an `Error` if the dgraph query is not possible.
  """
  def query_vertex!(graph, search_type, predicate, object, display) do
    {:ok, vertex} = query_vertex(graph, search_type, predicate, object, display)
    vertex
  end

  def query_vertex(graph, search_type, predicate, object) do
    query_vertex(graph, search_type, predicate, object, "expand(_all_)")
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
    # request = ExDgraph.Api.Request.new(query: query)
    # {:ok, msg} = channel |> ExDgraph.Api.Dgraph.Stub.query(request)
    # decoded_json = Poison.decode!(msg.json)
    vertices = res["vertices"]
    # Logger.info(fn -> "💡 vertices: #{inspect vertices}" end)
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

  # #########################
  # Sandbox: Move to ExDgraph
  # #########################
  @doc """
  Create first a map of the struct and add the struct_name as
  :vertex_type value to the map

  ## Examples

      iex> person = %Person{person_id: "LeonardoDaVinci", name: "Leonardo Da Vinci"}
      ...> {status, _} = ExdgraphGremlin.LowLevel.mutate_struct(conn(), person)
      ...> status
      :ok

  Returns a new node. {:ok, node} or {:error, "The value is not a struct"} if
  node_struct is not a struct
  """
  @spec mutate_struct(DBConnection, Struct) :: Struct
  def mutate_struct(conn, a_struct) do
    case a_struct do
      %{__struct__: struct_name} ->
        %{__struct__: struct_name} = a_struct
        map_from_struct = Map.from_struct(a_struct)
        # Giving Nodes a Type https://docs.dgraph.io/howto/#giving-nodes-a-type
        # TODO: vertex_type or other name? or user defined?
        # ':vertex_type' is more excactly. ':type' could be conflicted with user fields
        map_from_struct = Map.put(map_from_struct, :vertex_type, struct_name)
        # Logger.info(fn -> "💡 result: #{inspect(map_from_struct)}" end)
        mutate_map(conn, map_from_struct)

      _ ->
        {:error, "The value is not a struct"}
    end
  end

  @doc """
  Returns a new node. {:ok, node}
  """
  @spec mutate_map(DBConnetion, Map) :: Map
  def mutate_map(conn, a_map) do
    mutate_string = ""
    # TODO: Refactoring. Function to long.
    lambda = fn
      {predicate_key, object_value}, mutate_string
      when is_atom(object_value) and predicate_key == :vertex_type ->
        # Logger.debug fn -> "💡 1 #{inspect predicate_key} boolean: #{inspect object_value}" end
        mutate_string

      {predicate_key, object_value}, mutate_string
      when is_atom(object_value) and predicate_key != :vertex_type ->
        triple_boolean(mutate_string, predicate_key, object_value)

      {predicate_key, object_value}, mutate_string
      when is_list(object_value) ->
        list_mutate_string = ""
        # TODO: Check schema! Is it a list like alias_name: [string] ?
        # check_schema()
        lambda_list_element = fn each, list_mutate_string ->
          # Refactoring with external funs isn't better !
          # credo:disable-for-lines:2
          list_mutate_string =
            case each do
              %{__struct__: struct_name} ->
                # Logger.debug(fn -> "💡 1 object_value: #{inspect(object_value)}" end)
                %{__struct__: struct_name} = each
                map_from_struct = Map.from_struct(each)
                # Giving Nodes a Type https://docs.dgraph.io/howto/#giving-nodes-a-type
                # TODO: vertex_type or other name? or user defined?
                # ':vertex_type' is mor excactly. ':type' could be conflicted with user fields
                map_from_struct = Map.put(map_from_struct, :vertex_type, struct_name)
                triple_list_item(list_mutate_string, predicate_key, mutate_map(conn, a_map))

              _ ->
                # Logger.debug(fn -> "💡 2 object_value: #{inspect(object_value)}" end)
                list_mutate_string <> triple(predicate_key, each)
            end

          list_mutate_string
        end

        list_mutate_string = Enum.reduce(object_value, list_mutate_string, lambda_list_element)
        mutate_string <> list_mutate_string

      {predicate_key, object_value}, mutate_string ->
        # object_value = triple_transform_property(object_value)
        mutate_string <> triple(predicate_key, object_value)
    end

    mutate_string = Enum.reduce(a_map, mutate_string, lambda)
    # Logger.debug(fn -> "💡 mutate_string: #{inspect(mutate_string)}" end)
    {:ok, _} = ExDgraph.mutation(conn, mutate_string)
  end

  # Create a graphql triple for a boolean property.
  defp triple_boolean(mutate_string, predicate_key, object_value) do
    if is_boolean(object_value) do
      mutate_string =
        mutate_string <>
          " _:identifier" <>
          " \<" <>
          Atom.to_string(predicate_key) <> "\> \"" <> Atom.to_string(object_value) <> "\" . \n"
    else
      mutate_string
    end
  end

  # Transform a property as triple part.
  defp triple_transform_property(value) do
    # TODO: float and ....
    if is_boolean(value), do: value = Atom.to_string(value)
    if is_integer(value), do: value = Integer.to_string(value)
    " \"" <> value <> "\""
  end

  # add triple
  defp triple(predicate_key, object_value) do
    object_value = triple_transform_property(object_value)

    "    _:identifier" <>
      " \<" <> Atom.to_string(predicate_key) <> "\>" <> object_value <> " . \n"
  end

  defp triple_list_item(list_mutate_string, predicate_key, item_result) do
    {status, result} = item_result

    if status == :ok do
      identifier = result["uids"]["identifier"]

      list_mutate_string <>
        " _:identifier" <>
        " \<" <> Atom.to_string(predicate_key) <> "\> " <> " \<" <> identifier <> "\>" <> " . \n"
    else
      list_mutate_string
    end
  end

  def check_schema(conn) do
    # load schema
    # test every struct field
    #
  end
end
