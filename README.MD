## Capapp an example application written in Python/Flask

Original source code from https://github.com/pallets/flask/tree/16d83d6bb413bec09a656a659b98d897e7abcc81/examples/minitwit

## Docker instructions

To create a docker image execute: 

`docker build . -t capapp`

To run the docker image execute:

`docker run -p 5000:5000 capapp` and visit with your browser http://localhost:5000

To run unit tests inside the container execute:

`docker run capapp python setup.py test`

## Original Readme

Capapp 

because writing todo lists is not fun


### What is Capapp?

A SQLite and Flask powered twitter clone

###  How do I use it?

1. edit the configuration in the capapp.py file or
   export an `CAPAPP_SETTINGS` environment variable
   pointing to a configuration file.
2. install the app from the root of the project directory
   `pip install --editable .`
3. tell flask about the right application:
   `export FLASK_APP=capapp`
4. fire up a shell and run this:
   `flask initdb`
5. now you can run capapp:
   `flask run`

 the application will greet you on
         http://localhost:5000/

### Is it tested?

You betcha.  Run the `python setup.py test` file to
      see the tests pass.
