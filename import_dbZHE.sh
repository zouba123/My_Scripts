#!/bin/bash

################################################################################                                                                                        ##############
#       Auteur  :       
#       Date    :       
#       Description :                     
################################################################################                                                                                        ##############

#JDBC_URL="jdbc:hive2://aocsv155bed0p.cloudwatt.saint-gobain.net:10000/default;pr                                                                                        incipal=hive/aocsv155bed0p.cloudwatt.saint-gobain.net@ZA.IF.ATCSG.NET"

# nom de la base de données
DATABASE_NAME="not set"

#nom du layer du datalake qui contiendra la base de données
LAYER="not set"

# nom du repertoire correspondant au layer
LAYER_PATH="not set"

# description de la base de données
DESCRIPTION="not set"

# environnement dans lequel la base de données sera crée
ENVIRONNEMENT="not set"
# environnement dans lequel la base de données sera crée
TABLE="not set"
# Chemain de fichier de configuration sera crée
FILE="NOT SET"
#########################
# The command line help #
#########################
display_help() {
        echo "========================================================"
        echo "HELP"
        echo "========================================================"
        echo "Creation d'une base de données suivant les normes définies"
        echo "Usage: $0 -f <path file> -n <database name> -d <description> -l <raw|shd|ope|dsc> -e <dev|int|rec|preprod|prod> | -h "
        echo
		echo "  -f              Chemain de fichier de configuration"
        echo "  -n              Nom de la base de données sans la zone et l'environnement. exemple : as400_nat_pointp03_dwhdta"
        echo "  -d              Description de la base de données"
        echo "  -l              layer du datalake. valeurs possibles : raw, shd,ope, dsc"
        echo "  -e              Environnement ou tenant auquel la base de donnees est destinee. valeurs possibles : dev, int, rec, preprod, prod"
        echo "  -h              Affichage de l'aide"
        echo
        echo " exemple : $0 $1 -f /home/user/file.conf -n test01 -d 'description 01' -l raw -e dev "
        echo
        echo
    exit 1
}

##############################################
# The command line check parameters numbers  #
##############################################
check_parametre () {
if [ $# -eq 8 ]; then
	# check if the sqoop config file exists
	if [ ! -f $SQOOP_CONFIG_FILE ]; then
		echo $SQOOP_CONFIG_FILE not found
		exit 1
	fi
check_parametre
}


 

###############################
# The command line check file #
###############################

check_file () {
   if [ -f "$FILE" ];
then
   echo "File $FILE exist."
    return 0
else
      #  echo "File $FILE does not exist" >&2
        echo "Le fichier $FILE : $ENVIRONNEMENT n'est pas une valeur valide du parametre -f"
    return 0
fi
check_file
}


######################################
# check that layer provided is valid #
######################################
check_environnement_is_valid() {

        if [ "$ENVIRONNEMENT" = "dev" ]; then
                return 0
        fi

        if [ "$ENVIRONNEMENT" = "int" ]; then
                        return 0
        fi

        if [ "$ENVIRONNEMENT" = "rec" ]; then
                        return 0
        fi

        if [ "$ENVIRONNEMENT" = "preprod" ]; then
                        return 0
        fi

        if [ "$ENVIRONNEMENT" = "prod" ]; then
                        return 0
        fi

        echo
        echo "ERREUR : $ENVIRONNEMENT n'est pas une valeur valide du parametre -e"
        echo
        display_help

}

######################################
# check that layer provided is valid #
######################################
configure_and_check_layer_is_valid() {

        if [ "$LAYER" = "raw" ]; then
                LAYER_PATH="raw_layer"
                return 0
        fi

        if [ "$LAYER" = "shd" ]; then
                LAYER_PATH="shared_layer"
                        return 0
        fi

        if [ "$LAYER" = "ope" ]; then
                LAYER_PATH="optimized_layer"
                return 0
        fi

        if [ "$LAYER" = "dsc" ]; then
                LAYER_PATH="discovery_layer"
                        return 0
        fi

        echo
        echo "ERREUR : $LAYER n'est pas une valeur valide du parametre -l"
        echo
        display_help

}

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :
do
    case "$1" in
      -h | --help)
          display_help  # Call your function
          exit 0
          ;;
	  -f)
          FILE="$2"
		  check_file # Call check file function
          shift 2
          ;;
      -n)
          DATABASE_NAME="$2"
          shift 2
          ;;

      -l)
          LAYER="$2"
          shift 2
          configure_and_check_layer_is_valid
          ;;
      -e)
          ENVIRONNEMENT="$2"
          shift 2
          check_environnement_is_valid
          ;;
      -d)
          DESCRIPTION="$2"
          shift 2
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          ## or call function display_help
          exit 1
          ;;
      *)  # No more options
          break
          ;;
    esac
done

# construction du nom complet de la base de données
FULL_DATABASE_NAME=$DATABASE_NAME"_"$LAYER"_"$ENVIRONNEMENT

# repertoire par defaut de la base de données
LOCATION="/app/dev/sgdbf/commun/$LAYER_PATH/$FULL_DATABASE_NAME"

# commande SQL pour la création de la base de données
SQL_COMMAND="CREATE DATABASE IF NOT EXISTS $FULL_DATABASE_NAME COMMENT '$DESCRIPTION' LOCATION '$LOCATION'";

echo
echo
echo "DATABASE_NAME= $DATABASE_NAME"
echo "DESCRIPTION = $DESCRIPTION"
echo "LAYER = $LAYER"
echo "LAYER_PATH = $LAYER_PATH"
echo "ENVIRONNEMENT = $ENVIRONNEMENT"
echo "FULL_DATABASE_NAME = $FULL_DATABASE_NAME"
echo "LOCATION = $LOCATION"
echo "SQL_COMMAND = $SQL_COMMAND"
echo
echo

#beeline -u  $JDBC_URL  --verbose=true -e "$SQL_COMMAND"


echo
echo

