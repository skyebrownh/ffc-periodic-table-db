#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
re='^[0-9]+$'

if [[ $1 ]]
then
  # check if input is a number  
  if ! [[ $1 =~ $re ]]
  then
    # query based on string as symbol
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol = '$1'")

    # if not found by symbol
    if [[ -z $ELEMENT ]]
    then
      # query based on string as name
      ELEMENT=$($PSQL "SELECT * FROM elements WHERE name = '$1'")

      # if not found by name
      if [[ -z $ELEMENT ]]
      then
        # element not found
        echo "I could not find that element in the database."; exit 0
      fi
    fi
  else
    # query based on number
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number = $1")

    # if not found by number
    if [[ -z $ELEMENT ]]
    then
      echo "I could not find that element in the database."; exit 0
    fi
  fi

  # query properties
  echo $ELEMENT | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    PROPERTIES=$($PSQL "SELECT t.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types as t USING(type_id) INNER JOIN elements as e USING(atomic_number) WHERE e.atomic_number = $ATOMIC_NUMBER")

    echo $PROPERTIES | while read TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      # display output
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  done
else
  echo Please provide an element as an argument.
fi