# uklivetrains

A basic android app in flutter for viewing the live trains on a station on the UK rail network. **Note: The public version of this app is many hundreds of commits behind the private version. This repository may be updated at a later point in time**

New features that are _not_ included in this repository but have been coded and will be PRed in at a later date:
- Redesigned UI, all UI elements are now cohesive
- Trains can be fetched +- 24 hours vs +- 2 hours
- The home page is completely customisable, where you can track services one-off or daily, add departure boards, view tube status, list disruptions and more
- A photo of the train is matched to the live service, with facilities labelled.
- ... and many more
This is just a few of the features, the new version feels completely different.

A very old screenshot:

![](https://infinitydev.org.uk/demos/uklivetrainsapp1.png)

This project is paired with another [repository](https://github.com/infinitelyjames/LiveTrainsAPI_Public), which is an REST API wrapper for rail APIs. You'll need this as well to get this app working - make sure to copy your api key for the wrapper into `lib/modules/api.dart`.

For more information about the features, see the [projects section on my website](https://infinitydev.org.uk/)

## Forks

Note: I am currently working on major improvements in a private fork that will be PR-ed at a later date, to both this and the API wrapper.

## Licensing

As the API wrapper is designed to be modular with different APIs, the app itself will not have the specific attribution requirements of an API you may choose. You will need to modify the app to abide by licensing agreements of APIs that you choose to use. 


## Current Known Issues

- Train splitting is unintuitive UI in the direction of two trains joining
