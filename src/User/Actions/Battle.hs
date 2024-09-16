module User.Actions.Battle where

import System.Random (randomRIO)

data Combatant = Combatant {health :: Int, attack :: Int} deriving Show

createRandomCombatant :: (Int,Int) -> (Int,Int) ->IO Combatant
createRandomCombatant (healthFrom, healthTo) (attackFrom, attackTo) = 
    randomRIO (healthFrom, healthTo) >>= \randHealth -> 
    randomRIO (attackFrom, attackTo)  >>= \randAttack -> 
    return Combatant { health = randHealth, attack = randAttack }

damage :: Int -> IO Int
damage attack =
    randomRIO @Int (0, 100) >>= \mul ->
    return $ case () of
        _ | mul < 60  -> attack
          | mul < 85  -> 2 * attack
          | otherwise -> 3 * attack

battle :: Combatant -> IO (Bool, Combatant)
battle ourAdventurer = do
    golem <- createRandomCombatant (30, 60) (5, 15)
    --ourAdventurer <- createRandomCombatant (50, 100) (10, 20)
    
    act (golem, ourAdventurer)
   where
    act (golem, adventurer) = do

        putStrLn ("The Golem has " ++ show (health golem) ++ "HP and " ++ show (attack golem) ++ " attack.")
        putStrLn ("You have " ++ show (health adventurer) ++ "HP and " ++ show (attack adventurer) ++ " attack.")
        putStrLn "Will you fight or flight?"

        selectedAction <- getLine
        case selectedAction of
            "Flight" -> do
                flightChance <- randomRIO @Int (0,2) 
                if flightChance == 1 then do
                    putStrLn "You escaped!"
                    return (True, adventurer)
                else do
                    golemDamage <- damage $ attack golem
                    let updatedAdventurer = adventurer {health = health adventurer - golemDamage}
                    if health updatedAdventurer <= 0 then do
                        putStrLn "You could not escape... The Golem killed you *_*"
                        return (False, updatedAdventurer)
                    else do
                        --putStrLn ("The Golem stopped you and dealt " ++ show myDamage ++ "! Now you only have " ++ show (myHP - myDamage) ++ "HP!")
                        act (golem, updatedAdventurer)
            "Fight" -> do 
                golemDamage <- damage $ attack golem
                adventurerDamage <- damage $ attack adventurer
                let updatedAdventurer = adventurer {health = health adventurer - golemDamage}
                let updatedGolem = golem {health = health golem - adventurerDamage}
                if  | health updatedAdventurer <= 0 -> do
                        putStrLn "You could not escape... The Golem killed you *_*"
                        return (False, updatedAdventurer)
                    | health updatedGolem <= 0 -> do
                        putStrLn "You defeated the monster!" 
                        return (True, updatedAdventurer)
                    | otherwise -> do
                        act (updatedGolem, updatedAdventurer)
            _ -> do
                putStrLn "You have to fight or flight. There is a golem!"
                act (golem, adventurer)
