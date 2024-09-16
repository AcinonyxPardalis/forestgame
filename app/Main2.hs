module Main where

import Forest.Level1 (Forest (..), level1forest)
import System.Random (randomRIO)
import User.Actions.Move (AvailableMoves, move)
import User.Actions.Battle (battle, Combatant, createRandomCombatant)

main :: IO ()

main = do
  startingStamina <- randomRIO @Int (10_000, 20_000)
  adventurer <- createRandomCombatant (50,100) (10,20)
  putStrLn "\nYou're traped in a Forest, try to scape! Remember that you loose stamina with each step you take."
  gameLoop adventurer (startingStamina, level1forest)
 
  gameLoop :: Combatant -> (Int, Forest Int) -> IO ()
  gameLoop _ (_, FoundExit) = putStrLn "YOU'VE FOUND THE EXIT!!"
  gameLoop _ (s, _) | s <= 0 = putStrLn "You ran out of stamina and died -.-!"
  gameLoop adventurer (s, forest) = do
    let continueLoop = do
          putStrLn $ "\nYou have " ++ show s ++ " stamina, and you're still inside the Forest. Choose a path, brave adventurer: GoLeft, GoRight, or GoForward."
          selectedMove <- getLine
          gameLoop $ adventurer move (s, forest) (read @AvailableMoves selectedMove)
    battleDice <- randomRIO @Int (0, 3)
    case battleDice of
      2 -> do
        r <- battle adventurer
        if r then continueLoop else return ()
      _ -> continueLoop