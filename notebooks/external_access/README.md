# External Access

This example show how to create a UDF and a Stored procedure in Python that have access to the public internet, this example uses Google's API for Translation, if you would like to follow this example you will need a Google Cloud account so the API is enable.

## Setup
Create a project in Google GCP
* Enable the translate API

In GCP under the API & Services create:
* Create Oauth concent screeen
* Under create a OAuth 2.0 Client IDs

Next step is to authenticate the credentials to create the refresh token, 
it is posible to use a client but the easy way is to use REST:
* https://developers.google.com/identity/protocols/oauth2/web-server#httprest
* https://www.youtube.com/watch?v=NIlK6gAwKEM&t=33s

Once you are done getting the refresh token, use the 01_setup.sql scrip in this directory and change the parameters ID, Secrete & Refresh token and run the script

Also I am adding code in order to create a Store Procedure using Snowpark
* Change first your credentials in the credentials.py file in the repository
