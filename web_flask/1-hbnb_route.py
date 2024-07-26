#!/usr/bin/env python3
""" Flask web application with two routes """

from flask import Flask

# Create a Flask app instance
app = Flask(__name__)

@app.route('/', strict_slashes=False)
def index():
    """ Respond with a welcome message """
    return 'Hello HBNB!'

@app.route('/hbnb', strict_slashes=False)
def hbnb():
    """ Respond with a different message """
    return 'HBNB'

# Run the Flask app on host 0.0.0.0 and port 5000
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

