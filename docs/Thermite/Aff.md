## Module Thermite.Aff

This module provides functions for working with the Thermite UI library
and the `purescript-aff` asynchronous effect monad.

#### `asyncOne`

``` purescript
asyncOne :: forall eff state props action. (action -> props -> state -> Aff eff (state -> state)) -> (Error -> state -> state) -> PerformAction eff state props action
```

Create a `PerformAction` handler from a function which returns a single new state update asynchronously.

#### `asyncOne'`

``` purescript
asyncOne' :: forall eff state props action. (action -> props -> state -> Aff eff (state -> state)) -> PerformAction eff state props action
```

Create a `PerformAction` handler from a function which returns a single new state update asynchronously.

On error, this function writes its error to the console.

#### `asyncMany`

``` purescript
asyncMany :: forall eff state props action. (action -> props -> state -> Producer (state -> state) (Aff eff) Unit) -> PerformAction eff state props action
```

Create a `PerformAction` handler from a function which returns many new states asynchronously.

All errors are ignored so users should use `attempt` or some other means of catching asynchronous
exceptions.


