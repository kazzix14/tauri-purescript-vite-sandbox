module Main where

import Prelude

import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Random (randomInt)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.VDom.Driver (runUI)

main :: Effect Unit
main =
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI appComponent unit body

data Action
  = Increment
  | Decrement
  | Randomize

type State
  = Int

appComponent :: forall q i o m. MonadEffect m => H.Component q i o m
appComponent =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
    }
  where
  initialState :: forall ip. ip -> State
  initialState _ = 0

  render :: forall mo. State -> H.ComponentHTML Action () mo
  render state =
    HH.div_
      [ myButton Dec
      , HH.div_ [ HH.text $ show state ]
      , myHelper
      , myButton Inc
      , myButton Rnd
      ]

  handleAction :: forall op m. MonadEffect m => Action -> H.HalogenM State Action () op m Unit
  handleAction a = case a of
    Increment -> H.modify_ \state -> state + 1
    Decrement -> H.modify_ \state -> state - 1
    Randomize -> do
      n <- H.liftEffect $ randomInt 0 100
      H.modify_ \_ -> n

myHelper :: forall p i. HH.HTML p i
myHelper = HH.text "test"

data Order
  = Inc
  | Dec
  | Rnd

myButton :: forall w. Order -> HH.HTML w Action
myButton o =
  HH.button
    [ HE.onClick \_ -> case o of
        Inc -> Increment
        Dec -> Decrement
        Rnd -> Randomize
    ]
    [ HH.text case o of
        Inc -> "+"
        Dec -> "-"
        Rnd -> "random!"
    ]
