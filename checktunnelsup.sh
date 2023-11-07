#!/bin/bash

VPN_CONNECTION_ID=$1        # ID de connexion VPN passé en paramètre
AWS_REGION=$2
EXPECTED_VPN_STATE="available"  # Etat VPN attendu
EXPECTED_TUNNEL_STATUS="UP"  # Etat Tunnel attendu
CHECK_INTERVAL=5            # Intervalle en secondes entre chaque vérification
MAX_ATTEMPT=12               # nombre pax de tentatives, on ne va pas y passer la nuit non plus
CUR_ATTEMPT=0               # nombre courant de tentatives

while true; do
    CURRENT_VPN_STATE=$(aws ec2 describe-vpn-connections --vpn-connection-ids $VPN_CONNECTION_ID --region $AWS_REGION --query 'VpnConnections[0].State' --output text)
    (( CUR_ATTEMPT++ ))
    
    if [ "$CURRENT_VPN_STATE" == "$EXPECTED_VPN_STATE" ]; then
        echo
        echo "***************************************************************************"
        echo "************ VPN Connection $VPN_CONNECTION_ID is $CURRENT_VPN_STATE ************"
        echo "***************************************************************************"
        echo
        CURRENT_TUNNEL1_STATUS=$(aws ec2 describe-vpn-connections --vpn-connection-ids $VPN_CONNECTION_ID --region $AWS_REGION --query 'VpnConnections[0].VgwTelemetry[0].Status' --output text)
        CURRENT_TUNNEL2_STATUS=$(aws ec2 describe-vpn-connections --vpn-connection-ids $VPN_CONNECTION_ID --region $AWS_REGION --query 'VpnConnections[0].VgwTelemetry[1].Status' --output text)
        if [ "$CURRENT_TUNNEL1_STATUS" == "$EXPECTED_TUNNEL_STATUS" ]; then
            echo
            echo "********************************************************************************"
            echo "************ Tunnel 1 of VPN Connection $VPN_CONNECTION_ID is $CURRENT_TUNNEL1_STATUS ************"
            echo "********************************************************************************"
            echo
             if [ "$CURRENT_TUNNEL2_STATUS" == "$EXPECTED_TUNNEL_STATUS" ]; then
                echo
                echo "********************************************************************************"
                echo "************ Tunnel 2 of VPN Connection $VPN_CONNECTION_ID is $CURRENT_TUNNEL2_STATUS ************"
                echo "********************************************************************************"
                echo
                break
            else
                echo "****** Waiting for Tunnel 2 of VPN Connection $VPN_CONNECTION_ID to become $EXPECTED_TUNNEL_STATUS. Current state: $CURRENT_TUNNEL2_STATUS ... ******"
                sleep $CHECK_INTERVAL
            fi
        else
            echo "****** Waiting for Tunnel 1 of VPN Connection $VPN_CONNECTION_ID to become $EXPECTED_TUNNEL_STATUS. Current state: $CURRENT_TUNNEL1_STATUS ... ******"
            sleep $CHECK_INTERVAL
        fi
    else
        echo "****** Waiting for VPN Connection $VPN_CONNECTION_ID to become $EXPECTED_STATE. Current state: $CURRENT_STATE ... ******"
        sleep $CHECK_INTERVAL
    fi
    if [ $CUR_ATTEMPT -ge $MAX_ATTEMPT ]; then
        break
    fi
done