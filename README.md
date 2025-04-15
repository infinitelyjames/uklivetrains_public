# uklivetrains

A basic android app in flutter for viewing the live trains on a station on the UK rail network.

This project is paired with another [repository](https://github.com/infinitelyjames/LiveTrainsAPI_Public), which is an REST API wrapper for rail APIs. You'll need this as well to get this app working - make sure to copy your api key for the wrapper into `lib/modules/api.dart`.

For more information about the features, see the [projects section on my website](https://infinitydev.org.uk/)

## Licensing

As the API wrapper is designed to be modular with different APIs, the app itself will not have the specific attribution requirements of an API you may choose. You will need to modify the app to abide by licensing agreements of APIs that you choose to use. 


## Current Known Issues

- Train splitting is unintuitive UI in the direction of two trains joining
