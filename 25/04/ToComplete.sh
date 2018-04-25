#!/bin/bash

################################################################################                                                                                        ##############
#       Auteur  :       Zied
#       Date    :       2018-04-25
#       Description : Script en charge de l'importation de base de données avec sqoop
################################################################################                                                                                        ##############

                                                                                

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
CONFIGFILE="NOT SET"


###########################################################################
# class JDBC pour la connexion à l'AS400
DRIVER_CLASS=com.ibm.as400.access.AS400JDBCDriver
# URL JDBC vers la base de données
JDBC_URL="jdbc:as400://ASPP03.prod.pointp.saint-gobain.net/POINTP03"

# Colonne de partitionnement à utiliser
SPLIT_COLUMN=REGIUB

# Repertoire cible dans lequel les données seront deversées
TARGET_DIR=/app/dev/sgdbf/commun/raw_layer/AS400_STANAT_STNLFA
#TARGET_DIR=/tmp/AS400_SIEDTA_ISINVD

AS400_LOGIN=odi
AS400_PASSWORD=odi400

# Requete de récupération de données
QUERY="select * from STANAT.STNLFA WHERE AALIUB  in ('2017')  and MMLIUB in ('12') and  "
QUERY="select * from STANAT.STNLFA WHERE AALIUB  in ('2017')  and MMLIUB in ('12') and  "
###########################################################################

sqoop import --verbose --driver $DRIVER_CLASS \
--connect $JDBC_URL \
--username $AS400_LOGIN \
--password $AS400_PASSWORD \
--query "$QUERY"'$CONDITIONS' \
--split-by $SPLIT_COLUMN \
--target-dir $TARGET_DIR \
--append --fields-terminated-by "|"


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

check_file () {
   if [ -f "$CONFIGFILE" ];
then
   echo "File $CONFIGFILE exist."
    return 0
else
      #  echo "File $CONFIGFILE does not exist" >&2
        echo "Le fichier $CONFIGFILE :  n'est pas un chemain valide du parametre -f"
    return 0
fi
check_file
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
          ;;
      -e)
          ENVIRONNEMENT="$2"
          shift 2
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

FULL_DATABASE_NAME=$DATABASE_NAME"_"$LAYER"_"$ENVIRONNEMENT
LOCATION="/app/dev/sgdbf/commun/$LAYER_PATH/$FULL_DATABASE_NAME"
