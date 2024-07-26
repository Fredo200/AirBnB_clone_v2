#!/usr/bin/env python3
""" Flask web application with multiple view functions and default route values """

from flask import Flask

# Initialize the Flask application
app = Flask(__name__)
app.url_map.strict_slashes = False  # Disable strict slashes globally

@app.route('/')
def index():
    """ Display a welcome message """
    return 'Hello HBNB!'

@app.route('/hbnb')
def display_hbnb():
    """ Display another message """
    return 'HBNB'

@app.route('/c/<text>')
def display_c(text):
    """ Display 'C' followed by a text variable, with underscores replaced by spaces """
    formatted_text = text.replace('_', ' ')
    return f'C {formatted_text}'

@app.route('/python/', defaults={'text': 'is cool'})
@app.route('/python/<text>')
def display_python(text):
    """ Display 'Python' followed by a text variable, with a default value """
    formatted_text = text.replace('_', ' ')
    return f'Python {formatted_text}'

# Start the Flask development server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

