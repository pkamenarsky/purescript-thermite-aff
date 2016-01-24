-- | This module provides functions for working with the Thermite UI library
-- | and the `purescript-aff` asynchronous effect monad.

module Thermite.Aff where

import Prelude

import Data.Maybe

import Control.Monad.Eff
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Exception (EXCEPTION(), Error(), message)
import Control.Monad.Aff
import Control.Monad.Aff.AVar

import Control.Monad.Free.Trans (hoistFreeT)

import Control.Coroutine (($$))
import qualified Control.Coroutine as C

import qualified Thermite as T

-- | Create a `PerformAction` handler from a function which returns a single new state update asynchronously.
asyncOne :: forall eff state props action. 
            (action -> props -> state -> Aff eff (state -> state)) ->
            (Error -> state -> state) ->
            T.PerformAction eff state props action
asyncOne f fromError action props state k = runAff (k <<< fromError) k (f action props state)

-- | Create a `PerformAction` handler from a function which returns a single new state update asynchronously.
-- |
-- | On error, this function writes its error to the console.
asyncOne' :: forall eff state props action. 
             (action -> props -> state -> Aff eff (state -> state)) ->
             T.PerformAction eff state props action
asyncOne' f action props state k = runAff unsafeLog k (f action props state)
  where
  unsafeLog :: Error -> Eff eff Unit
  unsafeLog = unsafeInterleaveEff <<< log <<< message

-- | Create a `PerformAction` handler from a function which returns many new states asynchronously.
-- |
-- | All errors are ignored so users should use `attempt` or some other means of catching asynchronous
-- | exceptions.
asyncMany :: forall eff state props action. 
             (action -> props -> state -> C.Producer (state -> state) (Aff eff) Unit) ->
             T.PerformAction eff state props action
asyncMany f action props state k = unsafeInterleaveEff $ launchAff $ C.runProcess process
  where
  process :: C.Process (Aff eff) Unit
  process = f action props state $$ hoistFreeT liftEff consumer

  consumer :: C.Consumer (state -> state) (Eff eff) Unit
  consumer = C.consumer \state -> map Just (k state)
