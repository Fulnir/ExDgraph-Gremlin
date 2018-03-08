# ExDgraph-Gremlin
[![Build Status](https://semaphoreci.com/api/v1/fulnir/exdgraph-gremlin/branches/master/shields_badge.svg)](https://semaphoreci.com/fulnir/exdgraph-gremlin) [![codecov](https://codecov.io/bb/fulnir/exdgraph-gremlin/branch/master/graph/badge.svg)](https://codecov.io/bb/fulnir/exdgraph-gremlin) [![Ebert](https://ebertapp.io/github/Fulnir/ExDgraph-Gremlin.svg)](https://ebertapp.io/github/Fulnir/ExDgraph-Gremlin)
 [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE.md)

**Work In Progress**
The primary way in which graphs are processed are via graph traversals. In this package, elixir functions are which simulate gremlin.

This package is built on top of [ExDgraph](https://github.com/ospaarmann/exdgraph), a grpc-client for [dgraph](dgraph.io). Which is also work in progress.



# Gremlin like graph traversals

In this case, only elixir functions which simulate gremlin.

The primary way in which graphs are processed are via graph traversals.

## Gremlin Steps

### AddVertex Step
The `addV`-step is used to add vertices to the graph ([addV step](http://tinkerpop.apache.org/docs/current/reference/#addvertex-step))

  
The following Gremlin statement inserts a "toon" vertex into the graph
```
# run a operation using the Gremlin Console. 
gremlin> g.addV('toon')
==>v[13]
```

And now with **Elixir**.
```elixir
{:ok, graph} = Graph.new(ExDgraph.conn())

graph
|> addV(Toon)
```
The first line create the `Graph` and connect it to `dgraph`. This is not listed in all samples.

### AddProperty Step
The `property`-step is used to add properties to the elements of the graph. ([property step](http://tinkerpop.apache.org/docs/current/reference/#addproperty-step))

The following Gremlin statement inserts the "*Bugs Bunny*" vertex into the graph
```
gremlin> g.addV('toon').property('name','Bugs Bunny').property('type','Toon')
==>v[13]
```

And now with **Elixir**.
```elixir
{:ok, graph} = Graph.new(ExDgraph.conn())

graph
|> addV(Toon)
|> property("name", "Bugs Bunny")
|> property("type", "Toon")
```

### AddEdge Step
The `addE`-step is used to add an edge between two vertices  ([addE step](http://tinkerpop.apache.org/docs/current/reference/#addedge-step)) 


```elixir
marko =
    graph
    |> addV(Person)
    |> property("name", "Makro")

peter =
    graph
    |> addV(Person)
    |> property("name", "Peter")

# gremlin> g.addE('knows').from(marko).to(peter)
graph
|> addE("knows")
|> from(marko)
|> to(peter)
```

###  V Step


```elixir
edwin =
    graph
    |> addV(Person)
    |> property("name", "Edwin")
# Get a vertex with the unique identifier.
vertex =
    graph
    |> v(edwin.uid)
```




Copyright © 2018 Edwin Bühler  [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE.md)