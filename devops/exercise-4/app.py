from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/about', methods=['GET'])
def about():
    return jsonify({
        "name": "Simple REST API",
        "version": "1.0",
        "description": "This is a simple REST API built with Flask."
    })

if __name__ == '__main__':
    # host='0.0.0.0' ensures the Flask application is accessible from outside the container
    app.run(debug=True, host='0.0.0.0', port=5001)
