#!/usr/bin/env python3
""" A basic Flask web application """

from flask import Flask

# Initialize the Flask application
app = Flask(__name__)

@app.route('/', strict_slashes=False)
def greet():
    """ Display a welcome message """
    return 'Hello HBNB!'

# Start the Flask development server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
