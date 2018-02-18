# iot-stamp

ARM templates and scripts used to stand up a fully contains set of services within a resource group (i.e. a stamp).

- IOT Hub - linked to Event Hubs and Storage account for archiving raw events
- Routing to a group of Event Hubs that trigger Azure Functions
- Azure Functions Apps that publish events to Document DB
- ASA Job that connects to IOT Hub to query for specific events

The script that runs the templates in the correct order is [create-stamp.sh](iot-stamp/create-stamp.sh)
This project is a work in process and should not be used for production deployments.


