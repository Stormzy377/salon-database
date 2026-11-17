#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Exibir a lista de serviços formatada (#) <service>)
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Ler a escolha do usuário
  read SERVICE_ID_SELECTED

  # Verificar se o serviço existe
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Pedir o número de telefone
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Verificar se o cliente já existe
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Se não existir, pedir o nome e cadastrar
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    else
      # Se já existir, buscar o nome
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    fi

    # Pedir o horário do agendamento
    echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Inserir o agendamento na tabela appointments (removendo espaços extras das strings do psql)
    CLEAN_SERVICE_NAME=$(echo $SERVICE_NAME_SELECTED | sed 's/^ *| *$//g')
    CLEAN_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # Mensagem de sucesso exigida pelos testes
    echo -e "\nI have put you down for a $CLEAN_SERVICE_NAME at $SERVICE_TIME, $CLEAN_CUSTOMER_NAME."
  fi
}

MAIN_MENU