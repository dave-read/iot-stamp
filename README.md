# iot-stamp

ARM templates and scripts used to stand up a fully contained set of services within a resource group (i.e. a stamp).

- IOT Hub - linked to Event Hubs and Storage account for archiving raw events
- Routing to a group of Event Hubs that trigger Azure Functions
- Azure Functions Apps that publish events to Document DB
- ASA Job that connect to IOT Hub to query for specific events

The script that runs the templates in the correct order is [create-stamp.sh](iot-stamp/create-stamp.sh)
<<<<<<< HEAD
This project is a work in process and should not be used for production deployments.  Evetually these template can be combined when there's a more clear picture of the dependencies.
=======

This project is a work in process and should not be used for production deployments.
>>>>>>> 8608caf75890563866cce303931981b298146a45


