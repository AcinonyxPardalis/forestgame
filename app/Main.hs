module Main where

import Forest.Level1 (Forest (..), level1forest)
import System.Random (randomRIO)
import User.Actions.Move (AvailableMoves, move)
import User.Actions.Battle (battle, Combatant, createRandomCombatant)

main :: IO ()
main = do
  startingStamina <- randomRIO (10_000, 20_000)
  adventurer <- createRandomCombatant (50,100) (10,20)
  putStrLn "\nYou're trapped in a Forest, try to escape! Remember that you lose stamina with each step you take."
  gameLoop adventurer startingStamina level1forest

-- Adjusted gameLoop to match the expected function signature
gameLoop :: Combatant -> Int -> Forest Int  -> IO ()
gameLoop _ _ FoundExit = putStrLn "YOU'VE FOUND THE EXIT!!"
gameLoop _ s _ | s <= 0 = putStrLn "You ran out of stamina and died -.-!"
gameLoop adventurer s forest = do
  let continueLoop updatedAdventurer = do
        putStrLn $ "\nYou have " ++ show s ++ " stamina, and you're still inside the Forest. Choose a path, brave adventurer: GoLeft, GoRight, or GoForward."
        selectedMove <- getLine
        --let moveResult = move (s, forest) (read @AvailableMoves selectedMove)
        case move (s, forest) (read @AvailableMoves selectedMove) of
          (newStamina, newForest) -> gameLoop updatedAdventurer newStamina newForest
  battleDice <- randomRIO @Int (2, 2)
  case battleDice of
    2 -> do
      r <- battle adventurer
      case r of 
        (False, _) -> return ()
        (True, updatedAdventurer) ->continueLoop updatedAdventurer
    _ -> continueLoop adventurer
