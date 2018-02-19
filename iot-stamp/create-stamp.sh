#!/usr/bin/env bash
# Copyright (c) Microsoft.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

IOT_HUB_STORAGE_OUTPUT_NAME=iotHubRaw
IOT_HUB_STORAGE_CONTAINER="iot-raw-events"
ASA_REF_STORAGE_OUTPUT_NAME=asaJobRef
ASA_REF_STORAGE_CONTAINER="asa-ref-data"

if [ ! $# -eq 2 ]; then
    echo "usage: $0 stamp region"
    exit 1
fi

echo "creating stamp: $1 in region:$2"

STAMP=$1
LOCATION=$2

RG=iot-stamp$STAMP
echo "creating resource group $RG"
az group create --location $LOCATION --name $RG
if [ $? -ne 0 ];then
  echo "error creating resource group"
  exit 1
fi

# create storage accounts
echo "creating storage accounts deployment"
storageAccounts=$(az group deployment create \
   --name storage-accounts \
   --resource-group $RG \
   --template-file storage-accounts.json \
   --parameters stampName="$STAMP")
echo "storage account deployment done"

IOT_HUB_STORAGE_ACCOUNT=$(echo $storageAccounts |  jq -r .properties.outputs.${IOT_HUB_STORAGE_OUTPUT_NAME}.value)
ASA_REF_STORAGE_ACCOUNT=$(echo $storageAccounts |  jq -r .properties.outputs.${ASA_REF_STORAGE_OUTPUT_NAME}.value)

# Container for storing raw IOT events
echo "creating container $IOT_HUB_STORAGE_CONTAINER in storage account:$IOT_HUB_STORAGE_ACCOUNT"
az storage container create --account-name $IOT_HUB_STORAGE_ACCOUNT --name $IOT_HUB_STORAGE_CONTAINER 

# ASA needs container for ref data
echo "creating conatiner $ASA_REF_STORAGE_CONTAINER in storage account:$ASA_REF_STORAGE_ACCOUNT"
az storage container create --account-name $ASA_REF_STORAGE_ACCOUNT --name $ASA_REF_STORAGE_CONTAINER 

# Create Event Hubs with consumer groups for Functions
echo "creating Event Hubs deployment"
eventHubs=$(az group deployment create \
   --name event-hubs \
   --resource-group $RG \
   --template-file event-hubs.json \
   --parameters @event-hubs.parameters.json)
echo "event hubs deployment done"
EVENT_HUB_NS=$(echo $eventHubs |  jq -r .properties.outputs.eventHubNamespaceName.value)
echo "event hubs namspace:$EVENT_HUB_NS"

# Create IOT Hubs with routes to stroage and event hubs
echo "creating IOT Hubs deployment"
iotHub=$(az group deployment create \
   --name iot-hub \
   --resource-group $RG \
   --template-file iot-hub.json \
   --parameters @iot-hub.parameters.json \
   --parameters eventHubNamespaceName=$EVENT_HUB_NS \
   --parameters rawEventsStorageAccount=$IOT_HUB_STORAGE_ACCOUNT \
   --parameters rawEventsContainerName=$IOT_HUB_STORAGE_CONTAINER)
echo "event hubs deployment done:$iotHub"

# Create CosmosDB instance
echo "creating CosmosDB deployment"
db=$(az group deployment create \
   --name cosmos-db \
   --resource-group $RG \
   --template-file document-db.json )
 echo "document db deployment done:$db"

# Functions
echo "creating functions deployment"
functionApp=$(az group deployment create \
   --name functions \
   --resource-group $RG \
   --template-file function-app.json )
 echo "function app deployment done:$functionApp"





