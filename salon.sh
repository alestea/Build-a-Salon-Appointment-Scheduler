#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#echo $($PSQL "TRUNCATE appointments,customers")

SERVICE_MENU() 
{
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-3]) SERVICE_SELECTED ;;
        *) SERVICE_MENU "Please enter a valid service." ;;
  esac

}

SERVICE_SELECTED()
{
  # get customer info
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

  fi
    
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # get service name
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $GET_SERVICE_NAME| sed 's/ //g')

  # get service time
  echo -e "\nWhat is desired service time?"
  read SERVICE_TIME

  # insert into appointment
  INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # output message
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME."

}

SERVICE_MENU